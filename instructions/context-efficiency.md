# Context Efficiency Guidelines

Principles and practices for managing AI development configuration to maximize value per token while minimizing redundancy.

---

## Directory Structure

**Conversation Context Directories** (loaded in AI conversations):
- `configs/` - Tool setup, quality gates, permissions
- `instructions/` - Development practices, patterns, coding principles
- `templates/` - Reusable templates and quick references
- `workflows/` - Step-by-step processes and command references

**Non-Context Directories** (repository documentation, not for conversation context):
- `web-context/` - Industry research and reference material for updating this repository
- `.global/` - System configuration
- `.claude/` - Claude Code system files

**Important**: When counting lines, checking for duplicates, or maintaining context efficiency, **exclude web-context/** as it contains research material for humans updating the repository, not for AI conversation context.

---

## The Problem

**Context is expensive**: Memory files are loaded in every conversation. Unnecessary content:
- Wastes tokens that could be used for actual work
- Slows down AI response time
- Reduces available context for complex tasks
- Makes files harder to navigate and maintain

**Duplication compounds**: Each duplicated piece of information multiplies the cost across all files and all sessions.

---

## Core Principles

### 1. Single Source of Truth (SPoT)

**Principle**: Each piece of information lives in exactly ONE authoritative location.

**Why**: Eliminates duplication, ensures consistency, reduces maintenance burden.

**Pattern**:
```
❌ BAD: Information repeated in multiple files
instructions/claude-code-memory.md:
  - Tool installation: npm, rclone, pandoc
  - Tool configs: ~/.config/rclone/rclone.conf

configs/tools.md:
  - Tool installation: npm, rclone, pandoc  [DUPLICATE]
  - Tool configs: ~/.config/rclone/rclone.conf  [DUPLICATE]

✓ GOOD: Information in one place, referenced elsewhere
configs/tools.md:
  - Tool installation: npm, rclone, pandoc
  - Tool configs: ~/.config/rclone/rclone.conf

instructions/claude-code-memory.md:
  - See configs/tools.md for tool setup
```

**How to Identify SPoT Violations**:
```bash
# Find potential duplicates (search conversation context only)
grep -r "same phrase" configs/ instructions/ templates/ workflows/
# If found in multiple files, consolidate to one
```

### 2. Cross-Reference Over Duplication

**Principle**: Link to existing information instead of repeating it.

**Why**: Achieves 60% token reduction vs typical projects.

**Pattern**:
```markdown
❌ BAD: Repeating content
# File: workflows/google-docs-setup.md
rclone is installed with: curl https://rclone.org/install.sh | sudo bash
Config location: ~/.config/rclone/rclone.conf
...

# File: configs/tools.md
rclone is installed with: curl https://rclone.org/install.sh | sudo bash
Config location: ~/.config/rclone/rclone.conf
...

✓ GOOD: Cross-reference
# File: workflows/google-docs-setup.md
See [configs/tools.md](../configs/tools.md) for rclone installation and configuration.

# File: configs/tools.md
[Full details about rclone here]
```

**Cross-Reference Format**:
```markdown
[Relative path](../path/to/file.md)  # Example - replace with actual file path
```

### 3. Progressive Disclosure

**Principle**: Organize information in layers from general to specific.

**Why**: Users find what they need quickly without reading everything.

**Hierarchy**:
```
1. Entry Point (README.md)
   └─ What exists, where to find it

2. Overview Files
   └─ High-level concepts, cross-references to details

3. Detail Files
   └─ Complete information on specific topics

4. Command Reference
   └─ Quick one-liners for execution
```

**Example**:
```
README.md:
  → "For Google Docs workflow, see workflows/google-docs-setup.md"

workflows/google-docs-setup.md:
  → "For rclone installation, see configs/tools.md"
  → "For rclone commands, see workflows/one-liners.md"

configs/tools.md:
  → [Complete rclone installation guide]

workflows/one-liners.md:
  → [rclone commands with examples]
```

### 4. Information Density

**Principle**: Maximize signal, minimize noise.

**Formula**:
```
Value = (Useful Information) / (Total Tokens)

High Value:  Essential patterns, reusable templates, critical principles
Medium Value: Examples, explanations, context
Low Value:   Obvious information, verbose prose, redundant examples
```

**Guidelines**:
- **Dense**: Principles, patterns, templates (high reuse)
- **Moderate**: Examples, rationale (aids understanding)
- **Sparse**: Obvious details, redundant explanations (low value)

**Example - High Density**:
```markdown
## Error Handling
- MUST use try-catch for async operations
- MUST log errors with context
- MUST transform API errors to consistent shape
```

**Example - Low Density** (avoid):
```markdown
## Error Handling
When you're writing code, it's really important to handle errors properly.
Errors can occur in many situations, such as when network requests fail,
or when users provide invalid input, or when... [continues for 20 lines]
```

### 5. Token Budget Awareness

**Principle**: Treat tokens like a limited resource (because they are).

**Reality**:
- Every line added consumes tokens in EVERY future session
- Context limits are real (200k tokens is generous but finite)
- More context = slower responses, higher costs

**Target Metrics**:
- **Total Lines**: 1,500-2,000 lines for complete project context
- **Average File**: 100-200 lines
- **Quick References**: 30-50 lines
- **Templates**: 50-100 lines
- **Comprehensive Docs**: 150-250 lines max

**Current Repository**:
- Total: ~7,000 lines (comprehensive patterns and templates)
- Achieves high context efficiency through cross-referencing

---

## Before Adding Content Checklist

**CRITICAL**: Run this checklist EVERY time before adding to memory files.

### 1. Does This Already Exist?
```bash
# Search existing files (exclude web-context research directory)
grep -r "concept or phrase" instructions/ configs/ workflows/ templates/
```

- [ ] If found: Reference it instead of duplicating
- [ ] If not found: Proceed to next check

### 2. Is This Universal or Project-Specific?
- [ ] **Universal** (applies across projects): Add to appropriate directory
- [ ] **Project-specific**: Keep in project files, NOT in memory

**Examples**:
- Universal: Error handling principles, TDD practices
- Project-specific: "LoginButton should call handleLogin on click"

### 3. Will This Be Used Multiple Times?
- [ ] **Used in multiple sessions**: Worth adding
- [ ] **One-off solution**: Don't add, solve inline

**Test**: "Will I need this information again in a future, unrelated task?"

### 4. Can This Be Found in Official Docs?
- [ ] **Yes**: Reference the official docs instead
- [ ] **No**: Consider adding if universal and frequently needed

**Examples**:
- Don't add: React API documentation (available at react.dev)
- Do add: Project-specific patterns for using React

### 5. Is This a Pattern or One-Off?
- [ ] **Pattern** (reusable across situations): Add
- [ ] **One-off solution** (specific to one scenario): Don't add

**Examples**:
- Pattern: "Always validate user input before API calls"
- One-off: "Fix bug in LoginForm.tsx line 42"

### 6. What's the Information Density?
- [ ] **High**: Essential, frequently used, high reuse
- [ ] **Medium**: Helpful examples, useful context
- [ ] **Low**: Verbose, redundant, obvious

Only add HIGH and MEDIUM density content.

---

## Where to Add New Content

### By Content Type

| Content Type | Location | Format | Max Lines |
|-------------|----------|--------|-----------|
| Core Principles | `instructions/coding-principles.md` | MUST/SHOULD statements | 150 |
| Daily Practices | `instructions/development-practices.md` | Guidelines, examples | 250 |
| Tool Setup | `configs/tools.md` | Installation, config locations | 200 |
| Commands | `workflows/one-liners.md` | Copy-paste commands | 200 |
| Workflows | `workflows/[name].md` | Step-by-step process | 100-150 |
| Patterns | `instructions/[topic]-patterns.md` | Reusable patterns | 150-250 |
| Templates | `templates/[name].md` | Fill-in-the-blank | 50-150 |
| Quick Refs | `templates/quick-reference/[name].md` | At-a-glance | 30-50 |
| User Prefs | `instructions/claude-code-memory.md` | Personality, preferences | 100 |

### Decision Tree

```
Is it about tools/setup?
  → configs/tools.md

Is it a quick command?
  → workflows/one-liners.md

Is it a step-by-step process?
  → workflows/[name].md

Is it a coding principle?
  → instructions/coding-principles.md

Is it a daily practice?
  → instructions/development-practices.md

Is it a reusable pattern?
  → instructions/[topic]-patterns.md or templates/

Is it a user preference?
  → instructions/claude-code-memory.md
```

---

## Consolidation Patterns

### When to Create a New File
Create new file when:
- Information doesn't fit existing categories
- Adding to existing file would exceed size limits (250 lines)
- Topic deserves dedicated focus (e.g., security patterns)

### When to Consolidate
Consolidate when:
- Same information repeated in 3+ places
- Related information scattered across files
- Pattern emerges from multiple one-off solutions

**Example**:
```
Before:
- claude-code-memory.md mentions rclone
- google-docs-setup.md explains rclone setup
- one-liners.md has rclone commands
- development-practices.md references rclone

After:
- configs/tools.md: Single authoritative rclone doc
- Other files: Cross-reference configs/tools.md
```

---

## Auto-Generation Patterns

### Pattern 1: File Catalog

**Generate** instead of manually maintaining:

```bash
#!/bin/bash
# update-catalog.sh

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

cat > README.md <<'EOF'
# File Catalog

EOF

# Search conversation context directories only (exclude web-context)
for dir in configs instructions templates workflows; do
  find "$dir" -type f -name "*.md" | while read file; do
    LINES=$(wc -l < "$file")
    SUMMARY=$(head -3 "$file" | grep -E "^[^#]" | head -1)
    echo "- [$file]($file): $LINES lines - $SUMMARY" >> README.md
  done
done
```

**Benefits**:
- Always accurate
- No manual maintenance
- Regenerate anytime

### Pattern 2: Cross-Reference Map

**Generate** visualization of file relationships:

```bash
#!/bin/bash
# map-references.sh

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Find all markdown links (exclude web-context research directory)
grep -r "\[.*\](.*\.md)" configs/ instructions/ templates/ workflows/ | \
  sed -E 's/.*\[([^\]]+)\]\(([^)]+)\).*/\1 → \2/' | \
  sort -u
```

### Pattern 3: Duplicate Detection

**Automated** check for duplication:

```bash
#!/bin/bash
# detect-duplicates.sh

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Find lines repeated in multiple files (exclude web-context)
for dir in configs instructions templates workflows; do
  find "$dir" -name "*.md" -exec cat {} \;
done | awk 'length($0) > 50' | sort | uniq -d
```

---

## Maintenance Workflow

### Weekly Review
1. **Check for duplicates**: Run duplicate detection script
2. **Verify cross-references**: Ensure all links are valid
3. **Review recent additions**: Are they still needed? Can they be consolidated?
4. **Check file sizes**: Any files exceeding size limits?

### Monthly Audit
1. **Measure total context size**: `find configs/ instructions/ templates/ workflows/ -name "*.md" | xargs wc -l | tail -1`
2. **Identify low-value content**: What hasn't been used in 3 months?
3. **Consolidate**: Any patterns that emerged from multiple files?
4. **Update README**: Reflect current structure

---

## Metrics and Targets

### Recommended Metrics

**Small Project** (Simple patterns):
- Total lines: ~1,000-1,500
- Files: 8-12
- Average file size: ~100 lines

**Medium Project** (Comprehensive patterns):
- Total lines: ~2,000-3,000
- Files: 15-25
- Average file size: ~100-150 lines

**Large Project** (Full AI development workflow):
- Total lines: ~3,000-5,000
- Files: 25-40
- Average file size: ~100-200 lines

**Efficiency Target**:
- Achieve 60% reduction vs typical project documentation
- Cross-reference instead of duplicate
- Maintain comprehensive coverage with minimal redundancy

### Success Metrics

**Context Efficiency**:
- **Target**: 60% reduction vs typical project documentation
- **Measure**: Compare to project with similar scope but traditional docs

**Discoverability**:
- **Target**: Find any information within 2 file hops from README
- **Measure**: README → Topic file → Specific info

**Reusability**:
- **Target**: 80% of memory files referenced in multiple sessions
- **Measure**: Track file usage over time

---

## Anti-Patterns

### ❌ Copy-Paste Documentation
**Problem**: Copying content from one file to another.
**Fix**: Cross-reference instead.

### ❌ Documenting Everything
**Problem**: Adding every detail "just in case".
**Fix**: Only add what's universally applicable and frequently used.

### ❌ Verbose Explanations
**Problem**: Long-winded explanations of obvious concepts.
**Fix**: Dense, actionable content. Link to external docs for depth.

### ❌ One-Off Solutions in Memory
**Problem**: Adding specific bug fixes or one-time solutions.
**Fix**: Keep one-offs in project history, patterns in memory.

### ❌ Ignoring File Size
**Problem**: Files grow to 500+ lines.
**Fix**: Split into focused files, use cross-references.

---

## Examples

### Example 1: Good Context Efficiency

**Structure**:
```
README.md (150 lines)
  ├─ High-level catalog
  └─ Links to all files

configs/tools.md (155 lines)
  ├─ All tool setup in one place
  └─ Referenced by workflow files

workflows/one-liners.md (185 lines)
  ├─ All commands in one place
  └─ Referenced by workflow and config files

instructions/ (4 files, ~350 lines total)
  └─ Each file < 250 lines, cross-referenced

Total: ~1,000 lines for complete context
```

**Efficiency**: Every line earns its place through frequent reuse.

### Example 2: Poor Context Efficiency

**Structure**:
```
README.md (500 lines)
  ├─ Repeats all tool setup
  ├─ Repeats all commands
  └─ Repeats all principles

Each file duplicates content from others
Total: 3,000 lines with 60% duplication

Effective context: 1,200 lines
Wasted tokens: 1,800 lines (60%)
```

**Problem**: Same information repeated everywhere.

---

## Tools and Scripts

### Useful Commands

```bash
# Count total lines in conversation context (exclude web-context)
find configs/ instructions/ templates/ workflows/ -name "*.md" | xargs wc -l | tail -1

# Find duplicated content (lines > 50 chars appearing in multiple files)
for dir in configs instructions templates workflows; do
  find "$dir" -name "*.md" -exec cat {} \;
done | awk 'length($0) > 50' | sort | uniq -d

# Check file sizes
find configs/ instructions/ templates/ workflows/ -name "*.md" -exec wc -l {} \; | sort -n

# Find broken cross-references (within conversation context)
REPO_ROOT=$(git rev-parse --show-toplevel)
for dir in configs instructions templates workflows; do
  grep -r "\](.*\.md)" "$dir/"
done | sed -E 's/.*\]\(([^)]+)\).*/\1/' | while read link; do
  [ -f "$REPO_ROOT/$link" ] || echo "Broken: $link"
done
```

---

**Related Documentation**:
- [claude-code-memory.md](claude-code-memory.md) - User memory and preferences
- [development-practices.md](development-practices.md) - Documentation practices
- [README.md](../README.md) - Hub-and-spoke catalog structure

**Version**: 1.1.0 | **Created**: 2026-01-16 | **Updated**: 2026-01-21

**Key Takeaway**: Every line in conversation context files should earn its place through frequent reuse across multiple sessions. When in doubt, reference instead of duplicate. Exclude web-context/ from context management as it contains research material for repository maintenance.
