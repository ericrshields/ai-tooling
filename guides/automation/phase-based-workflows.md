# Phase-Based Workflow Automation

Comprehensive guide to creating structured workflows with clear phase boundaries, entry/exit criteria, and automated validation.

---

## Overview

Phase-based workflows break complex tasks into discrete stages with clear validation at each transition. This enables systematic progression, prevents proceeding with flawed foundations, and supports resumption after interruption.

**Key Principle**: Define what must be true to enter a phase (entry criteria) and what must be true to exit it (exit criteria), then automate validation.

---

## Core Concepts

### Phase-Based Progression

**Concept**: Break work into discrete phases with clear boundaries.

**Benefits**:
- Clear progress tracking
- Validation at each stage
- Prevents proceeding with flawed foundation
- Enables resumption after interruption

### Entry and Exit Criteria

**Entry Criteria**: Conditions that must be true to start a phase.

**Exit Criteria**: Conditions that must be true to complete a phase.

**Example**:
```
Phase: Implementation
Entry: Design approved, dependencies identified
Exit: Code compiles, lint passes, types check
```

### Automated Validation

**Concept**: Scripts that verify exit criteria are met before proceeding.

**Benefits**:
- Objective verification
- Prevents human error
- Consistent quality enforcement
- Fast feedback

---

## Generic Workflow Pattern

Applicable to most development tasks:

```yaml
workflow:
  name: "Generic Development Workflow"
  description: "Structured approach to feature development"

phases:
  # Phase 0: Planning
  - id: 0
    name: "Plan & Specify"
    description: "Define what to build and success criteria"

    entry_criteria:
      - "Requirements gathered"
      - "Stakeholders identified"

    tasks:
      - "Create specification document"
      - "Define acceptance criteria"
      - "Identify dependencies"
      - "Estimate complexity"

    exit_criteria:
      - "Specification complete and reviewed"
      - "Success criteria defined"
      - "Technical approach validated"

    validation:
      script: "validate-spec.sh"

    next_phase: 1

  # Phase 1: Research
  - id: 1
    name: "Research & Design"
    description: "Understand context and design solution"

    entry_criteria:
      - "Specification exists"
      - "Requirements clear"

    tasks:
      - "Review existing code and patterns"
      - "Identify reusable components"
      - "Design interfaces and contracts"
      - "Plan testing strategy"

    exit_criteria:
      - "Design documented"
      - "Interfaces defined"
      - "Approach validated"

    validation:
      script: "validate-design.sh"

    next_phase: 2

  # Phase 2: Implementation
  - id: 2
    name: "Implement"
    description: "Write code following design and standards"

    entry_criteria:
      - "Design approved"
      - "Interfaces defined"

    tasks:
      - "Implement core functionality"
      - "Add error handling"
      - "Add logging/observability"
      - "Document complex logic"

    exit_criteria:
      - "Code compiles/builds successfully"
      - "Static analysis passes"
      - "Code adheres to standards"

    validation:
      script: "validate-implementation.sh"

    next_phase: 3

  # Phase 3: Testing
  - id: 3
    name: "Test"
    description: "Verify functionality meets requirements"

    entry_criteria:
      - "Implementation complete"
      - "Code builds successfully"

    tasks:
      - "Write tests per project strategy (TDD/BDD/test-after)"
      - "Test edge cases"
      - "Test error conditions"
      - "Verify acceptance criteria"

    exit_criteria:
      - "Tests pass"
      - "Coverage meets project threshold"
      - "Acceptance criteria validated"

    validation:
      script: "validate-tests.sh"

    next_phase: 4

  # Phase 4: Review
  - id: 4
    name: "Review & Polish"
    description: "Quality check and refinement"

    entry_criteria:
      - "Tests passing"
      - "Implementation complete"

    tasks:
      - "Run all quality gates"
      - "Self-review against standards"
      - "Check performance"
      - "Update documentation"
      - "Clean up debug code"

    exit_criteria:
      - "All quality gates pass"
      - "Performance acceptable"
      - "Documentation updated"

    validation:
      script: "validate-quality.sh"

    next_phase: 5

  # Phase 5: Integration
  - id: 5
    name: "Submit for Review"
    description: "Prepare and submit for team review"

    entry_criteria:
      - "All quality gates pass"
      - "Work complete"

    tasks:
      - "Create commits following conventions"
      - "Push to remote"
      - "Create pull request"
      - "Link to specification/ticket"
      - "Request review"

    exit_criteria:
      - "PR created"
      - "CI passes"
      - "Review requested"

    validation:
      script: "validate-pr.sh"

    next_phase: null  # Complete
```

---

## Validation Script Templates

Scripts should follow patterns from [../../workflows/script-patterns.md](../../workflows/script-patterns.md).

### Specification Validation

```bash
#!/bin/bash
set -euo pipefail

echo "Validating specification..."

SPEC_FILE="${SPEC_FILE:-./spec.md}"

if [ ! -f "$SPEC_FILE" ]; then
  echo "ERROR: Specification file not found"
  exit 1
fi

# Check required sections exist
required_sections=(
  "Overview"
  "Requirements"
  "Success Criteria"
)

for section in "${required_sections[@]}"; do
  if ! grep -q "## $section" "$SPEC_FILE"; then
    echo "ERROR: Missing section: $section"
    exit 1
  fi
done

echo "✓ Specification valid"
```

### Implementation Validation

```bash
#!/bin/bash
set -euo pipefail

echo "=== Validating Implementation ==="

# Static analysis
echo "1/3 Static analysis..."
npm run lint || exit 1

# Type checking
echo "2/3 Type checking..."
npx tsc --noEmit || exit 1

# Build
echo "3/3 Build..."
npm run build || exit 1

echo "✓ Implementation valid"
```

### Test Validation

```bash
#!/bin/bash
set -euo pipefail

MIN_COVERAGE=${MIN_COVERAGE:-80}

echo "Running tests with coverage..."
npm test -- --coverage || exit 1

# Extract coverage percentage (adapt based on output format)
COVERAGE=$(grep "All files" coverage/lcov-report/index.html | sed -E 's/.*>([0-9.]+)%.*/\1/' || echo "0")

if [ "${COVERAGE%.*}" -lt "$MIN_COVERAGE" ]; then
  echo "ERROR: Coverage ${COVERAGE}% < ${MIN_COVERAGE}%"
  exit 1
fi

echo "✓ Tests passed with ${COVERAGE}% coverage"
```

### Quality Gate Validation

```bash
#!/bin/bash
set -euo pipefail

echo "=== Running All Quality Gates ==="

# Path to validation scripts
SCRIPT_DIR="$(dirname "$0")"

# Run all previous validations
"$SCRIPT_DIR/validate-implementation.sh"
"$SCRIPT_DIR/validate-tests.sh"

# Additional quality checks
echo "Checking for common issues..."

# No debug statements left
if grep -r "console\.log\|debugger" src/ 2>/dev/null; then
  echo "WARNING: Debug statements found"
fi

# No TODO/FIXME without context
if grep -r "TODO\|FIXME" src/ | grep -v "TODO:" 2>/dev/null; then
  echo "WARNING: Incomplete TODO markers found"
fi

echo "✓ Quality gates passed"
```

---

## State Tracking (Optional)

If implementing automated workflow transitions:

### State File Format

```json
{
  "current_phase": 2,
  "phase_name": "Implementation",
  "started_at": "2026-01-21T10:00:00Z",
  "last_validation": "2026-01-21T14:30:00Z",
  "validation_status": "pending",
  "history": [
    {
      "phase": 0,
      "started": "2026-01-20T09:00:00Z",
      "completed": "2026-01-20T16:00:00Z",
      "validation": "passed"
    }
  ]
}
```

### Transition Script

```bash
#!/bin/bash
set -euo pipefail

STATE_FILE="state.json"
CURRENT_PHASE=$(jq -r '.current_phase' "$STATE_FILE")
NEXT_PHASE=$((CURRENT_PHASE + 1))

# Run validation for current phase
VALIDATION_SCRIPT="./scripts/validate-phase-${CURRENT_PHASE}.sh"

if [ -f "$VALIDATION_SCRIPT" ]; then
  echo "Running validation for phase $CURRENT_PHASE..."
  if ! bash "$VALIDATION_SCRIPT"; then
    echo "ERROR: Validation failed, cannot transition"
    exit 1
  fi
fi

# Update state atomically
TEMP=$(mktemp)
jq ".current_phase = $NEXT_PHASE | .started_at = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" \
  "$STATE_FILE" > "$TEMP"
mv "$TEMP" "$STATE_FILE"

echo "✓ Transitioned to phase $NEXT_PHASE"
```

---

## Best Practices

1. **Keep phases focused**: Each phase should have clear purpose
2. **Make validation objective**: Exit criteria should be verifiable
3. **Allow flexibility**: Provide escape hatches for special cases
4. **Document rationale**: Explain why phases exist
5. **Iterate**: Refine workflow based on experience
6. **Right-size**: Match complexity to project needs
7. **Automate validation**: Humans forget, scripts don't

---

## Anti-Patterns

### ❌ Too Many Phases
**Problem**: Phases for every tiny step creates overhead.
**Fix**: Group related work into logical phases.

### ❌ Subjective Criteria
**Problem**: "Code looks good" can't be automated.
**Fix**: "Lint passes, types check, tests pass".

### ❌ Skipping Validation
**Problem**: "I'm sure it's fine, let's move on".
**Fix**: Fast validation scripts remove excuse to skip.

### ❌ One-Size-Fits-All
**Problem**: Same workflow for typo fix and major feature.
**Fix**: Different workflows for different change sizes.

---

**Related Documentation**:
- [technology-examples.md](technology-examples.md) - Language-specific validation commands
- [../../templates/workflow-automation-pattern.md](../../templates/workflow-automation-pattern.md) - Workflow hub
- [../../workflows/specification-driven-development.md](../../workflows/specification-driven-development.md) - Spec creation
- [../../rules/coding-principles.md](../../rules/coding-principles.md) - Testing strategies
- [../../workflows/script-patterns.md](../../workflows/script-patterns.md) - Validation script patterns
