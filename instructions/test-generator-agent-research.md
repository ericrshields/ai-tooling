# Test Generator Agent - Research & References

**Status**: Future implementation (Recommendation 2.3 from retrospective)
**Purpose**: Collect research and patterns for automated test generation agent
**Last Updated**: 2026-01-29

---

## Overview

Future agent for automatically generating test files from specifications, plans,
and component implementations. Should support multiple testing approaches beyond
traditional example-based tests.

---

## Testing Approaches to Support

### 1. Traditional Unit/Integration Tests

**Current Scope** (from Recommendation 2.3):
- Generate unit tests from component specifications
- Auto-generate integration tests for API interactions
- Target specific coverage thresholds (e.g., 80%)
- Follow project conventions (Jest, React Testing Library)

**Example Output**:
```typescript
// Auto-generated from KeepersTable component spec
describe('KeepersTable', () => {
  it('renders keeper rows', () => { /* ... */ })
  it('sorts by columns', () => { /* ... */ })
  it('calls edit handler on edit click', () => { /* ... */ })
})
```

### 2. Property-Based Testing

**Concept**: Generate many test inputs automatically based on properties/invariants

**Tools**:
- `fast-check` (JavaScript/TypeScript)
- `Hypothesis` (Python)
- `QuickCheck` (Haskell, original)

**Use Cases**:
- Testing that serialization roundtrips correctly
- Verifying commutative/associative properties
- Ensuring invariants hold across many inputs

**Example**:
```typescript
import fc from 'fast-check'

it('serialization roundtrips', () => {
  fc.assert(
    fc.property(fc.record({
      name: fc.string(),
      age: fc.nat()
    }), (user) => {
      expect(deserialize(serialize(user))).toEqual(user)
    })
  )
})
```

### 3. Deterministic Simulation Testing (DST)

**Reference**: [Deterministic Simulation Testing](https://poorlydefinedbehaviour.github.io/posts/deterministic_simulation_testing/)

**Key Innovation**: Goes beyond property-based testing by:
1. **Removing non-determinism** through seeded PRNGs
2. **Generating stateful action sequences** (not just isolated inputs)
3. **Enabling bug reproduction** via saved seeds
4. **Injecting failures systematically** (crashes, network issues, delays)

**Core Components**:

#### Seeded Random Number Generator
```typescript
// Pseudo-random but reproducible
const rng = createSeededRNG(12345)
const action = rng.choice(['CREATE', 'UPDATE', 'DELETE'])

// Bug found? Re-run with same seed to reproduce
const bugReproducer = createSeededRNG(12345) // Same sequence
```

#### Failure Injection Model
```typescript
// Simulate realistic system failures
enum Failure {
  NodeCrash,        // Server dies unexpectedly
  NetworkPartition, // Messages don't arrive
  MessageDelay,     // Messages arrive out of order
  MessageDrop,      // Messages lost permanently
  DiskFull,         // Storage exhausted
  Restart           // Process restart (lose in-memory state)
}

// Inject failures according to model
if (rng.probability(0.05)) {
  injectFailure(Failure.MessageDelay)
}
```

#### Oracle Pattern
```typescript
// External observer checks invariants
class ConsensusOracle {
  checkInvariant(replicas: Replica[]) {
    // Invariant: If consensus reached, all replicas agree
    const decidedValues = replicas
      .filter(r => r.hasDecided())
      .map(r => r.getDecidedValue())

    if (decidedValues.length > 0) {
      assert(new Set(decidedValues).size === 1,
        "Multiple different values decided - consensus violated!")
    }
  }
}
```

**Use Cases**:
- Distributed systems (consensus protocols, replication)
- State machines with complex event sequences
- Systems with timing-dependent behavior
- Concurrent/parallel code with race conditions

**Example Application**:
```typescript
// Test Grafana alerting state machine
describe('Alerting State Machine (Simulation)', () => {
  it('maintains invariants under chaos', () => {
    const seed = Date.now()
    const rng = createSeededRNG(seed)

    const system = new AlertingSystem()
    const oracle = new AlertingOracle()

    for (let i = 0; i < 1000; i++) {
      // Generate random action
      const action = rng.choice([
        'CREATE_ALERT',
        'UPDATE_ALERT',
        'DELETE_ALERT',
        'TRIGGER_ALERT',
        'RESOLVE_ALERT'
      ])

      // Occasionally inject failures
      if (rng.probability(0.1)) {
        injectFailure(rng.choice([
          Failure.DatabaseUnavailable,
          Failure.NotificationServiceDown,
          Failure.NetworkTimeout
        ]))
      }

      // Execute action
      system.execute(action)

      // Verify invariants
      try {
        oracle.checkInvariants(system)
      } catch (err) {
        console.error(`Bug found at seed ${seed}, action ${i}`)
        throw err
      }
    }
  })
})
```

**Benefits for Test Generator Agent**:
- Automatically explore state space (don't need manual test cases)
- Find edge cases humans wouldn't think of
- Reproduce bugs deterministically (seed = bug report)
- Test resilience under failure conditions
- Verify system invariants hold across many scenarios

---

## Related Testing Patterns

### Model-Based Testing
Generate tests from formal model of system behavior (state machines, FSMs)

### Mutation Testing
Introduce bugs intentionally to verify tests catch them (test the tests)

### Fuzz Testing
Generate random/malformed inputs to find crashes and security issues

### Metamorphic Testing
Test relations between inputs/outputs rather than exact outputs
(e.g., "reversing twice should return original")

---

## Test Generator Agent Capabilities (Proposed)

### Input Sources
1. **Component specifications** (from component-specification-workflow.md)
   - User stories → acceptance criteria tests
   - Props API → type tests
   - State management → integration tests

2. **Implementation plans** (from planning-workflow.md)
   - Verification steps → test cases
   - Edge cases → edge case tests
   - Error scenarios → error handling tests

3. **Existing code** (via static analysis)
   - Exported functions → unit tests
   - React components → rendering tests
   - API endpoints → integration tests

4. **System invariants** (from specifications)
   - "Active keeper is unique" → property test
   - "Data never lost" → simulation test with failures

### Output Types

1. **Unit Tests** (Jest, Vitest)
   ```typescript
   // Generated from function signature + JSDoc
   describe('calculateTotal', () => {
     it('sums positive numbers', () => { /* ... */ })
     it('handles empty array', () => { /* ... */ })
     it('handles negative numbers', () => { /* ... */ })
   })
   ```

2. **Component Tests** (React Testing Library)
   ```typescript
   // Generated from component props and user stories
   describe('KeepersTable', () => {
     it('renders empty state when no keepers', () => { /* ... */ })
     it('renders keeper rows', () => { /* ... */ })
     it('sorts by column on header click', () => { /* ... */ })
   })
   ```

3. **Property Tests** (fast-check)
   ```typescript
   // Generated from type signatures and invariants
   it('serialization roundtrips', () => {
     fc.assert(fc.property(keeperArbitrary, (keeper) => {
       expect(deserialize(serialize(keeper))).toEqual(keeper)
     }))
   })
   ```

4. **Simulation Tests** (custom framework)
   ```typescript
   // Generated from state machine + invariants
   it('maintains invariants under chaos', () => {
     simulateWithFailures(system, {
       actions: ['CREATE', 'UPDATE', 'DELETE'],
       failures: [NodeCrash, NetworkPartition],
       iterations: 10000,
       invariants: [uniqueActiveKeeper, dataConsistency]
     })
   })
   ```

### Coverage Analysis
- Measure coverage after generation
- Add tests for uncovered branches
- Suggest additional test scenarios

### Test Quality Checks
- Verify tests actually test something (not always passing)
- Check for flaky tests (non-deterministic)
- Ensure tests follow project conventions
- Validate test naming and organization

---

## Integration with Planning Workflow

**Phase 4: Create Implementation Plan**
- Agent analyzes plan verification steps
- Generates initial test suite outline
- Identifies testing gaps

**Phase 5: Implementation**
- Generate tests before or during implementation
- TDD approach: tests first, then implementation
- Parallel generation: tests + implementation simultaneously

**Phase 6: Verification**
- Run generated tests
- Measure coverage
- Add missing tests for gaps

---

## Challenges & Considerations

### Challenge 1: Test Quality
- Generated tests may be too simple or miss edge cases
- Need to balance quantity vs quality

**Mitigation**:
- Use specifications as ground truth
- Include property-based and simulation tests (explore state space)
- Human review generated tests
- Iterative refinement based on bugs found

### Challenge 2: Maintenance
- Generated tests need updating when code changes
- Risk of generating unmaintainable tests

**Mitigation**:
- Generate readable, idiomatic tests
- Follow project conventions strictly
- Include comments explaining what's being tested
- Provide regeneration capability

### Challenge 3: Project-Specific Conventions
- Each project has different test patterns
- Mocking strategies vary

**Mitigation**:
- Learn from existing tests in codebase
- Allow configuration of conventions
- Detect patterns automatically (existing test analysis)

### Challenge 4: Complex Dependencies
- Hard to generate tests for code with many dependencies
- Mocking external services

**Mitigation**:
- Analyze dependency graph
- Suggest refactoring if too tightly coupled
- Generate test fixtures/factories
- Use MSW for API mocking (HTTP level)

---

## References

### Articles
- [Deterministic Simulation Testing](https://poorlydefinedbehaviour.github.io/posts/deterministic_simulation_testing/) - Core DST concepts, Paxos example
- [Property-Based Testing](https://increment.com/testing/in-praise-of-property-based-testing/) - Introduction to PBT
- [Testing Without Mocks](https://www.jamesshore.com/v2/blog/2018/testing-without-mocks) - Sociable testing patterns

### Tools & Libraries
- [fast-check](https://github.com/dubzzz/fast-check) - Property-based testing for JS/TS
- [Hypothesis](https://hypothesis.readthedocs.io/) - Property-based testing for Python
- [Jepsen](https://jepsen.io/) - Distributed systems testing (simulation + real systems)
- [FoundationDB Testing](https://apple.github.io/foundationdb/testing.html) - Real-world DST implementation
- [Antithesis](https://antithesis.com/) - Commercial DST platform

### Patterns
- [Test Desiderata](https://kentbeck.github.io/TestDesiderata/) - Kent Beck on test properties
- [Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html) - Martin Fowler on test strategy
- [Oracle Problem](https://en.wikipedia.org/wiki/Test_oracle) - How to know expected output

---

## Next Steps (When Implementing)

1. **Start Simple**: Generate basic unit tests from function signatures
2. **Add Property Tests**: For pure functions and data transformations
3. **Component Tests**: For React components from specs
4. **Simulation Tests**: For complex state machines and distributed features
5. **Refinement**: Learn from human feedback, improve quality

---

**Related Agents**:
- [plan-reviewer-agent.md](plan-reviewer-agent.md) - Validates plan verification steps (test input)
- [document-analyzer-agent.md](../../.ai-context-store/user-wide/rules/document-analyzer-agent.md) - Extracts test requirements from specs

**Related Documentation**:
- [component-specification-workflow.md](../../.ai-context-store/user-wide/rules/component-specification-workflow.md) - Test strategy section
- [ai-tooling-improvements-secrets-keeper-retrospective.md](../../.ai-context-store/plans/ai-tooling-improvements-secrets-keeper-retrospective.md) - Recommendation 2.3
