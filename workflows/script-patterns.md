# Script Automation Patterns

Reusable patterns for writing reliable bash scripts for automation, validation, and workflow management.

---

## Core Principles

**Fail-Fast**: Exit immediately on errors
**Atomic**: Operations complete fully or not at all
**Idempotent**: Running twice has same effect as running once
**Clear Feedback**: Always say what succeeded or failed
**Exit Codes**: 0 = success, non-zero = specific failure

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

## Pattern 2: Atomic State Updates

**When**: Updating state files, configs, or any file that others depend on.

**Purpose**: Prevent corruption if script is interrupted mid-write.

**Pattern**:
```bash
#!/bin/bash
set -euo pipefail

STATE_FILE="state.json"
TEMP_FILE=$(mktemp)

# Write to temporary file first
cat > "$TEMP_FILE" <<EOF
{
  "phase": 3,
  "status": "in_progress",
  "updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# Atomic move: replaces old file only if write succeeded
mv "$TEMP_FILE" "$STATE_FILE"

echo "✓ State updated atomically"
```

**Why atomic**:
- If script crashes during write, original file unchanged
- `mv` is atomic on same filesystem
- Readers always see valid state (old or new, never partial)

**Bad pattern** (non-atomic):
```bash
# Writes directly - if interrupted, file corrupted
cat > state.json <<EOF
{
  "phase": 3,
EOF
# CRASH HERE - file is invalid JSON now
```

---

## Pattern 3: Safe File Operations

**When**: Copying, moving, or modifying important files.

**Pattern - Backup Before Modify**:
```bash
#!/bin/bash
set -euo pipefail

SOURCE="config.yml"
BACKUP="${SOURCE}.backup.$(date +%Y%m%d_%H%M%S)"

# Create backup first
cp "$SOURCE" "$BACKUP"
echo "Created backup: $BACKUP"

# Now safe to modify
sed -i 's/old/new/g' "$SOURCE"

echo "✓ Modified $SOURCE (backup at $BACKUP)"
```

**Pattern - rsync with Backup**:
```bash
#!/bin/bash
set -euo pipefail

SOURCE_DIR="./dotfiles/"
DEST_DIR="$HOME/"

# Sync with automatic backup of overwritten files
rsync -av \
  --backup \
  --suffix=".backup" \
  "$SOURCE_DIR" "$DEST_DIR"

echo "✓ Synced (overwritten files backed up with .backup suffix)"
```

**Pattern - Test Before Apply**:
```bash
#!/bin/bash
set -euo pipefail

CONFIG="/etc/app/config.yml"

# Validate new config before replacing
if yq eval . new-config.yml > /dev/null 2>&1; then
  cp "$CONFIG" "${CONFIG}.backup"
  cp new-config.yml "$CONFIG"
  echo "✓ Config updated"
else
  echo "ERROR: Invalid YAML in new-config.yml"
  exit 1
fi
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

## Pattern 7: Event Hooks (State Transitions)

**When**: Automating workflows with state changes that require pre/post actions.

**Concept**: Similar to Git hooks or lifecycle scripts (npm preinstall/postinstall), trigger scripts automatically on state transitions.

**Pattern - Generic Hook System**:
```bash
#!/bin/bash
set -euo pipefail

STATE_FILE="state.json"
HOOKS_DIR="./hooks"

function get_current_state() {
  jq -r '.state' "$STATE_FILE"
}

function transition_to() {
  local NEW_STATE=$1
  local OLD_STATE=$(get_current_state)

  # Run exit hook for current state (if exists)
  local EXIT_HOOK="${HOOKS_DIR}/on-exit-${OLD_STATE}.sh"
  if [ -f "$EXIT_HOOK" ]; then
    echo "Running exit hook for $OLD_STATE..."
    bash "$EXIT_HOOK"
  fi

  # Update state atomically
  local TEMP=$(mktemp)
  jq ".state = \"$NEW_STATE\"" "$STATE_FILE" > "$TEMP"
  mv "$TEMP" "$STATE_FILE"

  # Run enter hook for new state (if exists)
  local ENTER_HOOK="${HOOKS_DIR}/on-enter-${NEW_STATE}.sh"
  if [ -f "$ENTER_HOOK" ]; then
    echo "Running enter hook for $NEW_STATE..."
    bash "$ENTER_HOOK"
  fi

  echo "✓ Transitioned: $OLD_STATE → $NEW_STATE"
}

# Usage
transition_to "deployed"
```

**Example Hook Structure**:
```bash
project/
├── state.json
├── hooks/
│   ├── on-enter-building.sh
│   ├── on-exit-building.sh
│   ├── on-enter-testing.sh
│   ├── on-exit-testing.sh
│   ├── on-enter-deployed.sh
│   └── on-exit-deployed.sh
└── workflow.sh
```

**Example Hook Implementation**:
```bash
# hooks/on-enter-building.sh
#!/bin/bash
set -euo pipefail

echo "Preparing build environment..."
npm ci

# hooks/on-exit-testing.sh
#!/bin/bash
set -euo pipefail

echo "Cleaning up test artifacts..."
rm -rf coverage/ test-results/
```

**Real-World Analogs**:
- Git hooks (pre-commit, post-merge)
- npm lifecycle scripts (preinstall, postinstall)
- Systemd service hooks (ExecStartPre, ExecStopPost)
- CI/CD pipeline stages (before_script, after_script)

---

## Pattern 8: Configuration Validation

**When**: Scripts that depend on config files or environment vars.

**Pattern - Validate Config File**:
```bash
#!/bin/bash
set -euo pipefail

CONFIG_FILE="config.yml"

function validate_config() {
  local CONFIG=$1

  # Check file exists
  if [ ! -f "$CONFIG" ]; then
    echo "ERROR: Config file not found: $CONFIG"
    exit 2
  fi

  # Check valid YAML
  if ! yq eval . "$CONFIG" > /dev/null 2>&1; then
    echo "ERROR: Invalid YAML in $CONFIG"
    exit 3
  fi

  # Check required fields
  local REQUIRED_FIELDS=("name" "version" "settings")
  for field in "${REQUIRED_FIELDS[@]}"; do
    if ! yq eval ".$field" "$CONFIG" > /dev/null 2>&1; then
      echo "ERROR: Missing required field: $field"
      exit 3
    fi
  done

  echo "✓ Config validation passed"
}

validate_config "$CONFIG_FILE"
```

**Pattern - Validate Environment**:
```bash
#!/bin/bash
set -euo pipefail

function require_env() {
  local VAR=$1
  if [ -z "${!VAR:-}" ]; then
    echo "ERROR: Required environment variable not set: $VAR"
    exit 3
  fi
}

function require_command() {
  local CMD=$1
  if ! command -v "$CMD" &> /dev/null; then
    echo "ERROR: Required command not found: $CMD"
    exit 2
  fi
}

# Validate environment
require_env "API_KEY"
require_env "DATABASE_URL"
require_command "npm"
require_command "git"

echo "✓ Environment validation passed"
```

---

## Pattern 9: Tool Version Checks

**When**: Scripts that depend on specific tool versions.

**Pattern**:
```bash
#!/bin/bash
set -euo pipefail

function check_version() {
  local TOOL=$1
  local MIN_VERSION=$2
  local CURRENT_VERSION

  case "$TOOL" in
    node)
      CURRENT_VERSION=$(node --version | sed 's/v//')
      ;;
    npm)
      CURRENT_VERSION=$(npm --version)
      ;;
    *)
      echo "ERROR: Unknown tool: $TOOL"
      exit 1
      ;;
  esac

  if [ "$(printf '%s\n' "$MIN_VERSION" "$CURRENT_VERSION" | sort -V | head -n1)" != "$MIN_VERSION" ]; then
    echo "ERROR: $TOOL version $CURRENT_VERSION < required $MIN_VERSION"
    exit 2
  fi

  echo "✓ $TOOL version $CURRENT_VERSION (>= $MIN_VERSION)"
}

# Check required versions
check_version "node" "18.0.0"
check_version "npm" "9.0.0"
```

---

## Pattern 10: Dry Run Mode

**When**: Scripts that modify state, for testing script logic.

**Pattern**:
```bash
#!/bin/bash
set -euo pipefail

DRY_RUN=${DRY_RUN:-false}

function run_cmd() {
  local CMD="$1"

  if [ "$DRY_RUN" = "true" ]; then
    echo "[DRY RUN] Would execute: $CMD"
  else
    echo "Executing: $CMD"
    eval "$CMD"
  fi
}

# Usage
run_cmd "npm run build"
run_cmd "git commit -m 'Update config'"
run_cmd "git push"

# Enable dry run: DRY_RUN=true ./script.sh
```

---

## Complete Example: Quality Gate Script

Combines multiple patterns:

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

# Optional: Check bundle size
if [ -f "dist/main.js" ]; then
  BUNDLE_KB=$(du -k dist/main.*.js 2>/dev/null | cut -f1 || echo "0")
  MAX_KB=500

  if [ "$BUNDLE_KB" -gt "$MAX_KB" ]; then
    echo "WARNING: Bundle size ${BUNDLE_KB}KB > ${MAX_KB}KB" >&2
  else
    success "Bundle size ${BUNDLE_KB}KB within limit"
  fi
fi

echo ""
success "All quality gates passed"
exit 0
```

---

## Best Practices Summary

1. **Always use `set -euo pipefail`** at start of every script
2. **Use atomic updates** (temp file + mv) for state files
3. **Backup before modify** for important files
4. **Clear error messages** with specific exit codes
5. **Timeout protection** for external calls
6. **Validate inputs** before using them
7. **Provide dry-run mode** for destructive operations
8. **Poll, don't spin** when waiting for external services
9. **Use functions** for reusable logic
10. **Document exit codes** in script comments

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

### ❌ Partial State Updates
```bash
echo "$value" > state.json  # Bad: Leaves file in inconsistent state if interrupted
```
**Fix**: Use atomic updates
```bash
TEMP=$(mktemp)
echo "$value" > "$TEMP"
mv "$TEMP" state.json
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
- [quality-gates.md](../configs/quality-gates.md) - Validation gate patterns
- [one-liners.md](one-liners.md) - Command quick reference

**Version**: 1.0.0 | **Created**: 2026-01-16
