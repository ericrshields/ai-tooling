# Bad Examples - Commit & PR Message Reviewer

Examples of poorly-formatted messages that would fail validation, with explanations of issues and suggested improvements.

---

## Bad Commit Messages

### Example 1: Too Vague

```
fix bug
```

**Issues**:
- ❌ Subject too vague (what bug? where?)
- ❌ No body explaining context
- ❌ No issue reference

**Agent Output**:
```
✗ Message Review: NEEDS IMPROVEMENT

**Blocking Issues**:
1. **Subject too vague**: "fix bug"
   - Suggested: "Fix [specific behavior] in [component/module]"
   - Example: "Fix null pointer exception in user profile loader"

2. **Missing body**: No explanation of what was fixed or why

3. **Missing issue reference**: Project requires issue reference
```

**Suggested Fix**:
```
Fix null pointer exception in user profile loader

Profile loader was attempting to access user.email before checking
if user object was null, causing crashes when loading deleted user
profiles.

Added null check before accessing user properties and return error
state with appropriate message.

Fixes #789
```

---

### Example 2: Wrong Tense (Non-Imperative)

```
Added authentication feature
```

**Issues**:
- ❌ Past tense ("Added" not "Add")
- ❌ Vague "authentication feature" (what specifically?)
- ❌ No body with details

**Agent Output**:
```
✗ Message Review: NEEDS IMPROVEMENT

**Blocking Issues**:
1. **Non-imperative mood**: "Added"
   - Should be: "Add" (imperative)
   - Convention: Commit message should complete "This commit will..."

2. **Vague description**: "authentication feature"
   - Be specific: What aspect of authentication?
```

**Suggested Fix**:
```
Add session refresh token support to authentication

Implement automatic token refresh to reduce user login friction.
When access tokens expire, the system now attempts to refresh
using the refresh token before forcing re-authentication.

Relates to #456
```

---

### Example 3: Subject Too Long

```
Updated the authentication service to support refresh tokens and also fixed the bug where users were logged out too frequently due to session expiration
```

**Issues**:
- ❌ Subject 142 characters (limit: 70)
- ❌ Multiple topics in one commit (mixing feature and bug fix)
- ❌ Should be split into separate commits

**Agent Output**:
```
✗ Message Review: NEEDS IMPROVEMENT

**Blocking Issues**:
1. **Subject too long**: 142 characters (limit: 70)
   - Current: "Updated the authentication service to support refresh tokens and also fixed..."
   - Suggested: "Add refresh token support and fix session expiration"
   - Better: Split into two commits (one feature, one fix)

**Recommended**:
2. **Multiple topics**: Appears to contain feature + bug fix
   - Consider: Separate commits for separate changes
```

**Suggested Fix** (split into two commits):
```
Commit 1:
Add session refresh token support to authentication

[Details about refresh token implementation]

Relates to #456

---

Commit 2:
Fix premature logout due to session expiration

[Details about bug fix]

Fixes #789
```

---

### Example 4: Missing Context

```
Fix timeout
```

**Issues**:
- ❌ What timeout? (login, API, database?)
- ❌ No explanation of root cause
- ❌ No mention of how it was fixed

**Agent Output**:
```
✗ Message Review: NEEDS IMPROVEMENT

**Blocking Issues**:
1. **Insufficient context**: "timeout"
   - Which timeout? (login, API request, database query, session?)
   - What caused it?
   - How was it fixed?

2. **Missing body**: Should explain what, why, and how
```

**Suggested Fix**:
```
Fix login timeout when session expires

Users were seeing a timeout error instead of being redirected to
login when their session expired. The auth middleware was checking
credentials before session validity, causing the error handler to
trigger.

Changed order: now check session validity first, then credentials.

Fixes #789
```

---

## Bad PR Descriptions

### Example 1: No Context

```markdown
# Fix bug

Fixed the bug in authentication.
```

**Issues**:
- ❌ No summary of what bug or how fixed
- ❌ No test plan
- ❌ No issue reference
- ❌ Title too vague

**Agent Output**:
```
✗ PR Description Review: INCOMPLETE

**Missing Required Elements**:
1. ❌ **Summary**: Current description is too vague
   - What bug specifically?
   - What was the root cause?
   - How was it fixed?

2. ❌ **Test Plan**: No testing instructions
   - How can reviewers verify the fix?

3. ❌ **Issue Reference**: Which issue does this close?

4. ❌ **Title too vague**: "Fix bug"
   - Suggested: "Fix login timeout when session expires"
```

**Suggested Fix**: See good-examples.md for complete PR description template

---

### Example 2: Missing Test Plan

```markdown
# Add dark mode

Added dark mode to the dashboard. Users can now switch between light and dark themes.

Closes #456
```

**Issues**:
- ❌ No test plan (how to verify?)
- ❌ No screenshots (UI change without visuals)
- ❌ Summary lacks technical details

**Agent Output**:
```
✗ PR Description Review: INCOMPLETE

**Missing Required Elements**:
1. ❌ **Test Plan**: No instructions for testing
   - Add: Step-by-step testing instructions
   - Include: Edge cases to verify

2. ❌ **Screenshots**: UI change without screenshots
   - Add: Before/after screenshots
   - Show: Theme toggle in action

**Present Elements**:
- ✓ Summary (brief but adequate)
- ✓ Issue reference (Closes #456)
```

---

### Example 3: UI Change Without Screenshots

```markdown
# Update button styling

Changed the button colors and added hover effects to improve visual hierarchy.

## Test Plan

1. Click all buttons
2. Verify they work

Closes #789
```

**Issues**:
- ❌ No screenshots for visual change
- ❌ Test plan too vague ("verify they work" - what does that mean?)
- ❌ No specifics about color changes

**Agent Output**:
```
✗ PR Description Review: INCOMPLETE

**Missing Required Elements**:
1. ❌ **Screenshots**: UI changes must include visuals
   - Show: Before/after comparison
   - Include: All affected buttons

**Issues with Present Elements**:
2. ⚠ **Test Plan too vague**: "Verify they work"
   - Be specific: What should buttons look like?
   - What happens on hover? On click?
   - What about accessibility (keyboard nav, screen readers)?
```

---

## Bad PR Review Comments

### Example 1: Bare "LGTM"

```markdown
LGTM
```

**Issues** (context-dependent):
- ⚠ No context (acceptable for trivial PRs, poor for complex ones)
- ⚠ Doesn't indicate what was reviewed/tested

**Agent Output** (for non-trivial PR):
```
⚠ PR Review: COULD BE MORE HELPFUL

**Observation**:
While approval is clear, comment lacks specific feedback for non-trivial PR.

**Suggestions**:
Consider adding:
- What you specifically tested
- Any concerns or questions
- Acknowledgment of good changes

**Example Improved Comment**:
```
LGTM! Tested authentication flows locally and verified:
- Token refresh works correctly
- Error messages are clear
- No breaking changes to existing auth

Nice work on the error handling improvements!
```
```

---

### Example 2: Vague Criticism

```markdown
This is wrong.
```

**Issues**:
- ❌ No file:line reference (what is "this"?)
- ❌ No explanation of why it's wrong
- ❌ No suggestion for improvement

**Agent Output**:
```
✗ PR Review: NOT CONSTRUCTIVE

**Issues**:
1. **Vague criticism**: "This is wrong"
   - What specifically is wrong?
   - Where? (file:line reference needed)
   - Why is it wrong?
   - How should it be fixed?

**Suggested Approach**:
```
**AuthService.ts:45** - The current implementation could cause race conditions.

When multiple refresh requests happen simultaneously, they might both
get the same expired token and fail. Consider adding a mutex or queue
to ensure only one refresh happens at a time.

Example implementation:
```typescript
private refreshPromise: Promise<Token> | null = null;

async refresh() {
  if (this.refreshPromise) return this.refreshPromise;
  this.refreshPromise = this.doRefresh();
  return this.refreshPromise.finally(() => this.refreshPromise = null);
}
```
```

---

### Example 3: Nitpicking Without Value

```markdown
You used single quotes here but double quotes on line 34. Please be consistent.
```

**Issues** (if this is the only comment):
- ⚠ Focuses on style over substance
- ⚠ Better handled by linter/formatter
- ⚠ Doesn't acknowledge substantive aspects of PR

**Agent Output**:
```
⚠ PR Review: CONSIDER BROADER FEEDBACK

**Observation**:
Comment focuses on minor style issue. While consistency is good, consider:
- Is this enforced by linter? (Should be automated)
- Are there substantive issues to address?
- Have you acknowledged the positive aspects?

**Suggested Approach**:
If style is the only issue, acknowledge the good work first:
```
Code looks solid and tests cover the important cases.

Minor: Consider enabling ESLint/Prettier to auto-fix quote consistency
(saw mix of single/double quotes). Not blocking.

LGTM!
```
```

---

## Bad Ticket Descriptions

### Example 1: No Acceptance Criteria

```markdown
# Make login faster

The login is too slow. Make it faster.
```

**Issues**:
- ❌ No specific acceptance criteria
- ❌ "Faster" is subjective (how fast?)
- ❌ No context on current performance
- ❌ No user story format

**Agent Output**:
```
✗ Ticket Review: INCOMPLETE

**Missing Required Elements**:
1. ❌ **Acceptance Criteria**: What defines "faster"?
   - Current: Vague "make it faster"
   - Needed: Specific target (e.g., "<2 seconds", "50% reduction")

2. ❌ **User Story**: No user story format
   - Add: "As a [user], I want [action] so that [benefit]"

3. ❌ **Context**: No baseline data
   - What's current login time?
   - What's the bottleneck?
   - What's acceptable target?
```

**Suggested Fix**:
```markdown
# Reduce login time from 5s to <2s

## User Story

As a dashboard user, I want login to complete in under 2 seconds so that
I can access my data quickly without frustration.

## Acceptance Criteria

- [ ] Login completes in <2 seconds (95th percentile)
- [ ] Measured from button click to dashboard display
- [ ] Works on broadband connection (10Mbps+)
- [ ] No degradation in security

## Context

**Current State**: Login takes 5+ seconds on average
- Token generation: 1.5s
- Database lookup: 2s
- Frontend rendering: 1.5s

**Proposed Optimizations**:
- Add database indexes on user table (saves 1.5s)
- Pre-load dashboard template (saves 1s)
- Optimize token generation algorithm (saves 0.5s)

**Impact**: Affects 100% of users, multiple times per day

## Related Issues

Relates to #345 (general performance improvement)
```

---

### Example 2: Missing User Story

```markdown
# Add export button

Add button to export data.
```

**Issues**:
- ❌ No user story (who benefits? why?)
- ❌ No acceptance criteria (where? what format?)
- ❌ No context on why this is needed

**Agent Output**:
```
✗ Ticket Review: INCOMPLETE

**Missing Required Elements**:
1. ❌ **User Story**: Why do users need this?
   - Template: "As a [user], I want [action] so that [benefit]"

2. ❌ **Acceptance Criteria**: What defines "done"?
   - Where does button go?
   - What format (CSV, JSON, Excel)?
   - What data is exported?

3. ❌ **Context**: Why is this important?
   - User feedback? Usage data? Business need?
```

---

## Summary: Common Issues

**Commit Messages**:
- Too vague ("fix bug", "update code", "changes")
- Wrong tense (past instead of imperative)
- Subject too long (>70 chars)
- Missing context (no body, no explanation)
- No issue references (when required)

**PR Descriptions**:
- No summary or too vague
- Missing test plan
- UI changes without screenshots
- No issue references
- Missing checklist items

**PR Comments**:
- Bare "LGTM" on complex PRs
- Vague criticism without examples
- Nitpicking style without substance
- No acknowledgment of good work

**Tickets**:
- No acceptance criteria (or too vague)
- Missing user story
- No context on business value
- Subjective requirements ("fast", "better", "easy")
- No technical details or constraints
