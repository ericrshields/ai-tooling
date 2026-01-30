# Coding Practices Reference

Industry-standard development practices and approaches. This reference presents options and patterns for different project contexts. Project-specific instruction files should select and configure the appropriate practices for each codebase.

---

## Purpose of This Document

This document provides a **menu of options** rather than universal requirements. Different projects have different needs:

- **Startups with tight deadlines** may prioritize speed over comprehensive testing
- **Enterprise applications** may require strict testing and security practices
- **Prototypes** may skip formal testing entirely
- **Safety-critical systems** may need formal verification

**How to Use**: Read this as a reference. Create project-specific instruction files that specify which practices apply to your project and how strictly they should be enforced.

---

## I. Error Handling Approaches

### Standard Practice (Recommended for Most Projects)

Asynchronous operations should implement proper error handling.

**Typical Requirements**:
- Async functions use appropriate error handling mechanisms (try-catch, error returns, etc.)
- Errors are logged or propagated rather than silently swallowed
- User-facing errors display meaningful, actionable messages
- API/Service errors are transformed into consistent error shapes
- Critical sections implement error boundaries or recovery mechanisms

**When to Relax**: Prototypes, throwaway code, internal scripts

**When to Strengthen**: Production systems, user-facing applications, financial/healthcare systems

**Rationale**: Explicit error handling prevents silent failures that degrade user experience and makes debugging production issues tractable.

---

## II. Observability Strategies

### Logging Levels

Projects typically benefit from structured logging, though the required level varies.

**Common Approaches**:

**1. Minimal Logging (Prototypes, Scripts)**:
- Console logs for debugging
- Errors logged to stderr
- No structured format required

**2. Standard Logging (Most Applications)**:
- Structured logging with consistent format
- Log levels used appropriately (Debug, Info, Warn, Error)
- Significant events and state changes logged
- Sensitive data excluded (tokens, passwords, PII)

**3. Comprehensive Observability (Enterprise, Scale)**:
- Distributed tracing
- Performance instrumentation
- Correlation IDs across services
- Log aggregation and analysis
- Metrics and alerting

**When to Use Each**: Match observability investment to system criticality and operational needs.

**Rationale**: Structured logging enables rapid incident response and provides telemetry for identifying bottlenecks.

---

## III. Type Safety Options

### Language-Dependent Approaches

The appropriate level of type safety depends on the language and project context.

**Strongly Typed Languages (TypeScript, Rust, Go, Java)**:
- Use type systems fully; avoid escape hatches (any, unknown, dynamic)
- Explicit interfaces and type definitions
- External API responses validated against types
- Function signatures explicitly annotated

**Dynamically Typed Languages (Python, JavaScript, Ruby)**:
- Consider gradual typing (TypeScript, mypy, Sorbet)
- Document expected types in docstrings
- Validate inputs at boundaries
- Use type hints where supported

**When to Prioritize Type Safety**:
- Large codebases with multiple contributors
- Public APIs and libraries
- Long-lived production systems
- Complex business logic

**When Types Matter Less**:
- Small scripts and utilities
- Rapid prototypes
- Exploratory data analysis
- Projects with single maintainer

**Rationale**: Strong typing catches errors before runtime, improves IDE support, and serves as executable documentation.

---

## IV. Testing Strategies

### Overview

Multiple testing approaches exist, each with different tradeoffs. Choose based on project needs, team culture, and timeline constraints.

**Key Finding (2026 Research)**: "The most successful development teams often combine elements from each approach" rather than following one methodology exclusively.

---

### Option A: Test-Driven Development (TDD)

**Definition**: Write tests before implementation (Red-Green-Refactor cycle).

**When TDD Works Best**:
- Complex business logic requiring verification
- Long-lived projects where quality compounds
- Critical systems (healthcare, finance, aviation)
- Teams experienced with TDD
- Unit-level tests for specific functions/methods

**When TDD May Not Fit**:
- Quick prototypes or MVPs with tight deadlines (15-35% time increase)
- Unclear or rapidly changing requirements
- GUI development (automation costs exceed manual testing)
- Exploratory programming or research
- Small scripts or one-off utilities

**Benefits**:
- 40-90% reduction in defect rates (IBM/Microsoft study)
- Tests serve as executable specifications
- Confidence in refactoring
- Clear success criteria for AI-generated code

**Challenges**:
- Steep learning curve for beginners
- Initial time investment
- Requires mindset shift from traditional coding

**Typical Patterns**:
- GIVEN/WHEN/THEN structure
- Tests fail before implementation
- Independent, order-agnostic tests
- Minimal mocking; prefer integration tests

**Sources**: [Test-Driven Development trends 2026](https://medium.com/@sharmapraveen91/tdd-vs-bdd-vs-ddd-in-2025-choosing-the-right-approach-for-modern-software-development-6b0d3286601e), [TDD Myths](https://thinksys.com/development/test-driven-development-myths/), [When to use TDD](https://www.jrebel.com/blog/when-to-use-test-driven-development)

---

### Option B: Behavior-Driven Development (BDD)

**Definition**: Specify system behavior from user perspective, often using Given-When-Then syntax (Gherkin).

**When BDD Works Best**:
- Cross-functional collaboration (product, engineering, QA)
- End-to-end feature development
- Customer-facing applications where UX is critical
- Projects requiring non-technical stakeholder involvement

**Benefits**:
- Natural language specifications accessible to all stakeholders
- Focuses on user value over implementation details
- Facilitates shared understanding across disciplines
- Works well with AI (specifications in natural language)

**Typical Tools**: Cucumber, SpecFlow, Behave, Cypress (BDD style)

**Pattern**:
```gherkin
Feature: User Authentication
  Scenario: Successful login
    Given a registered user with email "user@example.com"
    When they enter valid credentials
    Then they should be redirected to the dashboard
```

**Sources**: [TDD vs BDD comparison](https://katalon.com/resources-center/blog/tdd-vs-bdd), [BrowserStack guide](https://www.browserstack.com/guide/tdd-vs-bdd-vs-atdd)

---

### Option C: Acceptance Test-Driven Development (ATDD)

**Definition**: Write acceptance tests based on user requirements before implementation.

**When ATDD Works Best**:
- Requirements-heavy projects with clear acceptance criteria
- Regulated industries requiring traceability
- Projects with strong product ownership
- Contract-driven development

**Benefits**:
- Ensures implementation matches user requirements
- Provides clear definition of "done"
- Requirements serve as foundation for development
- Strong alignment between stakeholders

**Difference from BDD**: ATDD focuses on acceptance criteria, BDD focuses on system behavior. Often used together.

**Sources**: [ATDD comparison](https://www.testmu.ai/blog/tdd-vs-bdd/)

---

### Option D: Test-After Development

**Definition**: Write implementation first, add tests afterward.

**When Test-After Works**:
- Rapid prototyping phase
- Exploratory programming
- Proof-of-concept development
- When requirements are unclear and evolving rapidly
- Research and experimentation

**Approach**:
- Build feature to validate concept
- Add tests once behavior stabilizes
- Refactor with test coverage in place
- Transition to test-first for production

**Consideration**: May miss edge cases until bugs appear; requires discipline to actually write tests afterward.

---

### Option E: Hybrid Approaches

**Most Common in Practice**: Teams combine multiple strategies based on context.

**Example Combinations**:

**TDD + BDD**:
- BDD for feature-level acceptance tests
- TDD for unit-level implementation
- Ensures both user value and code correctness

**Specification-Driven + TDD**:
- Write specification defining what to build
- Generate tests from specification
- Implement using TDD with generated tests
- Works excellently with AI agents

**Risk-Based Testing**:
- TDD for critical business logic
- Test-after for UI components
- Manual testing for experimental features

**By Component Type**:
- TDD for backend business logic
- Integration tests for APIs
- Manual + automated for UI
- Property-based testing for algorithms

---

### AI-Specific Testing: Evaluations

**Challenge**: Traditional testing doesn't work well for non-deterministic LLM outputs.

**Solution**: Implement "AI Evals" - curated test suites measuring LLM application quality.

**Evaluation Approaches**:

**1. Heuristic Evaluation**:
- Rule-based checks (response length, format, keyword presence)
- Fast and deterministic
- Good for structural validation

**2. LLM-as-Judge**:
- Another LLM evaluates output quality
- Captures nuance and semantic correctness
- Example: "Rate response 1-10 for helpfulness"

**3. Custom Scoring**:
- Domain-specific validation
- Business logic verification
- Example: Verify generated SQL is valid and safe

**Best Practice**: Integrate AI evals into CI/CD pipeline to catch regressions.

**Source**: [TDD with AI patterns](https://www.scrumlaunch.com/blog/test-driven-development-in-2024)

---

### Testing Pyramid

Regardless of when tests are written, balanced test coverage typically includes:

**Unit Tests (70%)**: Fast, isolated, test individual functions
**Integration Tests (20%)**: Test component interactions
**End-to-End Tests (10%)**: Test complete user flows

**Adjustment**: Ratios vary by project type. APIs may have more integration tests; libraries more unit tests.

---

## V. Simplicity and Pragmatism (YAGNI)

### Principle

**"You Aren't Gonna Need It"**: Build the simplest solution that meets current requirements.

**Recommended Practices** (Most Projects):
- Avoid speculative features not required today
- Defer abstraction until patterns emerge from real usage
- Add configuration options only when variation is needed now
- Explain "why" in comments when not self-evident
- Prefer duplication over premature abstraction for first 2-3 instances

**When to Plan Ahead**:
- Public APIs (breaking changes are costly)
- Frameworks and libraries (users depend on stability)
- Database schemas (migrations are expensive)
- Security architecture (hard to retrofit)

**Rationale**: Premature abstraction increases maintenance burden and cognitive load without delivering user value. Wait for proven need.

---

## VI. Security Requirements

### Universal Security Baseline

Unlike other practices, **security cannot be optional**. All code should meet minimum security standards:

**Input Validation**:
- Sanitize user input before use (prevent injection attacks)
- Validate data types and ranges
- Use parameterized queries for databases

**Secrets Management**:
- Never commit secrets to source control
- Use environment variables or secret management systems
- Rotate credentials regularly

**Authentication & Authorization**:
- Validate authentication state on protected operations
- Implement proper session management
- Use secure protocols for external communications

**Data Protection**:
- Never log sensitive data (tokens, passwords, PII)
- Encrypt sensitive data at rest and in transit
- Implement proper access controls

**Dependency Security**:
- Audit third-party dependencies for known vulnerabilities
- Keep dependencies updated
- Use dependency scanning tools

**Code Review**: Security requirements should be verified before merge.

**Why Universal**: Security vulnerabilities affect users and organizations. Unlike features, security cannot be "added later" without significant risk.

---

## VII. Quality Gates

### Common Quality Gate Configurations

Projects typically enforce quality standards before merging to main branch. The specific gates depend on project needs:

**Minimal (Prototypes)**:
- Build completes successfully
- No syntax errors

**Standard (Most Projects)**:
- Build completes without errors
- Type checking passes (if applicable)
- Linting passes with no errors
- Tests pass with all assertions green
- Code review completed

**Strict (Critical Systems)**:
- All standard gates
- Coverage threshold met (e.g., 80%+)
- Performance benchmarks met
- Security scan passes
- Documentation updated
- Breaking changes documented and approved

**Enforcement**: CI/CD pipeline typically blocks merges that fail required gates.

**Configuration**: Define which gates apply in project-specific instructions.

---

## Governance

### Using This Reference

**For New Projects**:
1. Review practices in this document
2. Select applicable practices based on project context
3. Document choices in project-specific instruction files
4. Specify enforcement level (required, recommended, optional)

**For Existing Projects**:
1. Document current practices
2. Compare to options in this reference
3. Identify gaps or desired improvements
4. Plan incremental adoption if changes needed

### Project-Specific Overrides

**Process for Customization**:
1. Copy relevant sections to project instruction files
2. Adjust language from "can" to "must" based on project needs
3. Include rationale for choices made
4. Document any deviations from standard practices
5. Review and update as project evolves

**Example**:
```markdown
# MyProject Coding Requirements

## Testing Strategy (from coding-principles.md)

This project uses **Test-Driven Development (TDD)** for all backend logic.

Rationale: Financial calculation accuracy is critical; TDD provides the
confidence needed for regulatory compliance.

Requirements:
- All business logic MUST have tests written first
- Tests MUST pass before code review
- Coverage MUST be >= 90% for /src/calculations/

Frontend components MAY use test-after approach for UI layout code.
```

### AI Agent Compliance

AI agents should:
1. Read project-specific instruction files first
2. Reference this document for context on available practices
3. Follow the practices specified for the specific project
4. Ask for clarification when project instructions are ambiguous

---

## Selecting Practices for Your Project

### Decision Framework

**Consider These Factors**:

1. **Project Phase**:
   - Prototype → Minimal practices, fast iteration
   - MVP → Standard practices, balanced quality
   - Production → Comprehensive practices, high quality

2. **Team Experience**:
   - Junior team → Start with simpler practices, add over time
   - Senior team → Can adopt more sophisticated practices

3. **Criticality**:
   - Internal tool → Lighter practices acceptable
   - Customer-facing → Standard practices
   - Safety/money critical → Strictest practices

4. **Timeline Pressure**:
   - Tight deadline → Pragmatic minimum
   - Normal timeline → Standard practices
   - Long-term → Investment in quality pays off

5. **Maintenance Horizon**:
   - Throwaway code → Minimal practices
   - 1-2 year lifespan → Standard practices
   - Multi-year → Comprehensive practices

### Example Configurations

**Startup MVP**:
- Error handling: Standard
- Logging: Minimal
- Type safety: Moderate (TypeScript with some any)
- Testing: Test-after or hybrid
- Security: Full compliance
- Quality gates: Minimal

**Enterprise Application**:
- Error handling: Standard with comprehensive boundaries
- Logging: Comprehensive observability
- Type safety: Strict
- Testing: TDD + BDD combination
- Security: Full compliance + audits
- Quality gates: Strict

**Open Source Library**:
- Error handling: Comprehensive
- Logging: Minimal (library shouldn't log)
- Type safety: Strict with full type exports
- Testing: TDD with high coverage (90%+)
- Security: Full compliance
- Quality gates: Strict + documentation

---

## Industry Sources

This reference is based on 2026 industry research:

- [TDD vs BDD vs DDD in 2025](https://medium.com/@sharmapraveen91/tdd-vs-bdd-vs-ddd-in-2025-choosing-the-right-approach-for-modern-software-development-6b0d3286601e)
- [Test Driven Development Myths 2026](https://thinksys.com/development/test-driven-development-myths/)
- [The state of TDD 2024](https://thestateoftdd.org/2024/)
- [TDD Relevance in 2024](https://www.scrumlaunch.com/blog/test-driven-development-in-2024)
- [When to Use TDD](https://www.jrebel.com/blog/when-to-use-test-driven-development)
- [TDD vs BDD vs ATDD Comparison](https://www.browserstack.com/guide/tdd-vs-bdd-vs-atdd)
- [Comprehensive TDD Review](https://mgx.dev/insights/test-driven-development-tdd-a-comprehensive-review-of-principles-practices-and-future-trends/d06a185864e44e8b8c46accf376e2cad)

