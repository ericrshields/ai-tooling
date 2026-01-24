# Agent Verification and Output Patterns

Patterns for evidence-based verification, decision tables, autonomy rules, output formatting, and progress reporting.

**About Examples**: This document uses concrete technology examples to illustrate patterns. These patterns are technology-agnostic and apply to any language or framework.

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

---

## Pattern 5: When to Ask vs. Proceed

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
I found some issues. The SearchBar component has an XSS vulnerability and you should fix it.
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

---

## Best Practices

### 1. Start with Constraints

Define boundaries before capabilities - what agent can't do is as important as what it can.

### 2. Be Specific

Use concrete commands, not vague descriptions. "Run `npm test`" not "check if tests work".

### 3. Provide Rationale

Help agent understand "why" rules exist, enables better decision-making in edge cases.

### 4. Use Examples

Show good/bad patterns with concrete code examples from relevant technology stack.

### 5. Test Instructions

Run agent with instructions, observe behavior, refine based on actual performance.

### 6. Iterate

Start strict, relax constraints as patterns prove reliable and safe.

### 7. Document Assumptions

Make implicit requirements explicit - don't assume agent knows project conventions.

---

## Technology Stack Variations

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

---

**Related Documentation**:
- [constraints-and-boundaries.md](constraints-and-boundaries.md) - This file
- [../agent-instruction-patterns.md](../agent-instruction-patterns.md) - Pattern hub
- [../quick-reference/agent-definition.md](../quick-reference/agent-definition.md) - Quick template
- [../quick-reference/decision-table.md](../quick-reference/decision-table.md) - Decision table template
