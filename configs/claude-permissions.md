# Claude Code Permissions Configuration

Comprehensive permissions configuration for Claude Code that allows non-destructive operations automatically while requiring approval for writes and denying exceptionally dangerous commands.

---

## Overview

This configuration file (`claude-permissions.json`) implements a three-tier permission system:

1. **Allow**: Non-destructive commands that can run automatically
2. **Ask**: Moderate-risk operations requiring explicit approval **each time**
3. **Deny**: Exceptionally dangerous commands that should never run

**Philosophy**: Maximize productivity by allowing safe read operations and common development tasks, while requiring explicit approval for write operations (to prevent unintended modifications), and blocking exceptionally dangerous commands.

---

## Permission Tiers

### Allow (Automatic)

Commands in the "allow" list run without prompting:

**Read Operations** (100% safe):
- File reading: `Read`, `Glob`, `Grep`
- Git read-only: `git status`, `git diff`, `git log`, `git show`, etc.
- Filesystem: `ls`, `find`, `cat`, `grep`, `wc`, `du`, etc.
- Package info: `npm list`, `npm outdated`
- GitHub CLI: `gh pr view`, `gh issue list`, etc.

**Build & Test** (safe, reversible):
- Build: `npm run build`, `yarn build`, `pnpm build`
- Test: `npm test`, `npm run test:*`
- Lint: `npm run lint`, `eslint`, `prettier`
- Type check: `tsc --noEmit`

**Safe Git Operations** (non-destructive):
- Stage: `git add`
- Pull/Fetch: `git pull`, `git fetch`
- Stash: `git stash`
- Branch: `git checkout -b`, `git switch -c`

**Tool Commands**:
- Version checks: `--version` flags
- Documentation: `--help` flags
- Validation scripts: `./validate-*.sh`

### Ask (Explicit Approval Required Each Time)

Commands in the "ask" list **always** require approval, even if approved before. These are moderate-risk operations that can modify files, git history, or dependencies.

**Important**: The hooks system ensures you are prompted for **each invocation**, preventing unintended batch operations.

**Git Write Operations**:
- `git commit` - Creates commits (to prevent log pollution)
- `git push` - Pushes to remote (requires approval each time)
- `git merge` - Merges branches (can cause conflicts)
- `git rebase` - Rewrites history (requires care)
- `git cherry-pick` - Applies commits (selective)

**File Operations**:
- `Write` - Creating/overwriting files
- `Edit` - Modifying existing files
- `mv`, `cp`, `rsync` - Moving/copying files
- `rm` - Single file deletion (not recursive)
- `git clean` - Removes untracked files

**Package Management**:
- `npm install`, `npm uninstall`, `npm ci`, `npm update`
- `yarn add`, `yarn remove`, `yarn install`

**GitHub Actions**:
- `gh pr create`, `gh pr merge`, `gh pr close`
- `gh issue create`, `gh issue close`
- `gh release create`

**Rclone Write Operations**:
- `rclone copy`, `rclone copyto`, `rclone move`
- `rclone sync`, `rclone delete`

### Deny (Forbidden)

Commands in the "deny" list will never run:

**Destructive Git**:
- `git push --force` - Rewrites history
- `git reset --hard` - Loses uncommitted changes
- `git clean -fd` - Deletes untracked files
- `git branch -D` - Force delete branches

**File Deletion**:
- `rm -rf` - Recursive force deletion
- `rmdir` - Directory deletion
- `shred` - Secure deletion

**System Commands**:
- `sudo`, `su` - Elevated privileges
- `shutdown`, `reboot` - System control
- `chmod +x` - Permission changes
- `kill -9`, `killall` - Process termination

**Secret Exposure**:
- Reading `.env` files
- Reading `secrets/` directories
- Reading SSH keys, AWS credentials
- Committing secrets to git

**Production Operations**:
- `npm publish` - Publishing packages
- `terraform destroy` - Infrastructure deletion
- `kubectl delete` - Kubernetes deletions
- Production deployments

**Database Operations**:
- `DROP TABLE`, `DROP DATABASE`
- `DELETE FROM` without WHERE
- `TRUNCATE`

**Network Attacks**:
- `nmap` - Port scanning
- `tcpdump` - Packet capture
- Netcat with execution flags

---

## Hooks System

The permissions configuration includes a **hooks** system that enforces re-prompting for "ask" commands:

```json
"hooks": {
  "PermissionRequest": [
    {
      "matcher": "ask",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "Moderate risk operation. Requires explicit approval for each invocation to prevent unintended modifications."
        }
      ]
    }
  ]
}
```

**How it works**:
1. When a command matches the "ask" list, the hook triggers
2. User sees the custom prompt explaining why approval is needed
3. Approval is required **for each invocation** (not cached)
4. This prevents unintended batch operations or accidental repeated executions

**Example**:
- First `git commit`: Prompts with "Moderate risk operation..."
- Second `git commit`: Prompts again (not cached)
- This ensures you consciously approve each commit, preventing log pollution

**Benefits**:
- **Prevents habit-based approvals**: Each prompt requires conscious decision
- **Batch protection**: Can't accidentally approve multiple destructive operations
- **Clear context**: Prompt explains why approval is needed
- **Flexible**: Can customize prompt message per command category if needed

---

## Installation

### Option 1: Global Settings (Recommended)

Apply to all Claude Code sessions:

```bash
# Backup existing settings
cp ~/.claude/settings.local.json ~/.claude/settings.local.json.backup

# Copy permissions file
cp current/configs/claude-permissions.json ~/.claude/settings.local.json

# Verify
cat ~/.claude/settings.local.json | jq '.permissions.allow | length'
```

### Option 2: Project-Specific Settings

Apply to specific project only:

```bash
# In project root
mkdir -p .claude
cp /path/to/claude-permissions.json .claude/settings.json
```

### Option 3: Merge with Existing Settings

If you have existing settings to preserve:

```bash
# Merge permissions into existing settings
jq -s '.[0] * .[1]' \
  ~/.claude/settings.local.json \
  current/configs/claude-permissions.json \
  > ~/.claude/settings.local.json.tmp

mv ~/.claude/settings.local.json.tmp ~/.claude/settings.local.json
```

---

## Customization

### Adding Permissions

To allow additional commands:

```json
{
  "permissions": {
    "allow": [
      // Add your custom commands
      "Bash(your-custom-command:*)",
      "Bash(another-command:*)"
    ]
  }
}
```

### Project-Specific Allowances

For project-specific needs, create `.claude/settings.json` in project root:

```json
{
  "permissions": {
    "allow": [
      "// Project-specific permissions",
      "Bash(make:*)",
      "Bash(./scripts/*.sh:*)",
      "Read(config/production.yml)"
    ]
  }
}
```

**Note**: Project settings merge with global settings.

### Removing Unsafe Defaults

If you find allowed commands too permissive:

```json
{
  "permissions": {
    "deny": [
      "// Override allows with denies",
      "Bash(git push:*)",
      "Bash(npm run build:*)"
    ]
  }
}
```

**Note**: Deny takes precedence over allow.

---

## Permission Patterns

### Glob Patterns

Use wildcards for flexible matching:

```json
"Bash(git diff:*)"     // Matches: git diff, git diff HEAD, git diff main...feature
"Read(**/*.ts)"        // Matches: any .ts file in any directory
"Bash(npm run test:*)" // Matches: npm run test, npm run test:unit, etc.
```

### Exact Matches

For precise control:

```json
"Bash(git push)"       // Only matches: git push (no arguments)
"Read(package.json)"   // Only matches: package.json (exact path)
```

### Negation (via deny)

Block specific patterns:

```json
{
  "allow": ["Bash(npm:*)"],    // Allow all npm commands
  "deny": ["Bash(npm publish:*)"] // Except publishing
}
```

### Path Patterns (File Operations)

Claude Code supports multiple path pattern types for scoping file operations like `Read`, `Edit`, and `Write`:

| Pattern Type | Meaning | Example | Matches |
|---|---|---|---|
| `~/path` | Path from **home directory** | `Read(~/.zshrc)` | `/home/user/.zshrc` |
| `//path` | **Absolute** path from filesystem root | `Write(//tmp/scratch.txt)` | `/tmp/scratch.txt` |
| `/path` | Path **relative to settings file location** | `Edit(/src/**/*.ts)` | `./src/**/*.ts` from settings file |
| `path` or `./path` | Path **relative to current working directory** | `Read(*.env)` | Files in current directory |

**Important**: A single slash path like `/Users/alice/file` is NOT absolute—it's relative to your settings file location. Use double slashes `//Users/alice/file` for true absolute paths.

**CRITICAL: Working Directory Context**

Claude Code uses **different working directories** for different operations:

1. **Normal Execution** (tools, commands, file operations):
   - **PWD = Project Root** (e.g., `~/.ai`)
   - `Read(.specs/constitution.md)` resolves from project root
   - `pwd` returns project directory
   - Relative paths in commands resolve from project root

2. **Permission Pattern Matching** (evaluating settings.local.json):
   - **PWD = Settings File Location** (e.g., `~/.claude/` or `~/.ai/.claude/`)
   - Pattern `Write(/**/*)` in `~/.claude/settings.local.json` matches `~/.claude/**/*`
   - Pattern `Write(/**/*)` in `~/.ai/.claude/settings.local.json` matches `~/.ai/**/*`
   - Leading `/` means "relative to settings file directory"

**Example**:
- Your project is at `~/.ai` with settings at `~/.ai/.claude/settings.local.json`
- Permission pattern: `Write(/**/*.md)` → matches `~/.ai/**/*.md` (from settings location)
- File operation: `Write(docs/file.md)` → writes to `~/.ai/docs/file.md` (from project root)

**Wildcard Support** (gitignore specification):
- `*` matches files in a **single directory** only
- `**` matches **recursively across directories**

**Examples**:

```json
{
  "permissions": {
    "allow": [
      "// Home directory paths (portable across machines)",
      "Read(~/.zshrc)",
      "Read(~/.ai-context-store/**/*)",
      "Write(~/.config/myapp/**/*)",

      "// Absolute paths (use double slash)",
      "Write(//tmp/**/*)",
      "Edit(//var/log/myapp.log)",

      "// Project-relative paths (relative to settings file)",
      "Read(/docs/**)",
      "Edit(/src/**/*.ts)",

      "// CWD-relative paths",
      "Read(*.env)",
      "Write(./output/**)"
    ],
    "deny": [
      "Read(~/.aws/**)",
      "Read(~/.ssh/id_*)",
      "Read(./.env)",
      "Edit(//etc/passwd)"
    ]
  }
}
```

**Use Cases**:
- **Tilde expansion** (`~`): Best for home directory paths that should work across different machines/users
- **Absolute paths** (`//`): For system paths like `/tmp` or `/var`
- **Relative paths** (`/`): For project-specific paths when settings are in project root
- **CWD-relative** (`./`): For current working directory operations

**Note**: Variable substitution like `${safeDirectories}` is **not supported**. For shared permissions, use the settings precedence hierarchy (managed → local → project → user) or reference `claude-directory-permissions.json` for safe directory lists.

---

## Security Considerations

### What This Protects Against

✓ **Accidental Deletions**: `rm -rf`, `git clean -fd`
✓ **Secret Leaks**: Reading/committing `.env` files
✓ **Production Incidents**: Deployments, database drops
✓ **History Rewrites**: Force pushes, hard resets
✓ **Privilege Escalation**: `sudo`, system commands

### What This Doesn't Protect Against

✗ **Intentional Actions**: User can manually run any command
✗ **Bug-Free Code**: Doesn't validate correctness
✗ **All Security**: Defense-in-depth still required
✗ **Network Security**: No firewall/encryption

### Best Practices

1. **Review Regularly**: Audit permissions quarterly
2. **Principle of Least Privilege**: Start restrictive, relax as needed
3. **Project-Specific**: Override defaults for special cases
4. **Version Control**: Commit project `.claude/settings.json`
5. **Test Changes**: Verify permissions in safe environment first
6. **Document Exceptions**: Comment why custom permissions needed

---

## Troubleshooting

### Command Blocked Unexpectedly

**Symptom**: Allowed command asks for approval

**Solutions**:
1. Check pattern match: `Bash(git diff:*)` vs `Bash(git diff)`
2. Verify settings loaded: `cat ~/.claude/settings.local.json`
3. Check deny overrides: Deny takes precedence over allow
4. Restart Claude Code: Settings cache may be stale

### Secret File Exposed

**Symptom**: `.env` file readable despite deny rules

**Reason**: Deny rules block Bash reads, but not Read tool by default

**Fix**: Add explicit Read denies:
```json
"deny": [
  "Read(.env)",
  "Read(**/.env)",
  "Bash(cat .env:*)"
]
```

### Too Many Prompts

**Symptom**: Every command asks for approval

**Reason**: Allow patterns too specific

**Fix**: Use broader patterns:
```json
// Before (too specific)
"Bash(npm run build)"

// After (broader)
"Bash(npm run build:*)"
```

### Permission Denied Error

**Symptom**: Claude refuses to run allowed command

**Reason**: System-level permissions, not Claude permissions

**Fix**: Check file permissions, user access
```bash
ls -la filename
chmod +x script.sh
```

---

## Configuration Examples

**Frontend Development**:
- Allow: `npm run dev/build/test`, `npx eslint/prettier`, git operations, read source files
- Deny: `npm publish`, reading `.env` files

**DevOps (Safe Operations)**:
- Allow: `kubectl get/describe/logs`, `docker ps/logs`, `terraform plan`, cloud read operations
- Deny: Delete operations (`kubectl delete`, `docker rm`, `terraform destroy`)

**Data Science**:
- Allow: `python`, `jupyter`, `pip list`, read data files (`.py`, `.ipynb`, `.csv`)
- Deny: Delete data/models, read credentials

---

## Related Documentation

- [claude-allowed-prompts.md](claude-allowed-prompts.md) - Semantic, intent-based permissions for plan mode execution
- [quality-gates.md](quality-gates.md) - Validation gate patterns and permission system structure
- [mcp-integration-patterns.md](mcp-integration-patterns.md) - MCP tool permissions
- [development-practices.md](../rules/development-practices.md) - Destructive command safety practices
- [tools.md](tools.md) - Claude Code configuration overview

**Permission Systems Overview**:
- **Static Permissions** (this file): Persistent, explicit command patterns for all sessions
- **Allowed Prompts**: Temporary, semantic permissions requested during plan mode - see [claude-allowed-prompts.md](claude-allowed-prompts.md)
- **MCP Permissions**: External tool/service permissions - see [mcp-integration-patterns.md](mcp-integration-patterns.md)

---

## Maintenance

### Quarterly Review Checklist

- [ ] Review allow list: Any commands no longer needed?
- [ ] Review deny list: Any new dangerous patterns to add?
- [ ] Check project overrides: Still needed?
- [ ] Test with new Claude Code version
- [ ] Update documentation if patterns changed

### When to Update

**Add to Allow**:
- New tool adopted (e.g., pnpm, bun)
- Safe command frequently prompted
- Development workflow slowed by prompts

**Add to Deny**:
- New dangerous command discovered
- Security incident occurred
- Compliance requirement added

**Remove from Allow**:
- Command rarely used
- Security concern identified
- Project no longer needs it

