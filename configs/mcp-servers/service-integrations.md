# MCP Service Integration Examples

Detailed integration patterns and examples for common MCP servers: Todoist, GitHub, Google Drive, and Slack.

---

## Overview

MCP servers provide standardized access to external services. This guide provides practical integration patterns for the most commonly used services.

---

## Todoist MCP Integration

### Installation

```bash
# Official Todoist MCP server (recommended)
claude mcp add --scope user --transport http todoist https://ai.todoist.net/mcp

# Alternative community servers
# @greirson/mcp-todoist - 28 tools for comprehensive management
# @abhiz123/todoist-mcp-server - Natural language focused
```

**Authentication**: OAuth via browser (~1 minute setup).

### Usage Patterns

**Pattern**: Create and manage tasks via natural language.

**Example Workflows**:
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

### Features

**Task Management**:
- Create, read, update, move, close/reopen tasks
- Natural language parsing for due dates, priorities, labels
- Project organization with sections and hierarchy
- Comments for additional context
- Labels for tagging and filtering

### API Reference

**For custom integrations**:
- REST API v1: https://developer.todoist.com/api/v1/
- Quick Add: Fastest way to create tasks programmatically
- SDKs: Python (`todoist-api-python`), JavaScript
- CLI: `doist` command-line tool

---

## GitHub MCP Integration

### Usage Patterns

**Pattern**: Create PRs, manage issues, monitor CI without leaving terminal.

**Example Workflow - Pull Request Creation**:
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

### Error Handling

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

### Permissions Example

```json
"allow": [
  "GitHub(pr view)",
  "GitHub(pr create)",
  "GitHub(pr status)",
  "GitHub(issue list)",
  "GitHub(issue view)"
],
"deny": [
  "GitHub(pr merge)",      // Require manual merge
  "GitHub(repo delete)",   // Prevent accidents
  "GitHub(branch delete)"  // Require manual cleanup
]
```

---

## Google Drive MCP Integration

### Usage Patterns

**Pattern**: Fetch Google Doc, edit as markdown, sync back.

**Example Workflow - Document Editing**:
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

### Permissions Example

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

---

## Slack MCP Integration

### Usage Patterns

**Pattern**: Post notifications and updates to team channels.

**Example Workflow - Deployment Notification**:
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

### Permissions Example

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

## Filesystem MCP Integration

### Usage Patterns

**Pattern**: Enhanced file operations with pattern-based permissions.

**Permissions Example**:
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

## Frontend-Specific Workflows

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
- [../mcp-integration-patterns.md](../mcp-integration-patterns.md) - MCP hub and core patterns
- [../claude-permissions.md](../claude-permissions.md) - Permission system
- [../quality-gates.md](../quality-gates.md) - Validation patterns
