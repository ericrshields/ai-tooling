# AI Development Configuration - Universal Catalog

**Purpose**: Hub-and-spoke entry point for AI-assisted development patterns, workflows, and configurations.

---

## Quick Start

### New Machine Setup
1. Review [configs/tools.md](configs/tools.md) - Install required tools
2. Apply [configs/claude-permissions.json](configs/claude-permissions.json) - Set up permissions (see [claude-permissions.md](configs/claude-permissions.md))
3. Read [configs/claude-code-auto-loading.md](configs/claude-code-auto-loading.md) - Configure auto-loading (CLAUDE.md, rules/, hooks)
4. Read [rules/claude-code-memory.md](rules/claude-code-memory.md) - Configure preferences

### Understanding AI Architecture
1. Review [rules/multi-agent-orchestration.md](rules/multi-agent-orchestration.md) - Framework comparison
2. Read [rules/agent-memory-patterns.md](rules/agent-memory-patterns.md) - Memory management
3. Check [rules/self-correction-patterns.md](rules/self-correction-patterns.md) - Error recovery

### Starting a New Task
1. Review [rules/coding-principles.md](rules/coding-principles.md) - Testing strategies, error handling, quality gates
2. Check [rules/development-practices.md](rules/development-practices.md) - Git commit format, destructive command safety
3. Use [workflows/one-liners.md](workflows/one-liners.md) - Command reference

### Building with AI
1. Start with [workflows/specification-driven-development.md](workflows/specification-driven-development.md) - Define what to build
2. Follow [workflows/tdd-development.md](workflows/tdd-development.md) - Build with quality
3. Use [workflows/code-review-patterns.md](workflows/code-review-patterns.md) - Validate before deployment

---

## File Catalog

### Specifications (.specs/)

Repository governance and principles (follows Spec-Driven Development pattern).

| File | Purpose |
|------|---------|
| [constitution.md](.specs/constitution.md) | **Repository Constitution**: Immutable principles, core values, quality thresholds, decision hierarchy, architectural principles |

### Configs (configs/)

Configuration files and permission systems.

| File | Purpose |
|------|---------|
| [claude-permissions.json](configs/claude-permissions.json) | 3-tier permissions with hooks: allow (auto), ask (approve), deny (blocked) |
| [claude-permissions.md](configs/claude-permissions.md) | Permissions documentation, tiers, hooks system, installation, customization |
| [claude-allowed-prompts.md](configs/claude-allowed-prompts.md) | Plan mode semantic permissions, intent-based matching, best practices |
| [claude-code-auto-loading.md](configs/claude-code-auto-loading.md) | **Auto-loading mechanisms**: CLAUDE.md files, rules/ directory, SessionStart hooks, migration guide, troubleshooting |
| [mcp-integration-patterns.md](configs/mcp-integration-patterns.md) | MCP usage patterns: scopes (user/local/project), Todoist, GitHub, Google Drive integrations |
| [mcp-servers/service-integrations.md](configs/mcp-servers/service-integrations.md) | Detailed MCP service integration examples: Todoist, GitHub, Google Drive, Slack, Filesystem |
| [tools.md](configs/tools.md) | Tool reference (Claude Code, rclone, pandoc, gh, jq) with installation patterns |
| [claude-permissions-future-consideration.json](configs/claude-permissions-future-consideration.json) | Permission decisions and workflow rationale |

### Rules (rules/)

Agent architecture, coordination, and development principles.

| File | Purpose |
|------|---------|
| [multi-agent-orchestration.md](rules/multi-agent-orchestration.md) | **Web Research**: Framework comparison (LangGraph, CrewAI, AutoGen), Google's 8 design patterns, state management, benchmarks |
| [observability-patterns.md](rules/observability-patterns.md) | **Web Research**: Traces/spans/evals, HITL patterns, leading platforms, risk-based routing, regulatory compliance |
| [self-correction-patterns.md](rules/self-correction-patterns.md) | **Web Research**: Two-layer architecture, monitoring signals, intervention strategies, error recovery, self-healing |
| [context-efficiency.md](rules/context-efficiency.md) | Context management: Single Source of Truth, cross-references, token budget, before-adding checklist |
| [development-practices.md](rules/development-practices.md) | **Unique practices**: Git commit guidelines (prose format), destructive command safety, reference priority order |
| [agent-memory-patterns.md](rules/agent-memory-patterns.md) | **Web Research**: Memory taxonomy (Factual/Experiential/Working), lifecycle management, context anti-patterns |
| [ai-tooling-duplication-detector-agent.md](rules/ai-tooling-duplication-detector-agent.md) | **Agent Definition**: Detects duplication in AI instruction files/configs; validates DRY, modular architecture, token efficiency; 4-block structure validation |
| [documentation-reviewer-agent.md](rules/documentation-reviewer-agent.md) | **Agent Definition**: Validates documentation quality, structure, DRY compliance; suggests related agents (writer, indexer, consolidator, analyzer, example-validator) |
| [plan-reviewer-agent.md](rules/plan-reviewer-agent.md) | **Agent Definition**: Validates implementation plans for accuracy, efficiency, completeness, security; suggests related agents (optimizer, estimator, architecture-validator, security-reviewer) |
| [coding-principles.md](rules/coding-principles.md) | **Testing strategies reference**: TDD, BDD, ATDD, test-after, hybrid approaches with 2026 research; Error handling, type safety, security, quality gates |
| [claude-code-memory.md](rules/claude-code-memory.md) | User preferences, personality settings, memory management guidelines |

### Workflows (workflows/)

Practical development workflow patterns and command references.

| File | Purpose |
|------|---------|
| [claude-code-usage.md](workflows/claude-code-usage.md) | Claude Code CLI patterns: context management, memory system, permissions, conversation lifecycle |
| [code-review-patterns.md](workflows/code-review-patterns.md) | **Web Research**: Prompt engineering, multi-dimensional parallel review, AI-on-AI patterns, quality gates, CI/CD integration |
| [script-patterns.md](workflows/script-patterns.md) | Bash automation patterns: fail-fast, atomic updates, safe operations, timeouts, polling |
| [tdd-development.md](workflows/tdd-development.md) | **Web Research**: TDD with LLMs, chunked workflows, AI evals, test generation, testing pyramid |
| [automated-development-workflow.md](workflows/automated-development-workflow.md) | **Vision**: 8-phase automated workflow (analysis → TDD → implementation → multi-dimensional review → PR → merge) |
| [one-liners.md](workflows/one-liners.md) | Quick command reference for all tools (version checks, rclone, pandoc, gh, git, jq) |
| [specification-driven-development.md](workflows/specification-driven-development.md) | **Web Research**: SDD methodology, GitHub Spec Kit workflow, living documentation |
| [google-docs-setup.md](workflows/google-docs-setup.md) | Google Docs integration via rclone + pandoc (download, convert, edit workflow) |

### Templates (templates/)

Reusable templates for agent instructions, component specs, and quick references.

| File | Purpose |
|------|---------|
| [agent-instruction-patterns.md](templates/agent-instruction-patterns.md) | Hub for 9 reusable agent instruction patterns: Supreme Constraints, Path Resolution, Evidence-Based, etc. |
| [workflow-automation-pattern.md](templates/workflow-automation-pattern.md) | Hub for phase-based workflow patterns with entry/exit criteria and validation gates |
| [frontend-component-spec.md](templates/frontend-component-spec.md) | Component specification template: user stories, API, state, accessibility, success criteria |
| [patterns/constraints-and-boundaries.md](templates/patterns/constraints-and-boundaries.md) | Agent constraint patterns: Supreme Constraints, Path Resolution, Boundaries, Instruction Density, RFC 2119 markers |
| [patterns/verification-and-output.md](templates/patterns/verification-and-output.md) | Agent verification patterns: Evidence-Based, Decision Tables, Autonomy Rules, Output Formatting, Progress Reporting |
| [quick-reference/agent-definition.md](templates/quick-reference/agent-definition.md) | Quick fill-in template for defining AI agents |
| [quick-reference/component-spec.md](templates/quick-reference/component-spec.md) | One-page component spec template |
| [quick-reference/quality-gate.md](templates/quick-reference/quality-gate.md) | Quick template for validation scripts |
| [quick-reference/decision-table.md](templates/quick-reference/decision-table.md) | Quick template for error handling decision tables |

### Patterns (patterns/)

Detailed implementation patterns split from hub files for focused reference.

| Directory | Purpose |
|-----------|---------|
| [code-review/](patterns/code-review/) | Code review patterns: prompt engineering, parallel review, CI/CD integration |
| [orchestration/](patterns/orchestration/) | Multi-agent orchestration: Google's 8 patterns, state management |
| [observability/](patterns/observability/) | Observability patterns: monitoring, HITL, challenges and solutions |
| [self-correction/](patterns/self-correction/) | Self-correction patterns: monitoring signals, intervention strategies |

### Guides (guides/)

Step-by-step guides split from workflow files for progressive disclosure.

| Directory | Purpose |
|-----------|---------|
| [scripting/](guides/scripting/) | Bash scripting guides: error handling, safe operations |
| [automation/](guides/automation/) | Automation guides: phase-based workflows, technology examples |

### Scripts (scripts/)

Validation and verification scripts for maintaining repository quality.

| File | Purpose |
|------|---------|
| [validate-structure.sh](scripts/validate-structure.sh) | Validates file lengths (<550 lines), checks for version footers, verifies section divider consistency |
| [verify-cross-references.sh](scripts/verify-cross-references.sh) | Verifies all markdown cross-references point to existing files, reports broken links |

---

## File Relationships

```
README.md (YOU ARE HERE)
    ├── Quick Start
    │   ├─→ configs/tools.md (tool installation)
    │   ├─→ configs/claude-permissions.json (permission setup)
    │   └─→ rules/claude-code-memory.md (preferences)
    │
    ├── AI Agent Architecture
    │   ├─→ rules/multi-agent-orchestration.md (framework selection)
    │   │   └─→ rules/agent-memory-patterns.md (state management)
    │   ├─→ rules/self-correction-patterns.md (error recovery)
    │   └─→ rules/observability-patterns.md (monitoring)
    │       └─→ rules/self-correction-patterns.md (HITL integration)
    │
    ├── Core Principles
    │   ├─→ .specs/constitution.md (repository governance)
    │   ├─→ rules/coding-principles.md (universal principles)
    │   ├─→ rules/development-practices.md (daily practices)
    │   └─→ rules/context-efficiency.md (documentation patterns)
    │
    └── Development Workflows
        ├─→ workflows/specification-driven-development.md
        │   └─→ workflows/tdd-development.md (implementation with tests)
        ├─→ workflows/tdd-development.md
        │   └─→ workflows/code-review-patterns.md (quality gates)
        ├─→ workflows/code-review-patterns.md
        │   └─→ rules/observability-patterns.md (CI/CD integration)
        ├─→ workflows/google-docs-setup.md
        │   ├─→ configs/tools.md (rclone + pandoc setup)
        │   └─→ workflows/one-liners.md (commands)
        ├─→ workflows/script-patterns.md (bash automation)
        └─→ workflows/one-liners.md (command SPoT)
```

---

## Information Architecture

### Single Source of Truth (SPoT)

Each type of information has ONE authoritative location:

**Agent Architecture**:
- **Framework selection**: `rules/multi-agent-orchestration.md`
- **Memory management**: `rules/agent-memory-patterns.md`
- **Error recovery**: `rules/self-correction-patterns.md`
- **Monitoring**: `rules/observability-patterns.md`

**Development Practices**:
- **Core principles**: `rules/coding-principles.md`
- **Daily practices**: `rules/development-practices.md`
- **Context efficiency**: `rules/context-efficiency.md`

**Workflows**:
- **Code review**: `workflows/code-review-patterns.md`
- **TDD patterns**: `workflows/tdd-development.md`
- **SDD workflow**: `workflows/specification-driven-development.md`
- **Bash automation**: `workflows/script-patterns.md`
- **Commands**: `workflows/one-liners.md`

**Configuration**:
- **Permissions**: `configs/claude-permissions.md`
- **MCP integration**: `configs/mcp-integration-patterns.md`
- **Tools**: `configs/tools.md`
- **User preferences**: `rules/claude-code-memory.md`

### Cross-Reference Pattern

Files reference each other instead of duplicating:
- Example: `code-review-patterns.md` references `observability-patterns.md` for CI/CD monitoring
- Example: `google-docs-setup.md` references `tools.md` for rclone setup
- Example: `multi-agent-orchestration.md` references `agent-memory-patterns.md` for state management
- Benefit: Each pattern documented once, referenced many times

### Progressive Disclosure

1. **Entry point** (README.md) - Navigate to what you need
2. **Pattern files** - Complete patterns with examples and sources
3. **Cross-references** - Related patterns and deeper dives
4. **Web research** (web-context/) - Original research synthesis

---

## Usage Guidelines

### When to Read Which File

**Starting a new AI project:**
1. `rules/multi-agent-orchestration.md` - Choose framework (LangGraph, CrewAI, AutoGen)
2. `workflows/specification-driven-development.md` - Define what to build
3. `workflows/tdd-development.md` - Build with quality
4. `workflows/code-review-patterns.md` - Quality gates

**Production deployment:**
1. `rules/observability-patterns.md` - Set up monitoring
2. `configs/claude-permissions.md` - Configure human oversight
3. `rules/self-correction-patterns.md` - Enable autonomous recovery

**Starting a new task:**
1. `rules/coding-principles.md` - Testing strategies, error handling, security principles
2. `rules/development-practices.md` - Git commit guidelines, destructive command safety
3. `workflows/one-liners.md` - Commands you'll need

**Tool configuration:**
1. `configs/tools.md` - Which tools and how to install
2. `workflows/claude-code-usage.md` - Claude Code context management and workflow
3. `configs/mcp-integration-patterns.md` - MCP server setup
4. `workflows/one-liners.md` - Commands for that tool

**Optimizing existing system:**
1. `rules/agent-memory-patterns.md` - Improve context efficiency
2. `rules/self-correction-patterns.md` - Add error recovery
3. `workflows/code-review-patterns.md` - Enhance quality gates
4. `rules/context-efficiency.md` - Documentation patterns

**Troubleshooting issues:**
1. `rules/observability-patterns.md` - Use traces to diagnose
2. `rules/self-correction-patterns.md` - Implement recovery strategies
3. `workflows/code-review-patterns.md` - Analyze quality gaps

### Adding New Content

**CRITICAL - Context Efficiency Checklist:**

Before adding content to any memory file:
1. Does this information already exist elsewhere? → Reference it instead
2. Is this universal or project-specific? → Universal goes here, project-specific stays in project
3. Will this be used in multiple future sessions? → If not, don't add it
4. Can this be found in official docs? → Reference the docs instead
5. Is this a pattern or a one-off solution? → Only patterns belong in memory

**Token Budget**: Every line added consumes context in every future session. Make it count.

**Where to add new content:**
- **AI agent patterns**: `rules/multi-agent-orchestration.md` or `rules/self-correction-patterns.md`
- **Testing strategies**: `rules/coding-principles.md` (testing approaches, quality standards)
- **Git/safety practices**: `rules/development-practices.md` (commit format, destructive commands)
- **Tool setup**: `configs/tools.md` or `configs/mcp-integration-patterns.md`
- **Commands**: `workflows/one-liners.md`
- **Workflow**: New file in `workflows/` (e.g., `workflows/docker-workflow.md`)
- **Templates**: New file in `templates/` or `templates/quick-reference/`
- **Preferences**: `rules/claude-code-memory.md`

---

## Maintenance

### CRITICAL: Keep Index Files Current

**ALWAYS update README.md when making repository changes:**
- Adding new files or directories → Update File Catalog section
- Removing files → Remove from File Catalog
- Reorganizing structure → Update File Relationships diagram
- Adding new patterns → Update relevant section and cross-references
- Changing file purposes → Update file descriptions

**The README is the entry point for all AI sessions. Outdated README = wasted context and confusion.**

### Version Control

- **Version all files** except sensitive configs (API keys, OAuth tokens in ~/.claude.json)
- **Commit changes** when updating patterns or adding workflows
- **Keep DRY**: Remove duplicated content, use cross-references

### Quality Standards

**CRITICAL DOCUMENTATION CONSTRAINTS**

These constraints are IMMUTABLE and apply to all files in this repository:

1. **ALWAYS update README.md**: Any file/directory changes MUST be reflected in README File Catalog immediately
2. **NEVER duplicate content**: Use cross-references, maintain Single Source of Truth
3. **ALWAYS verify cross-references**: Run `scripts/verify-cross-references.sh` before committing
4. **NEVER add version/line tracking**: Git handles versioning and change history
5. **MUST maintain Single Source of Truth**: Each pattern documented in exactly ONE place
6. **ALWAYS optimize for AI consumption**: Condense redundancy, use tables/lists, maximize signal-to-noise ratio

Rationale: Every line added consumes context in every future AI session. Make it count.

**See [.specs/constitution.md](.specs/constitution.md) for complete governance principles and decision hierarchy.**

**Before Adding Content:**
1. Does this exist elsewhere? → Cross-reference instead
2. Is this universal or project-specific? → Universal only
3. Will this be reused across sessions? → If not, don't add
4. Can this be found in official docs? → Link instead
5. Is this a pattern or one-off solution? → Only patterns belong here

### Quality Check

Periodically review for:
- Duplicated content → Consolidate or cross-reference
- Outdated information → Update or remove
- Missing cross-references → Add links
- Overly verbose sections → Simplify

---

## Content Sources

### Web Research (2026)

Files marked "**Web Research**" are synthesized from 100+ industry sources:
- Academic research (arXiv, IEEE, ACM papers 2025-2026)
- Industry practitioner blogs (Google, Anthropic, OpenAI)
- Framework documentation (LangGraph, CrewAI, AutoGen)
- Platform comparisons and benchmarks
- Observability tool documentation

**Research Directory**: `web-context/` contains raw research synthesis

### User Created

Templates and workflows created for practical use:
- Frontend component specs and workflows
- Agent instruction patterns
- Quick reference templates

### Industry Standards

Bash automation, coding principles, development practices:
- Established shell scripting best practices
- Universal software engineering principles
- Git workflow standards

---

## Design Principles

This structure follows:

1. **Hub-and-Spoke**: README.md as universal entry point
2. **Single Source of Truth**: Each pattern lives in exactly one place
3. **Cross-Reference Over Duplication**: Files reference each other
4. **Progressive Disclosure**: Entry point → patterns → details → sources
5. **Context Efficiency**: Maximize value per token, minimize redundancy
6. **Web Research Foundation**: AI patterns grounded in 2026 industry research

**Result**: Comprehensive, non-redundant catalog of AI development patterns and practical workflows.
