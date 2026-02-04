# SSH Configuration & Remote Access

Best practices for SSH configuration, AWS access patterns, and troubleshooting remote connection issues.

---

## Quick Decision: Direct SSH vs AWS SSM

| Scenario | Use Direct SSH | Use AWS SSM |
|----------|----------------|------------|
| **Public IP available** | ✅ Yes | ⚠️ Less common |
| **Private instance** | ❌ Not possible | ✅ Use this |
| **Need audit logs** | ❌ No centralized logging | ✅ CloudTrail logs all sessions |
| **Team access control** | ❌ Key-based only | ✅ IAM-based (better for teams) |
| **Setup complexity** | ✅ Simple (IP + key) | ⚠️ Complex (agent + IAM + document) |
| **Reliability** | ✅ No dependencies | ⚠️ Agent can be buggy |
| **Performance** | ✅ Direct, fast | ⚠️ Tunneled through AWS API |
| **Single developer** | ✅ Recommended | ⚠️ Overkill |

**Summary**: Direct SSH is simpler and more reliable for personal dev instances. Use SSM for team access, private networks, or audit requirements.

---

## Direct SSH Configuration

### SSH Config Format

```
Host dev-cloud
    HostName ec2-52-25-59-233.us-west-2.compute.amazonaws.com
    User ubuntu
    IdentityFile ~/.ssh/eshields-aws-us-west-2.pem
    ServerAliveInterval 10
    ServerAliveCountMax 3
    StrictHostKeyChecking accept-new
    IPQoS lowdelay throughput
```

**Key Settings**:
- `ServerAliveInterval 10`: Send keepalive every 10 seconds (detect dead sessions faster)
- `ServerAliveCountMax 3`: Close after 3 missed keepalives (30 seconds total)
- `StrictHostKeyChecking accept-new`: Auto-add new hosts to known_hosts without prompting
- `IPQoS lowdelay throughput`: Optimize for interactive use over high-bandwidth connections

### SSH Key Management

**Best Practices**:
- Keep keys in `~/.ssh/` with restrictive permissions (`600`)
- Use different keys for different purposes (work, personal, etc.)
- Rotate keys periodically
- Never commit keys to version control
- Consider key passphrases for added security

**Key Permission Fix** (if needed):
```bash
chmod 600 ~/.ssh/your-key.pem
chmod 700 ~/.ssh/
```

### Security: IP Whitelisting

If your server has public IP, restrict access to your IP:

```bash
# AWS Security Group rule example:
# Inbound: SSH (port 22) from YOUR_IP/32

# Verify your public IP:
curl https://icanhazip.com
```

---

## AWS SSM Session Manager (Advanced)

Use only if you need:
- Audit trails (CloudTrail logging)
- Team access control (IAM-based)
- Private instances (no public IP)
- Compliance requirements

### SSH over SSM: ProxyCommand

```
Host ssm-instance
    HostName i-0123456789abcdef0
    User ubuntu
    IdentityFile ~/.ssh/your-key.pem
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p"
    ServerAliveInterval 10
    ServerAliveCountMax 3
```

### Common SSM Issues

| Error | Cause | Fix |
|-------|-------|-----|
| `Plugin with name Port not found` | SSM agent outdated | `sudo snap refresh amazon-ssm-agent` |
| `Plugin with name Standard_Stream not found` | Agent/document mismatch | Restart instance or update agent |
| Session fails immediately | Agent not running | Check agent: `systemctl status amazon-ssm-agent` |
| Connection closes after ~15 min | Session timeout | Increase keepalive: `ServerAliveInterval 5` |

### Update SSM Agent

```bash
# While connected via SSH or direct EC2 console:
sudo snap refresh amazon-ssm-agent
# OR
sudo apt update && sudo apt install -y amazon-ssm-agent
sudo systemctl restart amazon-ssm-agent
sudo systemctl status amazon-ssm-agent
```

---

## Troubleshooting

### SSH Connection Drops Frequently

**Symptoms**: Connection closes with "Connection reset by peer" or "Connection closed by UNKNOWN port"

**Diagnosis Checklist**:
1. Check instance health: `aws ec2 describe-instance-status --instance-ids <id>`
2. Check CloudWatch metrics (CPU, memory, disk)
3. Review instance system logs
4. Test with `ssh -v` (verbose mode) for detailed handshake info

**Common Causes**:
- Instance running out of disk space
- Out of memory causing processes to crash
- SSM agent crashes (if using SSM method)
- Security group rules changed
- Network timeouts (increase ServerAliveInterval)

**Fix**:
```bash
# Check disk space
df -h

# Check memory
free -h

# Increase keepalive if frequent timeouts
ssh -o ServerAliveInterval=5 username@host
```

### "UNKNOWN port 65535" Error (SSM-specific)

This error occurs when SSM Session Manager tries to allocate a port for SSH tunneling but fails.

**Causes**:
- SSM agent is outdated or broken
- Agent can't communicate with AWS API
- Instance lost network connectivity mid-session

**Fix**:
1. Update SSM agent (see above)
2. Stop and restart instance (forces agent update)
3. Check instance in AWS console for system status checks

### Agent Version Chicken-and-Egg Problem

**Scenario**: SSM agent is broken, but you need SSM to fix it.

**Solution**: Use AWS Systems Manager Run Command with a fresh session:

```bash
aws ssm send-command \
  --instance-ids i-0123456789abcdef0 \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["sudo snap refresh amazon-ssm-agent","sudo systemctl restart amazon-ssm-agent"]' \
  --region us-west-2
```

If that fails, fall back to direct SSH (if public IP) or EC2 Instance Connect.

### Keepalive & Connection Reuse

SSH can hang if:
1. Network goes down (firewall drops connection)
2. NAT session times out
3. Server restarts

**Prevent hangs**:
```
# In ~/.ssh/config or per-command:
ServerAliveInterval 10        # Send keepalive every 10 seconds
ServerAliveCountMax 3         # Close after 3 missed keepalives
TCPKeepAlive yes              # Enable TCP-level keepalive
ConnectTimeout 30             # Timeout on initial connection
```

---

## SSH Config Organization

For multiple hosts, organize configs in modular files:

```
~/.ssh/config
├── Include ~/.ssh/config.d/*

~/.ssh/config.d/
├── work-grafana        (your prod/dev instances)
├── personal            (personal servers)
└── ci-systems          (CI/CD runners)
```

**Main config** (`~/.ssh/config`):
```
Host *
    AddKeysToAgent yes
    IgnoreUnknown UseKeychain
    UseKeychain yes

Include ~/.ssh/config.d/*
```

**Benefits**:
- Modular, easy to manage
- Can version control individual files
- No merge conflicts when updating

---

## Connection Recovery Script

For unreliable connections, wrap SSH with auto-retry logic:

```bash
#!/bin/bash
# ~/.local/bin/ssh-safe

MAX_RETRIES=3
RETRY_DELAY=2
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    ssh "$@" && exit 0
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
        echo "Connection failed. Retrying in ${RETRY_DELAY}s..."
        sleep $RETRY_DELAY
    fi
done

echo "Failed after $MAX_RETRIES attempts" >&2
exit 1
```

Usage:
```bash
ssh-safe user@host
ssh-safe your-config-alias
```

---

## Related Documentation

- [Terminal & Shell Setup](./terminal-setup.md) - Terminal emulator configuration
- [WSL2 Environment Setup](./wsl2-setup.md) - WSL2-specific SSH considerations
- [workflows/script-patterns.md](../../workflows/script-patterns.md) - Shell scripting with SSH
- [configs/tools.md](../../configs/tools.md) - Tool installation (gh, aws-cli, etc.)
- [guides/scripting/](../scripting/) - Bash automation patterns
