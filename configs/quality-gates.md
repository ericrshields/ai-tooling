# Quality Gates and Validation Patterns

Comprehensive index for quality assurance, validation patterns, and permission-based quality controls across the development workflow.

---

## Overview

Quality gates are automated or manual checkpoints that ensure code, documentation, and processes meet defined standards before proceeding to the next phase. This index organizes validation patterns, quality review strategies, and permission controls.

**Purpose**: Serve as hub for all quality/validation content distributed across workflows, templates, and configurations.

---

## Validation Script Patterns

**Primary Source**: [workflows/script-patterns.md](../workflows/script-patterns.md)

Comprehensive bash automation patterns for validation scripts:
- **Pattern 1**: Fail-Fast Error Handling (`set -euo pipefail`)
- **Pattern 2**: Exit Code Standards (0=success, 1-255=failures)
- **Pattern 5**: Atomic Updates (temporary files with atomic moves)
- **Pattern 7**: Event Hooks (state transition validation)

**Key Sections**:
- Error handling and exit codes
- Atomic operations for safe validation
- Timeout and polling patterns
- Validation script composition

**Use When**: Writing validation scripts for phase gates, CI/CD, or quality checks.

---

## Quality Review Strategies

**Primary Source**: [workflows/code-review-patterns.md](../workflows/code-review-patterns.md)

Comprehensive AI-powered code review patterns and quality gates:
- Multi-dimensional parallel review
- AI-on-AI review patterns
- Quality gate enforcement strategies
- CI/CD integration patterns

**Key Sections**:
- Prompt engineering for code review
- Autonomous quality gates
- Multi-perspective review (security, performance, maintainability)
- Automated review workflows

**Use When**: Setting up code review processes, CI/CD quality gates, or automated quality enforcement.

---

## Phase-Based Validation

**Primary Source**: [templates/workflow-automation-pattern.md](../templates/workflow-automation-pattern.md)

Phase-based workflow automation with entry/exit criteria and validation gates:
- Entry and exit criteria patterns
- Automated validation at phase boundaries
- Technology-specific validation commands (Node.js, Python, Go, Rust)
- Validation script templates

**Key Sections**:
- Generic workflow pattern with validation phases
- Validation script templates (spec, implementation, tests, quality)
- Technology-specific examples
- State tracking patterns

**Use When**: Designing multi-phase workflows with quality checkpoints at each transition.

---

## Permission System and Quality Controls

**Primary Source**: [configs/claude-permissions.md](claude-permissions.md)

Permission-based quality controls and approval workflows:
- 3-tier permission system (allow, ask, deny)
- Hook-based validation triggers
- Destructive command safety gates
- Approval workflows for sensitive operations

**Key Sections**:
- Permission tiers and their quality implications
- Hook system for validation triggers
- Safe vs destructive operation classification
- Permission customization patterns

**Use When**: Configuring automated assistant permissions, safety controls, or approval workflows.

---

## Quick Reference Template

**Primary Source**: [templates/quick-reference/quality-gate.md](../templates/quick-reference/quality-gate.md)

One-page quick template for creating validation scripts:
- Script structure template
- Common validation checks
- Exit code patterns
- Example implementations

**Use When**: Quickly creating a new validation script for a specific purpose.

---

## Related Patterns

### Testing Strategies
See [rules/coding-principles.md](../rules/coding-principles.md) for comprehensive testing strategies (TDD, BDD, ATDD, test-after, hybrid) that feed into quality gates.

### Development Practices
See [rules/development-practices.md](../rules/development-practices.md) for destructive command safety protocols and git commit quality standards.

### Script Automation
See [workflows/script-patterns.md](../workflows/script-patterns.md) for safe automation patterns including fail-fast, atomic operations, and timeout protection.

### Coding Principles
See [rules/coding-principles.md](../rules/coding-principles.md) for error handling, type safety, security principles, and quality standards.

---

## Usage Guidelines

### When Starting a New Project

1. **Define quality standards**: Review coding-principles.md
2. **Choose validation approach**: Select from code-review-patterns.md
3. **Set up phase gates**: Use workflow-automation-pattern.md
4. **Write validation scripts**: Follow script-patterns.md
5. **Configure permissions**: Apply claude-permissions.md

### When Adding Quality Gates to Existing Workflows

1. **Identify critical checkpoints**: Where should validation occur?
2. **Create validation scripts**: Use quick-reference/quality-gate.md template
3. **Integrate with CI/CD**: Follow code-review-patterns.md integration section
4. **Test validation**: Ensure gates catch issues without false positives

### When Reviewing Quality Processes

1. **Audit existing gates**: Are they catching issues?
2. **Check for gaps**: What's not being validated?
3. **Optimize performance**: Are validations fast enough?
4. **Review false positives**: Are gates too strict?

---

## Best Practices

1. **Automate validation**: Manual checks are forgotten, scripts are consistent
2. **Fail fast**: Detect issues as early as possible in the workflow
3. **Clear error messages**: Failed validation should explain what's wrong and how to fix it
4. **Objective criteria**: Gates should be verifiable, not subjective
5. **Fast feedback**: Validation should complete quickly (seconds to minutes, not hours)
6. **Appropriate strictness**: Balance catching issues vs developer friction

---

## Anti-Patterns

### ❌ Too Many Gates
**Problem**: Excessive validation creates developer friction
**Fix**: Focus on high-value gates at critical transitions

### ❌ Subjective Criteria
**Problem**: "Code looks good" can't be automated or verified
**Fix**: Use objective measures (lint passes, types check, tests pass, coverage >80%)

### ❌ Slow Validation
**Problem**: 30-minute validation runs discourage frequent checking
**Fix**: Optimize scripts, run expensive checks only on CI, use parallel execution

### ❌ Unclear Failures
**Problem**: "Validation failed" without context
**Fix**: Include specific error messages, line numbers, and remediation steps

---

## Integration Points

This quality gates index integrates with:
- **Workflow automation**: workflow-automation-pattern.md uses these patterns for phase transitions
- **Code review**: code-review-patterns.md implements quality gates in review process
- **Script patterns**: script-patterns.md provides implementation patterns for validation scripts
- **Permission system**: claude-permissions.md enforces quality controls through permissions
- **Coding principles**: coding-principles.md defines the standards that gates enforce

