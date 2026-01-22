# MCP Integration Patterns

Patterns for integrating Model Context Protocol (MCP) servers and plugins with Claude Code workflows.

---

## What is MCP?

**Model Context Protocol (MCP)**: Standard protocol for connecting Claude to external data sources and tools.

**Benefits**:
- Unified interface for external services
- Permission-based access control
- Consistent error handling
- Tool composition and chaining

**Common MCPs**:
- **GitHub**: PR management, issue tracking, CI status
- **Google Drive/Docs**: Document access and editing
- **Todoist**: Task and project management
- **Filesystem**: Enhanced file operations
- **Database**: Direct database queries
- **Slack/Discord**: Team communication
- **JIRA**: Ticket management
- **Browser**: Web automation

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

# Test MCP server
# Ask Claude: "Use <server> to..."
```

---

## Permission Patterns

### Whitelist-Based MCP Access

**Pattern**: Explicitly allow specific MCP tools, deny everything else by default.

**Configuration Location**: `.claude/settings.json` or `.claude/settings.local.json` in project root

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

#### Coarse (High Trust)
```json
"allow": ["GitHub(*)"]  // All GitHub MCP tools
```
**Use when**: Trusted environment, low risk operations

#### Medium (Balanced)
```json
"allow": [
  "GitHub(pr:*)",      // All PR operations
  "GitHub(issue:*)"    // All issue operations
]
```
**Use when**: Want flexibility within categories

#### Fine (Maximum Control)
```json
"allow": [
  "GitHub(pr view)",   // Only view PRs
  "GitHub(pr create)", // Only create PRs
  "GitHub(issue list)" // Only list issues
]
```
**Use when**: Security-critical, production environments

### Frontend-Relevant Permissions

**GitHub MCP** (PR workflow):
```json
"allow": [
  "GitHub(pr view)",
  "GitHub(pr create)",
  "GitHub(pr status)",
  "GitHub(pr review)",
  "GitHub(issue list)",
  "GitHub(issue view)"
],
"deny": [
  "GitHub(pr merge)",      // Require manual merge
  "GitHub(repo delete)",   // Prevent accidents
  "GitHub(branch delete)"  // Require manual cleanup
]
```

**Google Drive MCP** (Document collaboration):
```json
"allow": [
  "GoogleDrive(read:*)",         // Read any file
  "GoogleDrive(list:*)",         // List files/folders
  "GoogleDocs(export:*)"         // Export docs
],
"deny": [
  "GoogleDrive(delete:*)",       // Prevent deletions
  "GoogleDrive(share:*)",        // Control sharing manually
  "GoogleDocs(modify:**/final/*)" // Protect final docs
]
```

**Filesystem MCP** (Project files):
```json
"allow": [
  "Filesystem(read:**/*.{ts,tsx,js,jsx})",  // Read source
  "Filesystem(read:**/*.{md,json,yml})",    // Read configs
  "Filesystem(list:src/**)"                  // List source files
],
"deny": [
  "Filesystem(read:.env*)",                  // Protect secrets
  "Filesystem(read:node_modules/**)",        // Reduce noise
  "Filesystem(write:**)"                     // Use native Write tool
]
```

---

## Integration Examples

### GitHub MCP - Pull Request Workflow

**Use Case**: Create PR with proper description and labels.

**Pattern**:
```markdown
1. Get current branch and changes:
   - GitHub(branch current)
   - GitHub(diff main...HEAD)

2. Generate PR description from commits:
   - GitHub(log main...HEAD)
   - Analyze commits, create summary

3. Create PR:
   - GitHub(pr create --title "..." --body "..." --label "frontend")

4. Monitor CI:
   - GitHub(pr checks)
   - Poll until complete or timeout

5. Handle result:
   - Success: Notify user
   - Failure: Report failed checks
```

**Error Handling**:
```typescript
try {
  const pr = await mcp.call("GitHub", "pr create", {
    title: "Add component",
    body: description
  });
  console.log(`PR created: ${pr.url}`);
} catch (error) {
  if (error.code === "UNAUTHORIZED") {
    console.error("GitHub authentication failed. Run: gh auth login");
  } else if (error.code === "CONFLICT") {
    console.error("PR already exists for this branch");
  } else {
    console.error(`GitHub error: ${error.message}`);
  }
  process.exit(1);
}
```

### Google Drive MCP - Document Editing

**Use Case**: Fetch Google Doc, edit as markdown, sync back.

**Pattern**:
```markdown
1. Search for document:
   - GoogleDrive(search "Document Name")
   - Get file ID from results

2. Export to markdown:
   - GoogleDocs(export {fileId} markdown)
   - Save to temp file

3. Edit with Claude:
   - Read temp file
   - Make edits
   - Write back to temp file

4. User manually syncs back:
   - Open Google Doc in browser
   - Copy-paste updated markdown
   - Preserves comments and formatting
```

**Why manual sync**: Preserves comments and change history in Google Docs.

### Todoist MCP - Task Management

**Use Case**: Manage tasks and projects via natural language.

**Installation**:
```bash
# Official Todoist MCP server (recommended)
claude mcp add --scope user --transport http todoist https://ai.todoist.net/mcp

# Alternative community servers
# @greirson/mcp-todoist - 28 tools for comprehensive management
# @abhiz123/todoist-mcp-server - Natural language focused
```

**Authentication**: OAuth via browser (~1 minute setup)

**Pattern**:
```markdown
1. Create task with natural language:
   - "Add task: Review MCP documentation tomorrow at 2pm !p1 @work"
   - Todoist(task create) parses and creates task

2. Query tasks:
   - "Show me my tasks for this week"
   - Todoist(task list --filter "this week")

3. Organize with projects:
   - "Create project: Q1 Frontend Improvements"
   - Todoist(project create)

4. Update task status:
   - "Complete the task about MCP docs"
   - Todoist(task close)

5. Bulk operations:
   - "Move all tasks labeled @frontend to the Done section"
   - Todoist(task update --bulk)
```

**Features**:
- Task management: Create, read, update, move, close/reopen
- Natural language parsing: Due dates, priorities, labels
- Project organization: Sections, hierarchy
- Comments: Add context to tasks
- Labels: Tag and filter tasks

**Usage Examples**:
```markdown
# Daily planning
"Add these to Todoist for tomorrow: review PRs, update docs, team sync at 2pm"

# Project setup
"Create a Todoist project called 'Homepage Redesign' with sections: Design, Development, Testing"

# Task queries
"Show me all high-priority tasks due this week"
"List tasks in the 'AI Development' project"

# Updates
"Mark the 'Write tests' task as complete"
"Change the 'Deploy' task to high priority"
```

**API Reference** (for custom integrations):
- REST API v1: https://developer.todoist.com/api/v1/
- Quick Add: Fastest way to create tasks programmatically
- SDKs: Python (`todoist-api-python`), JavaScript
- CLI: `doist` command-line tool

### Slack MCP - Team Notifications

**Use Case**: Post deployment notification to team channel.

**Pattern**:
```markdown
1. Format notification:
   - Deployment status (success/failure)
   - Version deployed
   - Changes included
   - Rollback command (if needed)

2. Post to channel:
   - Slack(post_message {channel: "#deploys", text: message})

3. Thread on failure:
   - Slack(post_message {channel: "#deploys", thread_ts: ts, text: details})
```

**Permission**:
```json
"allow": [
  "Slack(post_message:#deploys)",
  "Slack(post_message:#incidents)"
],
"deny": [
  "Slack(post_message:#general)",  // Prevent spam
  "Slack(delete_message:*)"        // Prevent accidents
]
```

---

## When to Use MCPs vs Native Tools

### Use MCP When:
- **External service integration**: GitHub, JIRA, Slack
- **Enhanced capabilities**: Database queries, browser automation
- **Unified interface**: Consistent API across tools
- **Permission control**: Need granular access control

### Use Native Tools When:
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
      // Handle specific error types
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
        if (i === MAX_RETRIES - 1) throw error;  // Last attempt
      }
    }
  }
}
```

---

## Advanced Patterns

### Pattern 1: MCP Composition

**Use Case**: Chain multiple MCP calls to accomplish complex task.

```markdown
Example: PR with CI validation

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
3. **Separate configs**: Dev vs prod permission sets
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

### Permission Denied
```bash
# Check current permissions
cat .claude/settings.local.json | jq '.permissions'

# Add required permission
# Edit .claude/settings.local.json
```

### MCP Timeout
```bash
# Check MCP server health
curl http://localhost:3000/health  # Adjust port

# Restart MCP server
claude mcp restart [server-name]
```

---

## Frontend-Specific MCP Workflows

### Workflow 1: Component PR with Screenshots

```markdown
1. Implement component locally
2. Run build and tests
3. Take screenshot using Browser MCP:
   - Browser(navigate http://localhost:3000/component)
   - Browser(screenshot component-preview.png)
4. Create PR with GitHub MCP:
   - GitHub(pr create --title "..." --body "...")
   - Upload screenshot to PR
5. Request review:
   - GitHub(pr review --request @reviewer)
6. Notify on Slack:
   - Slack(post_message "#frontend-reviews" "PR ready: {url}")
```

### Workflow 2: Bundle Size Tracking

```markdown
1. Build production bundle
2. Calculate bundle size
3. Store in Google Sheets via GoogleSheets MCP:
   - GoogleSheets(append {sheet: "Bundle Sizes", data: [date, size, commit]})
4. Check for regression:
   - If size increase > 10%:
     - Slack(post_message "#performance" "Bundle size increased")
```

---

**Related Documentation**:
- [tools.md](tools.md) - Claude Code and MCP overview
- [quality-gates.md](quality-gates.md) - Permission system structure
- [multi-agent-orchestration.md](../instructions/multi-agent-orchestration.md) - Agent coordination

**Version**: 1.0.0 | **Created**: 2026-01-16
