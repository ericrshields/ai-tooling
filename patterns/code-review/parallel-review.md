# Multi-Dimensional Parallel Code Review

Patterns for running specialized review agents in parallel with result synthesis.

---

## Overview

**Core Pattern**: Run multiple review agents in parallel, each focused on specific dimension, then synthesize results.

**Benefits**:
- **Speed**: 5-6x faster than sequential reviews
- **Specialization**: Each agent focuses on its expertise area
- **Reduced churn**: Collect all feedback before iterating
- **Comprehensive**: No dimension overlooked

---

## Review Dimensions

### 1. Security Review

**Focus Areas**:
- OWASP Top 10 vulnerabilities
- Authentication and authorization flaws
- Input validation and sanitization
- Secrets in code or logs
- Dependency vulnerabilities
- Cryptography usage
- Session management
- Error handling (information leakage)

**Prompt Example**:
```
"You are a security engineer. Review this code for security vulnerabilities:
1. OWASP Top 10 risks
2. Authentication/authorization flaws
3. Input validation issues
4. Secrets or sensitive data in code
5. Dependency security concerns

For each issue found, provide:
- Vulnerability type
- Severity (Critical/High/Medium/Low)
- Exploitation scenario
- Specific remediation"
```

### 2. Performance Review

**Focus Areas**:
- Algorithmic complexity (Big O)
- Memory usage and leaks
- Database query optimization (N+1 queries, missing indexes)
- Caching opportunities
- Network efficiency (unnecessary calls, batching)
- Lazy loading vs. eager loading
- Resource cleanup

**Prompt Example**:
```
"You are a performance engineer. Analyze this code for performance issues:
1. Algorithmic complexity - identify O(n²) or worse
2. Memory usage - potential leaks or excessive allocation
3. Database queries - N+1 problems, missing indexes
4. Caching - opportunities for improvement
5. Network efficiency - redundant or unoptimized calls

Prioritize by impact on user experience."
```

### 3. Maintainability Review

**Focus Areas**:
- Code complexity (cyclomatic, cognitive)
- DRY violations (code duplication)
- SOLID principles compliance
- Naming conventions (clarity, consistency)
- Code organization (structure, modularity)
- Magic numbers and strings
- Comment quality and necessity
- Function/method length and responsibility

**Prompt Example**:
```
"You are a staff engineer reviewing for maintainability:
1. Code complexity - identify overly complex functions
2. DRY violations - duplicated logic
3. SOLID principles - violations and improvements
4. Naming - unclear or inconsistent names
5. Organization - structural improvements

Focus on long-term maintainability."
```

### 4. Accessibility Review (UI Code)

**Focus Areas**:
- WCAG 2.1/2.2 AA compliance
- Semantic HTML usage
- ARIA attributes (proper usage, not overuse)
- Keyboard navigation support
- Screen reader compatibility
- Color contrast ratios
- Focus management
- Alternative text for images

**Prompt Example**:
```
"You are an accessibility expert. Review this UI code for WCAG 2.2 AA compliance:
1. Semantic HTML - proper element usage
2. ARIA attributes - necessary and correct
3. Keyboard navigation - all interactive elements accessible
4. Screen reader - proper labeling and announcements
5. Color contrast - meets minimum ratios

Identify violations and provide fixes."
```

### 5. Style & Standards Review

**Focus Areas**:
- Linting rule compliance
- Formatting consistency (whitespace, indentation)
- Type safety (TypeScript, type annotations)
- Documentation completeness
- Naming conventions (camelCase, PascalCase, etc.)
- Import organization
- File structure conventions

**Prompt Example**:
```
"Review this code for style and standard compliance:
1. Linting rules - [specific rules]
2. Formatting - consistency with codebase
3. Type safety - proper type annotations
4. Documentation - JSDoc/docstrings present and accurate
5. Naming - follows team conventions [specify conventions]

Compare against existing codebase patterns in [files]."
```

### 6. Test Coverage Review

**Focus Areas**:
- Tests present for new code
- Edge cases covered
- Implementation-specific tests (brittle tests)
- Test quality and maintainability
- Test organization and naming
- Mock usage appropriateness
- Test data management

**Prompt Example**:
```
"Review the test coverage for this code:
1. Are tests present for all new functionality?
2. Are edge cases covered (null, empty, boundary values)?
3. Are tests implementation-specific (brittle)?
4. Is test quality good (clear, maintainable)?
5. Are integration points tested?

Suggest additional test cases needed."
```

---

## Implementation Pattern: Parallel Fan-Out/Gather

### Structure

```
Code Submission
       ↓
    Fan-Out
       ├→ Security Review Agent
       ├→ Performance Review Agent
       ├→ Maintainability Review Agent
       ├→ Accessibility Review Agent (if UI)
       ├→ Style & Standards Review Agent
       └→ Test Coverage Review Agent
       ↓ (All run in parallel)
    Gather Results
       ↓
 Synthesis Agent
       ↓
Combined Review Report
```

### Fan-Out Phase

**Distribute code to specialized review agents**

**Considerations**:
- Each agent receives full code context
- Clear mandate for each agent
- Independent execution (no dependencies between agents)
- Timeout handling for each agent

**Implementation**:
```
reviews = parallel_execute([
    (security_review, code),
    (performance_review, code),
    (maintainability_review, code),
    (accessibility_review, code) if is_ui_code else None,
    (style_review, code),
    (test_review, code, tests)
])
```

### Parallel Execution Phase

**Each agent analyzes independently**

**Requirements**:
- Agents don't share state
- Failures isolated (one agent failing doesn't block others)
- Progress tracking
- Resource limits (tokens, time)

**Monitoring**:
- Track each agent's progress
- Collect partial results if some agents timeout
- Log execution times for optimization

### Gather Phase

**Collect results from all agents**

**Handling**:
- Wait for all to complete (or timeout)
- Structure results uniformly
- Handle partial results gracefully
- Preserve agent-specific metadata

**Data Structure**:
```json
{
  "security": {
    "issues": [...],
    "status": "completed",
    "execution_time": "2.3s"
  },
  "performance": {
    "issues": [...],
    "status": "completed",
    "execution_time": "1.8s"
  },
  "maintainability": {
    "issues": [...],
    "status": "timeout",
    "partial_results": true
  }
}
```

### Synthesis Phase

**Combine findings into unified report**

**Synthesis Agent Responsibilities**:
- Merge all findings
- Identify duplicates across agents
- Resolve conflicts (different severity ratings)
- Prioritize issues (critical first)
- Group related issues
- Create actionable recommendations
- Generate summary statistics

**Output Structure**:
```markdown
# Code Review Summary

## Critical Issues (Requires immediate action)
- [Security] SQL Injection vulnerability in user input (auth.py:42)
- [Performance] N+1 query in user listing (users.py:156)

## High Priority
- [Maintainability] Function exceeds complexity threshold (process.py:88)
- [Accessibility] Missing ARIA labels on form inputs (form.tsx:23)

## Medium Priority
- [Style] Inconsistent naming convention (utils.py:15, 34, 67)
- [Test] Missing edge case tests for null inputs

## Suggestions
- [Performance] Consider caching user preferences
- [Maintainability] Extract complex logic to separate functions

## Statistics
- Total issues: 12
- Critical: 2
- High: 4
- Medium: 4
- Suggestions: 2
```

---

## AI-on-AI Code Review

### Emerging Pattern (2026)

**Concept**: One AI model reviews code generated by another AI model.

**Research Quote**: "Bolster quality gates around AI code contribution with more tests, more monitoring, and perhaps even AI-on-AI code reviews, which has been seen to catch things one model missed."

### Implementation Approaches

**1. Different Models**

**Pattern**:
- Generator: GPT-4 writes code
- Reviewer: Claude Sonnet 4.5 reviews code

**Benefit**: Different models have different strengths and blind spots.

**Example**:
```
GPT-4 generates implementation
   ↓
Claude reviews for:
   - Logic errors
   - Edge cases
   - Security issues
   - Best practices
```

**2. Different Contexts**

**Pattern**:
- Generator context: Optimistic, focus on implementation
- Reviewer context: Critical, focus on finding issues

**Benefit**: Cognitive separation prevents confirmation bias.

**Example**:
```
Generator prompt: "Implement this feature following best practices"
Reviewer prompt: "Find all potential issues, assume code is untrusted"
```

**3. Multi-Pass Review**

**Pattern**:
- Pass 1: Security-focused model/prompt
- Pass 2: Performance-focused model/prompt
- Pass 3: Maintainability-focused model/prompt

**Benefit**: Specialized expertise per pass.

**Example**:
```
Code generation
   ↓
Security review (model fine-tuned for security)
   ↓
Performance review (model specialized for optimization)
   ↓
Maintainability review (general model with maintainability prompt)
   ↓
Synthesis
```

---

## LLM-as-Judge Pattern

**Concept**: Use LLM to evaluate code quality systematically.

**Approaches**:

**1. Heuristic Scoring**:
```
"Evaluate this code on:
- Complexity (1-10, lower is better)
- Readability (1-10, higher is better)
- Maintainability (1-10, higher is better)

Provide score and justification."
```

**2. LLM-as-Judge**:
```
"Rate this code 1-10 for:
- Security (1=many vulnerabilities, 10=secure)
- Performance (1=poor, 10=optimal)
- Maintainability (1=hard to maintain, 10=easy)

Explain each rating."
```

**3. Custom Logic**:
```
"Based on our project standards:
- Max function length: 50 lines
- Max cyclomatic complexity: 10
- Required: Type annotations
- Required: Unit tests for public functions

Does this code meet standards? List violations."
```

**Application**: Use scores to decide whether code needs revision before merging.

---

**Related Documentation**:
- [parallel-review.md](parallel-review.md) - Multi-dimensional review implementation
- [ci-cd-integration.md](ci-cd-integration.md) - Quality gates and CI/CD
- [../../rules/multi-agent-orchestration.md](../../rules/multi-agent-orchestration.md) - Agent coordination patterns
