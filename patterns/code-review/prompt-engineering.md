# Prompt Engineering for AI Code Review

Comprehensive prompt patterns for automated code review using LLMs based on 2026 industry research.

---

## Overview

AI-powered code review has matured significantly by 2026. Prompt engineering is the foundation for effective LLM-based code review, enabling specialized, accurate, and actionable feedback.

**Key Principle**: Clear prompts with role assignment, context, and constraints produce better results than generic review requests.

---

## Core Techniques (2026)

### 1. Role Prompting

**Concept**: Explicitly assign the LLM a role, profession, or perspective.

**Effect**: Improves relevance, tone, and domain focus.

**Examples**:
```
"You are a security auditor assessing the following code for OWASP vulnerabilities"

"You are a senior performance engineer reviewing this code for optimization opportunities"

"You are a staff engineer enforcing team code standards and best practices"
```

**Best Practices**:
- Be specific about the role and expertise level
- Include relevant background (e.g., "with 10 years experience")
- Specify the perspective (security, performance, maintainability)

### 2. Few-Shot Learning

**Concept**: Provide examples of good/bad code with explanations.

**Research Finding**: "When data insufficient for fine-tuning, use few-shot learning without persona"

**Pattern**:
```
Example 1 (Bad):
[code snippet with vulnerability]
Issue: SQL injection vulnerability due to string concatenation
Severity: Critical

Example 2 (Good):
[code snippet with parameterized query]
Correct approach: Uses parameterized queries to prevent injection

Now review:
[code to review]
```

**Best Practices**:
- Use examples from same codebase when possible
- Include severity ratings
- Explain why it's good or bad
- 2-3 examples typically sufficient

### 3. Chain-of-Thought

**Concept**: Ask LLM to explain reasoning step-by-step.

**Effect**: Improves accuracy for complex analysis.

**Pattern**:
```
"Review this code for security issues. For each issue found:
1. Explain what the vulnerability is
2. Describe how it could be exploited
3. Assess the severity
4. Recommend a specific fix"
```

**Benefits**:
- More thorough analysis
- Better explanations
- Easier to validate reasoning
- Helps catch subtle issues

### 4. Zero-Shot with Context

**Concept**: Provide clear instructions without examples.

**Pattern**:
```
"Analyze this code for:
- Performance bottlenecks
- Memory leaks
- Inefficient algorithms
- Opportunities for caching

Prioritize issues by impact."
```

**When to Use**:
- Pattern detection
- Structural analysis
- Well-defined criteria
- Simple review tasks

### 5. Meta Prompting

**Concept**: Have LLM generate review criteria, then apply them.

**Pattern**:
```
Step 1: "Given this codebase's architecture and patterns, what should code review criteria be?"
Step 2: Use generated criteria to review code
```

**Benefits**:
- Adapts to project-specific standards
- Discovers implicit patterns
- Creates tailored review checklists

### 6. Self-Consistency

**Concept**: Generate multiple reviews, identify consensus.

**Pattern**:
```
Run review 3 times with same prompt
Compare results
Report only issues found in 2+ runs
```

**Benefits**:
- Reduces false positives
- Increases confidence in findings
- Catches non-deterministic issues

---

## Fine-Tuning vs. Prompt Engineering

### Research Findings (2026)

**Optimal Approach**: "LLMs for code review should be fine-tuned to achieve highest performance"

**Fallback**: "When data insufficient for fine-tuning, use few-shot learning without persona"

**Implication**: Investment in fine-tuned models pays off for production use.

### When to Fine-Tune

**Invest in Fine-Tuning When**:
- High volume of code reviews
- Consistent codebase patterns
- Specific domain requirements
- Critical quality requirements
- Sufficient training data available (hundreds of reviewed PRs)

**Returns**:
- Better accuracy
- Fewer false positives
- Faster execution (smaller prompts)
- Consistent quality

### When to Use Prompt Engineering

**Rely on Prompts When**:
- Limited training data
- Diverse codebases
- Rapidly evolving standards
- Prototyping and experimentation
- Flexibility more valuable than optimization

---

## Prompt Patterns for Code Review

### Pattern 1: Context + Question + Constraints

**Structure**:
```
Context: [What is this code, what does it do]
Question: [What specific analysis to perform]
Constraints: [Assumptions, boundaries, focus areas]
```

**Example**:
```
Context: "This is a React component that handles user authentication flow"
Question: "Review this code for security vulnerabilities"
Constraints: "Focus on OWASP Top 10, assume external API calls are trusted, ignore UI styling issues"
```

**Benefits**:
- Clear scope
- Relevant analysis
- Avoids tangential issues

### Pattern 2: Role + Code + Checklist

**Structure**:
```
Role: [Who is doing the review]
Code: [The code to review]
Checklist: [Specific items to check]
```

**Example**:
```
Role: "You are a senior security engineer with expertise in web application security"
Code: [authentication code block]
Checklist:
- Input validation on all user inputs
- SQL injection risks in database queries
- XSS vulnerabilities in output rendering
- Authentication token security
- Secrets management (no hardcoded credentials)
- Session management security
```

**Benefits**:
- Comprehensive coverage
- Systematic review
- Trackable items

### Pattern 3: Comparison + Analysis

**Structure**:
```
"Compare this implementation to [reference].
Identify inconsistencies and suggest alignment."
```

**Example**:
```
"Compare this authentication implementation to the pattern in auth/standard-auth.py.
Identify:
1. Deviations from the standard pattern
2. Missing security measures present in the standard
3. Improvements made in this version
4. Recommendations for alignment"
```

**Benefits**:
- Ensures consistency
- Leverages existing patterns
- Identifies improvements and regressions

### Pattern 4: Historical Context

**Structure**:
```
"This code replaces [old implementation].
Review for:
1. [Migration concern 1]
2. [Migration concern 2]
..."
```

**Example**:
```
"This code replaces the authentication system in auth-v1.py.
Review for:
1. Backward compatibility - can existing sessions still work?
2. Migration path - how do users transition?
3. Performance - is this faster or slower than v1?
4. Security - any regressions in security posture?"
```

**Benefits**:
- Migration-aware
- Prevents regressions
- Smooth transitions

---

## Best Practices from Practitioners

### 1. Treat LLM as Pair Programmer

**Principle**: "Experienced developers treat the LLM as a powerful pair programmer that requires clear direction, context and oversight rather than autonomous judgment."

**Implementation**:
- Provide clear instructions
- Give sufficient context
- Validate recommendations
- Don't blindly accept suggestions
- Maintain human oversight

### 2. Define Clear Review Criteria

**Before Requesting Review**:
- What specific issues are you looking for?
- What patterns are acceptable/unacceptable?
- What is the risk tolerance for this code?
- What are the priorities (security > performance > style)?

**Example Criteria Document**:
```markdown
# Code Review Criteria - Payment Module

## Critical (Must Fix)
- Security vulnerabilities (OWASP Top 10)
- Data loss scenarios
- Race conditions in transactions

## High Priority (Should Fix)
- Performance issues (>100ms response time)
- Error handling gaps
- Missing transaction logging

## Low Priority (Nice to Fix)
- Code style inconsistencies
- Minor refactoring opportunities
```

### 3. Provide Sufficient Context

**Include**:
- Purpose of the code (what problem it solves)
- Existing patterns in codebase (reference files)
- Known constraints (performance, compatibility)
- Related code files (dependencies, callers)
- Business context (why this matters)

**Example**:
```
"Review this payment processing code.

Context:
- Purpose: Handle credit card payments for subscriptions
- Existing pattern: See payment/stripe-integration.py for reference
- Constraints: Must complete within 3 seconds, PCI DSS compliant
- Related: payment/models.py, payment/webhook-handler.py
- Business: Critical path, handles $1M+/day in transactions

Focus on security and reliability."
```

### 4. Validate Review Quality

**Ongoing Quality Assurance**:
- Spot-check AI reviews against human reviews (sample 10%)
- Track false positives (flagged issues that aren't real)
- Track false negatives (missed issues found later)
- Refine prompts based on errors
- Fine-tune models when sufficient data available

**Metrics to Track**:
- Agreement rate with human reviews
- False positive rate
- False negative rate (from post-merge issues)
- Time saved vs. manual review
- Developer satisfaction

### 5. Parallel Over Sequential

**Principle**: Run independent reviews in parallel.

**Benefits**:
- Reduce total review time (5-6x faster)
- Minimize iteration churn (get all feedback at once)
- Improve developer experience (faster feedback)
- Comprehensive coverage (no dimension skipped for time)

**Implementation**:
```
# Bad: Sequential
security_review(code)      # 3 minutes
performance_review(code)   # 2 minutes
maintainability_review(code) # 2 minutes
Total: 7 minutes

# Good: Parallel
parallel_execute([
    security_review(code),
    performance_review(code),
    maintainability_review(code)
])
Total: 3 minutes (slowest agent)
```

---

## Sources

- [AI Prompts for Code Review: Catch Bugs, Improve Structure, Ship Better Code](https://5ly.co/blog/ai-prompts-for-code-review/)
- [Fine-tuning and prompt engineering for large language models-based code review automation](https://www.sciencedirect.com/science/article/pii/S0950584924001289)
- [Best practices for LLM prompt engineering](https://www.palantir.com/docs/foundry/aip/best-practices-prompt-engineering)
