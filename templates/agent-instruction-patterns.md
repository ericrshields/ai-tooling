# Agent Instruction Patterns

Hub for reusable templates and patterns for defining AI agent instructions, commands, and automated workflows.

**About Examples**: Detailed pattern files use concrete technology examples (React, Jest, npm, Python, Go) to illustrate patterns. These patterns are technology-agnostic and apply to any language, framework, or toolchain.

---

## Overview

Effective agent instructions require clear constraints, boundaries, verification strategies, and output formats. This hub organizes nine essential patterns into two categories.

**Key Principle**: Maximize autonomous action while preventing harmful mistakes through clear, enforceable rules.

---

## Pattern Categories

### Constraints and Boundaries

Define what agents can and cannot do, where they operate, and how strictly instructions should be followed.

**Patterns**:
1. **Supreme Constraints** - Immutable rules that override all other instructions
2. **Path Resolution Protocol** - Ensure agent works from correct directory
3. **Boundary Setting** - Define scope (in/out of scope)
4. **Instruction Density** - Match detail level to risk (strict vs. flexible)

See [patterns/constraints-and-boundaries.md](patterns/constraints-and-boundaries.md) for detailed implementation.

### Verification and Output

Define how agents verify their work, make decisions, and report results.

**Patterns**:
5. **Evidence-Based Verification** - Require proof, prevent assumptions
6. **Decision Tables** - Explicit logic for all scenarios
7. **Autonomy Rules** - When to ask vs. proceed vs. never do
8. **Output Structuring** - Standardize result format
9. **Progress Reporting** - Visibility for long-running tasks

See [patterns/verification-and-output.md](patterns/verification-and-output.md) for detailed implementation.

---

## Quick Reference Table

| Pattern | When to Use | Purpose |
|---------|-------------|---------|
| Supreme Constraints | Always | Define immutable rules |
| Path Resolution | File operations | Prevent "file not found" |
| Evidence-Based | Critical operations | Prevent assumptions |
| Decision Tables | Multiple scenarios | Consistent handling |
| Autonomy Rules | Risk present | Balance speed and safety |
| Boundary Setting | Multi-agent systems | Prevent scope creep |
| Output Structuring | User-facing results | Consistent, actionable output |
| Progress Reporting | Long tasks | User visibility |
| Instruction Density | Varies by risk | Match detail to risk level |

---

## Combining Patterns

### Example: Complete Agent Definition

```markdown
# Test Generator Agent

## SUPREME CONSTRAINTS
1. NEVER modify source code: Only create test files
2. NEVER commit changes: Report for user review
3. NEVER install dependencies: Use existing test environment

## PATH RESOLUTION PROTOCOL
1. Get repo root: `git rev-parse --show-toplevel`
2. Verify project type: Check for marker file
3. Locate source and test directories

## ROLE BOUNDARIES

### THIS AGENT MUST:
- Generate tests following project conventions
- Achieve coverage targets defined in config

### THIS AGENT MUST NOT:
- Modify source implementation
- Change test framework configuration

## AUTONOMY RULES

### PROCEED WITHOUT ASKING:
- Creating test files: Core responsibility
- Following existing patterns: Maintains consistency

### ALWAYS ASK:
- Deviating from test framework: Architecture decision
- Complex mocking strategies: May need guidance

## OUTPUT FORMAT

### Summary
Generated [N] test files with [X]% coverage

### Files Created
- List of test files with coverage metrics

### Actions Required
- [ ] Review generated tests
- [ ] Run test command to verify
```

---

## Best Practices

1. **Start with constraints**: Define boundaries before capabilities
2. **Be specific**: "Run `npm test`" not "check if tests work"
3. **Provide rationale**: Help agent understand "why" rules exist
4. **Use examples**: Show good/bad patterns
5. **Test instructions**: Run agent, observe behavior, refine
6. **Iterate**: Start strict, relax as patterns prove reliable
7. **Document assumptions**: Make implicit requirements explicit

---

## Anti-Patterns

### ❌ Vague Instructions
```markdown
Please review the code and make it better.
```
**Problem**: No definition of "better", no boundaries, no format.

### ❌ Conflicting Instructions
```markdown
MUST fix all issues found.
MUST NOT modify code.
```
**Problem**: Impossible to satisfy both.

### ❌ Missing Error Handling
```markdown
Run the tests.
```
**Problem**: No guidance on what to do if tests fail.

### ❌ Assumed Knowledge
```markdown
Use the standard approach for this.
```
**Problem**: Agent doesn't know what "standard" means here.

---

## COMMON AGENT TYPES

Specialized agents organized by function. These agents implement the patterns defined in this document.

### Development Lifecycle Agents

**Analysis & Planning**:
- **context-analyzer**: Deep code analysis, architecture understanding, impact assessment
- **test-planner**: TDD test strategy, coverage analysis
- **plan-generator**: Creates implementation plans from requirements
- **plan-reviewer**: Validates plans for accuracy, efficiency, completeness (see [../rules/plan-reviewer-agent.md](../rules/plan-reviewer-agent.md))

**Implementation**:
- **code-writer**: Implements changes following patterns
- **test-writer**: Writes unit, integration, edge case tests
- **refactorer**: Improves code structure without changing behavior
- **migration-agent**: Handles version upgrades, framework migrations

### Review & Quality Agents

**Code Review** (run in parallel, see [../workflows/code-review-patterns.md](../workflows/code-review-patterns.md)):
- **security-reviewer**: OWASP Top 10, auth/authz, vulnerability scanning
- **performance-reviewer**: Complexity, memory, database optimization
- **maintainability-reviewer**: SOLID principles, complexity metrics, code organization
- **code-duplication-detector**: DRY validation, identifies duplicated code patterns, suggests refactoring, detects copy-paste code
- **accessibility-reviewer**: WCAG compliance, semantic HTML, ARIA
- **style-reviewer**: Linting, formatting, type safety
- **test-quality-reviewer**: Coverage, brittleness, edge cases

**Documentation Quality**:
- **documentation-reviewer**: Validates structure, cross-references, quality standards (see [../rules/documentation-reviewer-agent.md](../rules/documentation-reviewer-agent.md))
- **documentation-duplication-detector**: DRY validation, identifies duplicated content across files, enforces Single Source of Truth, suggests consolidation
- **documentation-writer**: Creates/updates documentation
- **documentation-indexer**: Maintains catalogs, detects drift
- **example-validator**: Runs code examples, validates commands

### Synthesis & Integration Agents

**Coordination**:
- **review-synthesizer**: Collects parallel findings, prioritizes, deduplicates
- **workflow-orchestrator**: Coordinates multi-agent workflows, manages state
- **progress-reporter**: Provides visibility, reports status

**CI/CD Integration**:
- **ci-reviewer**: Integrates reviews into pipelines
- **ci-monitor**: Tracks pipeline progress, analyzes failures
- **test-runner**: Executes tests, suggests fixes
- **pr-generator**: Creates PRs with descriptions

### Specialized Domain Agents

**AI Tooling** (specialized for AI configuration/documentation repos):
- **ai-tooling-duplication-detector**: Detects duplication in instruction files, configs, patterns; validates DRY principles for AI context efficiency
- **context-optimizer**: Analyzes AI context files for efficiency, suggests consolidation
- **instruction-validator**: Validates instruction files follow architecture patterns

**Security**:
- **security-reviewer**: Comprehensive security validation
- **threat-modeler**: Identifies attack vectors, risks
- **secrets-scanner**: Detects hardcoded credentials

**Performance**:
- **performance-reviewer**: Comprehensive performance analysis
- **load-tester**: Simulates traffic, identifies bottlenecks
- **profiler-analyzer**: Interprets profiling data

**Architecture**:
- **architecture-validator**: Deep architectural review
- **dependency-analyzer**: Analyzes dependencies, suggests updates
- **technical-debt-tracker**: Identifies and prioritizes tech debt

### Meta Agents

**Quality & Learning**:
- **reviewer-quality-checker**: Validates review outputs, detects false positives
- **ai-on-ai-reviewer**: Reviews AI-generated code with different model
- **pattern-learner**: Extracts patterns from successful implementations

---

**Related Documentation**:
- [patterns/constraints-and-boundaries.md](patterns/constraints-and-boundaries.md) - Constraints, path resolution, boundaries, instruction density
- [patterns/verification-and-output.md](patterns/verification-and-output.md) - Evidence, decision tables, autonomy, output, progress
- [quick-reference/agent-definition.md](quick-reference/agent-definition.md) - Quick fill-in template
- [../rules/multi-agent-orchestration.md](../rules/multi-agent-orchestration.md) - How agents coordinate
- [../configs/quality-gates.md](../configs/quality-gates.md) - Validation patterns
