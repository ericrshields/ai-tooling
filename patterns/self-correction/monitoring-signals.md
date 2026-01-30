# Monitoring Signals for Self-Correcting Agents

Comprehensive signals for detecting when AI agents need to self-correct or escalate.

---

## Overview

Self-correcting agents must autonomously detect when they're failing or stuck. Monitoring signals provide the feedback needed for intervention decisions.

**Key Principle**: Detect failures early through explicit and implicit signals, then route to appropriate intervention strategy.

---

## Explicit Failure Indicators

### 1. Action Repetition (Stuck in Loop)

**Signal**: Same action attempted multiple times.

**Indicates**:
- Agent doesn't recognize failure
- Lack of alternative strategies
- Misunderstanding of problem

**Detection**:
```
if action_history[-3:] == [same_action] * 3:
    signal_failure("repetitive_action")
```

**Example**: Agent tries `npm install` three times in a row, each failing with same error.

### 2. Excessive Latency (No Progress)

**Signal**: Operation taking significantly longer than expected.

**Indicates**:
- Inefficient approach
- Resource contention
- Blocking issues

**Detection**:
```
if elapsed_time > expected_time * threshold:
    signal_failure("excessive_latency")
```

**Example**: Code generation expected in 30 seconds takes 5 minutes.

### 3. Plan Complexity (Overly Convoluted)

**Signal**: Plan becoming increasingly complex.

**Indicates**:
- Wrong approach to problem
- Over-engineering solution
- Losing sight of objective

**Detection**:
```
if plan_complexity > complexity_threshold:
    signal_failure("plan_too_complex")
```

**Example**: Simple feature requires 15-step plan with conditional branching.

### 4. Error Messages from Tools

**Signal**: Tools returning errors.

**Indicates**:
- Invalid parameters
- Incorrect assumptions
- Environment issues

**Detection**:
```
if tool_result.status == "error":
    analyze_error(tool_result.error_message)
```

**Example**: File not found error indicates wrong working directory.

### 5. Constraint Violations

**Signal**: Breaking defined constraints.

**Indicates**:
- Misunderstanding requirements
- Invalid state transitions
- Logic errors

**Detection**:
```
if not validate_constraints(current_state):
    signal_failure("constraint_violation")
```

**Example**: Agent attempts to modify read-only file.

---

## Implicit Failure Indicators

### Lack of Progress

**Signals**:
- Task completion percentage not advancing
- No new information gathered
- Repeated similar states

**Detection**: Track progress metrics, alert if no change over N iterations.

### Quality Degradation

**Signals**:
- Output quality decreasing
- More errors in generated content
- Less coherent responses

**Detection**: Compare quality scores to baseline, trend analysis.

### Resource Exhaustion

**Signals**:
- Approaching token limits
- Memory usage growing rapidly
- Cost exceeding budget

**Detection**: Resource usage monitoring, threshold alerts.

---

## Monitoring Thresholds

### Recommended Thresholds

| Signal | Threshold | Action |
|--------|-----------|--------|
| Action repetition | 3 identical actions | Re-plan |
| Latency | 3x expected time | Escalate or change approach |
| Plan complexity | >10 steps for simple task | Simplify or seek guidance |
| Token usage | >2x expected | Optimize or escalate |
| Error rate | >3 errors in 5 attempts | Meta-controller analysis |

### Adaptive Thresholds

**Adjust based on**:
- Task complexity (complex tasks tolerate more time/tokens)
- Historical patterns (learn normal ranges)
- Context constraints (time pressure, budget limits)
- Agent capabilities (some agents slower but more accurate)

---

## Detection Implementation

### Monitoring Infrastructure

**Required Components**:
- Action history tracking (last N actions)
- Timing instrumentation (start/end timestamps)
- Resource usage tracking (tokens, memory)
- Quality scoring (output evaluation)
- Error log aggregation

**Example**:
```python
class AgentMonitor:
    def __init__(self):
        self.action_history = []
        self.start_time = None
        self.token_usage = 0
        self.errors = []

    def track_action(self, action):
        self.action_history.append(action)

        # Check for repetition
        if len(self.action_history) >= 3:
            if self.action_history[-3:] == [action] * 3:
                self.signal("repetitive_action")

    def check_latency(self):
        elapsed = time.now() - self.start_time
        if elapsed > self.expected_time * 3:
            self.signal("excessive_latency")

    def signal(self, failure_type):
        # Trigger intervention strategy
        intervene(failure_type, self.get_context())
```

---

## Integration with Intervention

**Flow**:
```
Monitor detects signal
    ↓
Classify failure type
    ↓
Route to intervention strategy:
    ├→ Re-planning (strategic error)
    ├→ Local correction (execution error)
    ├→ Tool invocation (needs specialized help)
    └→ Escalation (beyond capability)
```

---

**Related Documentation**:
- [intervention-strategies.md](intervention-strategies.md) - Recovery patterns
- [../../rules/self-correction-patterns.md](../../rules/self-correction-patterns.md) - Self-correction hub
- [../observability/monitoring-implementation.md](../observability/monitoring-implementation.md) - Production monitoring
