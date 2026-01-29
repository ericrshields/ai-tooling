# Claude Code Auto-Loading Mechanisms

Complete reference for how Claude Code automatically loads context into conversations.

---

## Overview

Claude Code has **specific, built-in mechanisms** for auto-loading context. Custom directories like `.claude/instructions/` or `.claude/custom/` are **NOT automatically loaded** unless explicitly configured.

---

## Auto-Loaded Context

### 1. CLAUDE.md Files

**Locations** (all auto-loaded at session start):
- `~/.claude/CLAUDE.md` - User-wide, applies to all projects
- `./.claude/CLAUDE.md` - Project-specific, in repository `.claude/` directory
- `./CLAUDE.md` - Project-specific, at repository root
- `./CLAUDE.local.md` - Personal project settings (gitignored)

**Loading Order**: User → Project → Local (merged together)

**Example Structure**:
```markdown
# My Development Guidelines

## Coding Standards
- Always use TypeScript strict mode
- Prefer functional components in React
- Follow TDD practices

## Related Documentation
@./docs/architecture.md
@~/.ai/instructions/coding-principles.md
```

**Import Syntax**: Use `@filepath` to import other files into CLAUDE.md

### 2. Rules Directory

**Locations** (all .md files auto-loaded):
- `~/.claude/rules/*.md` - User-wide rules
- `./.claude/rules/*.md` - Project-specific rules

**Behavior**: Every markdown file in rules/ directories is automatically loaded

**Best Practice**: Modular, focused files (one topic per file)

**Example Structure**:
```
~/.claude/rules/
├── interaction-patterns.md
├── context-management.md
├── planning-workflow.md
└── task-management.md
```

**When to Use**:
- Multiple instruction files that should all load
- Modular organization of patterns and practices
- Shared across all sessions automatically

### 3. SessionStart Hooks

**Location**: `settings.local.json` (user-wide or project-specific)

**Purpose**: Load specific files BEFORE rules files load, useful for:
- Critical files that must be read first (e.g., project constitutions)
- Files in custom directories that aren't auto-loaded
- Dynamic content generation at session start

**Configuration**:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cat ~/.claude/instructions/00-project-constitution.md"
          }
        ]
      }
    ]
  }
}
```

**Multiple Files**:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cat ~/.claude/critical-file.md ~/.claude/another-file.md"
          }
        ]
      }
    ]
  }
}
```

**Status**: ⚠️ **BROKEN for new conversations** (GitHub Issue #10373, January 2026)

**Known Bug**: SessionStart hooks execute successfully but their output is **never injected into context** for brand new conversations. Hooks work correctly for `/clear`, `/compact`, and resume operations, but silently fail for new sessions.

**Recommendation**: **Use rules/ directory instead** for static content.

**Workarounds** (until bug is fixed):
1. **Use rules/ directory** - Move static files to `~/.claude/rules/*.md` (auto-loads reliably)
2. **Manual `/clear`** - Run `/clear` at session start to force hooks to fire
3. **UserPromptSubmit hooks** - Work correctly but wasteful (inject on EVERY prompt)

**When to Use** (once bug is fixed):
- Dynamic content generation (git status, recent commits)
- Conditional loading (check if file exists, load if present)
- Content that changes between sessions

---

## NOT Auto-Loaded

### Custom Directories

These are **NOT automatically loaded**:
- `.claude/instructions/`
- `.claude/patterns/`
- `.claude/workflows/`
- `.claude/custom/`
- Any other custom directory names

**To Load Them**: Use SessionStart hooks or CLAUDE.md imports

### settings.local.json

**NOT loaded as context**, only used for:
- Permissions configuration
- Hooks configuration
- Other tool settings

---

## Loading Hierarchy

**Order of operations** when Claude Code starts:

1. **SessionStart hooks fire**
   - Commands execute
   - Output added to context

2. **CLAUDE.md files load**
   - User-wide (`~/.claude/CLAUDE.md`)
   - Project-specific (`./.claude/CLAUDE.md` or `./CLAUDE.md`)
   - Local (./CLAUDE.local.md`)
   - Imports resolved (`@filepath` syntax)

3. **Rules files load**
   - All `~/.claude/rules/*.md`
   - All `./.claude/rules/*.md`

4. **Conversation begins**
   - All context from above is available
   - Dynamic memory system starts learning

---

## Configuration Patterns

### Pattern 1: Critical Constitution File

**Problem**: Need project constitution to load before everything else

**Solution**: Use rules/ directory with `00-` prefix
```bash
~/.claude/rules/00-project-constitution.md
```

**Why**:
- Loads reliably (SessionStart hooks broken for new conversations)
- Files load alphabetically, so `00-` prefix ensures it loads first
- Zero context duplication
- No hook complexity

**Alternative** (once SessionStart bug is fixed):
```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "cat ~/.claude/instructions/00-project-constitution.md"
      }]
    }]
  }
}
```

### Pattern 2: Modular Rules

**Problem**: Many instruction files, want them all auto-loaded

**Solution**: Rules directory
```bash
~/.claude/rules/
├── interaction-patterns.md
├── context-management.md
├── task-management.md
├── planning-workflow.md
└── permission-patterns.md
```

**Why**: All files automatically load, no hooks needed, easy to add/remove

### Pattern 3: Conditional Loading

**Problem**: Load project-specific constitution only if it exists

**Solution**: SessionStart hook with conditional
```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "[ -f .specs/constitution.md ] && cat .specs/constitution.md || true"
      }]
    }]
  }
}
```

**Why**: Checks for file existence, loads if present, continues if not

### Pattern 4: All-Rules Approach (RECOMMENDED)

**Problem**: Multiple instruction files, all should auto-load reliably

**Solution**: Rules directory only (no hooks needed)
```
~/.claude/rules/
├── 00-project-constitution.md (loads first alphabetically)
├── interaction-patterns.md (auto-loaded)
├── context-management.md (auto-loaded)
├── task-management.md (auto-loaded)
└── planning-workflow.md (auto-loaded)
```

**Why**:
- No dependency on broken SessionStart hooks
- All files auto-load reliably
- `00-` prefix ensures constitution loads first
- Zero configuration needed
- Simple, maintainable structure

---

## Migration Guide

### From `.claude/instructions/` to Proper Auto-Loading

**Before** (not working):
```
~/.claude/
└── instructions/
    ├── file1.md
    ├── file2.md
    └── file3.md
```
❌ Nothing auto-loads

**After Option 1** - SessionStart Hook:
```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "cat ~/.claude/instructions/*.md"
      }]
    }]
  }
}
```
✓ All files load via hook

**After Option 2** - Rules Directory:
```bash
mv ~/.claude/instructions/*.md ~/.claude/rules/
```
✓ All files auto-load

**After Option 3** - Hybrid:
- Critical file stays in instructions/, loaded via SessionStart hook
- Other files move to rules/ for auto-loading

---

## Best Practices

### File Organization

**Do**:
- Use CLAUDE.md for project-specific guidelines
- Use rules/ for modular, reusable patterns
- Use SessionStart hooks for critical files that must load first
- Keep files focused (one topic per file)

**Don't**:
- Create custom directories expecting them to auto-load
- Put everything in one giant CLAUDE.md file
- Duplicate content across files
- Forget to test that hooks actually work

### Context Efficiency

**Remember**:
- Every auto-loaded file consumes context in EVERY session
- Keep files lean and focused
- Use cross-references instead of duplicating
- Regularly audit what's auto-loading

**Measure**:
```bash
# Check total auto-loaded content
cat ~/.claude/CLAUDE.md ~/.claude/rules/*.md | wc -l
```

**UserPromptSubmit Hook Efficiency Warning**:

If you inject the same file on every prompt using UserPromptSubmit hooks, context accumulates **quadratically**:

| Turn | Tokens Used | Waste |
|------|-------------|-------|
| 1    | 170         | 0     |
| 2    | 340         | 170   |
| 3    | 510         | 340   |
| 10   | 1,700       | 1,530 |
| 50   | 8,500       | 8,330 |

**Why**: Conversation history includes all previous turns, so the same content appears multiple times in context.

**Solution**: Use rules/ directory for static content (loaded once, available always, zero duplication)

### Testing

**Verify auto-loading works**:
1. Add content to CLAUDE.md or rules/
2. Exit and restart Claude Code
3. Ask "What are my coding standards?"
4. Verify new content is in context

**Test SessionStart hooks**:
1. Add hook to settings.local.json
2. Exit and restart Claude Code
3. Check if hook output appears in initial context
4. Debug with `echo "Hook fired"` if needed

---

## Troubleshooting

### Files Not Loading

**Symptom**: Added files to `.claude/instructions/` but they're not in context

**Cause**: Custom directories aren't auto-loaded

**Solution**: Move to rules/ or add SessionStart hook

### SessionStart Hook Not Firing

**Symptom**: Hook command in settings.json but no output

**Causes**:
1. **Known Bug (Issue #10373)**: SessionStart hooks don't inject context for new conversations (only work for `/clear`, `/compact`, resume)
2. JSON syntax error in settings file
3. File path doesn't exist
4. Command fails silently

**Solutions**:
1. **Best**: Move content to `~/.claude/rules/*.md` (bypasses hook entirely)
2. **Temporary**: Run `/clear` at session start to trigger hooks
3. **Debug**: Add echo statement to verify execution:
```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "echo 'Hook fired!' && cat ~/.claude/instructions/file.md"
      }]
    }]
  }
}
```

**References**:
- [GitHub Issue #10373](https://github.com/anthropics/claude-code/issues/10373) - Root cause identified with proposed fix

### Context Overload

**Symptom**: Auto-loading too much content, context fills quickly

**Solutions**:
1. Audit what's auto-loading: `cat ~/.claude/CLAUDE.md ~/.claude/rules/*.md | wc -l`
2. Remove rarely-used files from auto-load
3. Move detailed content to reference files, load on-demand
4. Use cross-references instead of full content

---

## Related Documentation

- [claude-code-usage.md](../workflows/claude-code-usage.md) - Complete Claude Code usage guide
- [context-efficiency.md](../instructions/context-efficiency.md) - Context management principles
- [claude-permissions.md](claude-permissions.md) - Permission configuration patterns

---

**Source**: Derived from official Claude Code documentation and real-world testing (January 2026)

**Last Updated**: 2026-01-28 - Verified auto-loading behavior, documented all mechanisms
