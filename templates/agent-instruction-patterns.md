# Agent Instruction Patterns

Reusable templates and patterns for defining AI agent instructions, commands, and automated workflows.

**About Examples**: This document uses concrete technology examples (React, Jest, npm, Python, Go) to illustrate patterns. These patterns are technology-agnostic and apply to any language, framework, or toolchain. Adapt the specific commands and file structures to match your project's stack.

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

**Example - Frontend Stack**:
```markdown
## SUPREME CONSTRAINTS - Component Analyzer

1. NEVER modify component files: Read-only analysis
2. NEVER install or update packages: Use locked versions
3. NEVER run build or dev server: Analyze static code only
```

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

## Pattern 3: Evidence-Based Verification

**When to Use**: Prevent assumptions, require concrete proof.

**Purpose**: Ensure agent bases decisions on actual state, not guesses.

**Template**:
```markdown
## EVIDENCE-BASED VERIFICATION

Before taking action, ALWAYS gather evidence:

1. [Check 1]: [Command/Tool to verify]
2. [Check 2]: [Command/Tool to verify]
3. [Check 3]: [Command/Tool to verify]

NEVER assume:
- File contents without reading
- Command success without checking exit code
- State without verification

Report evidence in format: "[Claim]: [Evidence]"
```

**Good Example - Test Fixer**:
```markdown
## EVIDENCE-BASED VERIFICATION

Before claiming tests pass:

1. Run test command: `npm test`
2. Verify exit code: `$? -eq 0`
3. Check test output: "Tests: X passed, 0 failed"

Before claiming fix applied:

1. Read modified file: Show exact changed lines
2. Re-run tests: Demonstrate failure → success
3. Git diff: Show exact changes made

NEVER say "tests should pass now" without running them.
```

**Bad Example**:
```markdown
The code looks correct, so tests should pass now.
```
❌ Assumption, no verification

**Example - Frontend Stack**:
```markdown
## EVIDENCE-BASED VERIFICATION - Bundle Analyzer

Before reporting bundle size:
1. Run build: `npm run build`
2. Measure bundle: `du -b dist/main.*.js`
3. Show exact bytes: "Bundle size: 487,234 bytes"

Before suggesting optimization:
1. Profile current: Show baseline metrics
2. Apply change: Show exact modification
3. Re-measure: Show new metrics with diff
```

---

## Pattern 4: Decision Table

**When to Use**: Handle multiple error/state scenarios consistently.

**Purpose**: Explicit logic for every possible outcome.

**Template**:
```markdown
## DECISION TABLE: [Scenario Name]

| Condition | Action | Rationale |
|-----------|--------|-----------|
| [State 1] | [Action 1] | [Why] |
| [State 2] | [Action 2] | [Why] |
| [State 3] | [Action 3] | [Why] |
| Default | [Fallback] | [Why] |
```

**Good Example - Test Runner**:
```markdown
## DECISION TABLE: Test Failure Handling

| Condition | Action | Rationale |
|-----------|--------|-----------|
| All tests pass | Report success, exit 0 | Validation complete |
| Tests fail in new code | Report failures with context | Actionable feedback |
| Tests fail in old code | Report, suggest separate ticket | Out of scope |
| Tests timeout | Report timeout, suggest increasing | Config issue |
| Test setup fails | Report error, check dependencies | Environment issue |
| No tests found | Report warning, suggest adding tests | Coverage gap |
```

**Bad Example**:
```markdown
If tests fail, report the error.
```
❌ No distinction between failure types, no guidance on what to do

**Example - Frontend Stack**:
```markdown
## DECISION TABLE: Component Import Errors

| Error Type | Action | Rationale |
|------------|--------|-----------|
| Module not found | Check if package installed | Missing dependency |
| Named export missing | Verify export in source file | API mismatch |
| Default import on named | Suggest `import { X }` | Import style wrong |
| Circular dependency | Show dependency chain | Architecture issue |
| Type-only import needed | Add `import type` | TypeScript requirement |
```

---

## Pattern 5: When to Ask vs Proceed

**When to Use**: Define autonomy boundaries for agent.

**Purpose**: Maximize autonomous action while preventing harmful mistakes.

**Template**:
```markdown
## AUTONOMY RULES

### PROCEED WITHOUT ASKING when:
- [Safe action 1]: [Why it's safe]
- [Safe action 2]: [Why it's safe]

### ALWAYS ASK when:
- [Risky action 1]: [Why ask]
- [Risky action 2]: [Why ask]

### NEVER DO (even if asked):
- [Prohibited action 1]: [Why prohibited]
- [Prohibited action 2]: [Why prohibited]
```

**Good Example - Auto-Fixer**:
```markdown
## AUTONOMY RULES

### PROCEED WITHOUT ASKING when:
- Fixing auto-fixable lint errors: ESLint marks them safe
- Adding missing imports: Deterministic, low risk
- Formatting code with Prettier: Preserves behavior

### ALWAYS ASK when:
- Refactoring logic: Behavior change possible
- Removing "unused" code: Might be used dynamically
- Changing API contracts: Breaking change risk

### NEVER DO (even if asked):
- Commit and push changes: User control required
- Delete test files: Tests are safety net
- Disable linting rules: Masks underlying issues
```

**Bad Example**:
```markdown
Ask the user before making changes.
```
❌ Too restrictive, agent won't be useful

**Example - Frontend Stack**:
```markdown
## AUTONOMY RULES - Component Generator

### PROCEED WITHOUT ASKING when:
- Creating component file in /src/components/: Expected location
- Creating test file with same name: Standard practice
- Adding PropTypes based on usage: Defensive programming

### ALWAYS ASK when:
- Choosing state management pattern: Architecture decision
- Adding third-party library: Dependency management
- Creating in non-standard location: Might break conventions

### NEVER DO:
- Modify package.json: Dependency decisions are user's
- Generate components in node_modules/: Wrong location
- Create without tests: Quality requirement
```

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

## Pattern 7: Output Structuring

**When to Use**: Standardize agent output format.

**Purpose**: Consistent, parseable, actionable results.

**Template**:
```markdown
## OUTPUT FORMAT

ALWAYS structure output as follows:

### Summary
[1-2 sentence overview]

### Results
[Structured findings]

### Actions Required
- [ ] [Action 1]
- [ ] [Action 2]

### Evidence
[Concrete proof: command output, file contents, diffs]

### Metadata
- Duration: [time]
- Files checked: [count]
- Issues found: [count by severity]
```

**Good Example - Code Reviewer**:
```markdown
## OUTPUT FORMAT

### Summary
Reviewed 5 components, found 2 HIGH and 3 MEDIUM severity issues.

### Results

#### HIGH Severity
1. **XSS Risk in SearchBar.tsx:45**
   - Issue: Unescaped user input rendered directly
   - Fix: Use DOMPurify or React's built-in escaping

2. **Missing Error Boundary in App.tsx**
   - Issue: Uncaught errors will crash entire app
   - Fix: Wrap <Router> in <ErrorBoundary>

#### MEDIUM Severity
[...]

### Actions Required
- [ ] Fix HIGH severity issues before merge
- [ ] Consider MEDIUM severity improvements
- [ ] Add tests for error cases

### Evidence
```typescript
// SearchBar.tsx:45 (BEFORE)
<div dangerouslySetInnerHTML={{__html: userInput}} />
```

### Metadata
- Duration: 3.2s
- Files checked: 12
- Issues: 2 HIGH, 3 MEDIUM, 5 LOW
```

**Bad Example**:
```markdown
I found some issues. The SearchBar component has an XSS vulnerability and you should fix it. Also there are some other problems.
```
❌ Unstructured, missing severity, no evidence, not actionable

---

## Pattern 8: Progress Reporting

**When to Use**: Long-running agents or multi-step workflows.

**Purpose**: User visibility into agent progress.

**Template**:
```markdown
## PROGRESS REPORTING

Report progress using this format:

**Phase [X/Y]: [Phase Name]**
- [Step 1]: [Status] ✓/⏳/✗
- [Step 2]: [Status] ✓/⏳/✗

Update after each major step completes.

When blocked, report:
- What was attempted
- What failed
- What's needed to proceed
```

**Good Example - Build Validator**:
```markdown
## PROGRESS REPORTING

**Phase 1/4: Environment Check**
- Node version >= 18: ✓
- npm installed: ✓
- node_modules present: ✓

**Phase 2/4: Type Check**
- Running tsc --noEmit: ✓ (0 errors)

**Phase 3/4: Lint Check**
- Running ESLint: ✗ (3 errors)
  - Blocking: Must fix lint errors before build

**Blocked**: Lint errors must be resolved. See errors above.
```

**Bad Example**:
```markdown
Checking things... Done.
```
❌ No detail, can't tell what succeeded or failed

**Example - Frontend Stack**:
```markdown
**Phase 1/5: Component Analysis**
- Found 23 components: ✓
- Identified dependencies: ✓

**Phase 2/5: Bundle Size Analysis**
- Built production bundle: ⏳
```

---

## Pattern 9: Instruction Density

**When to Use**: Determine how constrained vs flexible agent should be.

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

## Combining Patterns

### Example: Complete Agent Definition

This shows how to combine multiple patterns into a cohesive agent definition. Adapt specifics to your technology stack.

```markdown
# Test Generator Agent

## SUPREME CONSTRAINTS
1. NEVER modify source code: Only create test files
2. NEVER commit changes: Report for user review
3. NEVER install dependencies: Use existing test environment

## PATH RESOLUTION PROTOCOL
1. Get repo root: `git rev-parse --show-toplevel`
2. Verify project type: Check for marker file (package.json, go.mod, pyproject.toml)
3. Locate source directories: [Define based on project structure]
4. Locate test directories: [Define based on conventions]

## ROLE BOUNDARIES

### THIS AGENT MUST:
- Generate tests following project conventions
- Follow existing test patterns in codebase
- Achieve coverage targets defined in project config

### THIS AGENT MUST NOT:
- Modify source implementation
- Change test configuration or framework
- Run tests (separate test-runner agent handles this)

## DECISION TABLE: Test Strategy

| Code Type | Test Approach | Rationale |
|-----------|---------------|-----------|
| Pure functions | Input/output verification | Deterministic, easy to test |
| Stateful logic | Mock state, verify transitions | Isolate state changes |
| External dependencies | Mock externals, verify calls | Isolate from environment |
| UI/presentation | Snapshot or integration tests | Verify rendered output |

## AUTONOMY RULES

### PROCEED WITHOUT ASKING:
- Creating test files: Core responsibility
- Following existing patterns: Maintains consistency
- Adding standard assertions: Best practice

### ALWAYS ASK:
- Deviating from test framework: Architecture decision
- Complex mocking strategies: May need guidance
- Testing internal/private APIs: Design question

## OUTPUT FORMAT

### Summary
Generated [N] test files with [X]% coverage

### Files Created
- List of test files with coverage metrics

### Coverage Report
[Show coverage statistics]

### Actions Required
- [ ] Review generated tests
- [ ] Run test command to verify
- [ ] Adjust assertions if needed

## EVIDENCE-BASED VERIFICATION

After generating tests:
1. Show exact files created
2. Run coverage command
3. Report actual coverage percentage
```

### Technology Stack Variations

**React/TypeScript + Jest**:
```markdown
## PATH RESOLUTION PROTOCOL
1. Verify React project: Check package.json for "react"
2. Source: `$REPO_ROOT/src/components/**/*.tsx`
3. Tests: `$REPO_ROOT/src/components/__tests__/`
4. Test command: `npm test -- --coverage`
```

**Python + pytest**:
```markdown
## PATH RESOLUTION PROTOCOL
1. Verify Python project: Check for pyproject.toml or setup.py
2. Source: `$REPO_ROOT/src/**/*.py`
3. Tests: `$REPO_ROOT/tests/**/*_test.py`
4. Test command: `pytest --cov=src`
```

**Go + testing**:
```markdown
## PATH RESOLUTION PROTOCOL
1. Verify Go project: Check for go.mod
2. Source: `$REPO_ROOT/**/*.go` (exclude *_test.go)
3. Tests: `$REPO_ROOT/**/*_test.go`
4. Test command: `go test -cover ./...`
```

**Ruby + RSpec**:
```markdown
## PATH RESOLUTION PROTOCOL
1. Verify Ruby project: Check for Gemfile
2. Source: `$REPO_ROOT/lib/**/*.rb`
3. Tests: `$REPO_ROOT/spec/**/*_spec.rb`
4. Test command: `rspec --format documentation`
```

---

## Best Practices

1. **Start with constraints**: Define boundaries before capabilities
2. **Be specific**: "Run npm test" not "check if tests work"
3. **Provide rationale**: Help agent understand "why" rules exist
4. **Use examples**: Show good/bad patterns
5. **Test instructions**: Run agent with instructions, refine based on behavior
6. **Iterate**: Start strict, relax as patterns prove reliable
7. **Document assumptions**: Make implicit requirements explicit

### Using Emphasis Markers (RFC 2119 Keywords)

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
- General preferences without strong rationale: "Prefer X over Y" (not "ALWAYS use X")
- Context-dependent choices without clear winner: "Consider using X when Y" (not "MUST use X")
- Best practices that allow flexibility: "Use descriptive names" (not "ALWAYS use 50+ character names")
- Stylistic guidelines: "Keep functions small" (not "NEVER write functions over 10 lines")

**Principle**: Emphasis markers signal requirement levels using RFC 2119 conventions. MUST/NEVER for absolute constraints, SHOULD for strong recommendations with possible exceptions, MAY for truly optional. Overusing them dilutes effectiveness—reserve for true safety/correctness/quality requirements.

---

## Anti-Patterns

### ❌ Vague Instructions
```markdown
Please review the code and make it better.
```
**Problem**: No definition of "better", no boundaries, no format

### ❌ Conflicting Instructions
```markdown
MUST fix all issues found.
MUST NOT modify code.
```
**Problem**: Impossible to satisfy both

### ❌ Missing Error Handling
```markdown
Run the tests.
```
**Problem**: No guidance on what to do if tests fail

### ❌ Assumed Knowledge
```markdown
Use the standard approach for this.
```
**Problem**: Agent doesn't know what "standard" means here

---

**Related Documentation**:
- [multi-agent-orchestration.md](../instructions/multi-agent-orchestration.md) - How agents coordinate
- [quality-gates.md](../configs/quality-gates.md) - Validation patterns
- [quick-reference/agent-definition.md](quick-reference/agent-definition.md) - Quick template

**Version**: 1.1.0 | **Created**: 2026-01-16 | **Updated**: 2026-01-22
