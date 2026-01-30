# Development Practices Guide

Critical daily practices that aren't covered in other pattern files. For comprehensive coverage see:
- [coding-principles.md](coding-principles.md) - Testing strategies, error handling, type safety, quality gates
- [workflows/code-review-patterns.md](../workflows/code-review-patterns.md) - Code review automation and patterns
- [workflows/script-patterns.md](../workflows/script-patterns.md) - Safe automation patterns
- [rules/context-efficiency.md](context-efficiency.md) - Documentation efficiency

---

## Git & Version Control

### Commit Message Guidelines

**Structure** (1-3 paragraphs maximum):
- **First paragraph**: Summary of what changed (50-72 characters ideal)
- **Second paragraph** (optional): Why it changed and context
- **Third paragraph** (optional): Impact, related items, or notes

**Format**:
- Use prose, not bullet-point lists
- For extensive details, put them in documentation instead
- Focus on why, not what (code shows what)

**Examples**:

```
Good:
Fix authentication timeout on slow connections

Users on slower networks were experiencing session timeouts during
the OAuth flow. This extends the timeout from 5s to 30s and adds
retry logic with exponential backoff.

Fixes issue #123. Tested on 3G and satellite connections.
```

```
Bad:
- Fixed timeout
- Added retry
- Updated tests
- Changed config
```

**Commit Practices**:
- Small, focused commits over monolithic changes
- Single responsibility per commit when possible
- Perform periodic status checks during development
- Ask about creating smaller commits when changes become large/varied

**Branch Management**:
- Always track the appropriate base branch when creating feature branches
- Use descriptive branch names that reference the work being done
- Ask about branch strategy if unclear

**Rationale**: Small, focused commits with prose descriptions create clear history that's easy to review, revert, and understand.

---

## Destructive Command Safety

**CRITICAL**: Never run potentially destructive commands without first creating a backup or ensuring the user is aware of the risk.

### Commands Requiring Backup or Explicit Warning

| Command | Risk | Mitigation |
|---------|------|------------|
| `rsync` (without `--backup`) | Overwrites files | Use `--backup --suffix=.bak` |
| `rm` / `rm -rf` | Permanent deletion | `cp -r target target.backup` first |
| `mv` (to existing file) | Overwrites destination | `mv target target.old` first |
| `git reset --hard` | Discards uncommitted changes | `git stash` instead |
| `git push --force` | Rewrites remote history | Warn user explicitly |
| `git clean -fd` | Deletes untracked files | `git clean -n` to preview |
| `truncate` / `> file` | Erases file contents | Backup first |
| Database operations | Data loss | `DELETE` / `DROP` / `TRUNCATE` require confirmation |

### Required Actions Before Destructive Operations

**1. Create backup when possible:**
```bash
# Before rsync
rsync --backup --suffix=.bak source/ dest/

# Before rm
cp -r directory directory.backup

# Before potentially destructive edit
cp important-file.txt important-file.txt.backup
```

**2. If backup not possible, warn the user explicitly:**
- Describe exactly what will be lost
- Ask for explicit confirmation
- Suggest safer alternatives if they exist

**3. Verify current state first:**
```bash
# Before rm
ls -la target-directory/

# Before git reset --hard
git status
git diff
```

### Safe Alternatives

| Instead of | Use | Why |
|------------|-----|-----|
| `git reset --hard` | `git stash` | Preserves changes |
| `git reset` (on pushed) | `git revert` | Preserves history |
| `mv file target` | `mv target target.old && mv file target` | Keeps backup |
| Command | Command `--dry-run` | Preview changes |

**Rationale**: Data loss is often irrecoverable. Taking a few seconds to create a backup or warn the user can prevent hours or days of lost work.

**For additional safe patterns, see:**
- [workflows/one-liners.md](../workflows/one-liners.md) - Safe command examples
- [workflows/script-patterns.md](../workflows/script-patterns.md) - Atomic operations, fail-fast patterns

---

## Reference Information Priority

When researching solutions or learning new technologies, prioritize sources in this order:

1. **Official documentation** - Framework, library, or language docs
   - Most accurate and up-to-date
   - Canonical API reference

2. **MDN Web Docs** - For web technologies (HTML, CSS, JavaScript, Web APIs)
   - Comprehensive and well-maintained
   - Cross-browser compatibility info

3. **StackOverflow** - Accepted or highly voted answers
   - Real-world solutions
   - Verify dates (older answers may be outdated)

4. **Vetted community forums** - Language/framework specific (Reddit r/rust, Elixir Forum, etc.)
   - Current best practices
   - Community consensus

5. **Trusted technical blogs** - Known experts and established publications
   - In-depth explanations
   - Verify author credentials

6. **Everything else** - Use with caution and cross-reference
   - May be outdated or incorrect
   - Always verify with official sources

**Rationale**: Official sources provide accurate, up-to-date information. Community sources require validation but can provide practical insights. Starting with high-quality sources saves debugging time.

---

## Related Documentation

- [coding-principles.md](coding-principles.md) - Error handling, testing strategies, type safety, security, quality gates
- [context-efficiency.md](context-efficiency.md) - Documentation patterns, single source of truth
- [workflows/code-review-patterns.md](../workflows/code-review-patterns.md) - Automated code review, quality gates
- [workflows/script-patterns.md](../workflows/script-patterns.md) - Safe automation, atomic operations
- [workflows/one-liners.md](../workflows/one-liners.md) - Command reference

