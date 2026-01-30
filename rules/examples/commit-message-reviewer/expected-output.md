# Expected Output - Commit & PR Message Reviewer

Examples showing what the agent should output for various validation scenarios.

---

## Scenario 1: Good Commit Message (Pass)

**Input**:
```
Fix login timeout when session expires in auth flow

Users were seeing a generic error page when their session expired
instead of being redirected to the login page. This change adds
session expiration checks before authentication attempts and
redirects users to login with a clear "Session expired" message.

The timeout was occurring because the auth middleware checked
credentials before session validity, causing the error handler
to trigger instead of the session refresh logic.

Fixes #789
```

**Expected Output**:
```markdown
✓ Message Review: APPROVED

**Type**: Commit Message

**Summary**: Message is clear, specific, and follows project standards

**Strengths**:
- Subject line concise (51 characters) and descriptive
- Imperative mood used correctly ("Fix" not "Fixed")
- Issue reference included (Fixes #789)
- Body explains what changed and why
- Technical context provided for future maintainers

**Format Checks**:
- ✓ Subject ≤70 characters (51)
- ✓ Imperative mood
- ✓ Specific description (not vague)
- ✓ Blank line between subject and body
- ✓ Body lines ≤72 characters
- ✓ Issue reference present

**Exit Code**: 0
```

---

## Scenario 2: Vague Commit Message (Fail)

**Input**:
```
fix bug
```

**Expected Output**:
```markdown
✗ Message Review: NEEDS IMPROVEMENT

**Type**: Commit Message

**Blocking Issues** (must fix):

1. **Subject too vague**: "fix bug"
   - Issue: Doesn't specify what bug or where
   - Impact: Future maintainers won't understand what changed
   - Suggested: "Fix [specific behavior] in [component]"
   - Example: "Fix null pointer exception in user profile loader"

2. **Missing body**: No explanation provided
   - Required: Explain what was changed and why
   - Include: Root cause, solution approach, impact

3. **Missing issue reference**: Project requires issue reference
   - Add: "Fixes #123" or "Relates to PROJ-456" in commit body

**Suggested Rewrite**:
```
Fix null pointer exception in user profile loader

Profile loader was attempting to access user.email before checking
if user object was null, causing crashes when loading deleted user
profiles.

Added null check before accessing user properties and return error
state with appropriate message.

Fixes #[issue-number]
```

**Exit Code**: 2 (vague message)
```

---

## Scenario 3: Complete PR Description (Pass)

**Input**: (See good-examples.md - PR Example 1)

**Expected Output**:
```markdown
✓ PR Description Review: APPROVED

**PR**: #456
**Type**: UI Feature

**Summary**: PR description is complete and follows best practices

**Present Elements**:
- ✓ Clear summary with business context
- ✓ Detailed test plan with specific steps
- ✓ Screenshots showing visual changes (3 images)
- ✓ Breaking changes documented (none)
- ✓ Checklist completed (all items checked)
- ✓ Issue reference (Closes #456)
- ✓ Reviewers tagged (@design-team)

**Quality Indicators**:
- Summary explains both what and why
- Test plan is actionable (specific steps, not "tested it")
- Screenshots show before/after comparison
- Accessibility considerations mentioned
- Documentation updates noted

**Exit Code**: 0
```

---

## Scenario 4: Incomplete PR Description (Fail)

**Input**:
```markdown
# Add dark mode

Added dark mode to the dashboard. Users can now switch themes.

Closes #456
```

**Expected Output**:
```markdown
✗ PR Description Review: INCOMPLETE

**PR**: #456
**Type**: UI Feature (inferred from title)

**Missing Required Elements**:

1. ❌ **Test Plan**: No testing instructions provided
   - Required: Step-by-step instructions for reviewers
   - Should include: How to toggle theme, what to verify, edge cases
   - Example template:
     ```
     ## Test Plan
     1. Navigate to dashboard
     2. Open Settings → Appearance
     3. Click "Dark Mode" toggle
     4. Verify: All dashboard elements use dark colors
     5. Refresh page → Verify: Dark mode persists
     ```

2. ❌ **Screenshots**: UI changes require before/after screenshots
   - Add: Screenshots or video showing visual changes
   - Include: Light mode (before), dark mode (after), theme toggle UI
   - Format: `![description](url)` or attached files

**Present Elements**:
- ✓ Summary (brief but provides basic context)
- ✓ Issue reference (Closes #456)

**Recommendations**:

3. ⚠ **Summary could be more detailed**:
   - Add: Technical approach (how was it implemented?)
   - Add: Business context (why now? user requests?)
   - Include: Scope (which components affected?)

**Suggested Template**:
```markdown
## Summary
[Expand current summary with technical details and context]

## Changes
- List of components/files modified
- Technical approach

## Test Plan
[Add step-by-step testing instructions]

## Screenshots
**Before** (Light mode):
![light-mode](url)

**After** (Dark mode):
![dark-mode](url)

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Accessibility verified
```

**Exit Code**: 6 (missing test plan)
```

---

## Scenario 5: Bare "LGTM" on Complex PR (Warning)

**Input**:
```
LGTM
```

**Context**: PR with 500+ lines changed across 10 files

**Expected Output**:
```markdown
⚠ PR Review: COULD BE MORE HELPFUL

**PR**: #456
**Comment**: "LGTM"
**PR Size**: Large (500+ lines, 10 files)

**Observation**:
While approval is clear, this PR is non-trivial and would benefit from
more specific feedback to help the author and future reviewers.

**Suggestions** (not blocking, but recommended):

Consider adding:
1. **What you tested**: Specific scenarios or flows you verified
2. **Any concerns**: Even non-blocking questions or observations
3. **Acknowledgment**: Call out particularly good changes
4. **Context**: What aspects you focused on (security, performance, etc.)

**Example Improved Comment**:
```
LGTM! Tested the authentication refactoring locally:
- Login flow works correctly with new token refresh
- Error messages are clear and actionable
- Session handling improved (no premature logouts)

Reviewed:
- AuthService changes (nice use of dependency injection!)
- Token refresh logic (well-tested with edge cases)
- Error handling (comprehensive)

Minor note: Consider adding retry logic for network errors in
token refresh (line 234), but not blocking.

Great work on improving the architecture!
```

**Why This Matters**:
- Helps author understand what was verified
- Provides context for future reviewers
- Acknowledges good work (team morale)
- Identifies areas of focus (useful for audits)

**Exit Code**: 8 (bare LGTM, optional improvement)
```

---

## Scenario 6: Wrong Tense in Commit Message (Fail)

**Input**:
```
Added authentication feature
```

**Expected Output**:
```markdown
✗ Message Review: NEEDS IMPROVEMENT

**Type**: Commit Message

**Blocking Issues**:

1. **Non-imperative mood**: "Added"
   - Issue: Should be imperative ("Add" not "Added")
   - Convention: Subject should complete "This commit will..."
   - Current: "This commit will Added authentication feature" (incorrect)
   - Corrected: "This commit will Add authentication feature" (correct)

2. **Vague description**: "authentication feature"
   - Issue: What aspect of authentication?
   - Be specific: Token refresh? OAuth? Session management?
   - Example: "Add session refresh token support to authentication"

**Recommended Improvements**:

3. **Missing body**: No explanation of what or why
   - Add: Technical details of implementation
   - Add: Business context or user impact
   - Add: Issue reference if applicable

**Suggested Rewrite**:
```
Add session refresh token support to authentication

Implement automatic token refresh to reduce user login friction.
When access tokens expire, the system now attempts to refresh
using the refresh token before forcing re-authentication.

This improves user experience by reducing forced logouts from
5-10 per day to <1 for typical usage patterns.

Relates to #456
```

**Exit Code**: 3 (non-imperative mood)
```

---

## Scenario 7: Subject Line Too Long (Fail)

**Input**:
```
Updated the authentication service to support refresh tokens and also fixed the bug where users were logged out too frequently
```

**Expected Output**:
```markdown
✗ Message Review: NEEDS IMPROVEMENT

**Type**: Commit Message

**Blocking Issues**:

1. **Subject too long**: 128 characters (limit: 70)
   - Issue: Subject will be truncated in git tools, GitHub UI
   - Current: "Updated the authentication service to support refresh tokens and also fixed..."
   - Truncated: "Updated the authentication service to support refresh tokens and al..."

   **Options**:

   A. **Condense** (if single topic):
      ```
      Add refresh token support and fix session logout bug
      ```
      (Then explain details in body)

   B. **Split** (if multiple topics - recommended):
      ```
      Commit 1: Add session refresh token support to authentication
      Commit 2: Fix premature logout due to session expiration
      ```

**Recommended Improvements**:

2. **Multiple topics detected**:
   - Subject mentions both feature ("support refresh tokens") and bug fix ("fixed the bug")
   - Best practice: One commit per logical change
   - Rationale: Easier to review, revert, understand history

**Exit Code**: 1 (subject too long)
```

---

## Scenario 8: Ticket Missing Acceptance Criteria (Fail)

**Input**:
```markdown
# Make login faster

The login is too slow. Make it faster.
```

**Expected Output**:
```markdown
✗ Ticket Review: INCOMPLETE

**Ticket**: PROJ-123 (inferred)
**Type**: Performance Improvement

**Missing Required Elements**:

1. ❌ **Acceptance Criteria**: No specific, testable criteria
   - Issue: "faster" is subjective - how fast is fast enough?
   - Required: Specific measurable target
   - Example: "Login completes in <2 seconds (95th percentile)"

   **Should include**:
   - Target metric (time, size, requests, etc.)
   - Measurement method (from button click to dashboard display)
   - Conditions (network speed, typical load, etc.)

2. ❌ **User Story Format**: No user story provided
   - Required: "As a [user type], I want [action] so that [benefit]"
   - Example: "As a dashboard user, I want login to complete in under 2 seconds so that I can access my data quickly"

3. ❌ **Context**: No baseline or analysis
   - What's current login time?
   - What's causing slowness? (database? network? rendering?)
   - What's acceptable performance?
   - How many users affected?

**Suggested Rewrite**:
```markdown
# Reduce login time from 5s to <2s

## User Story
As a dashboard user, I want login to complete in under 2 seconds so that
I can access my data quickly without frustration.

## Acceptance Criteria
- [ ] Login completes in <2 seconds (95th percentile)
- [ ] Measured from button click to dashboard display
- [ ] Works on broadband connection (10Mbps+)
- [ ] No degradation in security or reliability

## Context
**Current State**: Login takes 5+ seconds on average
- Token generation: 1.5s
- Database lookup: 2s (main bottleneck)
- Frontend rendering: 1.5s

**Proposed Optimizations**:
- Add database indexes on user table (saves ~1.5s)
- Pre-load dashboard template (saves ~1s)
- Optimize token generation algorithm (saves ~0.5s)

**Expected Result**: ~2s total (60% improvement)

**Impact**: Affects 100% of users, multiple times per day

## Technical Notes
- Database: PostgreSQL 14
- Current indexes: users(id), users(email)
- Proposed: Add composite index on users(email, status, last_login)

Relates to #345 (general performance improvement initiative)
```

**Exit Code**: 9 (missing acceptance criteria)
```

---

## Performance Expectations

**Validation Time**:
- Commit message: <1 second
- PR description: <2 seconds
- Ticket description: <3 seconds

**Accuracy**:
- False positive rate: <5%
- Issue detection: >95%
- Suggestion quality: Actionable and specific

**Exit Codes**:
- 0: Pass (all checks)
- 1: Subject too long
- 2: Vague message
- 3: Non-imperative mood
- 4: Missing issue reference
- 5: Body formatting issues
- 6: PR missing test plan
- 7: PR missing summary
- 8: Bare LGTM (optional improvement)
- 9: Ticket missing acceptance criteria
