# Workflow Automation Pattern

Template for creating phase-based automated workflows with quality gates and validation scripts.

**Purpose**: Provides a structured approach to breaking complex development tasks into phases with clear entry/exit criteria and automated validation.

**When to Use**: Multi-day features, complex integrations, or any work requiring systematic progression through defined stages.

---

## Core Concepts

### Phase-Based Progression

**Concept**: Break work into discrete phases with clear boundaries.

**Benefits**: Clear progress tracking, validation at each stage, prevents proceeding with flawed foundation, enables resumption after interruption.

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

**Benefits**: Objective verification, prevents human error, consistent quality enforcement, fast feedback.

---

## Workflow Structure Template

### Basic YAML Structure

```yaml
workflow:
  name: "[Workflow Name]"
  description: "[What this workflow accomplishes]"

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
```

---

## Generic Development Workflow

Standard 5-phase workflow applicable to most development tasks:

**Phase 0: Plan & Specify** - Define what to build and success criteria.
- Entry: Requirements gathered
- Exit: Specification complete, approach validated
- Validation: Spec has required sections

**Phase 1: Research & Design** - Understand context and design solution.
- Entry: Specification exists
- Exit: Design documented, interfaces defined
- Validation: Design review complete

**Phase 2: Implement** - Write code following design and standards.
- Entry: Design approved
- Exit: Code compiles, static analysis passes
- Validation: Lint + typecheck + build

**Phase 3: Test** - Verify functionality meets requirements.
- Entry: Implementation complete
- Exit: Tests pass, coverage threshold met
- Validation: Test suite + coverage check

**Phase 4: Review & Polish** - Quality check and refinement.
- Entry: Tests passing
- Exit: All quality gates pass
- Validation: Full quality gate suite

**Phase 5: Submit for Review** - Prepare and submit for team review.
- Entry: Quality gates pass
- Exit: PR created, CI passes
- Validation: PR validation script

See [../guides/automation/phase-based-workflows.md](../guides/automation/phase-based-workflows.md) for complete workflow YAML and validation scripts.

---

## Technology-Specific Examples

Validation commands vary by language and framework, but workflow structure stays the same.

**Node.js/TypeScript**: `npm run lint`, `npx tsc --noEmit`, `npm test -- --coverage`, `npm run build`

**Python**: `flake8 src/`, `mypy src/`, `pytest --cov=src`, `python -m build`

**Go**: `golangci-lint run`, `go vet ./...`, `go test -cover ./...`, `go build ./...`

**Rust**: `cargo clippy`, `cargo check`, `cargo test`, `cargo build --release`

**Ruby**: `rubocop`, `bundle check`, `rspec`, `bundle install`

See [../guides/automation/technology-examples.md](../guides/automation/technology-examples.md) for complete validation scripts per technology.

---

## Implementation Strategies

### Option 1: Manual Workflow

Use workflow as a checklist without automation. Best for simple projects and learning the pattern.

### Option 2: Script-Driven Workflow

Implement state tracking and automation with `state.json` and transition scripts. Best for complex projects and repeated workflows.

### Option 3: Tool Integration

Integrate with CI/CD pipeline, project management tools, git hooks, and IDE plugins. Best for team workflows and mature processes.

---

## Customizing for Your Project

### 1. Define Phases

**Questions**:
- What are the major milestones?
- What can be validated at each stage?
- What should block forward progress?
- What dependencies exist between phases?

### 2. Set Validation Criteria

**For each phase**:
- What must be true to start? (Entry criteria)
- What must be true to finish? (Exit criteria)
- How can we verify automatically? (Validation script)

### 3. Create Validation Scripts

Follow [../workflows/script-patterns.md](../workflows/script-patterns.md) patterns.

### 4. Document Exceptions

When is it okay to skip phases?
- Trivial changes (typos, comments)
- Hotfixes (document as technical debt)
- Prototypes (specify transition criteria)

---

## Integration with Other Patterns

**Specification-Driven Development**: Phase 0 creates specification following [../workflows/specification-driven-development.md](../workflows/specification-driven-development.md).

**Testing Strategies**: Phase 3 uses approach selected from [../instructions/coding-principles.md](../instructions/coding-principles.md).

**Quality Gates**: Validation scripts implement gates from project standards.

**Agent Instructions**: Agents can follow workflow phases using patterns from [agent-instruction-patterns.md](agent-instruction-patterns.md).

---

**Related Documentation**:
- [../guides/automation/phase-based-workflows.md](../guides/automation/phase-based-workflows.md) - Detailed workflow patterns and validation scripts
- [../guides/automation/technology-examples.md](../guides/automation/technology-examples.md) - Language-specific validation commands
- [../workflows/specification-driven-development.md](../workflows/specification-driven-development.md) - Spec creation
- [../instructions/coding-principles.md](../instructions/coding-principles.md) - Testing strategies
- [../workflows/script-patterns.md](../workflows/script-patterns.md) - Script patterns
- [agent-instruction-patterns.md](agent-instruction-patterns.md) - Agent workflow instructions
