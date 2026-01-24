# Safe Operations Patterns for Bash Scripts

Patterns for atomic state updates, safe file operations, configuration validation, and event hooks.

---

## Overview

Safe operations prevent data corruption, enable rollback, and ensure scripts complete fully or not at all.

**Core Principles**:
- **Atomic**: Operations complete fully or not at all
- **Idempotent**: Running twice has same effect as running once
- **Backup**: Preserve original state before modifications

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

## Pattern 7: Event Hooks (State Transitions)

**When**: Automating workflows with state changes that require pre/post actions.

**Concept**: Similar to Git hooks or lifecycle scripts, trigger scripts automatically on state transitions.

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

## Anti-Patterns

### ❌ Partial State Updates
```bash
echo "$value" > state.json  # Bad: Leaves file inconsistent if interrupted
```
**Fix**: Use atomic updates with temp file + mv.

### ❌ No Backup Before Destructive Operation
```bash
sed -i 's/old/new/g' important-config.yml  # Bad: No way to undo
```
**Fix**: Create backup first.

---

**Related Documentation**:
- [error-handling-patterns.md](error-handling-patterns.md) - Fail-fast and error reporting
- [../../workflows/script-patterns.md](../../workflows/script-patterns.md) - Script patterns hub
- [../../workflows/one-liners.md](../../workflows/one-liners.md) - Command reference
