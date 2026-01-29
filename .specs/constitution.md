# Repository Constitution

**Purpose**: Define immutable principles and constraints that govern all decisions, patterns, and practices in this repository.

**Scope**: This constitution applies to all content, workflows, and tooling documented in `~/.ai`

**Authority**: This file is the supreme authority. When conflicts arise, constitution takes precedence over all other documentation.

---

## Core Values

These values define the repository's identity and guide all decisions:

### 1. Context Efficiency

**Principle**: Every line must justify its context cost.

**Rationale**: Memory files are loaded in every AI session. Wasted tokens reduce capacity for actual work.

**Application**:
- Maximize signal-to-noise ratio
- Use tables for structured data
- Avoid verbose explanations
- Cross-reference instead of duplicate

### 2. Single Source of Truth (SSoT)

**Principle**: Each concept documented in exactly ONE authoritative location.

**Rationale**: Duplication creates maintenance burden and context waste. Changes must be made in multiple places, leading to inconsistencies.

**Application**:
- One file owns each concept
- Other files cross-reference the owner
- Hub-and-spoke architecture (README → detail files)
- Never copy-paste between files

### 3. AI-First Design

**Principle**: Optimize for AI consumption, not human browsing.

**Rationale**: This repository exists to provide context to AI agents. Human readability is secondary.

**Application**:
- Structured formats (tables, lists, decision trees)
- Clear section headers for navigation
- Explicit cross-references with file paths
- Progressive disclosure (summary → details)

### 4. Evidence-Based

**Principle**: Require proof, prevent assumptions.

**Rationale**: AI agents must verify before acting. Assumptions lead to errors.

**Application**:
- Read files before editing
- Verify paths exist before referencing
- Run validation scripts before committing
- Document sources for research content

### 5. Progressive Disclosure

**Principle**: Summary first, details on demand.

**Rationale**: Not all sessions need all details. Provide overview with links to deep dives.

**Application**:
- Hub files (README, pattern hubs) provide summaries
- Detail files contain implementation specifics
- Cross-references enable drilling down
- Related Documentation sections at file end

---

## Immutable Constraints

These constraints are ABSOLUTE and NEVER negotiable:

### Documentation Constraints

1. **NEVER duplicate content**: Use cross-references to maintain Single Source of Truth
2. **ALWAYS update README.md**: File Catalog must reflect current repository state
3. **ALWAYS verify cross-references**: Run `scripts/verify-cross-references.sh` before committing
4. **NEVER exceed 550 lines per file**: Split large files using hub-and-spoke pattern
5. **NEVER add version footers**: Git handles versioning and change history
6. **NEVER add line number tracking**: Use git blame for change attribution

### Quality Constraints

7. **ALWAYS run validation scripts**: Both structure and cross-reference validation must pass
8. **ALWAYS use 3-hyphen section dividers**: Standard is `---`, not 4+ hyphens
9. **ALWAYS document in markdown**: No proprietary formats, ensure longevity
10. **ALWAYS include Related Documentation**: Every file links to related content

### Architectural Constraints

11. **ALWAYS maintain hub-and-spoke**: README is universal entry point
12. **ALWAYS use relative paths**: Enable repository portability
13. **ALWAYS preserve directory structure**: Established patterns provide discoverability
14. **NEVER create circular references**: Enforce clear hierarchy

---

## Quality Thresholds

Non-negotiable standards that must be met:

### File Structure

- **Hub-and-spoke architecture**: README → category READMEs → detail files
- **Maximum file length**: 550 lines (forces proper decomposition)
- **Minimum file purpose**: Each file serves distinct, documented purpose
- **Cross-reference validity**: Zero broken links tolerated

### Documentation Quality

- **Validation scripts pass**: `validate-structure.sh` and `verify-cross-references.sh` both exit 0
- **Catalog completeness**: All files/directories documented in README
- **Single Source of Truth**: No duplicated content across files
- **Context efficiency**: High signal-to-noise ratio

### Code Examples

- **Accuracy**: All commands, configurations, code snippets must be correct
- **Generalization**: Use technology-agnostic examples where possible
- **Attribution**: Note when examples are technology-specific

---

## Decision Hierarchy

When conflicts arise, follow this priority order:

1. **Constitution** (this file) - Immutable principles
2. **Patterns** (`templates/patterns/`) - Reusable approaches
3. **Instructions** (`instructions/`) - Development practices and principles
4. **Workflows** (`workflows/`) - Specific processes and step-by-step guides
5. **Configs** (`configs/`) - Tool settings and permissions

**Example**: If a workflow suggests duplicating content but patterns enforce DRY, the pattern wins. If a pattern contradicts an immutable constraint, the constraint wins.

---

## Architectural Principles

### Hub-and-Spoke Architecture

**Pattern**: Single entry point (README) that branches to category hubs, which branch to detail files.

**Benefits**:
- Discoverability: Everything findable from README
- Scalability: Add detail files without cluttering hub
- Context control: Load only needed detail files

**Implementation**:
```
README.md (entry point)
  ├─→ instructions/README.md (hub)
  │    ├─→ coding-principles.md (detail)
  │    └─→ development-practices.md (detail)
  ├─→ workflows/README.md (hub)
  └─→ templates/README.md (hub)
```

### Layered Information Design

**Pattern**: Three layers of information density:

1. **Hub Files** (README): 1-line descriptions, link to detail
2. **Category Hubs**: Summaries with purpose, link to implementation
3. **Detail Files**: Full implementation, examples, edge cases

**Purpose**: AI agents can stop at appropriate depth for task at hand.

### Cross-Reference Protocol

**Pattern**: Always use relative paths from current file location.

**Format**: `[Description](../path/to/file.md)` or `[Description](./file.md)`

**Rationale**: Repository portability, enables validation scripts

---

## Security Baseline

### Credential Management

- **NEVER commit credentials**: No API keys, tokens, passwords in files
- **NEVER hardcode paths with usernames**: Use `~/` or `$HOME`
- **ALWAYS use safe directory references**: Document permissions needed

### Example Safety

- **NEVER include destructive commands without warnings**: Flag `rm -rf`, `git reset --hard`
- **ALWAYS validate user input in examples**: Demonstrate input validation patterns
- **ALWAYS consider OWASP Top 10**: Security awareness in all code examples

### Permission Model

- **Ask before destructive operations**: Git force push, file deletion, system changes
- **Auto-approve safe operations**: File reads, searches, validation scripts
- **Document permission requirements**: Explicit in configs/claude-permissions.md

---

## Change Management

### Adding New Content

**Before creating new file**:
1. Does this exist elsewhere? → Cross-reference instead
2. Does this belong in existing file? → Add section instead
3. Is this generic enough for templates/? → Create template
4. Does this repeat patterns? → Abstract to pattern file

**After creating new file**:
1. Update README File Catalog
2. Add cross-references from related files
3. Add "Related Documentation" section to new file
4. Run validation scripts
5. Update relevant hub files

### Modifying Existing Content

**Process**:
1. Read current content first
2. Verify no duplication being created
3. Update cross-references if file purpose changes
4. Run validation scripts
5. Update README if file description changes

### Removing Content

**Process**:
1. Search for cross-references to file being removed
2. Update or remove those references
3. Remove from README File Catalog
4. Run validation scripts to catch broken links
5. Commit with clear rationale for removal

---

## File Organization Standards

### Directory Structure

Established directories serve specific purposes:

- **configs/**: Tool configuration, permissions, quality gates
- **instructions/**: Development practices, patterns, principles
- **workflows/**: Step-by-step processes, command sequences
- **templates/**: Reusable templates and quick references
- **patterns/**: Detailed pattern implementations (organized by category)
- **guides/**: Step-by-step guides split from workflows for progressive disclosure
- **scripts/**: Validation and verification scripts
- **web-context/**: External research and references (exempt from 550-line limit)
- **.specs/**: Repository specifications (constitution, requirements)

### Naming Conventions

- **Kebab-case**: `multi-agent-orchestration.md`, not `MultiAgentOrchestration.md`
- **Descriptive**: `code-review-patterns.md`, not `patterns.md`
- **Consistent suffixes**: `-agent.md` for agents, `-patterns.md` for pattern files

---

## Success Criteria

This repository succeeds when:

1. **AI Efficiency**: Claude Code sessions find needed context in <3 file reads
2. **Maintainability**: Changes localized to single files (no cascading edits)
3. **Discoverability**: All content findable from README within 2 clicks
4. **Quality**: Validation scripts always pass
5. **Usefulness**: Patterns are actually used in real projects
6. **Clarity**: Minimal questions about "where does X go?"

---

## Enforcement

### Automated Validation

**Pre-commit checks** (recommended):
```bash
#!/bin/bash
# .git/hooks/pre-commit
./scripts/validate-structure.sh
./scripts/verify-cross-references.sh
```

### Manual Review

**Before committing**:
- [ ] README updated if files added/removed
- [ ] Cross-references verified
- [ ] No duplication introduced
- [ ] Validation scripts pass
- [ ] File under 550 lines (or has splitting plan)

### Continuous Improvement

**Periodic review** (monthly/quarterly):
- Identify duplicated content → consolidate
- Find missing cross-references → add them
- Detect documentation drift → update
- Measure against success criteria → adjust

---

## Related Documentation

- [../README.md](../README.md) - Repository entry point and file catalog
- [../instructions/context-efficiency.md](../instructions/context-efficiency.md) - Context management principles
- [../instructions/development-practices.md](../instructions/development-practices.md) - Daily development practices
- [../configs/quality-gates.md](../configs/quality-gates.md) - Validation patterns and quality standards
- [../workflows/specification-driven-development.md](../workflows/specification-driven-development.md) - SDD methodology and constitution role
