# Workflow Automation Pattern

Template for creating phase-based automated workflows with quality gates and validation scripts.

**Purpose**: Provides a structured approach to breaking complex development tasks into phases with clear entry/exit criteria and automated validation.

**When to Use**: Multi-day features, complex integrations, or any work requiring systematic progression through defined stages.

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

**Entry Criteria**: Conditions that must be true to start a phase
**Exit Criteria**: Conditions that must be true to complete a phase

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

## Workflow Structure Template

### Basic YAML Structure

```yaml
workflow:
  name: "[Workflow Name]"
  description: "[What this workflow accomplishes]"
  version: "1.0.0"

settings:
  auto_validate: true          # Run validation scripts automatically
  block_on_failure: true       # Prevent progression if validation fails
  validation_dir: "./scripts"  # Where validation scripts live

phases:
  - id: 0
    name: "[Phase Name]"
    description: "[What happens in this phase]"

    entry_criteria:
      - "[Condition 1]"
      - "[Condition 2]"

    tasks:
      - "[Task 1]"
      - "[Task 2]"

    exit_criteria:
      - "[Condition 1]"
      - "[Condition 2]"

    validation:
      script: "validate-[phase].sh"

    next_phase: 1

  - id: 1
    name: "[Next Phase]"
    # ...repeat structure
```

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

Scripts should follow patterns from [script-patterns.md](../workflows/script-patterns.md).

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

# Adapt these to your project's build system
echo "1/3 Static analysis..."
# npm run lint        # Node.js
# cargo clippy        # Rust
# golangci-lint run   # Go
# flake8 .           # Python

echo "2/3 Type checking..."
# npx tsc --noEmit   # TypeScript
# mypy .             # Python
# go vet ./...       # Go

echo "3/3 Build..."
# npm run build      # Node.js
# cargo build        # Rust
# go build ./...     # Go
# python -m compileall  # Python

echo "✓ Implementation valid"
```

### Test Validation

```bash
#!/bin/bash
set -euo pipefail

MIN_COVERAGE=${MIN_COVERAGE:-80}

echo "Running tests with coverage..."

# Adapt to your test framework
# npm test -- --coverage                    # Jest
# pytest --cov=src --cov-report=term       # Python pytest
# go test -cover ./...                     # Go
# cargo test                               # Rust

# Coverage check (adjust based on output format)
# COVERAGE=$(extract_coverage_from_output)
# if [ "$COVERAGE" -lt "$MIN_COVERAGE" ]; then
#   echo "ERROR: Coverage ${COVERAGE}% < ${MIN_COVERAGE}%"
#   exit 1
# fi

echo "✓ Tests passed"
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

## Technology-Specific Examples

### Node.js/TypeScript Project

```yaml
settings:
  validation_dir: "./scripts"
  spec_file: "./spec.md"

# Validation commands
validation_commands:
  lint: "npm run lint"
  typecheck: "npx tsc --noEmit"
  test: "npm test -- --coverage"
  build: "npm run build"
```

### Python Project

```yaml
settings:
  validation_dir: "./scripts"
  spec_file: "./SPEC.md"

validation_commands:
  lint: "flake8 src/"
  typecheck: "mypy src/"
  test: "pytest --cov=src --cov-report=term"
  build: "python -m build"
```

### Go Project

```yaml
settings:
  validation_dir: "./scripts"
  spec_file: "./DESIGN.md"

validation_commands:
  lint: "golangci-lint run"
  typecheck: "go vet ./..."
  test: "go test -cover ./..."
  build: "go build ./..."
```

### Rust Project

```yaml
settings:
  validation_dir: "./scripts"
  spec_file: "./DESIGN.md"

validation_commands:
  lint: "cargo clippy"
  typecheck: "cargo check"
  test: "cargo test"
  build: "cargo build --release"
```

---

## Implementation Strategies

### Option 1: Manual Workflow

Use workflow as a checklist without automation:
- Create markdown file with phases
- Check off tasks manually
- Run validation scripts manually
- Track progress in project management tool

**Best for**: Simple projects, learning the pattern

### Option 2: Script-Driven Workflow

Implement state tracking and automation:
- Store current phase in `state.json`
- Create transition script that runs validations
- Block progression on validation failure
- Track progress automatically

**Best for**: Complex projects, repeated workflows

### Option 3: Tool Integration

Integrate with existing tools:
- CI/CD pipeline enforces quality gates
- Project management tool tracks phases
- Git hooks run validations
- IDE plugins show current phase

**Best for**: Team workflows, mature processes

---

## Customizing for Your Project

### 1. Define Phases

Questions to ask:
- What are the major milestones?
- What can be validated at each stage?
- What should block forward progress?
- What dependencies exist between phases?

### 2. Set Validation Criteria

For each phase:
- What must be true to start? (Entry criteria)
- What must be true to finish? (Exit criteria)
- How can we verify automatically? (Validation script)

### 3. Create Validation Scripts

Follow [script-patterns.md](../workflows/script-patterns.md):
- Use `set -euo pipefail`
- Clear error messages
- Specific exit codes
- Timeout protection

### 4. Document Exceptions

When is it okay to skip phases?
- Trivial changes (typos, comments)
- Hotfixes (document as technical debt)
- Prototypes (specify transition criteria)

---

## Integration with Other Patterns

### Specification-Driven Development

Workflow Phase 0 creates specification following [specification-driven-development.md](../workflows/specification-driven-development.md).

### Testing Strategies

Workflow Phase 3 uses testing approach selected from [coding-principles.md](../instructions/coding-principles.md).

### Quality Gates

Validation scripts implement quality gates from project-specific standards.

### Agent Instructions

Agents can be instructed to follow workflow phases using patterns from [agent-instruction-patterns.md](./agent-instruction-patterns.md).

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
    },
    {
      "phase": 1,
      "started": "2026-01-21T09:00:00Z",
      "completed": "2026-01-21T10:00:00Z",
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
**Problem**: Phases for every tiny step creates overhead
**Fix**: Group related work into logical phases

### ❌ Subjective Criteria
**Problem**: "Code looks good" can't be automated
**Fix**: "Lint passes, types check, tests pass"

### ❌ Skipping Validation
**Problem**: "I'm sure it's fine, let's move on"
**Fix**: Fast validation scripts remove excuse to skip

### ❌ One-Size-Fits-All
**Problem**: Same workflow for typo fix and major feature
**Fix**: Different workflows for different change sizes

---

## Related Documentation

- [specification-driven-development.md](../workflows/specification-driven-development.md) - Spec creation
- [coding-principles.md](../instructions/coding-principles.md) - Testing strategies
- [script-patterns.md](../workflows/script-patterns.md) - Validation script patterns
- [agent-instruction-patterns.md](./agent-instruction-patterns.md) - Agent workflow instructions

---

**Version**: 1.0.0 | **Created**: 2026-01-21
