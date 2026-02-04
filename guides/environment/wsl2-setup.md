# WSL2 Environment Setup

Windows Subsystem for Linux 2 (WSL2) configuration, optimization, and best practices for development.

---

## What is WSL2?

**WSL2** is Windows Subsystem for Linux 2—a lightweight Linux environment running on Windows 10/11 that allows you to run Linux tools, shells, and develop in a native Linux environment while staying on Windows.

**Key Benefits**:
- ✅ Native Linux filesystem and tools
- ✅ Full Docker support
- ✅ Seamless Windows/Linux interoperability
- ✅ Near-native Linux performance

---

## Installation & Setup

### Prerequisites

- Windows 10 (build 19041+) or Windows 11
- Virtualization enabled in BIOS
- Admin access

### Install WSL2

```bash
# PowerShell (run as Administrator)
wsl --install -d Ubuntu

# This installs:
# - WSL2 kernel
# - Ubuntu 24.04 LTS distro
# - Linux kernel updates
```

### First Boot

After installation:

```bash
# Windows Terminal or command prompt
ubuntu

# You'll be prompted to create a username/password
# This is your WSL2 Linux user (separate from Windows user)
```

### Update System

```bash
# Inside WSL2 Ubuntu
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y build-essential git curl wget
```

---

## WSL2 Configuration

### Allocate Resources

WSL2 auto-allocates resources but can consume too much. Limit if needed:

**File**: `%USERPROFILE%\.wslconfig`

```ini
[wsl2]
# Limit memory to 4GB (default: 50% of total)
memory=4GB

# Limit processors (default: total cores)
processors=4

# Swap size
swap=2GB

# Enable systemd support (Ubuntu 22.04+)
systemd=true

# Enable nested virtualization (for Docker-in-Docker)
nestedVirtualization=true
```

**Apply changes**:
```bash
# PowerShell (Windows, not WSL)
wsl --shutdown
# This terminates all WSL2 instances and reloads config
```

### Enable Systemd

Modern Ubuntu includes systemd support (required for many services):

```bash
# Inside WSL2 Ubuntu
sudo systemctl status  # Should work without errors
```

---

## File System & Performance

### WSL vs Windows Filesystem

**Performance Comparison**:

| Operation | WSL Filesystem | Windows Filesystem (/mnt/c) |
|-----------|---|---|
| **Read/Write speed** | ✅ Native Linux (~1000 MB/s) | ⚠️ Slower (~200 MB/s) |
| **File permissions** | ✅ Full support | ⚠️ Limited |
| **Symlinks** | ✅ Supported | ❌ Not supported |
| **Large files** | ✅ Optimized | ⚠️ Slower |

**Best Practice**: Keep development files in WSL filesystem (`~/projects`), not Windows drive.

### File Interoperability

**Access WSL files from Windows**:
```
\\wsl$\Ubuntu\home\username\projects
```

In File Explorer: `\\wsl$\Ubuntu\home\username`

**Access Windows files from WSL**:
```bash
cd /mnt/c/Users/YourName/Documents
```

### Optimize for Development

```bash
# .wslconfig for development workflow
[wsl2]
memory=6GB           # More RAM for builds
processors=6        # More cores for parallel builds
swap=4GB
systemd=true        # Enable systemd for services
nestedVirtualization=true
```

---

## Package Management

### APT (Ubuntu default)

```bash
# Update package list
sudo apt update

# Install packages
sudo apt install -y git curl node.js

# Upgrade all packages
sudo apt upgrade -y

# Clean up
sudo apt autoremove
```

### Snap (Alternative)

```bash
# Works in WSL2 (with systemd enabled)
sudo snap install node --classic
```

### Conda/Python

```bash
# Install miniconda
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
conda --version
```

---

## SSH in WSL2

### SSH Key Setup

Store SSH keys in WSL2 (not Windows):

```bash
# Generate new key (if needed)
ssh-keygen -t ed25519 -f ~/.ssh/eshields-aws-us-west-2.pem

# Set permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/eshields-aws-us-west-2.pem
```

### SSH Config Location

```bash
~/.ssh/config           # WSL2 SSH config
~/.ssh/config.d/        # Modular configs
~/.ssh/known_hosts      # Known hosts
```

**Note**: Separate from Windows SSH config (if using PuTTY or other Windows SSH tool).

### SSH Agent

```bash
# Add to ~/.bashrc to start SSH agent on shell startup
eval "$(ssh-agent -s)" > /dev/null
ssh-add ~/.ssh/eshields-aws-us-west-2.pem 2>/dev/null
```

---

## Development Tools

### Node.js / NPM

```bash
# Via apt
sudo apt install -y nodejs npm

# Via nvm (better for version management)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
```

### Python / Pip

```bash
# Install Python
sudo apt install -y python3 python3-pip python3-venv

# Create virtual environment
python3 -m venv ~/venv
source ~/venv/bin/activate
```

### Docker in WSL2

```bash
# Install Docker
sudo apt install -y docker.io

# Run Docker without sudo (optional)
sudo usermod -aG docker $USER
newgrp docker

# Test
docker run hello-world
```

### Git

```bash
# Install
sudo apt install -y git

# Configure
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global core.sshCommand "ssh -i ~/.ssh/eshields-aws-us-west-2.pem"
```

---

## npm Cache Management

### The Problem: Unbounded Cache Growth

npm cache can grow to hundreds of GB due to:
- **No size limit**: npm removed `cache-max` option (deprecated in npm 8+)
- **Never auto-cleans**: Cache only grows, never shrinks automatically
- **Corrupted files**: Failed downloads create garbage that forces re-downloads
- **Real-world impact**: Cache can balloon from 0 to 391GB in 24 hours if corrupted

### Symptoms of Corrupted Cache

- Disk fills rapidly despite clearing cache yesterday
- npm install takes unusually long
- Same packages downloaded repeatedly
- npm process hangs or consumes high CPU/memory

### Diagnosis & Repair

```bash
# Check cache size
du -sh ~/.npm

# Verify cache integrity (repairs corruption, compresses data)
npm cache verify

# If verify fails or cache is too large
npm cache clean --force
```

**What `npm cache verify` does**:
- Validates all cached package checksums
- Removes corrupted/garbage files
- Compresses cache data
- Can free 50-90% of cache size if corrupted

### Prevention: Weekly Maintenance

Add to crontab:

```bash
crontab -e

# Add this line (runs every Sunday at 2 AM):
0 2 * * 0 npm cache verify > /tmp/npm-cache-verify.log 2>&1
```

Or create a maintenance script:

```bash
# ~/.local/bin/npm-cache-maintenance
#!/bin/bash
echo "$(date): Running npm cache verify..." >> /var/log/npm-cache.log
npm cache verify >> /var/log/npm-cache.log 2>&1
echo "Disk usage after cleanup:" >> /var/log/npm-cache.log
df -h /home >> /var/log/npm-cache.log
```

Then cron:
```bash
0 2 * * 0 /home/ubuntu/.local/bin/npm-cache-maintenance
```

### Alternative: Use pnpm

For projects where possible, switch to `pnpm`:

```bash
npm install -g pnpm
cd /project
pnpm install  # instead of npm install
```

**Benefits**:
- Uses 50-70% less disk space (content-addressable cache)
- Stores each package version once, links to projects
- Much faster installs on second run
- Automatic cleanup

### Monitoring

Monitor cache size periodically:

```bash
# Check if cache is growing too fast
du -sh ~/.npm
df -h

# Add to weekly checks or alerts
```

---

## Integration with Claude Code

### Setting Default Shell

Configure Claude Code to use bash instead of PowerShell:

**File**: `~/.claude/settings.local.json`

```json
{
  "shell": "bash",
  "shellArgs": ["-c"]
}
```

### WSL Directory Access

Claude Code can directly access WSL files:

```bash
# From Windows CLI
claude code --repo //wsl$/Ubuntu/home/username/projects/my-repo

# Or just navigate there in Windows Terminal
cd \\wsl$\Ubuntu\home\username\projects\my-repo
```

---

## Troubleshooting

### WSL2 Keeps Crashing

```bash
# Check status
wsl -l -v

# Repair
wsl --unregister Ubuntu
wsl --install -d Ubuntu
```

### Disk Space Issues

```bash
# Check usage in WSL
df -h

# Compact WSL2 virtual disk (Windows PowerShell)
Optimize-VHD -Path "$env:LOCALAPPDATA\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\LocalState\ext4.vhdx" -Mode Full
```

### Slow Performance on /mnt/c

This is expected. Solution: **Keep projects in WSL filesystem** (`~/projects`), not Windows drive.

### SSH Key Permissions

```bash
# Fix if you get "Permissions too open" error
chmod 600 ~/.ssh/id_ed25519
chmod 700 ~/.ssh
```

### DNS Issues

```bash
# If DNS resolution fails
sudo resolvectl status
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
```

---

## Performance Optimization Checklist

- [ ] Allocate adequate memory/CPU in `.wslconfig`
- [ ] Enable systemd (for services)
- [ ] Keep development files in WSL filesystem, not `/mnt/c/`
- [ ] Use WSL2 (not WSL1) for performance
- [ ] Keep Ubuntu updated: `sudo apt update && sudo apt upgrade`
- [ ] Clean up unused packages: `sudo apt autoremove`
- [ ] Monitor disk usage: `df -h`

---

## Related Documentation

- [Terminal & Shell Setup](./terminal-setup.md) - Windows Terminal configuration
- [SSH Configuration](./ssh-configuration.md) - SSH in WSL2 context
- [guides/scripting/](../scripting/) - Bash scripting in WSL2
- [configs/tools.md](../../configs/tools.md) - Tool installation
