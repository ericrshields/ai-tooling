# Script Automation Patterns

Hub for reusable patterns for writing reliable bash scripts for automation, validation, and workflow management.

---

## Overview

Reliable bash automation requires fail-fast error handling, atomic operations, and clear feedback. These patterns prevent silent failures, data corruption, and debugging nightmares.

**Core Principles**:
- **Fail-Fast**: Exit immediately on errors
- **Atomic**: Operations complete fully or not at all
- **Idempotent**: Running twice has same effect as running once
- **Clear Feedback**: Always say what succeeded or failed
- **Exit Codes**: 0 = success, non-zero = specific failure

---

## Pattern Categories

### Error Handling and Reporting

Essential patterns for catching errors early and providing actionable feedback.

**Patterns**:
1. **Fail-Fast Error Handling** - `set -euo pipefail` for immediate error detection
2. **Clear Error Reporting** - Helper functions for error/warn/success messages
3. **Timeout Protection** - Prevent scripts hanging on external services
4. **Polling External Services** - Bounded waits with clear feedback

See [../guides/scripting/error-handling-patterns.md](../guides/scripting/error-handling-patterns.md) for detailed implementation.

### Safe Operations

Patterns for preventing data corruption and enabling safe rollback.

**Patterns**:
5. **Atomic State Updates** - Temp file + atomic move pattern
6. **Safe File Operations** - Backup before modify, test before apply
7. **Event Hooks** - Pre/post state transition hooks
8. **Configuration Validation** - Validate configs and environment
9. **Tool Version Checks** - Ensure dependencies meet requirements
10. **Dry Run Mode** - Test script logic without side effects

See [../guides/scripting/safe-operations-patterns.md](../guides/scripting/safe-operations-patterns.md) for detailed implementation.

---

## Quick Reference

| Pattern | Purpose | Exit Code on Error |
|---------|---------|-------------------|
| Fail-Fast | Stop on any error | Command's exit code |
| Error Reporting | Clear user feedback | Customizable (0-5) |
| Timeout Protection | Prevent hanging | 5 (timeout), 1 (failure) |
| Atomic Updates | Prevent corruption | N/A (transactional) |
| Backup Before Modify | Enable rollback | 1 (general error) |
| Config Validation | Catch setup issues early | 2 (missing), 3 (invalid) |
| Version Checks | Ensure compatibility | 2 (version too old) |
| Dry Run | Test safely | 0 (no errors) |

---

## Essential Script Template

Every automation script should start with:

```bash
#!/bin/bash
set -euo pipefail

# Configuration
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Helper functions
function error() {
  echo "ERROR: $1" >&2
  exit "${2:-1}"
}

function success() {
  echo "✓ $1"
}

# Script logic here
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

## Exit Code Convention

Standardize exit codes for consistent error handling:

| Exit Code | Meaning | Example |
|-----------|---------|---------|
| 0 | Success | All operations completed |
| 1 | General error | Command failed, unspecified |
| 2 | Missing file/dependency | package.json not found |
| 3 | Configuration error | Invalid YAML, missing field |
| 4 | External service failure | API unreachable |
| 5 | Timeout | Operation exceeded time limit |

---

## Anti-Patterns

### ❌ Ignoring Errors
```bash
command || true  # Bad: Swallows all errors
```

### ❌ Partial State Updates
```bash
echo "$value" > state.json  # Bad: Inconsistent if interrupted
```

### ❌ Infinite Waits
```bash
while ! curl https://api.example.com; do
  sleep 1  # Bad: Could wait forever
done
```

---

**Related Documentation**:
- [../guides/scripting/error-handling-patterns.md](../guides/scripting/error-handling-patterns.md) - Fail-fast, error reporting, timeouts, polling
- [../guides/scripting/safe-operations-patterns.md](../guides/scripting/safe-operations-patterns.md) - Atomic updates, backups, hooks, validation
- [../configs/quality-gates.md](../configs/quality-gates.md) - Validation gate patterns
- [one-liners.md](one-liners.md) - Command quick reference
