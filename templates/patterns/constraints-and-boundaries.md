# Agent Constraints and Boundaries Patterns

Patterns for defining immutable rules, boundaries, and instruction density for AI agents.

**About Examples**: This document uses concrete technology examples (React, Jest, npm, Python, Go) to illustrate patterns. These patterns are technology-agnostic and apply to any language, framework, or toolchain.

---

## Pattern 1: Supreme Constraints

**When to Use**: Define immutable rules that agent must never violate.

**Purpose**: Set boundaries that override all other instructions.

**Template**:
```markdown
## SUPREME CONSTRAINTS

These constraints are IMMUTABLE and take precedence over all other instructions:

1. [Constraint 1]: [Rationale]
2. [Constraint 2]: [Rationale]
3. [Constraint 3]: [Rationale]

Violating these constraints will cause [specific consequence].
```

**Good Example - Test Runner Agent**:
```markdown
## SUPREME CONSTRAINTS

These constraints are IMMUTABLE and take precedence over all other instructions:

1. NEVER modify source code: Your role is to run tests, not fix them
2. NEVER commit changes: Report results only
3. NEVER install packages: Use existing test environment

Violating these constraints will corrupt the test results and make them unreliable.
```

**Bad Example**:
```markdown
## Important Rules
- Try not to modify code
- Avoid making changes if possible
- Be careful with commits
```
❌ Too vague, not enforceable, sounds optional

---

## Pattern 2: Path Resolution Protocol

**When to Use**: Ensure agent works from correct directory and finds files reliably.

**Purpose**: Prevent "file not found" errors from wrong working directory.

**Template**:
```markdown
## PATH RESOLUTION PROTOCOL

ALWAYS follow this sequence when starting work:

1. Run `git rev-parse --show-toplevel` to get repository root
2. Verify expected marker file exists (e.g., `package.json`, `README.md`)
3. Store repo root as base for all subsequent paths
4. Use absolute paths constructed from repo root

NEVER assume current working directory is correct.
```

**Good Example - Frontend Linter**:
```markdown
## PATH RESOLUTION PROTOCOL

1. Get repo root: `REPO_ROOT=$(git rev-parse --show-toplevel)`
2. Verify frontend app: Check `$REPO_ROOT/package.json` contains "react"
3. All paths relative to $REPO_ROOT:
   - Source: `$REPO_ROOT/src/`
   - Config: `$REPO_ROOT/.eslintrc.js`
   - Tests: `$REPO_ROOT/tests/`

NEVER use relative paths like `./src/` or `../config/`.
```

**Bad Example**:
```markdown
Check if src/ directory exists
```
❌ Doesn't verify working directory, will fail if not in repo root

---

## Pattern 6: Boundary Setting

**When to Use**: Define what agent WILL and WON'T do.

**Purpose**: Prevent scope creep and role confusion.

**Template**:
```markdown
## ROLE BOUNDARIES

### THIS AGENT MUST:
1. [Primary responsibility 1]
2. [Primary responsibility 2]

### THIS AGENT MUST NOT:
1. [Out of scope action 1]: [Alternative]
2. [Out of scope action 2]: [Alternative]

### IN SCOPE:
- [Task type 1]
- [Task type 2]

### OUT OF SCOPE:
- [Task type 3]: Use [other agent/tool]
- [Task type 4]: Use [other agent/tool]
```

**Good Example - Accessibility Reviewer**:
```markdown
## ROLE BOUNDARIES

### THIS AGENT MUST:
1. Identify accessibility violations in components
2. Suggest WCAG-compliant fixes with examples

### THIS AGENT MUST NOT:
1. Fix code: Use accessibility-fixer agent instead
2. Review performance: Use performance-reviewer agent
3. Review security: Use security-reviewer agent

### IN SCOPE:
- ARIA attributes and roles
- Keyboard navigation
- Semantic HTML structure
- Color contrast ratios
- Screen reader compatibility

### OUT OF SCOPE:
- Visual design decisions: Designer responsibility
- Performance optimization: Different agent
- Browser compatibility: Different concern
```

**Bad Example**:
```markdown
Review the code for issues.
```
❌ No boundaries, will try to review everything

---

## Pattern 9: Instruction Density

**When to Use**: Determine how constrained vs. flexible agent should be.

**Purpose**: Match instruction detail to task risk and complexity.

**Guidance**:
```
HIGH DENSITY (Strict, Detailed)
Use when:
- High risk of damage (writes, deletes, deploys)
- Specific format required (reports, configs)
- Security critical (auth, secrets, validation)

LOW DENSITY (Flexible, Outcome-focused)
Use when:
- Creative problem solving needed
- Multiple valid approaches exist
- Read-only exploration
```

**Example - High Density (Deployment Agent)**:
```markdown
## DEPLOYMENT PROTOCOL

MUST execute steps in EXACT order:

1. Verify branch: MUST be `main`, fail if not
2. Run validation: `npm run validate`
3. Create release tag: `git tag v$(cat package.json | jq -r .version)`
4. Push tag: `git push origin [tag]`
5. Wait for CI: Poll until green or 10min timeout
6. Deploy: `npm run deploy:production`
7. Verify: `curl https://api.example.com/health`
8. Notify: Post to #deploys Slack channel

NEVER skip steps. NEVER proceed if any step fails.
```

**Example - Low Density (Research Agent)**:
```markdown
## RESEARCH OBJECTIVE

Investigate state management patterns in the codebase and recommend best approach for new feature.

Deliverable:
- Summary of current patterns
- Pros/cons of each
- Recommendation with rationale

Use your judgment on which files to examine and how deep to investigate.
```

---

## Using Emphasis Markers (RFC 2119 Keywords)

**When to use ALL CAPS emphasis markers** - based on RFC 2119 requirement levels:

**Absolute Requirements/Prohibitions**:
- **MUST / REQUIRED**: Absolute requirement that must be satisfied
- **MUST NOT / SHALL NOT**: Absolute prohibition
- **NEVER**: Absolute prohibition (colloquial equivalent to MUST NOT)
- **ALWAYS**: Absolute requirement (colloquial equivalent to MUST)

**Strong Recommendations**:
- **SHOULD / RECOMMENDED**: Strong recommendation, but valid exceptions may exist
- **SHOULD NOT / NOT RECOMMENDED**: Strong discouragement, but valid exceptions may exist

**Optional**:
- **MAY / OPTIONAL**: Truly optional, implementer's choice

**Emphasis/Severity**:
- **CRITICAL**: Safety-critical rules preventing data loss, corruption, or security issues
- **IMPORTANT**: Key guidelines requiring attention, but not absolute requirements

**Good examples**:
```markdown
NEVER modify source code when in read-only analysis mode
MUST verify all changes pass tests before committing
ALWAYS read files before editing them
SHOULD prefer existing patterns over creating new ones
MAY use test-after approach for UI layout code
CRITICAL: Every line in memory files consumes context in every future session
```

**When NOT to use emphasis markers**:
- General preferences without strong rationale
- Context-dependent choices without clear winner
- Best practices that allow flexibility
- Stylistic guidelines

**Principle**: Emphasis markers signal requirement levels using RFC 2119 conventions. MUST/NEVER for absolute constraints, SHOULD for strong recommendations with possible exceptions, MAY for truly optional. Overusing them dilutes effectiveness—reserve for true safety/correctness/quality requirements.

---

**Related Documentation**:
- [verification-and-output.md](verification-and-output.md) - Verification and output patterns
- [../agent-instruction-patterns.md](../agent-instruction-patterns.md) - Pattern hub
- [../quick-reference/agent-definition.md](../quick-reference/agent-definition.md) - Quick template
