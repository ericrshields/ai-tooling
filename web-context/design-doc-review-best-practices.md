# Design Document Review Best Practices - Research

**Research Date**: 2026-01-30
**Purpose**: Best practices for reviewing software design documents
**Use Case**: Foundation for design-doc-reviewer-agent.md

---

## Overview

Research into industry best practices for conducting effective design document reviews before implementation. Focus on ensuring design documents are complete, technically sound, and implementable.

---

## Key Sources

### 1. Atlassian - Software Design Document Guidelines

**Source**: [Software Design Document [Tips & Best Practices] | The Workstream](https://www.atlassian.com/work-management/knowledge-sharing/documentation/software-design-document)

**Key Insights**:

**Essential Document Sections**:
- Overview/Executive Summary
- Goals and requirements
- System architecture
- Data design (models, schemas)
- Interface design (APIs, user interfaces)
- Assumptions and constraints
- Success metrics

**Best Practices**:
- Use clear, simple language to avoid jargon
- Keep documents current by regularly reviewing and updating
- Make documents easily accessible in central location
- Include diagrams for complex architectures
- Document decisions AND rationale (why this approach)

**Review Focus**:
- Verify all stakeholders understand the design
- Check technical approaches are feasible
- Ensure requirements map to design elements
- Validate assumptions are explicit

---

### 2. Microsoft Engineering Fundamentals - Design Reviews

**Source**: [Incorporating Design Reviews into an Engagement - Engineering Fundamentals Playbook](https://microsoft.github.io/code-with-engineering-playbook/design/design-reviews/recipes/engagement-process/)

**Key Insights**:

**When to Conduct Design Reviews**:
- Before implementation starts (catch issues early)
- After requirements are clear but before coding
- When changing existing architecture
- For systems with multiple integration points

**Review Timing and Frequency**:
- Schedule 1-2 design sessions per sprint as part of normal meeting cadence
- Distribute documentation prior to session (allow prep time)
- Time-box reviews to maintain focus

**Review Team Composition**:
- Technical lead or architect (facilitator)
- Implementation team members
- Subject matter experts for integrations
- Security expert (if handling sensitive data)
- Product owner (for requirement clarity)

**Review Checklist**:
- [ ] Requirements are clear and complete
- [ ] Technical approach is feasible
- [ ] Architecture aligns with existing systems
- [ ] Security implications addressed
- [ ] Performance requirements defined
- [ ] Testing strategy included
- [ ] Rollback/recovery plan exists
- [ ] Dependencies identified
- [ ] Success criteria measurable

**Anti-Patterns to Avoid**:
- Design by committee (too many opinions, no decisions)
- Rubber stamp reviews (approve without analysis)
- Over-designing for hypothetical future needs
- Skipping reviews to "move faster" (creates rework later)

---

### 3. Medium - Design Documents and Design Reviews Guide

**Source**: [A Guide to Software Design Documents and Design Reviews | by Jean-Sébastien Basque-Girouard](https://medium.com/@jssbbbgggg/a-guide-to-software-design-documents-and-design-reviews-afd40569be7b)

**Key Insights**:

**Design Document Purpose**:
- Creates shared understanding before implementation
- Documents decisions for future reference
- Surfaces problems early when changes are cheap
- Reduces rework and implementation churn

**Creating Effective Design Docs**:
- Start with problem statement (why are we building this?)
- Document alternatives considered (not just chosen approach)
- Include non-goals (what we're NOT building)
- Be specific about API contracts and data models
- Call out assumptions explicitly

**Design Review Process**:

**1. Preparation Phase**:
- Author distributes doc 2-3 days before meeting
- Reviewers read and prepare questions
- Author prepares to defend/explain decisions

**2. Review Meeting**:
- Author presents design (10-15 minutes)
- Q&A and discussion (30-45 minutes)
- Capture action items and open questions
- Aim for consensus, not perfection

**3. Post-Review**:
- Author addresses feedback
- Updates document with decisions made
- Shares revised doc with team
- Archives for future reference

**Red Flags in Design Docs**:
- Vague requirements ("should be fast", "easy to use")
- Missing error handling
- Unstated assumptions
- No consideration of edge cases
- Unclear success criteria
- No alternatives discussed

---

### 4. Smartsheet - Design Review Process Essentials

**Source**: [Design Review Process Essentials | Smartsheet](https://www.smartsheet.com/content/design-review-process)

**Key Insights**:

**Design Review Benefits**:
- Catch defects early (10-100x cheaper than production fixes)
- Improve design quality through diverse perspectives
- Share knowledge across team
- Ensure alignment with standards and patterns
- Reduce implementation risk

**Review Types**:

**1. Preliminary Design Review**:
- Early in design phase
- High-level architecture and approach
- Identify major risks or blockers
- 30-60 minutes

**2. Detailed Design Review**:
- Complete design document
- Detailed technical approach
- API contracts and data models
- 60-90 minutes

**3. Final Design Review**:
- Sign-off before implementation
- All open questions resolved
- Implementation plan validated
- 30 minutes

**Effective Review Criteria**:

**Structure**:
- Clear scope and boundaries
- Well-organized sections
- Appropriate level of detail
- Diagrams supplement text

**Content**:
- Requirements traceable to design
- Assumptions documented
- Constraints identified
- Success criteria defined
- Error scenarios covered

**Quality**:
- Technically accurate
- Feasible to implement
- Aligned with architecture
- Secure by design
- Performant and scalable

---

### 5. Quora - Practical Tips for Software Design Reviews

**Source**: [What are some tips for conducting a software design review? - Quora](https://www.quora.com/What-are-some-tips-for-conducting-a-software-design-review)

**Key Insights** (Community Best Practices):

**For Authors**:
- Write the doc for your audience (implementers, not executives)
- Include diagrams (architecture, sequence, data flow)
- Explain trade-offs, not just final decision
- Be open to feedback (ego-free)
- Update doc based on review feedback

**For Reviewers**:
- Read the doc before the meeting (don't waste meeting time)
- Ask "why" questions to understand rationale
- Challenge assumptions constructively
- Suggest alternatives if you see issues
- Focus on substance, not style

**For Facilitators**:
- Keep discussion on track (park tangents)
- Ensure all voices heard (not just loudest)
- Capture action items and owners
- Time-box discussions (avoid analysis paralysis)
- Follow up on unresolved questions

**Questions to Always Ask**:
- What problem does this solve?
- Why this approach vs. alternatives?
- What are the failure modes?
- How will we test this?
- What are the rollback plans?
- What are the performance implications?
- What are the security implications?
- How does this scale?

---

## Common Design Document Sections

Based on research across sources:

### Mandatory Sections

1. **Executive Summary**
   - 2-3 paragraph overview
   - Problem statement
   - Proposed solution at high level
   - Key decisions

2. **Requirements**
   - Functional requirements (prioritized)
   - Non-functional requirements (performance, security, etc.)
   - Out of scope (what we're NOT building)
   - Acceptance criteria

3. **Architecture/Design**
   - System architecture diagram
   - Component breakdown
   - Technology choices with rationale
   - API contracts
   - Data models

4. **Constraints**
   - Technical constraints (browser support, performance limits)
   - Business constraints (budget, timeline)
   - Security constraints
   - Dependencies on other systems

5. **Success Criteria**
   - Measurable outcomes
   - Key metrics
   - Definition of done

### Conditional Sections

6. **Security & Compliance** (if handling sensitive data)
   - Threat model
   - Authentication/authorization
   - Data protection
   - Compliance requirements

7. **Migration Strategy** (if replacing existing system)
   - Phased rollout plan
   - Rollback approach
   - Data migration
   - Backward compatibility

8. **Open Questions** (if major decisions unresolved)
   - List of unresolved questions
   - Owners for resolving
   - Blocking vs. non-blocking

---

## Design Review Anti-Patterns

### Process Anti-Patterns

**1. No Preparation**
- Reviewers show up without reading doc
- Meeting becomes doc reading session
- No meaningful feedback provided

**2. Design by Committee**
- Too many reviewers with conflicting opinions
- No decision authority established
- Endless debate, no consensus

**3. Rubber Stamping**
- Review is formality, not substance
- No one challenges assumptions
- Issues discovered during implementation

**4. Perfectionism Paralysis**
- Trying to design for every edge case
- Over-engineering for hypothetical futures
- Never reaching "good enough to proceed"

**5. Skipping Reviews**
- "We don't have time" mentality
- Leads to rework and delays (ironic)
- Technical debt accumulates

### Content Anti-Patterns

**1. Solution Looking for Problem**
- Design starts with tech ("let's use X")
- Problem not clearly articulated
- Requirements unclear or missing

**2. Vague Requirements**
- "Fast", "scalable", "user-friendly"
- No quantifiable success criteria
- Untestable acceptance criteria

**3. Missing Alternatives**
- Only one approach considered
- No trade-off analysis
- No justification for choice

**4. Hidden Assumptions**
- Unstated assumptions about environment
- Assumed availability of resources
- Assumed user knowledge/behavior

**5. No Failure Planning**
- Only happy path documented
- Error scenarios not considered
- No rollback or recovery plan

---

## Review Quality Checklist

Use this checklist during design doc reviews:

### Completeness
- [ ] All required sections present
- [ ] Requirements prioritized (MUST/SHOULD/COULD)
- [ ] API contracts complete (if applicable)
- [ ] Data models defined (if applicable)
- [ ] Success criteria measurable
- [ ] Constraints documented

### Clarity
- [ ] Problem statement clear
- [ ] Requirements specific and testable
- [ ] Technical jargon explained
- [ ] Diagrams supplement text
- [ ] Assumptions explicit

### Technical Quality
- [ ] Approach is feasible
- [ ] Technology choices justified
- [ ] Architecture aligns with existing systems
- [ ] Performance implications considered
- [ ] Security addressed
- [ ] Testing strategy included

### Completeness
- [ ] All requirements addressed in design
- [ ] Edge cases considered
- [ ] Error scenarios documented
- [ ] Dependencies identified
- [ ] Migration/rollback planned

### Actionability
- [ ] Implementation can start from this doc
- [ ] Open questions flagged
- [ ] Action items captured
- [ ] Next steps clear

---

## Integration with Agent Design

The design-doc-reviewer-agent.md implements these best practices as:

**Phase 1: Structure Validation**
→ Ensures all mandatory sections present

**Phase 2: Requirement Quality Review**
→ Checks for specificity, testability, prioritization

**Phase 3: Technical Feasibility Analysis**
→ Validates approaches are sound and feasible

**Phase 4: Constraint Verification**
→ Ensures constraints are realistic

**Phase 5: Clarity and Completeness Check**
→ Detects ambiguities and gaps

**Phase 6: Success Criteria Validation**
→ Verifies criteria are measurable

---

## Key Takeaways

**1. Review Early, Review Often**
- Catch issues before implementation (10-100x cheaper)
- Design reviews are investment, not overhead

**2. Focus on Substance**
- Technical feasibility over formatting
- Testable requirements over vague goals
- Measurable outcomes over aspirational statements

**3. Make Reviews Actionable**
- Specific feedback, not generic criticism
- Clear action items with owners
- Categorize issues (blocking vs. nice-to-have)

**4. Design for Implementers**
- Write for the developer who will build this
- Include enough detail to start coding
- Answer "how will I test this?"

**5. Document Decisions AND Rationale**
- Why this approach vs. alternatives
- What trade-offs were made
- What assumptions were made

---

## Related Research

- [code-review-automation.md](code-review-automation.md) - Code review best practices
- [specification-driven-development.md](specification-driven-development.md) - Spec-first development
- [agent-architecture-patterns.md](agent-architecture-patterns.md) - Agent design patterns

---

**References**:
- Atlassian: https://www.atlassian.com/work-management/knowledge-sharing/documentation/software-design-document
- Microsoft Engineering Fundamentals: https://microsoft.github.io/code-with-engineering-playbook/design/design-reviews/recipes/engagement-process/
- Smartsheet: https://www.smartsheet.com/content/design-review-process
- Medium (Jean-Sébastien Basque-Girouard): https://medium.com/@jssbbbgggg/a-guide-to-software-design-documents-and-design-reviews-afd40569be7b
