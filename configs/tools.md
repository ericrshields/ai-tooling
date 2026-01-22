# AI Development Tools Reference

Common tools that enhance AI-assisted development workflows and their typical configurations.

## Core AI Tools

### Claude Code
AI coding assistant with persistent memory and workflow automation.

**Purpose**: Interactive CLI tool for AI-assisted software development
**Config Location**: `~/.claude/`
**Memory File**: `~/.claude/CLAUDE.md` (user preferences and workflows)
**Settings**: `~/.claude.json` (API keys - DO NOT SHARE)
**Installation**: Official installer from claude.ai/code
**Version Check**: `claude --version`

**Key Features**:
- Persistent memory across sessions
- Custom commands/skills
- Plugin and MCP server support
- File history and context management

## Document Management Tools

### rclone
Command-line tool for syncing files with cloud storage providers.

**Purpose**: Access and sync cloud storage (Google Drive, Dropbox, S3, etc.) via CLI
**Config Location**: `~/.config/rclone/rclone.conf` (OAuth tokens - DO NOT SHARE)
**Installation**: `curl https://rclone.org/install.sh | sudo bash`
**Docs**: https://rclone.org/docs/

**Common Uses**:
- Download Google Docs for editing
- Sync files across machines
- Backup to cloud storage
- Mount cloud storage as local filesystem

**Setup**: Run `rclone config` to add remotes (e.g., Google Drive, S3)
**Typical Remote Name**: `gdrive:` for Google Drive

### pandoc
Universal document converter supporting dozens of formats.

**Purpose**: Convert between document formats (docx ↔ markdown, PDF, HTML, etc.)
**Installation**: `sudo apt install pandoc` (Linux) or `brew install pandoc` (macOS)
**Docs**: https://pandoc.org/

**Common Uses**:
- Convert Google Docs to markdown for AI editing
- Generate documentation in multiple formats
- Transform between markup languages
- Create PDFs from markdown (requires LaTeX)

**Supported Formats**: Markdown, HTML, LaTeX, docx, PDF, epub, and many more

## Development Tools

### GitHub CLI (gh)
Official GitHub command-line tool for repository operations.

**Purpose**: Create PRs, manage issues, view CI status without leaving terminal
**Installation**: https://cli.github.com/
**Config Location**: `~/.config/gh/`

**Common Uses**:
- Create pull requests: `gh pr create`
- View PR status: `gh pr status`
- Manage issues: `gh issue list`
- Review code: `gh pr review`

### jq
Lightweight JSON processor for querying and manipulating JSON data.

**Purpose**: Parse, filter, and transform JSON from command line
**Installation**: `sudo apt install jq` or `brew install jq`
**Docs**: https://jqlang.github.io/jq/

**Common Uses**:
- Parse API responses
- Extract specific fields from JSON
- Format JSON for readability
- Transform JSON structures

## Potential Additional Tools

### fzf
Fuzzy finder for interactive file and command selection.

**Purpose**: Fast, interactive filtering for files, command history, etc.
**Installation**: https://github.com/junegunn/fzf
**Use Cases**: Quickly find files, search command history, filter lists

### yq
YAML processor similar to jq but for YAML files.

**Purpose**: Query and manipulate YAML configuration files
**Installation**: https://github.com/mikefarah/yq
**Use Cases**: Parse CI configs, extract values from YAML, transform YAML

### mutt/neomutt
Terminal-based email client.

**Purpose**: Read and send email from command line
**Installation**: `sudo apt install mutt` or `neomutt`
**Use Cases**: Email workflows, automation, offline access
**Note**: Requires IMAP/SMTP or MCP server setup

## Tool Configuration Patterns

### Config File Locations

Most tools follow XDG Base Directory conventions:
- Config: `~/.config/toolname/`
- Data: `~/.local/share/toolname/`
- Cache: `~/.cache/toolname/`

Some tools use home directory:
- `~/.toolname/` or `~/.toolnamerc`

### Authentication Storage

**Secure storage** (OAuth tokens, API keys):
- Claude Code: `~/.claude.json`
- rclone: `~/.config/rclone/rclone.conf`
- GitHub CLI: `~/.config/gh/hosts.yml`

**NEVER commit these files to version control or share them.**

### Setup on New Machine

1. Install tools using package manager or official installers
2. Copy non-sensitive config files from `~/.ai/`
3. Re-authenticate tools that require OAuth (rclone, gh, etc.)
4. Verify with version checks or test commands

### Best Practices
- Use separate API keys per machine when possible
- Rotate credentials periodically
- Revoke access for unused or compromised keys
- Store sensitive configs outside version control
- Use environment variables for secrets in scripts

## Tool Commands and Troubleshooting

For version checks, update commands, and troubleshooting steps, see `workflows/one-liners.md`.

**Common issues:**
- **rclone**: Authentication issues usually require re-running `rclone config`
- **pandoc**: PDF generation requires LaTeX to be installed
- **Claude Code**: Check `~/.claude/debug/` for error logs

## Claude Code Plugins and MCPs

### What are MCPs?
**Model Context Protocol (MCP)**: Standard for connecting Claude to external data sources and tools.

**Examples**:
- **GitHub MCP**: Create PRs, manage issues, view CI status
- **Google Drive MCP**: Access documents, spreadsheets
- **Filesystem MCP**: Enhanced file access patterns
- **Database MCPs**: Query databases directly

### What are Plugins?
**Plugins**: Extensions that add capabilities to Claude Code (code review, linting, etc.)

### Configuration Patterns

**Permission-based access**: Control which MCP tools Claude can use automatically vs. requiring approval.

**Configuration location**: `.claude/settings.json` or `.claude/settings.local.json` in project root

**For detailed patterns on MCP integration and permissions, see:**
- [mcp-integration-patterns.md](mcp-integration-patterns.md) - MCP usage patterns and permission configs
- [quality-gates.md](quality-gates.md) - Permission system structure and examples

**Basic structure**:
```json
{
  "permissions": {
    "allow": [
      "Bash(npm run build)",
      "Read(**/*.ts)",
      "GitHub(pr view)"
    ],
    "deny": [
      "Read(.env*)",
      "Bash(rm *)"
    ]
  }
}
```

---

**Note**: This is a reference guide, not an installation status tracker. Actual installed versions and configurations may vary by machine.
