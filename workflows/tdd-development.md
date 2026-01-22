# Test-Driven Development with AI

Comprehensive patterns for TDD workflows with AI assistants based on 2026 industry research.

---

## Overview

Test-Driven Development has proven highly effective with AI-assisted code generation. Tests act as guard rails, quality barriers, and clear success criteria for LLMs.

**Key Finding**: Research shows that providing LLMs with tests in addition to problem statements significantly enhances code generation outcomes (IEEE/ACM 2024).

**Real-World Success**: At Anthropic, approximately 90% of Claude Code is written by Claude Code itself using TDD principles.

---

## Why TDD Works with AI

### 1. Guard Rails for Code Generation

**Concept**: Tests act as user-defined, context-specific constraints

**Benefits**:
- LLM tries to fulfill test requirements from the beginning
- Avoids nasty surprises down the road
- Clear boundaries for acceptable implementation

**Example**:
```
Without tests: "Generate a function to process user input"
→ Ambiguous, many possible implementations

With tests: "Generate a function that passes these tests: [test cases]"
→ Clear requirements, specific expected behavior
```

### 2. Quality Barriers

**Concept**: Human defines design intent, AI implements within constraints

**Benefits**:
- Tests verify correctness against predefined criteria
- Discipline where human sets quality standards
- AI explores implementation space within boundaries

**Pattern**:
```
Human: Defines what constitutes correct behavior (tests)
AI: Explores how to achieve that behavior (implementation)
Tests: Validate the implementation meets the defined behavior
```

### 3. Edge Cases from Start

**Concept**: Include edge cases and boundary conditions in tests upfront

**Benefits**:
- Generated code handles edge cases from beginning
- Reduces debugging cycles
- More robust implementations

**Example Tests**:
```javascript
test("handles empty array", () => {...});
test("handles single element", () => {...});
test("handles null input", () => {...});
test("handles very large input", () => {...});
test("handles special characters", () => {...});
```

---

## TDD Workflow Patterns

### Pattern 1: Tests-First Generation

**Classic TDD adapted for AI**

**Steps**:
1. **Human writes failing tests**
   - Define expected behavior
   - Include edge cases
   - Specify error handling

2. **Provide tests + requirements to LLM**
   - Clear context on what to build
   - Tests define success criteria
   - Any additional constraints or patterns

3. **LLM generates code to pass tests**
   - Implementation guided by test requirements
   - AI explores solutions within test constraints

4. **Run tests, iterate on failures**
   - Identify which tests fail
   - AI adjusts implementation
   - Repeat until all pass

5. **Human reviews passing implementation**
   - Verify implementation quality
   - Check for maintainability
   - Ensure no unintended side effects

**Benefits**:
- Clear success criteria (tests pass)
- Reduced ambiguity (tests are executable specs)
- Faster convergence (AI knows when done)
- Higher confidence in AI-generated code

**Example Workflow**:
```
1. Human writes test:
   test("calculateDiscount applies 10% for orders over $100", () => {
       expect(calculateDiscount(150)).toBe(135);
   });

2. Prompt to AI:
   "Implement calculateDiscount to pass this test: [test code]
    Additional context: Discount logic should be clear and maintainable."

3. AI generates implementation

4. Run test → Passes or get specific failure

5. If fails, AI adjusts based on failure message

6. Human reviews passing code for quality
```

### Pattern 2: Chunked TDD

**Break large tasks into testable chunks**

**Concept**: "A chunked workflow fits nicely with a test-driven development (TDD) approach where developers can write or generate tests for each piece as they go."

**Steps**:
1. **Identify logical chunks**
   - Functions
   - Classes
   - Modules
   - Features

2. **For each chunk**:
   - Write/generate tests for that chunk
   - Generate implementation for that chunk
   - Verify tests pass
   - Integrate with existing code

3. **Move to next chunk**
   - Build on completed chunks
   - Maintain test coverage throughout

**Benefits**:
- Fits within LLM context windows
- Incremental progress with continuous validation
- Early detection of design issues
- Manageable scope per iteration

**Example**:
```
Feature: User Authentication System

Chunk 1: Password Validation
- Tests for password strength requirements
- Generate password validation logic
- Verify tests pass

Chunk 2: User Registration
- Tests for registration flow
- Generate registration logic (using password validator from Chunk 1)
- Verify tests pass

Chunk 3: Login Process
- Tests for authentication
- Generate login logic (using registration from Chunk 2)
- Verify tests pass

Chunk 4: Session Management
- Tests for session handling
- Generate session logic
- Verify tests pass
```

### Pattern 3: AI-Generated Tests + Human Review

**Leverage AI to accelerate test creation**

**Steps**:
1. **Human provides requirements**
   - What should the code do?
   - What are the constraints?
   - What are known edge cases?

2. **AI generates tests based on requirements**
   - Comprehensive test coverage
   - May identify edge cases human missed
   - Structured test suites

3. **Human reviews and refines tests**
   - Validate tests match intent
   - Add missing test cases
   - Remove inappropriate tests
   - Adjust assertions

4. **AI generates implementation**
   - Code to pass reviewed tests

5. **Verify tests pass**
   - Run test suite
   - Iterate if needed

**Benefits**:
- Faster test creation
- AI may think of edge cases human overlooked
- Human ensures tests are appropriate and complete
- Combines speed of AI with judgment of human

**Example Prompt for Test Generation**:
```
"Generate comprehensive unit tests for a function that:
- Converts temperature between Celsius and Fahrenheit
- Should handle decimal values
- Should validate input is a number
- Should throw error for invalid input

Include tests for:
- Normal cases (0°C, 100°C, 32°F, 212°F)
- Edge cases (negative temperatures, extreme values)
- Error cases (null, undefined, non-numeric)
- Boundary values"
```

---

## Challenges with LLM Applications

### Traditional Testing Limitations

**Problem**: "With the rise of LLMs, the regular software development cycle doesn't really work because you can't write a simple test."

**Reasons**:
- **Non-deterministic outputs**: LLMs may generate different responses to same input
- **Context-dependent behavior**: Output varies based on conversation history
- **Emergent capabilities**: Unexpected behaviors difficult to specify in advance

**Example**:
```javascript
// Traditional test (deterministic)
expect(add(2, 3)).toBe(5); // Always true

// LLM application test (non-deterministic)
expect(llm.generate("Hello")).toBe("Hi there!"); // May fail randomly
```

### Solution: AI Evals

**Definition**: Continually gather and curate test suites to measure how well your LLM application is working

**Requirements**:
- **Curated eval datasets**: Representative examples with expected quality
- **Evaluation metrics**: How to measure quality (heuristics, LLM-as-judge, custom)
- **Continuous updates**: Evolve evals as requirements and world changes
- **CI/CD integration**: Run evals automatically on every change

**Evaluation Approaches**:

**1. Heuristic Evaluation**
- Rule-based checks
- Fast and deterministic
- Example: Response length, keyword presence, format validation

**2. LLM-as-Judge**
- Use another LLM to evaluate output quality
- Flexible, captures nuance
- Example: "Rate this response 1-10 for helpfulness and accuracy"

**3. Custom Scoring**
- Domain-specific validation
- Business logic checks
- Example: Verify generated SQL is syntactically valid and safe

**Integration**: "Integrate AI evals into CI/CD pipeline to catch regressions early"

---

## Testing Pyramid for AI Code

### Unit Tests (Base - Most Tests)

**Purpose**: Test individual functions and methods in isolation

**AI Role**: Generate tests based on function signature and docstring

**Human Role**: Review for completeness, add edge cases, validate quality

**Pattern**:
```
Human: "Write comprehensive unit tests for this function:

def calculate_shipping(weight, distance, express=False):
    '''Calculate shipping cost based on weight, distance, and shipping speed.

    Args:
        weight: Package weight in kg (positive number)
        distance: Shipping distance in km (positive number)
        express: Whether to use express shipping (default False)

    Returns:
        Shipping cost in dollars

    Raises:
        ValueError: If weight or distance is negative or zero
    '''
    pass
"

AI: Generates comprehensive unit tests covering:
- Normal cases (various weights and distances)
- Edge cases (very small/large values, boundary conditions)
- Error cases (negative values, zero values)
- Express vs. standard shipping
- Type validation