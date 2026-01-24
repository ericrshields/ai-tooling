# Quick Reference: Quality Gate Script

Fill-in-the-blank template for validation scripts.

---

## Script: `validate-[name].sh`

**Purpose**: [What this gate validates]
**Blocks**: [What is blocked if this fails]
**Duration**: ~[X] seconds

---

```bash
#!/bin/bash
set -euo pipefail

#-------------------
# Configuration
#-------------------
[VARIABLE]="[value]"
[MAX_VALUE]=[number]

#-------------------
# Validation
#-------------------
echo "Validating [what]..."

[command to run validation]

# Check result
if [success condition]; then
  echo "✓ [Gate name] passed"
  exit 0
else
  echo "ERROR: [Specific failure message]"
  echo "Fix: [How to resolve]"
  exit [exit code]
fi
```

---

## Exit Codes
- `0`: Validation passed
- `1`: [Specific failure type]
- `2`: [Another failure type]

---

**Related Documentation**:
- [../../configs/quality-gates.md](../../configs/quality-gates.md) - Quality gate patterns
- [../../workflows/script-patterns.md](../../workflows/script-patterns.md) - Script automation
- [../../guides/scripting/error-handling-patterns.md](../../guides/scripting/error-handling-patterns.md) - Error handling
