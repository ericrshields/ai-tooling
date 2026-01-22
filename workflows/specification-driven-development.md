# Specification-Driven Development (SDD)

Comprehensive patterns for SDD workflows based on 2026 industry research.

---

## Overview

Specification-Driven Development has emerged as the standard practice for AI-assisted development in 2026. The industry prediction: "Within 2026, most development will be at least spec-assisted."

**Core Principle**: Specifications serve as executable artifacts and single source of truth that guide development and evolve with the project.

**Key Finding**: Pattern validated by GitHub Spec Kit and industry convergence on Constitution → Requirements → Specification → Plan → Tasks → Implementation workflow.

---

## SDD Workflow Pattern

### Five-Phase Standard

**Phase 1: Constitution**
- Project principles and values
- Technical philosophy
- Non-negotiable constraints
- Team agreements

**Phase 2: Requirements**
- User needs and stories
- Functional requirements
- Non-functional requirements (performance, security, accessibility)
- Acceptance criteria

**Phase 3: Specification**
- Detailed technical specification
- API contracts
- Data models
- Component interactions
- Edge cases and error handling

**Phase 4: Plan**
- Implementation strategy
- Task breakdown
- Dependencies
- Milestones

**Phase 5: Tasks → Implementation**
- Specific work items
- Execution guided by spec
- Continuous validation against spec
- Spec evolves with discoveries

---

## GitHub Spec Kit Workflow

### Tooling Support (2026)

**GitHub Spec Kit**: Open-source SDD toolkit, agent-agnostic

**Features**:
- Template-based specification creation
- Version control integration
- Spec validation and linking
- Living documentation generation

### Pattern Validation

**Industry Standard** (GitHub Spec Kit):
1. Constitution
2. Specification
3. Plan
4. Tasks
5. Implementation

**Observation**: This matches the emerging industry pattern exactly.

---

## Specifications as Living Documentation

### Key Characteristics

**1. Executable Artifacts**
- Not just documentation
- Used by AI agents to guide development
- Validated during implementation
- Updated based on learnings

**2. Single Source of Truth**
- All stakeholders reference the spec
- Changes flow through spec updates
- Spec drives implementation, not vice versa

**3. Continuous Evolution**
- Spec updated as requirements clarify
- Discoveries during implementation feed back
- Version controlled alongside code
- Historical context preserved

---

## Integration with AI Development

### AI Agents Use Specs For

**Planning**:
- Understand project goals
- Identify constraints
- Design solutions that fit

**Implementation**:
- Generate code matching spec
- Validate against requirements
- Handle specified edge cases

**Testing**:
- Generate tests from spec
- Verify behavior matches spec
- Identify spec gaps

**Review**:
- Check compliance with spec
- Flag deviations
- Suggest spec improvements

---

## Best Practices

### Specification Quality

**Clear and Unambiguous**:
- Precise language
- Examples for complex cases
- Clear success criteria

**Complete Coverage**:
- Normal cases
- Edge cases
- Error scenarios
- Performance requirements

**Maintainable**:
- Structured and organized
- Version controlled
- Easy to update
- Searchable

### Spec Evolution

**When to Update**:
- Requirements change
- Implementation reveals gaps
- New edge cases discovered
- Performance needs adjust

**How to Update**:
- Document reason for change
- Update related sections
- Notify stakeholders
- Regenerate affected code

---

## Sources

- GitHub Spec Kit documentation
- [specification-driven-development.md](../web-context/specification-driven-development.md) (detailed research)

---

**Created**: 2026-01-20 | **Source**: Web research on SDD methodology
