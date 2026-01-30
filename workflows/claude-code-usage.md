# Claude Code Usage Patterns

Practical guidance for effective use of Claude Code CLI, including context management, conversation lifecycle, and workflow optimization.

---

## Context Window Management

### Understanding Context Types

Claude Code maintains three separate context systems:

**1. Memory Files** - Static Auto-Loaded Context
- **CLAUDE.md files**: User (`~/.claude/CLAUDE.md`) and project-level (`./CLAUDE.md`, `./.claude/CLAUDE.md`)
- **Rules directory**: All `.md` files in `~/.claude/rules/` and `./.claude/rules/` (RECOMMENDED)
- **SessionStart hooks**: ⚠️ **BROKEN for new conversations** (GitHub Issue #10373) - use rules/ instead
- Automatically loaded at conversation start
- Project/user-wide guidelines and patterns
- Examples: coding standards, workflow patterns, interaction preferences

**2. Dynamic Memory System** - Learned Context
- Facts learned about you and your preferences during sessions
- Persists across conversation restarts (unless `/clear` is used)
- Visible via `/memory` command
- Examples: "prefers TypeScript", "working on Grafana OSS", "uses TDD"

**3. Custom Directories** - Manual Reference Only
- Directories like `.claude/rules/` or custom folders are NOT auto-loaded
- Must be loaded via CLAUDE.md imports (SessionStart hooks broken for new conversations)
- Better alternative: Use rules/ directory for reliable auto-loading

### Conversation Management Commands

**Exit and Restart** (`exit` then `claude`)
- **Use for**: Natural session breaks, switching projects, starting fresh work
- **Result**: Clean conversation history, memory learnings preserved
- **When**: End of day, switching between unrelated tasks, clean mental break
- **Example**:
  ```bash
  $ claude
  > [work on feature X]
  > exit
  $ claude
  > [work on feature Y - I still remember your preferences]
  ```

**Manual Compact** (`/compact` with notes)
- **Use for**: Mid-task when context fills up, ongoing related work
- **Result**: Compressed history with user-controlled preservation, memory intact
- **When**: Context approaching 70-80% (140,000-160,000 of 200,000 tokens)
- **Why**: Auto-compact uses summarization without your input; manual gives control
- **Example**:
  ```
  /compact Remember: hub-and-spoke architecture, sync script is critical,
  always read README first, using Oxford commas throughout
  ```

**Clear Command** (`/clear`)
- **Use for**: Almost never (testing, debugging edge cases only)
- **Result**: Nuclear option - wipes everything including memory learnings
- **When**: Only when genuinely need to reset all context and memory
- **Warning**: Destroys accumulated memory about your preferences and patterns

### Context Budget

- **Total capacity**: 200,000 tokens
- **Warning threshold**: 140,000-160,000 tokens (70-80%)
- **Auto-compact trigger**: Near 200,000 tokens
- **Recommendation**: Monitor token usage in corner display; request warnings when approaching threshold

### Best Practices

**Default workflow** (most tasks):
1. Continue working in same conversation across related tasks
2. Context auto-manages; no manual intervention needed
3. Exit and restart only at natural session breaks

**Long sessions** (context filling up):
1. Watch for context warnings (70-80% usage)
2. Use `/compact` with explicit preservation notes
3. Specify important decisions, patterns, or context to maintain
4. Continue working without losing critical information

**Starting fresh** (new day/project):
1. Exit current session
2. Start new `claude` session
3. Memory of your preferences preserved automatically
4. Clean conversation history for new work

---

## Permissions System

### Configuration Hierarchy

Permissions follow additive merging with most-restrictive-wins for conflicts:

**Priority order**:
1. **Deny** > **Ask** > **Allow** (conflict resolution)
2. **Project-local** (`./.claude/settings.local.json`) merges with
3. **User-wide** (`~/.claude/settings.local.json`)

**Example**:
- User-wide allows read operations, asks for writes, denies destructive ops
- Project-local adds `Bash(./sync-memory.py:*)` permission
- Result: All user-wide permissions + project-local additions

### Permission Tiers

See [../configs/claude-permissions.md](../configs/claude-permissions.md) for complete documentation.

**Allow**: Auto-approved, no prompt
- Read operations (Read, Glob, Grep)
- Git read commands (status, diff, log)
- Safe utilities (ls, find, cat, jq)

**Ask**: Requires approval each time
- Write/Edit operations
- Git commits and pushes
- Package management (npm install)

**Deny**: Blocked completely
- Destructive operations (rm -rf, git push --force)
- System commands (sudo, chmod +x)
- Secret files (.env, credentials)

---

## File and Directory Structure

### Memory Files and Rules

**Auto-Loaded Locations**:
- `~/.claude/CLAUDE.md` - User-wide memory file
- `./CLAUDE.md` or `./.claude/CLAUDE.md` - Project-specific memory file
- `~/.claude/rules/*.md` - User-wide rules (all .md files loaded)
- `./.claude/rules/*.md` - Project-specific rules (all .md files loaded)

**Purpose**: Automatically loaded into every conversation as static context

**Contents**:
- Coding patterns and guidelines
- Project-specific workflows
- Interaction preferences
- Development standards

**Rules Directory Ordering**: For files that must load first
```bash
# Use 00- prefix for priority loading (alphabetical order)
~/.claude/rules/00-constitution.md  # Loads first
~/.claude/rules/interaction-patterns.md
~/.claude/rules/task-management.md
```

**SessionStart Hooks** (⚠️ BROKEN):
- GitHub Issue #10373: Don't inject context for new conversations
- Only work for `/clear`, `/compact`, and resume operations
- **Recommendation**: Use rules/ directory instead

**Custom Directories** (e.g., `.claude/rules/`):
- NOT auto-loaded by Claude Code
- Must use CLAUDE.md imports to load (SessionStart hooks broken)
- Better alternative: Move to rules/ directory

### Settings Files

**User-wide**: `~/.claude/settings.local.json`
- Base permissions for all projects
- Safe directories and common tools
- Universal git operations

**Project-local**: `<project>/.claude/settings.local.json`
- Project-specific permission additions
- Special tooling access (e.g., sync scripts)
- Overrides for project needs

---

## Memory System

### What Gets Remembered

The memory system learns and retains:
- **Preferences**: Language choices, coding style, conventions
- **Context**: Current projects, technologies in use
- **Decisions**: Architectural choices, patterns adopted
- **Workflows**: Preferred development approaches

### Memory Lifecycle

**Preserved across**:
- Exit and restart (`exit` then `claude`)
- Multiple conversation sessions
- Different working directories

**Lost when**:
- `/clear` command used
- Explicit memory reset requested

### Managing Memory

**View memory**: Use `/memory` command

**Explicit additions**: Request additions when important patterns emerge

**Cleanup**: Periodically review and remove outdated context

---

## Workflow Optimization

### Continuous Work Sessions

For related tasks in same context:
```bash
$ claude
> help me fix bug in authentication
[work together]
> now add password reset feature
[continue working]
> review the changes for security issues
[still same conversation - context maintained]
> exit
```

**Advantages**:
- Full context of earlier decisions
- No repeated explanations
- Natural conversation flow

### Context-Aware Restarts

For unrelated tasks or clean breaks:
```bash
$ claude
> [work on frontend components]
> exit

$ cd ~/other-project
$ claude
> [work on backend API - fresh context, preserved memory]
> exit
```

**Advantages**:
- Clean separation between projects
- No context pollution
- Memory of preferences maintained

### Mid-Task Compaction

When context fills during long sessions:
```bash
$ claude
> [extensive work on feature]
> [context at 75% - warning received]
> /compact Remember: using hub-and-spoke pattern,
  refactored auth to JWT, tests use Jest,
  deployment target is Kubernetes
> [continue working with preserved decisions]
```

**Advantages**:
- User controls what's preserved
- Avoids lossy auto-summarization
- Maintains critical context for ongoing work

---

## Tips and Tricks

### Proactive Context Warnings

Request warnings when approaching context limits:
- Watch for 70-80% token usage
- Get notified before auto-compact triggers
- Time to prepare `/compact` notes

### Configuration Syncing

Use hub-and-spoke configuration repos:
- Centralized source of truth for settings
- Sync to `~/.claude/` (user-wide) and `<project>/.claude/` (project-local)
- See `~/.ai-context-store/` for pattern

### Memory and Rules Files

Keep CLAUDE.md and rules/ files focused:
- Universal patterns only
- Cross-reference instead of duplicate
- Every line costs tokens in every session
- Use `00-` prefix in rules/ for files that must load first (alphabetical ordering)
- Avoid custom directories - use rules/ for reliable auto-loading

### Permission Testing

Test new permissions safely:
- Start with `ask` tier
- Graduate to `allow` after validation
- Use `deny` for truly dangerous operations

---

## Troubleshooting

### Memory Not Persisting

**Symptom**: Claude doesn't remember previous sessions

**Causes**:
- Used `/clear` instead of `exit`
- Memory system not enabled
- New machine without memory sync

**Solution**: Exit and restart instead of clearing

### Context Filling Too Fast

**Symptom**: Frequent auto-compact triggers

**Causes**:
- Large instruction files
- Verbose conversation history
- Reading many large files

**Solutions**:
- Trim instruction files to essentials
- Use `/compact` proactively with notes
- Exit and restart for new topics

### Permissions Not Working

**Symptom**: Unexpected permission prompts

**Causes**:
- Project-local settings not merged
- Typo in permission pattern
- More restrictive rule taking precedence

**Solutions**:
- Check both user and project settings files
- Verify pattern syntax (use wildcards correctly)
- Remember: deny > ask > allow

---

## Related Files

- [../configs/claude-permissions.md](../configs/claude-permissions.md) - Complete permissions documentation
- [../configs/mcp-integration-patterns.md](../configs/mcp-integration-patterns.md) - MCP server configuration
- [../rules/claude-code-memory.md](../rules/claude-code-memory.md) - User preferences and personality
- [../rules/context-efficiency.md](../rules/context-efficiency.md) - Documentation patterns
- [./one-liners.md](./one-liners.md) - Command reference

