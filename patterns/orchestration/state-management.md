# State Management Patterns for Multi-Agent Systems

Patterns for efficient state and context management in multi-agent orchestration.

---

## Overview

Proper state management is critical for multi-agent performance and scalability. Poor patterns lead to exponential token growth and context exhaustion.

**Key Principle**: Agents recall exactly the snippets they need for the current step, not entire conversation histories.

---

## Anti-Pattern: Context Stuffing

### The Problem

**Pattern**: Passing entire conversation history to every agent at every step.

**Consequences**:
- Exponential token growth
- Slow inference times
- High costs
- Context window exhaustion
- Poor scalability

**Example of Bad Practice**:
```
Agent receives: [Every message from session start to now]
Token usage: Grows linearly with session length
Result: Unsustainable for long sessions
```

---

## Best Practice: Memory-Based Workflow

### The Solution

**Approach**: Agents recall exactly the snippets they need for current step.

**Implementation**:
- **Short-term memory (STM)**: Recent inputs for immediate decisions
- **Long-term memory (LTM)**: Stored across sessions in databases or vector stores
- **Working memory**: Active context for current specific task

**Benefits**:
- Constant token usage regardless of session length
- Faster execution
- Scalable to long-horizon tasks
- Efficient context utilization

**Example of Good Practice**:
```
Agent receives: [Relevant context for current task only]
Token usage: Constant regardless of session length
Result: Sustainable for indefinite sessions
```

---

## State Delta Pattern (LangGraph)

### Concept

**Pattern**: Pass only what changed, not entire state.

**Implementation**:
```
Previous State: {user: "John", task: "review", file: "auth.py"}
Action: Updated severity of issue
State Delta: {issue_severity: "high"}
New State: {user: "John", task: "review", file: "auth.py", issue_severity: "high"}
```

**Benefits**:
- Minimal token usage
- Clear change tracking
- Efficient state updates
- Easy debugging (can see exactly what changed)

---

## Memory Architecture

For detailed memory patterns, see [../../instructions/agent-memory-patterns.md](../../instructions/agent-memory-patterns.md).

### Memory Types

**Factual Memory (Knowledge)**:
- Facts, data, domain knowledge
- Storage: Databases, knowledge graphs
- Retrieval: Semantic search, indexing

**Experiential Memory (Insights & Skills)**:
- Learned patterns, successful strategies
- Storage: Vector embeddings, example libraries
- Retrieval: Similarity search, clustering

**Working Memory (Active Context)**:
- Current task state, recent interactions
- Storage: In-process, fast access
- Retrieval: Immediate access, no search

### Memory Lifecycle

**Formation**: Identify what to remember, structure for retrieval.

**Evolution**: Consolidate similar experiences, forget outdated information.

**Retrieval**: Semantic search, temporal ordering, similarity matching.

---

## Performance Optimization Strategies

### Token Efficiency

**Techniques**:
- Use state deltas (LangGraph pattern)
- Implement memory-based retrieval
- Prune irrelevant context
- Summarize long conversations
- Share factual memory across agents

### Execution Speed

**Techniques**:
- Maximize parallelism for independent tasks
- Use faster framework (LangGraph) for critical paths
- Optimize slowest agents first
- Consider timeout strategies
- Cache repeated computations

### Cost Optimization

**Techniques**:
- Track token usage per agent
- Use cheaper models for non-critical agents
- Implement result caching
- Batch similar operations
- Set budget limits

---

## Framework-Specific Patterns

### LangGraph State Management

**Approach**: Pass state deltas between nodes.

**Benefits**:
- Lowest token consumption of all frameworks
- 2.2x faster than CrewAI
- Efficient memory usage

**When to Use**: Production systems, performance-critical applications, strict resource budgets.

### CrewAI State Management

**Approach**: Full context visibility - agents see all previous work.

**Benefits**:
- Comprehensive awareness
- Context-aware decision making
- Thoughtful deliberation

**Trade-off**: Slower (2.2x) but more thorough.

**When to Use**: Quality and thoroughness over speed, research tasks, content creation.

### AutoGen State Management

**Approach**: Message-based communication.

**Benefits**:
- Flexible agent interaction
- Rich communication protocols
- Asynchronous messaging

**When to Use**: Conversational AI, systems requiring complex inter-agent communication.

---

## Best Practices

### For Short Tasks (< 1 hour)

- **Working Memory**: Sufficient for most needs
- **State Delta**: Not critical
- **Context Stuffing Risk**: Low

### For Medium Tasks (1 hour - 1 day)

- **Working Memory**: Track task state
- **State Delta**: Beneficial for efficiency
- **Memory Retrieval**: Reference past similar tasks

### For Long Tasks (> 1 day)

- **Working Memory**: Current session only
- **State Delta**: Critical for scalability
- **Memory Retrieval**: Essential for context
- **Consolidation**: Regular summarization needed

---

## Integration with Other Patterns

**With Parallel Pattern**: Each parallel agent maintains independent working memory, shares factual memory.

**With Loop Pattern**: Working memory updated each iteration, factual memory referenced for validation.

**With Hierarchical Pattern**: Supervisor maintains high-level state, workers maintain task-specific state.

---

**Related Documentation**:
- [google-eight-patterns.md](google-eight-patterns.md) - Pattern catalog
- [../../instructions/agent-memory-patterns.md](../../instructions/agent-memory-patterns.md) - Memory architecture details
- [../../instructions/multi-agent-orchestration.md](../../instructions/multi-agent-orchestration.md) - Framework selection
- [../../instructions/context-efficiency.md](../../instructions/context-efficiency.md) - Context management principles
