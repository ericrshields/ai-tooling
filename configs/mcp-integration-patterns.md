# MCP Integration Patterns

Hub for patterns on integrating Model Context Protocol (MCP) servers and plugins with Claude Code workflows.

---

## Overview

**Model Context Protocol (MCP)**: Standard protocol for connecting Claude to external data sources and tools.

**Benefits**: Unified interface for external services, permission-based access control, consistent error handling, tool composition and chaining.

**Common MCPs**: GitHub, Google Drive/Docs, Todoist, Filesystem, Database, Slack/Discord, JIRA, Browser.

---

## Configuration Scopes

MCP servers are installed **per-user (globally)** by default, not per Claude Code instance.

### Scope Types

| Scope | Storage | Availability | Use Case |
|-------|---------|--------------|----------|
| **user** (default) | `~/.claude.json` | All projects for you | Personal tools (Todoist, Gmail) |
| **local** | `~/.claude.json` | Current project only for you | Project-specific testing |
| **project** | `.mcp.json` | All team members via git | Team collaboration tools |

### Adding MCP Servers

```bash
# User scope (default) - available across all projects
claude mcp add --scope user <server-name>

# Local scope - only for current project, only for you
claude mcp add --scope local <server-name>

# Project scope - shared with team via git
claude mcp add --scope project <server-name>

# HTTP-based servers
claude mcp add --transport http <name> <url>
```

### Configuration Files

**User/Local scope**:
- Location: `~/.claude.json`
- Contains: OAuth sessions, MCP configs for user/local scopes
- Security: ⚠️ Contains sensitive data, never commit to git

**Project scope**:
- Location: `.mcp.json` in project root
- Contains: Shared MCP server configurations
- Security: ✅ Can be committed (if no secrets)

### Management Commands

```bash
# List installed MCP servers
cat ~/.claude.json | grep -A 20 "mcpServers"

# Remove MCP server
claude mcp remove --scope user <server-name>

# Test MCP server - ask Claude: "Use <server> to..."
```

---

## Permission Patterns

### Whitelist-Based MCP Access

**Pattern**: Explicitly allow specific MCP tools, deny everything else by default.

**Configuration Location**: `.claude/settings.json` or `.claude/settings.local.json` in project root.

**Structure**:
```json
{
  "permissions": {
    "allow": [
      "MCPServerName(tool_name)",
      "MCPServerName(tool_pattern:*)",
      "GitHub(pr view)",
      "GitHub(pr create)",
      "GitHub(issue list)",
      "GoogleDrive(read:*)",
      "Filesystem(read:**/*.md)"
    ],
    "deny": [
      "GitHub(repo delete)",
      "GoogleDrive(delete:*)",
      "Database(drop:*)"
    ]
  }
}
```

### Granularity Levels

**Coarse** (High Trust):
```json
"allow": ["GitHub(*)"]  // All GitHub MCP tools
```

**Medium** (Balanced):
```json
"allow": [
  "GitHub(pr:*)",      // All PR operations
  "GitHub(issue:*)"    // All issue operations
]
```

**Fine** (Maximum Control):
```json
"allow": [
  "GitHub(pr view)",   // Only view PRs
  "GitHub(pr create)", // Only create PRs
  "GitHub(issue list)" // Only list issues
]
```

---

## Service Integration Examples

Detailed patterns and workflows for common MCP services.

**Todoist**: Task management via natural language, OAuth setup, bulk operations, API reference.

**GitHub**: PR workflow, issue management, CI monitoring, error handling.

**Google Drive**: Document editing workflow, export/import, comment preservation.

**Slack**: Team notifications, deployment alerts, channel permissions.

See [mcp-servers/service-integrations.md](mcp-servers/service-integrations.md) for detailed integration guides.

---

## When to Use MCPs vs. Native Tools

### Use MCP When

- **External service integration**: GitHub, JIRA, Slack
- **Enhanced capabilities**: Database queries, browser automation
- **Unified interface**: Consistent API across tools
- **Permission control**: Need granular access control

### Use Native Tools When

- **Local file operations**: Read, Write, Edit are more direct
- **Shell commands**: Bash tool for git, npm, etc.
- **Simple operations**: Don't need MCP overhead
- **Offline work**: MCPs require network

### Decision Matrix

| Task | MCP | Native | Reason |
|------|-----|--------|--------|
| Read local file | ❌ | ✅ Read | Direct, no overhead |
| Create GitHub PR | ✅ GitHub | ❌ | Requires API access |
| Run npm build | ❌ | ✅ Bash | Shell command |
| Query database | ✅ Database | ❌ | Safe, validated queries |
| Edit code file | ❌ | ✅ Edit | Direct file access |
| Search JIRA tickets | ✅ JIRA | ❌ | Requires API access |

---

## Error Handling Patterns

### MCP Error Types

| Error Type | Cause | Action |
|------------|-------|--------|
| `UNAUTHORIZED` | Auth token expired/invalid | Re-authenticate MCP |
| `FORBIDDEN` | Insufficient permissions | Update permissions config |
| `NOT_FOUND` | Resource doesn't exist | Verify resource ID/name |
| `RATE_LIMITED` | Too many requests | Wait and retry with backoff |
| `TIMEOUT` | MCP server unresponsive | Check MCP server status |
| `INVALID_PARAMS` | Wrong parameters | Validate parameters |

### Error Handling Template

```typescript
async function callMCP(server: string, tool: string, params: any) {
  const MAX_RETRIES = 3;
  const RETRY_DELAY = 1000;

  for (let i = 0; i < MAX_RETRIES; i++) {
    try {
      const result = await mcp.call(server, tool, params);
      return result;

    } catch (error) {
      if (error.code === "RATE_LIMITED") {
        console.log(`Rate limited, retrying in ${RETRY_DELAY}ms...`);
        await sleep(RETRY_DELAY * (i + 1));  // Exponential backoff
        continue;

      } else if (error.code === "UNAUTHORIZED") {
        console.error(`Auth failed for ${server}. Fix: [auth command]`);
        throw error;

      } else if (error.code === "NOT_FOUND") {
        console.error(`Resource not found: ${params}`);
        return null;  // Graceful degradation

      } else {
        console.error(`${server} error: ${error.message}`);
        if (i === MAX_RETRIES - 1) throw error;
      }
    }
  }
}
```

---

## Advanced Patterns

### Pattern 1: MCP Composition

**Use Case**: Chain multiple MCP calls to accomplish complex task.

**Example - PR with CI validation**:
```markdown
1. GitHub(pr create) → Get PR number
2. Wait for CI
3. GitHub(pr checks {pr_number}) → Poll CI status
4. If CI passes:
   - Slack(post_message) → Notify team
5. If CI fails:
   - GitHub(pr review {pr_number}) → Request changes
   - Slack(post_message) → Alert team
```

### Pattern 2: MCP Fallback

**Use Case**: Graceful degradation if MCP unavailable.

```typescript
async function getIssues() {
  try {
    // Try GitHub MCP
    return await mcp.call("GitHub", "issue list");
  } catch (error) {
    console.warn("GitHub MCP unavailable, falling back to gh CLI");
    // Fallback to native Bash tool
    const result = await bash.exec("gh issue list --json number,title");
    return JSON.parse(result);
  }
}
```

### Pattern 3: Permission-Aware Actions

**Use Case**: Check permissions before attempting action.

```typescript
async function createPR(title: string, body: string) {
  // Check if permission granted
  if (!hasPermission("GitHub(pr create)")) {
    console.log("GitHub PR creation requires approval");
    await askUserPermission("Create GitHub PR?");
  }

  // Now safe to call
  return await mcp.call("GitHub", "pr create", {title, body});
}
```

---

## MCP Configuration Best Practices

1. **Start restrictive**: Use fine-grained permissions initially
2. **Log MCP calls**: Track what's being accessed
3. **Separate configs**: Dev vs. prod permission sets
4. **Regular review**: Audit permissions quarterly
5. **Document rationale**: Why each permission is needed
6. **Version control**: Commit settings to repo (except secrets)
7. **Test failure modes**: Ensure graceful degradation
8. **Timeout protection**: Don't wait forever for MCP responses

---

## Troubleshooting

### MCP Server Not Found
```bash
# Check available MCPs
claude mcp list

# Check MCP configuration
cat ~/.claude/settings.json | jq '.mcps'
```

### Authentication Failed
```bash
# Re-authenticate GitHub MCP
gh auth login

# Re-authenticate Google Drive MCP
rclone config reconnect gdrive
```

### Remote/SSH Authentication (OAuth Not Available)

**Problem**: OAuth flows require a browser callback to localhost, which doesn't work when Claude Code runs on a remote server over SSH.

**Solution**: Manually configure API tokens in `~/.claude.json` using Authorization headers.

**Steps**:
1. Get API token from service's developer settings:
   - **Todoist**: https://todoist.com/prefs/integrations → Developer → API token
   - **GitHub**: https://github.com/settings/tokens → Generate new token

2. Edit `~/.claude.json` to add headers:
```json
{
  "mcpServers": {
    "todoist": {
      "type": "http",
      "url": "https://ai.todoist.net/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_API_TOKEN_HERE"
      }
    }
  }
}
```

3. Restart Claude Code for changes to take effect.

**Alternative**: Use SSH port forwarding if you prefer OAuth:
```bash
# From local machine, forward callback port
ssh -L 8080:localhost:8080 user@remote-server
# Then run /mcp in Claude Code
```

### Permission Denied
```bash
# Check current permissions
cat .claude/settings.local.json | jq '.permissions'

# Add required permission by editing .claude/settings.local.json
```

### MCP Timeout
```bash
# Check MCP server health
curl http://localhost:3000/health  # Adjust port

# Restart MCP server
claude mcp restart [server-name]
```

---

**Related Documentation**:
- [mcp-servers/service-integrations.md](mcp-servers/service-integrations.md) - Detailed service integrations
- [claude-permissions.md](claude-permissions.md) - Permission system
- [tools.md](tools.md) - Tool overview
- [quality-gates.md](quality-gates.md) - Validation patterns
