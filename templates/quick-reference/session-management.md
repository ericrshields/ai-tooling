# Session Management Quick Reference

One-page guide for managing Claude Code sessions, tasks, and agents.

---

## Quick Decisions

| Scenario | Action | Result |
|----------|--------|--------|
| **Need to reload agents** | `/resume` | Agents loaded, tasks preserved ✅ |
| **Want fresh start** | `exit` + `claude` | New session, new task list |
| **Added new agent file** | `/resume` | Agent appears in `/agents` |
| **Tasks not showing** | Check you're in same directory | Tasks tied to session ID + directory |

---

## Common Commands

```bash
/agents                    # List all available agents (built-in + custom)
/tasks                     # Show current task list
/resume                    # Restart session (preserve tasks, reload agents)
exit                       # Exit session completely
```

---

## Custom Agent Setup

**1. Create agent file**: `~/.claude/agents/my-agent.md`
```yaml
---
name: my-agent
description: When to use this agent
tools: Read, Grep, Glob
model: sonnet
---
# Agent body here
```

**2. Reload session**: `/resume`

**3. Verify**: `/agents` (should show "my-agent")

**4. Use**:
```typescript
Task({
  subagent_type: "my-agent",
  prompt: "Do something"
})
```

---

## Task Persistence

**Storage**: `~/.claude/tasks/[session-id]/`

**Scope**: Session ID + directory

**Carry over**:
- ✅ Same session (via `/resume`)
- ❌ New session (different session ID)

---

## The /resume Trick

**Problem**: Need agents loaded, don't want to lose tasks

**Solution**:
```bash
# Add agent files to ~/.claude/agents/
ln -s /path/to/agents ~/.claude/agents

# Reload without losing tasks
/resume

# Verify
/agents     # Agents now show ✅
/tasks      # Tasks still there ✅
```

**Why it works**: `/resume` reinitializes with same session ID

---

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Agents not in `/agents` | Not loaded at session start | `/resume` |
| "Agent type not found" | Agent not registered | Check frontmatter, `/resume` |
| Tasks disappeared | Different session ID | Use `/resume` instead of restart |

---

**Full Documentation**: See `~/.ai/workflows/claude-code-session-management.md`
