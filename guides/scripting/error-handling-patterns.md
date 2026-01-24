# Bash Error Handling Patterns

Comprehensive patterns for fail-fast error handling, clear reporting, and timeout protection in bash scripts.

---

## Overview

Reliable bash scripts require explicit error handling, clear feedback, and timeout protection. These patterns prevent silent failures and provide actionable error messages.

**Core Principles**:
- **Fail-Fast**: Exit immediately on errors
- **Clear Feedback**: Always say what succeeded or failed
- **Exit Codes**: 0 = success, non-zero = specific failure types

---

## Pattern 1: Fail-Fast Error Handling

**When**: Every script that should stop on errors.

**Pattern**:
```bash
#!/bin/bash
set -euo pipefail

# -e: Exit on any command error
# -u: Exit on undefined variable
# -o pipefail: Exit if any command in pipe fails
```

**Benefits**:
- Catches errors immediately
- No cascading failures
- Clear failure point

**Example**:
```bash
#!/bin/bash
set -euo pipefail

echo "Building project..."
npm run build  # Will exit script if build fails

echo "Running tests..."
npm test  # Only runs if build succeeded

echo "✓ All steps completed"
```

**Without fail-fast** (bad):
```bash
#!/bin/bash

npm run build  # Might fail silently
npm test       # Runs even if build failed
echo "Done"    # Always prints, even on failure
```

---

## Pattern 4: Clear Error Reporting

**When**: Always, but especially in validation scripts and CI.

**Pattern**:
```bash
#!/bin/bash
set -euo pipefail

function error() {
  echo "ERROR: $1" >&2
  exit "${2:-1}"
}

function warn() {
  echo "WARNING: $1" >&2
}

function success() {
  echo "✓ $1"
}

# Usage
if [ ! -f "package.json" ]; then
  error "package.json not found" 2
fi

if [ ! -d "node_modules" ]; then
  warn "node_modules missing, running npm install"
  npm install
fi

success "Dependencies ready"
```

**Exit Code Convention**:
```bash
# Exit codes communicate what failed
exit 0   # Success
exit 1   # General error
exit 2   # Missing file/dependency
exit 3   # Configuration error
exit 4   # External service failure
exit 5   # Timeout
```

**Example with Exit Codes**:
```bash
#!/bin/bash
set -euo pipefail

# Run tests and categorize failures
if ! npm test; then
  # Check what kind of failure
  if grep -q "ETIMEDOUT" npm-debug.log 2>/dev/null; then
    echo "ERROR: Tests timed out"
    exit 5
  else
    echo "ERROR: Tests failed"
    exit 1
  fi
fi

exit 0
```

---

## Pattern 5: Timeout Protection

**When**: Calling external services, long-running commands.

**Purpose**: Prevent scripts hanging indefinitely.

**Pattern - Simple Timeout**:
```bash
#!/bin/bash
set -euo pipefail

TIMEOUT=30  # seconds

if timeout "$TIMEOUT" npm test; then
  echo "✓ Tests passed"
else
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 124 ]; then
    echo "ERROR: Tests timed out after ${TIMEOUT}s"
    exit 5
  else
    echo "ERROR: Tests failed"
    exit 1
  fi
fi
```

**Pattern - Timeout with Retry**:
```bash
#!/bin/bash
set -euo pipefail

MAX_RETRIES=3
TIMEOUT=10

for i in $(seq 1 $MAX_RETRIES); do
  echo "Attempt $i/$MAX_RETRIES..."

  if timeout "$TIMEOUT" curl -f https://api.example.com/health; then
    echo "✓ Service healthy"
    exit 0
  fi

  if [ $i -lt $MAX_RETRIES ]; then
    echo "Retrying in 5s..."
    sleep 5
  fi
done

echo "ERROR: Service unreachable after $MAX_RETRIES attempts"
exit 4
```

---

## Pattern 6: Polling External Services

**When**: Waiting for CI, deploys, async operations to complete.

**Pattern**:
```bash
#!/bin/bash
set -euo pipefail

MAX_WAIT=300  # 5 minutes
POLL_INTERVAL=5
ELAPSED=0

echo "Waiting for CI to complete..."

while [ $ELAPSED -lt $MAX_WAIT ]; do
  STATUS=$(gh pr view --json statusCheckRollup -q '.statusCheckRollup[0].status')

  case "$STATUS" in
    "SUCCESS")
      echo "✓ CI passed"
      exit 0
      ;;
    "FAILURE")
      echo "ERROR: CI failed"
      exit 1
      ;;
    "PENDING"|"IN_PROGRESS")
      echo "CI in progress... (${ELAPSED}s elapsed)"
      sleep $POLL_INTERVAL
      ELAPSED=$((ELAPSED + POLL_INTERVAL))
      ;;
    *)
      echo "ERROR: Unknown CI status: $STATUS"
      exit 1
      ;;
  esac
done

echo "ERROR: CI timed out after ${MAX_WAIT}s"
exit 5
```

**Benefits**:
- Bounded wait time
- Clear progress feedback
- Handles all status cases
- Proper exit codes

---

## Complete Example: Quality Gate Script

Combines fail-fast, error reporting, and timeout patterns:

```bash
#!/bin/bash
# validate-all.sh - Complete quality gate validation

set -euo pipefail

#-------------------
# Configuration
#-------------------
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

#-------------------
# Helper Functions
#-------------------
function error() {
  echo "ERROR: $1" >&2
  exit "${2:-1}"
}

function success() {
  echo "✓ $1"
}

function run_gate() {
  local NAME=$1
  local CMD=$2

  echo ""
  echo "=== Running $NAME ==="

  if timeout 120 bash -c "$CMD"; then
    success "$NAME passed"
  else
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 124 ]; then
      error "$NAME timed out" 5
    else
      error "$NAME failed" 1
    fi
  fi
}

#-------------------
# Validation
#-------------------
echo "Starting quality gate validation..."

# Validate environment
if [ ! -f "package.json" ]; then
  error "Not in a Node.js project (package.json not found)" 2
fi

# Run gates
run_gate "Type Check" "npx tsc --noEmit"
run_gate "Lint" "npm run lint"
run_gate "Tests" "npm test"
run_gate "Build" "npm run build"

echo ""
success "All quality gates passed"
exit 0
```

---

## Anti-Patterns

### ❌ Ignoring Errors
```bash
command || true  # Bad: Swallows all errors
```
**Fix**: Handle errors explicitly
```bash
if ! command; then
  echo "ERROR: command failed"
  exit 1
fi
```

### ❌ Infinite Waits
```bash
while ! curl https://api.example.com; do
  sleep 1  # Bad: Could wait forever
done
```
**Fix**: Add timeout and max retries
```bash
for i in $(seq 1 60); do
  if curl https://api.example.com; then
    break
  fi
  sleep 1
done
```

---

**Related Documentation**:
- [safe-operations-patterns.md](safe-operations-patterns.md) - Atomic updates and safe file operations
- [../../workflows/script-patterns.md](../../workflows/script-patterns.md) - Script patterns hub
- [../../configs/quality-gates.md](../../configs/quality-gates.md) - Validation gate patterns
- [../../workflows/one-liners.md](../../workflows/one-liners.md) - Command quick reference
