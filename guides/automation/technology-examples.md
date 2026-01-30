# Technology-Specific Workflow Examples

Workflow configuration and validation commands for different languages and frameworks.

---

## Overview

Phase-based workflows are technology-agnostic, but validation commands vary by language and framework. This guide provides specific examples for common stacks.

**Pattern**: The workflow structure (phases, entry/exit criteria) remains the same; only validation commands change.

---

## Node.js/TypeScript Project

### Configuration

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

### Validation Scripts

**Implementation Validation**:
```bash
#!/bin/bash
set -euo pipefail

echo "=== Validating Implementation ==="

echo "1/3 Static analysis..."
npm run lint

echo "2/3 Type checking..."
npx tsc --noEmit

echo "3/3 Build..."
npm run build

echo "✓ Implementation valid"
```

**Test Validation**:
```bash
#!/bin/bash
set -euo pipefail

MIN_COVERAGE=${MIN_COVERAGE:-80}

npm test -- --coverage

# Check coverage threshold (adjust parsing for your tool)
echo "✓ Tests passed"
```

---

## Python Project

### Configuration

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

### Validation Scripts

**Implementation Validation**:
```bash
#!/bin/bash
set -euo pipefail

echo "=== Validating Implementation ==="

echo "1/3 Linting..."
flake8 src/

echo "2/3 Type checking..."
mypy src/

echo "3/3 Build..."
python -m build

echo "✓ Implementation valid"
```

**Test Validation**:
```bash
#!/bin/bash
set -euo pipefail

MIN_COVERAGE=${MIN_COVERAGE:-80}

pytest --cov=src --cov-report=term --cov-fail-under=$MIN_COVERAGE

echo "✓ Tests passed"
```

---

## Go Project

### Configuration

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

### Validation Scripts

**Implementation Validation**:
```bash
#!/bin/bash
set -euo pipefail

echo "=== Validating Implementation ==="

echo "1/3 Linting..."
golangci-lint run

echo "2/3 Vetting..."
go vet ./...

echo "3/3 Build..."
go build ./...

echo "✓ Implementation valid"
```

**Test Validation**:
```bash
#!/bin/bash
set -euo pipefail

MIN_COVERAGE=${MIN_COVERAGE:-80}

# Run tests with coverage
go test -cover -coverprofile=coverage.out ./...

# Check coverage threshold
COVERAGE=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | sed 's/%//')

if [ "${COVERAGE%.*}" -lt "$MIN_COVERAGE" ]; then
  echo "ERROR: Coverage ${COVERAGE}% < ${MIN_COVERAGE}%"
  exit 1
fi

echo "✓ Tests passed with ${COVERAGE}% coverage"
```

---

## Rust Project

### Configuration

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

### Validation Scripts

**Implementation Validation**:
```bash
#!/bin/bash
set -euo pipefail

echo "=== Validating Implementation ==="

echo "1/3 Linting..."
cargo clippy -- -D warnings

echo "2/3 Type checking..."
cargo check

echo "3/3 Build..."
cargo build --release

echo "✓ Implementation valid"
```

**Test Validation**:
```bash
#!/bin/bash
set -euo pipefail

cargo test

echo "✓ Tests passed"
```

---

## Ruby Project

### Configuration

```yaml
settings:
  validation_dir: "./scripts"
  spec_file: "./SPEC.md"

validation_commands:
  lint: "rubocop"
  typecheck: "steep check"  # If using Steep
  test: "rspec"
  build: "bundle install"
```

### Validation Scripts

**Implementation Validation**:
```bash
#!/bin/bash
set -euo pipefail

echo "=== Validating Implementation ==="

echo "1/2 Linting..."
rubocop

echo "2/2 Dependencies..."
bundle check

echo "✓ Implementation valid"
```

**Test Validation**:
```bash
#!/bin/bash
set -euo pipefail

MIN_COVERAGE=${MIN_COVERAGE:-80}

rspec --format documentation

# Check coverage (if using SimpleCov)
if [ -f coverage/.last_run.json ]; then
  COVERAGE=$(jq -r '.result.line' coverage/.last_run.json)
  if [ "${COVERAGE%.*}" -lt "$MIN_COVERAGE" ]; then
    echo "ERROR: Coverage ${COVERAGE}% < ${MIN_COVERAGE}%"
    exit 1
  fi
fi

echo "✓ Tests passed"
```

---

## Customizing for Your Stack

### 1. Identify Validation Tools

**Questions**:
- What linter does the project use?
- What type checker (if applicable)?
- What test framework and runner?
- What build command?

### 2. Create Validation Scripts

Follow [../../workflows/script-patterns.md](../../workflows/script-patterns.md):
- Use `set -euo pipefail`
- Clear error messages
- Specific exit codes
- Timeout protection if needed

### 3. Set Appropriate Thresholds

**Coverage**: Adjust `MIN_COVERAGE` based on project criticality (60-90%).

**Performance**: Set timeouts based on expected build/test times.

**Quality**: Configure linter strictness for project needs.

---

**Related Documentation**:
- [phase-based-workflows.md](phase-based-workflows.md) - Workflow structure and patterns
- [../../templates/workflow-automation-pattern.md](../../templates/workflow-automation-pattern.md) - Workflow hub
- [../../workflows/script-patterns.md](../../workflows/script-patterns.md) - Script automation patterns
- [../../rules/coding-principles.md](../../rules/coding-principles.md) - Testing strategies
