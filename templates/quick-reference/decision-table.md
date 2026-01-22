# Quick Reference: Decision Table

Fill-in-the-blank template for error handling decision tables.

---

## Scenario: [Scenario Name]

**Context**: [When this decision table applies]
**Goal**: [What we're trying to achieve]

---

| Condition | Action | Exit Code | Rationale |
|-----------|--------|-----------|-----------|
| [Success condition] | [Action to take] | 0 | [Why this is correct] |
| [Error type 1] | [Action to take] | 1 | [Why this is correct] |
| [Error type 2] | [Action to take] | 2 | [Why this is correct] |
| [Edge case] | [Action to take] | 3 | [Why this is correct] |
| Default/Unknown | [Fallback action] | 1 | [Safe default] |

---

## Implementation Template

```bash
case "[condition]" in
  "[value1]")
    [action]
    exit 0
    ;;
  "[value2]")
    [action]
    exit 1
    ;;
  *)
    echo "ERROR: Unknown state: $condition"
    exit 1
    ;;
esac
```

---

**For complete patterns, see:** [agent-instruction-patterns.md](../agent-instruction-patterns.md)
