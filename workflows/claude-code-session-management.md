# Claude Code Session Management

Patterns for managing sessions, tasks, and custom agents in Claude Code.

**Audience**: Users managing long-running projects with custom agents and task lists

---

## Core Concepts

### Session Identity

**Each session has a unique ID** that determines task storage:

```
~/.claude/tasks/[session-id]/
                └── *.json (task files)
```

**Session ID is tied to**:
- Working directory
- Session initialization time
- Claude Code instance

**Implication**: Tasks don't automatically carry over to new sessions in different directories or with different session IDs.

---

## Custom Agent Registration

### Agent Loading Behavior

**Custom agents load at session initialization**:

1. Claude Code scans `~/.claude/agents/` directory
2. Reads all `.md` files with proper frontmatter
3. Registers them as available agents
4. **Does NOT dynamically reload during session**

### Required Frontmatter Format

```yaml
---
name: agent-name
description: Clear description of when to delegate to this agent
tools: Read, Grep, Glob, WebFetch
model: sonnet | haiku | opus
---
```

### Verification

**Check loaded agents**:
```bash
/agents
# Shows:
# - Built-in agents (Bash, general-purpose, Explore, Plan, etc.)
# - User agents section (custom agents from ~/.claude/agents/)
```

**Use custom agent**:
```typescript
Task({
  subagent_type: "design-doc-reviewer",
  description: "Review design doc",
  prompt: "Review the design doc at path/to/doc.md"
})
```

---

## Task Persistence

### Storage Location

**Tasks persist in**:
```
~/.claude/tasks/[session-id]/
├── 1.json
├── 2.json
├── 3.json
└── ...
```

**Each task file contains**:
- Task ID, subject, description
- Status (pending/in_progress/completed)
- Owner, metadata
- Dependencies (blocks/blockedBy)

### Task Scope

**Tasks are scoped to**:
- Specific session ID
- Specific project directory

**New session = Different session ID = Different task storage**

---

## The /resume Trick

### Problem

You need to reload agents (requires session restart), but don't want to lose your task list.

### Solution: Use /resume

**What /resume does**:
1. Restarts the current session
2. Reinitializes with same session ID
3. Loads agents from `~/.claude/agents/`
4. **Preserves task list** (same session ID)

### Workflow

```bash
# 1. Create agent symlink (in running session)
ln -s ~/.ai-context-store/user-wide/agents ~/.claude/agents

# 2. Resume session (don't exit!)
/resume

# 3. Verify agents loaded
/agents
# Shows your custom agents ✅

# 4. Verify tasks preserved
/tasks
# Shows all your tasks ✅
```

### Why This Works

| Action | Session ID | Agents | Tasks |
|--------|-----------|--------|-------|
| **exit + new session** | New ID | ✅ Loaded | ❌ Lost |
| **/resume** | Same ID | ✅ Loaded | ✅ Preserved |

**Key insight**: `/resume` reinitializes without changing session ID.

---

## Session Restart Strategies

### Strategy 1: Full Restart (Clean Slate)

**When**: Starting new work, want fresh context

```bash
exit
claude
# New session ID, new task list, agents loaded
```

**Trade-offs**:
- ✅ Fresh context, agents loaded
- ❌ Lose task list
- ❌ Lose conversation history

---

### Strategy 2: /resume (Preserve Tasks)

**When**: Need to reload agents/config without losing tasks

```bash
/resume
# Same session ID, agents reloaded, tasks preserved
```

**Trade-offs**:
- ✅ Tasks preserved
- ✅ Agents reloaded
- ✅ Conversation history preserved (to extent possible)
- ⚠️ Context window still fills over time

---

### Strategy 3: Session Handoff (Explicit Context Transfer)

**When**: Moving to new session but need context continuity

**Steps**:
1. Create handoff note with current status:
   ```bash
   # Document current state
   echo "Working on task #24, updated design doc" > /tmp/handoff.md
   ```

2. Exit and start new session:
   ```bash
   exit
   claude
   ```

3. Load handoff in new session:
   ```bash
   "I'm continuing work from previous session. See /tmp/handoff.md.
    Please use TaskList to show current tasks and continue."
   ```

**Trade-offs**:
- ✅ Fresh session, agents loaded
- ✅ Explicit context handoff
- ❌ Tasks may not carry over (different session ID)
- ⚠️ Manual context transfer required

---

## Agent System Architecture

### Two Agent Systems

Claude Code has **two separate agent systems**:

| System | Command | Source | Use Case |
|--------|---------|--------|----------|
| **MCP Agents** | `/agents` | MCP servers | External integrations |
| **Custom Subagents** | `Task(subagent_type=...)` | `~/.claude/agents/*.md` | Project-specific workflows |

**Both show in `/agents` output**, but serve different purposes:
- **Built-in agents**: Bash, general-purpose, Explore, Plan
- **User agents**: Custom agents from `~/.claude/agents/`

### Custom Agent Files

**Not loaded as context** - they're definitions used when spawning agents:
- `rules/*.md` files → Loaded in every conversation ✅
- `agents/*.md` files → Used when spawning agents (not in context) ❌

**Analogy**: Agent files are like function definitions - they define behavior but aren't executed until called.

---

## Troubleshooting

### "Agent type 'X' not found"

**Cause**: Agent not loaded at session start.

**Fix**: Use `/resume` to reload agents, or restart session.

---

### "Tasks not found in new session"

**Cause**: New session has different session ID.

**Fix**:
- **Option 1**: Use `/resume` instead of exit
- **Option 2**: Accept that new sessions have fresh task lists
- **Option 3**: Manually reference old task files from `~/.claude/tasks/[old-session-id]/`

---

### "Agents show in /agents but Task tool fails"

**Cause**: Agent frontmatter format incorrect.

**Fix**: Verify frontmatter has required fields:
```yaml
---
name: agent-name           # Required
description: ...           # Required
tools: Read, Grep, ...     # Required
model: sonnet              # Required
---
```

---

## Best Practices

### 1. Use /resume for Agent Reloading

When you need to reload agents/config:
- ✅ Use `/resume` to preserve tasks
- ❌ Don't exit + restart unless you want fresh tasks

### 2. Document Session State

Before major transitions:
- Create handoff notes in `/tmp/`
- Document current task status
- Note critical decisions or context

### 3. Verify Agent Loading

After adding new agents:
```bash
/resume      # Reload session
/agents      # Verify agents appear
```

### 4. Task List as Continuity Anchor

Tasks are your cross-session memory:
- Create tasks for multi-session work
- Update task status regularly
- Use task descriptions to capture context

### 5. Session ID Awareness

Understand that:
- Tasks are tied to session ID
- New sessions = new task storage
- `/resume` preserves session ID

---

## Related Documentation

- Task management patterns - See `~/.ai-context-store/user-wide/rules/task-management-patterns.md`
- Interaction patterns - See `~/.ai-context-store/user-wide/rules/interaction-patterns.md`
- Agent registration guide - See `~/.ai-context-store/plans/agent-registration-guide.md`
- [claude-code-usage.md](claude-code-usage.md) - Claude Code CLI patterns and context management

---

## Changelog

| Date | Changes | Author |
|------|---------|--------|
| 2026-02-02 | Initial documentation based on session management learnings | Eric Shields |

**Key Discovery**: `/resume` reinitializes session, reloading agents while preserving task list (same session ID)
