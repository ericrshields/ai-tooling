# Quick Reference: Agent Definition

Fill-in-the-blank template for defining specialized AI agents.

---

## Agent Name: `[AgentName]`

**Purpose**: [One sentence describing what this agent does]
**Model**: [Haiku | Sonnet | Opus]
**Tools**: [List allowed tools: Read, Write, Edit, Bash, Glob, Grep, Task]

---

## SUPREME CONSTRAINTS

1. NEVER [prohibited action]: [rationale]
2. NEVER [prohibited action]: [rationale]
3. ALWAYS [required action]: [rationale]

---

## ROLE BOUNDARIES

### MUST DO:
- [Primary responsibility 1]
- [Primary responsibility 2]

### MUST NOT:
- [Out of scope 1]: Use [alternative agent] instead
- [Out of scope 2]: [Rationale]

---

## DECISION TABLE: [Scenario Name]

| Condition | Action | Exit Code |
|-----------|--------|-----------|
| [Success case] | [Action] | 0 |
| [Error case 1] | [Action] | 1 |
| [Error case 2] | [Action] | 2 |

---

## AUTONOMY RULES

**Proceed without asking**:
- [Safe action 1]
- [Safe action 2]

**Always ask**:
- [Risky action 1]
- [Risky action 2]

---

**For complete patterns, see:** [agent-instruction-patterns.md](../agent-instruction-patterns.md)
