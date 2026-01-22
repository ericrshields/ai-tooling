# Quick Command Reference

Common one-liner commands and workflows for AI-assisted development.

## Tool Version Checks

Check installed versions of development tools:

```bash
claude --version
rclone version
pandoc --version
gh --version
jq --version
```

## Tool Updates

Update tools to latest versions:

```bash
# rclone - re-run install script
curl https://rclone.org/install.sh | sudo bash

# System package manager tools (Debian/Ubuntu)
sudo apt update && sudo apt upgrade pandoc jq gh

# macOS with Homebrew
brew upgrade pandoc jq gh

# Claude Code - auto-updates or manual reinstall from claude.ai/code
```

## rclone Commands

### List and Search
```bash
rclone ls gdrive:                              # List all files
rclone lsd gdrive:                             # List folders only
rclone lsl gdrive:                             # List with details
rclone lsf gdrive: --recursive | grep "term"  # Search recursively
rclone lsjson gdrive: | grep "pattern"         # JSON output for parsing
```

### Download Files
```bash
rclone copyto "gdrive:filename.docx" /tmp/file.docx
rclone copy gdrive:folder/ ./local-folder/
rclone copyto gdrive:<file-id> /tmp/file.docx  # Download by file ID
```

### Upload Files
```bash
rclone copyto /tmp/file.docx "gdrive:filename.docx"
rclone copy ./local-folder/ gdrive:folder/
```

### Configuration
```bash
rclone config                                  # Interactive setup/modification
rclone config show                             # Display current configuration
```

## pandoc Commands

### Format Conversion
```bash
pandoc input.docx -o output.md                 # docx to markdown
pandoc input.md -o output.docx                 # markdown to docx
pandoc input.docx -o output.html               # docx to HTML
pandoc input.docx -o output.pdf                # docx to PDF (requires LaTeX)
```

### With Options
```bash
pandoc input.docx -o output.md --wrap=none     # Don't wrap long lines
pandoc input.md -o output.docx --standalone    # Standalone document
pandoc --version                                # Check version and features
```

## GitHub CLI Commands

```bash
gh pr create                                    # Create pull request
gh pr status                                    # View PR status
gh pr list                                      # List pull requests
gh pr view [number]                             # View PR details
gh pr review [number]                           # Review a PR
gh issue list                                   # List issues
gh issue create                                 # Create new issue
gh repo view                                    # View repository details
```

## Git Backup Commands

Safe backup before destructive operations:

```bash
# Backup before potentially destructive operations
cp -r directory directory.backup
cp important-file.txt important-file.txt.backup

# Backup with timestamp
cp file.txt file.txt.$(date +%Y%m%d_%H%M%S).backup

# Git stash as backup
git stash push -m "backup before risky operation"
```

## Project-Specific Command Examples

These commands are examples from specific projects and may not exist in all environments. Adapt as needed:

```bash
# Example: Workflow commands (if configured)
/start-workflow TICKET-123                     # Start work on ticket
/review-changes                                # Run code review
/gh-pull-request                               # Create pull request
/smoke-test                                    # Run smoke tests
```

## JSON/YAML Processing

```bash
# jq for JSON
cat file.json | jq '.field'                    # Extract field
cat file.json | jq '.[] | select(.id == 123)'  # Filter
curl api.com/data | jq '.'                     # Format API response

# yq for YAML (if installed)
cat config.yml | yq '.database.host'           # Extract YAML field
cat config.yml | yq -o json                    # Convert YAML to JSON
```

## File Operations with Safety

```bash
# rsync with backup
rsync --backup --suffix=.bak source/ dest/

# Move with confirmation
mv -i source dest                              # Interactive (prompts on overwrite)

# Find and preview before delete
find . -name "*.tmp" -ls                       # Preview what would be deleted
find . -name "*.tmp" -delete                   # Actually delete (after preview)
```

## Troubleshooting Commands

### rclone
```bash
rclone config                                  # Refresh OAuth tokens
rclone config show                             # Check configuration
rclone lsd gdrive:                            # Test connection
```

### Claude Code
```bash
ls ~/.claude/debug/                            # Check for error logs
cat ~/.claude.json                             # Verify API key (don't share!)
```

### Git
```bash
git status                                     # Check current state
git log --oneline -10                          # Recent commits
git diff                                       # Unstaged changes
git diff --staged                              # Staged changes
git stash list                                 # List stashed changes
```

---

**Purpose**: Quick reference for common commands. For complete documentation, see individual workflow files or tool documentation.

**Version**: 1.0.0 | **Created**: 2026-01-15
