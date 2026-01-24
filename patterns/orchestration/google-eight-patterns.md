# Google's Eight Essential Multi-Agent Patterns

Comprehensive guide to Google's design patterns for multi-agent orchestration (2026).

---

## Overview

Google identified eight essential patterns that cover the majority of multi-agent use cases. These patterns provide a structured approach to designing agent workflows.

**Philosophy**: Match the pattern to your workflow needs, combine patterns for complex scenarios.

---

## Foundational Execution Patterns

### 1. Sequential Pattern

**Description**: One agent executes after another in a pipeline.

**Structure**:
```
Agent 1 → Agent 2 → Agent 3 → Result
```

**Use Cases**:
- Linear workflows with dependencies
- Each step builds on previous
- Clear sequential logic

**Example**: Analyze requirements → Generate code → Write tests → Create documentation

### 2. Loop Pattern

**Description**: Repeat execution until condition met.

**Structure**:
```
Agent → Check Condition → If Not Met → Loop Back
                       ↓ If Met
                      Result
```

**Use Cases**:
- Iterative refinement
- Test-driven development
- Quality improvement cycles

**Example**: Generate code → Run tests → Fix failures → Repeat until all tests pass

### 3. Parallel Pattern (Fan-Out/Gather)

**Description**: Multiple agents execute simultaneously, results synthesized.

**Structure**:
```
        ┌→ Agent 1 →┐
Task → ├→ Agent 2 →├→ Synthesize → Result
        └→ Agent 3 →┘
```

**Use Cases**:
- Independent subtasks
- Multi-dimensional analysis
- Specialized reviews

**Benefits**:
- 5-6x faster than sequential
- Comprehensive coverage
- Specialized expertise per agent

**Example** (Code Review):
```
Code → [Security Review | Performance Review | Maintainability Review]
         ↓                 ↓                    ↓
       Synthesis Agent → Combined Review Report
```

---

## Advanced Patterns

### 4. Branching Pattern

**Description**: Conditional routing based on results or context.

**Structure**:
```
Agent → Evaluate Result → Route to Agent A (if condition X)
                       → Route to Agent B (if condition Y)
                       → Route to Agent C (otherwise)
```

**Use Cases**:
- Context-dependent workflows
- Risk-based routing
- Specialized handling by case type

**Example**: Classify issue → Route to bug fix agent, feature agent, or documentation agent

### 5. Hierarchical Pattern

**Description**: Supervisor agents coordinate worker agents.

**Structure**:
```
Supervisor Agent (Planning & Coordination)
       ↓
[Worker Agent 1 | Worker Agent 2 | Worker Agent 3]
       ↓
Supervisor Agent (Integration & Review)
```

**Use Cases**:
- Complex workflows needing coordination
- Resource allocation and load balancing
- High-level planning with detailed execution

**Example**: Project manager agent coordinates developer, tester, and devops agents

### 6. Collaborative Pattern

**Description**: Agents negotiate and decide together.

**Structure**:
```
Problem → [Agent 1 ←→ Agent 2 ←→ Agent 3]
               ↓ (Discussion & Consensus)
          Agreed Solution
```

**Use Cases**:
- Decisions requiring multiple perspectives
- Conflict resolution
- Strategic planning

**Example**: Architectural decision - agents debate approaches, reach consensus

### 7. Competitive Pattern

**Description**: Multiple agents propose solutions, best is selected.

**Structure**:
```
Problem → [Agent 1 | Agent 2 | Agent 3]
           ↓         ↓         ↓
       [Solution 1 | Solution 2 | Solution 3]
           ↓
       Selection Agent (Evaluate & Choose Best)
           ↓
       Best Solution
```

**Use Cases**:
- Exploring multiple approaches
- Optimization problems
- Creative solution generation

**Example**: Multiple code implementations, select most efficient/maintainable

### 8. Hybrid Pattern

**Description**: Combination of multiple patterns.

**Structure**: Mix and match patterns based on workflow needs.

**Use Cases**:
- Real-world complex workflows
- Multi-phase processes
- Adaptive systems

**Example**:
```
Sequential planning →
  Parallel implementation (fan-out) →
    Competitive solution selection →
      Hierarchical integration →
        Loop-based refinement
```

---

## Parallel Fan-Out/Gather Pattern (Deep Dive)

### Why This Pattern Matters

**Performance**: 5-6x faster than sequential execution for independent tasks.

**Coverage**: Comprehensive analysis from multiple specialized perspectives.

**Quality**: Each agent focuses on specific expertise area.

### Implementation Steps

**1. Fan-Out Phase**

**Process**: Distribute task to multiple specialized agents.

**Considerations**:
- Clear task boundaries for each agent
- Minimal overlap to avoid redundant work
- Appropriate specialization per agent

**Example**:
```
Code submission →
  ├→ Security Agent (OWASP vulnerabilities)
  ├→ Performance Agent (bottlenecks, optimization)
  ├→ Maintainability Agent (readability, modularity)
  ├→ Accessibility Agent (WCAG compliance)
  └→ Testing Agent (coverage, quality)
```

**2. Parallel Execution Phase**

**Process**: Agents work independently and simultaneously.

**Requirements**:
- Agents must be truly independent (no shared state dependencies)
- Each agent has access to needed context
- Execution isolated to prevent interference

**Monitoring**:
- Track progress of each agent
- Handle failures gracefully (one agent failing doesn't block others)
- Set timeouts for each agent

**3. Gather Phase**

**Process**: Collect results from all agents.

**Handling**:
- Wait for all agents to complete (or timeout)
- Collect results in structured format
- Handle partial results if some agents failed

**Data Structure**:
```
{
  "security": security_agent_results,
  "performance": performance_agent_results,
  "maintainability": maintainability_agent_results,
  "accessibility": accessibility_agent_results,
  "testing": testing_agent_results
}
```

**4. Synthesis Phase**

**Process**: Combine findings into coherent output.

**Synthesis Agent Responsibilities**:
- Merge findings from all agents
- Identify conflicts or contradictions
- Prioritize issues
- Create unified report
- Provide actionable recommendations

**Output Format**:
```
Combined Review Report:
- Critical Issues (any agent)
- High Priority (consensus)
- Medium Priority (specific agent)
- Suggestions for Improvement
- Overall Assessment
```

### Best Practices

**Agent Independence**:
- Ensure agents can run without waiting for others
- Avoid shared mutable state
- Provide each agent with necessary context

**Error Handling**:
- Continue even if one agent fails
- Mark failed agent results explicitly
- Provide partial results when possible

**Result Prioritization**:
- Critical security issues elevated
- Consistent severity/priority scale across agents
- Clear action items

**Performance Optimization**:
- Limit parallel agents to avoid resource exhaustion
- Consider batching if many items to review
- Monitor and optimize slowest agents

---

## Real-World Implementation Patterns

### Pattern 1: Hierarchical with Parallel Review

**Use Case**: Complete development workflow from planning to deployment.

**Structure**:
```
Supervisor Agent (Create Plan)
       ↓
[Code Agent | Test Agent | Doc Agent] (Parallel Implementation)
       ↓
[Security Review | Performance Review | Maintainability Review] (Parallel Review)
       ↓
Integration Agent (Synthesize feedback, coordinate fixes)
       ↓
Deployment Agent (Release)
```

**Benefits**:
- Clear separation of concerns
- Parallel execution where possible
- Comprehensive quality review
- Coordinated integration

### Pattern 2: Sequential with Self-Correction Loops

**Use Case**: TDD workflow with automatic fixing.

**Structure**:
```
Analyze Requirements → Plan Implementation → Implement Code → Run Tests
                                                ↓           ↓
                                            [If Fail]   [If Pass]
                                                ↓           ↓
                                        Fix Code ←┘      Review → Deploy
                                           ↑
                                      (Loop until pass)
```

**Benefits**:
- Automatic error recovery
- Test-driven approach
- Clear quality gate (tests must pass)
- Reduces manual intervention

### Pattern 3: Amazon Q Developer (Real Example)

**Use Case**: Modernize thousands of legacy Java applications.

**Agent Structure**:
- **Agent 1**: Analyze dependencies and compatibility
- **Agent 2**: Update syntax to modern Java
- **Agent 3**: Run comprehensive test suites
- **Agent 4**: Document all changes made

**Execution**: All agents work in parallel, coordinator synthesizes results.

**Results**: Successfully modernized large codebases at scale.

**Lessons**:
- Specialization enables complex transformations
- Parallel execution critical for scale
- Comprehensive testing prevents regressions
- Documentation agent ensures maintainability

---

## Sources

- [Google's Eight Essential Multi-Agent Design Patterns](https://www.infoq.com/news/2026/01/multi-agent-design-patterns/)

---

**Related Documentation**:
- [state-management.md](state-management.md) - Memory and context patterns
- [../../instructions/multi-agent-orchestration.md](../../instructions/multi-agent-orchestration.md) - Framework selection
- [../../patterns/code-review/parallel-review.md](../../patterns/code-review/parallel-review.md) - Parallel review implementation
