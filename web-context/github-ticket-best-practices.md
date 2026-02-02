# GitHub Ticket Best Practices (2025-2026)

Research synthesis on GitHub issue structure, acceptance criteria formats, Definition of Ready patterns, and label conventions.

**Research Date**: 2026-02-02
**Sources**: Zenhub, Atlassian, GitHub Docs, Monday.com, industry practitioner blogs

---

## Issue Structure Standards

### Title Requirements

**Format**: `[Type]: Clear, specific description of what needs to happen`

**Good Titles**:
- `Fix: Login timeout when session expires on slow networks`
- `Feature: Add export to CSV for user reports`
- `Bug: Dashboard crashes when filtering by date range > 1 year`

**Anti-Patterns**:
- ❌ `fix bug` - Too vague
- ❌ `update` - No context
- ❌ `changes` - Non-descriptive
- ❌ `WIP` - Not a title

### Description Structure

**Minimum Required**:
1. **Context**: Why this work is needed (1-2 sentences)
2. **Scope**: What is in/out of scope
3. **Acceptance Criteria**: Testable conditions for "done"

**For Features** (add):
- User story format
- Success metrics (if applicable)

**For Bugs** (add):
- Steps to reproduce
- Expected vs actual behavior
- Environment details

---

## User Story Format

### Standard Format

```
As a [specific user role],
I want [action/feature],
so that [business benefit].
```

### Quality Criteria

**Role Specificity**:
- ❌ "As a user" (too generic when more specific applies)
- ✅ "As a billing administrator"
- ✅ "As a first-time visitor"

**Action Clarity**:
- ❌ "I want better performance" (vague)
- ✅ "I want to export my data to CSV"

**Benefit Articulation**:
- ❌ "so that I can use it" (circular)
- ✅ "so that I can analyze trends in spreadsheet software"

### Examples

**Good**:
```
As a team lead,
I want to see aggregated time reports for my team,
so that I can identify workload imbalances before burnout occurs.
```

**Poor**:
```
As a user,
I want the feature to work,
so that I can use it.
```

---

## Acceptance Criteria Formats

### Format 1: Given-When-Then (BDD)

Best for: Complex scenarios, integration points, state transitions

```gherkin
Given [precondition/initial state]
When [action/trigger]
Then [expected outcome]
```

**Example**:
```gherkin
Given I am logged in as a billing admin
When I click "Export to CSV" on the invoices page
Then a CSV file downloads containing all visible invoices
And the file includes columns: Invoice ID, Date, Amount, Status
```

### Format 2: Checkbox List

Best for: Simple features, multiple independent conditions

```markdown
- [ ] User can click "Export" button on reports page
- [ ] CSV file downloads within 5 seconds for up to 10,000 rows
- [ ] File includes all visible columns in current sort order
- [ ] Error message displays if export fails (not silent failure)
```

### Format 3: Numbered Conditions

Best for: Sequential requirements, priority ordering

```markdown
1. Export button visible only to users with "reports:export" permission
2. Button disabled while export is in progress (prevents double-click)
3. Progress indicator shown for exports > 1000 rows
4. File named with pattern: `report-{type}-{date}.csv`
```

### Testability Requirements

Each acceptance criterion MUST have:
- **Clear pass/fail scenario**: Can be verified as true or false
- **Observable outcome**: Can be seen, measured, or checked
- **No subjective language** without metrics

**Subjective → Measurable**:
| Subjective | Measurable |
|------------|------------|
| "Fast" | "< 2 seconds" |
| "Responsive" | "Works on viewport ≥ 320px" |
| "User-friendly" | "Completes in ≤ 3 clicks" |
| "Secure" | "Requires authentication token" |
| "Scalable" | "Handles 10,000 concurrent users" |

---

## Definition of Ready (DoR)

### Core Criteria (6 Items)

An issue is "Ready" for sprint when ALL of these are true:

1. **Requirements Clear**: Stated with specific action verbs and measurable outcomes
2. **Acceptance Criteria Defined**: Pass/fail scenarios documented
3. **Scope Bounded**: Single sprint-sized OR explicitly marked as epic
4. **Dependencies Listed**: Blocking issues, external teams, APIs identified
5. **No Blockers**: No "waiting on" status without timeline
6. **Estimable**: Team can estimate effort (even if rough)

### DoR Checklist Template

```markdown
## Definition of Ready Checklist

- [ ] Requirements use specific action verbs (not "improve", "enhance")
- [ ] Each acceptance criterion has pass/fail scenario
- [ ] Scope fits single sprint (or marked as epic with breakdown)
- [ ] Dependencies documented (issues, teams, APIs)
- [ ] No open blockers or blockers have resolution timeline
- [ ] Team has enough context to estimate
```

### Red Flags

Issues NOT ready if:
- Requirements say "improve X" without metrics
- Acceptance criteria use subjective terms ("fast", "good", "better")
- Scope is unbounded ("and more", "etc.", "TBD")
- Dependencies marked "TBD" or "unknown"
- Waiting on external input with no timeline

---

## Bug Report Structure

### Required Sections

```markdown
## Summary
[1-2 sentence description of the bug]

## Steps to Reproduce
1. [First step]
2. [Second step]
3. [Step where bug occurs]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- OS: [e.g., macOS 14.2, Windows 11]
- Browser: [e.g., Chrome 120, Firefox 121]
- App Version: [e.g., v2.3.1]
- Account Type: [e.g., Free, Pro, Enterprise]

## Additional Context
- Screenshots/videos (if applicable)
- Console errors (if applicable)
- Frequency: [Always, Sometimes, Rarely]
```

### Severity Guidelines

| Severity | Definition | Example |
|----------|------------|---------|
| Critical | System unusable, data loss, security vulnerability | Login completely broken |
| High | Major feature broken, no workaround | Cannot save documents |
| Medium | Feature broken but workaround exists | Export fails but can copy manually |
| Low | Minor issue, cosmetic | Button slightly misaligned |

---

## Label Conventions

### Naming Patterns

**Type Labels** (what kind of work):
- `type:bug`, `type:feature`, `type:task`, `type:chore`, `type:docs`

**Priority Labels** (urgency):
- `priority:critical`, `priority:high`, `priority:medium`, `priority:low`

**Status Labels** (workflow state):
- `status:triage`, `status:ready`, `status:in-progress`, `status:blocked`

**Area Labels** (component/module):
- `area:auth`, `area:ui`, `area:api`, `area:database`

### Project Configuration

Projects SHOULD define their labels in configuration:

```json
{
  "ticketLabels": {
    "types": ["bug", "feature", "task", "chore", "docs"],
    "priorities": ["critical", "high", "medium", "low"],
    "areas": ["auth", "ui", "api", "database", "infra"]
  }
}
```

When project labels are defined, validation should check against them.
When not defined, use industry-standard labels as advisory suggestions.

---

## Anti-Patterns

### Acceptance Criteria Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Implementation details | "Use Redux for state" | "State persists across page reload" |
| Subjective without metrics | "UI should be responsive" | "Page loads in ≤ 3s on 3G" |
| Vague verbs | "Improve performance" | "Reduce API latency to < 200ms" |
| Oversized (>8 criteria) | Too much for one issue | Split into focused issues |
| TODO in criteria | "Fix the login (TODO: decide how)" | Resolve before marking ready |
| Internal tool references | "See Slack thread" or "Task #25" | Include relevant context inline |

### Title Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Single word | "fix", "update" | "Fix: Login timeout on slow networks" |
| No type indicator | "Button broken" | "Bug: Submit button unresponsive on mobile" |
| Too long (>70 chars) | Hard to scan | Summarize; put details in description |

---

## Integration with Workflows

### Sprint Planning

1. **Before Planning**: All candidate issues pass DoR checklist
2. **During Planning**: Team reviews acceptance criteria for clarity
3. **After Planning**: Issues move to "Ready" status

### PR Workflow

- PR description links to issue
- PR checklist maps to acceptance criteria
- Review verifies acceptance criteria met

### Definition of Done (DoD)

Distinct from DoR - DoD is when work is COMPLETE:
- All acceptance criteria verified
- Code reviewed and approved
- Tests passing
- Documentation updated (if applicable)
- Deployed to staging (if applicable)

---

## Sources

- **Zenhub**: "Acceptance Criteria: Best Practices for Quality Development" (2025)
- **Atlassian**: "Definition of Ready" and "User Stories with Examples" (2025)
- **GitHub Docs**: "Best practices for projects" (2026)
- **Monday.com**: "User Story Template 2025: The Ultimate Guide"
- **Agile Alliance**: "Definition of Ready" pattern documentation

---

**Related Files**:
- `~/.ai-context-store/user-wide/agents/github-ticket-reviewer.md` - Minimal agent
- `~/.ai-context-store/docs/agents/github-ticket-reviewer-spec.md` - Comprehensive spec
- `~/.ai-context-store/user-wide/agents/commit-message-reviewer.md` - Related agent (format validation)
