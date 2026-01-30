# Good Examples - Commit & PR Message Reviewer

Examples of well-formatted commit messages, PR descriptions, and tickets that pass validation.

---

## Good Commit Messages

### Example 1: Bug Fix with Context

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

**Why Good**:
- ✅ Subject line concise (51 chars) and specific
- ✅ Imperative mood: "Fix" not "Fixed"
- ✅ Body explains what, why, and how
- ✅ Issue reference included
- ✅ Context helps future maintainers

---

### Example 2: Feature Addition

```
Add session refresh token support to authentication

Implement automatic token refresh to reduce user login friction.
When access tokens expire, the system now attempts to refresh
using the refresh token before forcing re-authentication.

This improves user experience by reducing forced logouts from
5-10 per day to <1 for typical usage patterns.

Technical details:
- New /auth/refresh endpoint in API
- Client-side token expiration checking
- Automatic retry logic with exponential backoff

Relates to #456
```

**Why Good**:
- ✅ Clear, specific feature description
- ✅ Explains business value ("reduce user login friction")
- ✅ Technical details in body
- ✅ Impact quantified ("5-10 per day to <1")
- ✅ Issue reference included

---

### Example 3: Refactoring

```
Refactor authentication module to use dependency injection

Replace hardcoded dependencies in AuthService with constructor
injection to improve testability and maintainability.

This change:
- Makes unit testing easier (can mock dependencies)
- Reduces coupling between auth and database layers
- Follows established patterns in codebase

No functional changes to authentication behavior.

Relates to #234 (tech debt reduction)
```

**Why Good**:
- ✅ Explains what was refactored and why
- ✅ Notes "no functional changes" (important for reviewers)
- ✅ Lists specific benefits
- ✅ References related ticket

---

## Good PR Descriptions

### Example 1: UI Feature

```markdown
# Add dark mode support to dashboard

## Summary

Implement dark mode theme for dashboard to reduce eye strain and improve
accessibility. Users can toggle between light/dark themes via settings panel,
with preference saved to localStorage.

This addresses frequent user feedback about dashboard brightness in low-light
environments (23 requests in past quarter).

## Changes

- New `ThemeProvider` component wrapping app
- Dark mode color palette in theme configuration
- Theme toggle in user settings panel
- localStorage persistence for theme preference
- Updated all dashboard components to use theme colors

## Test Plan

1. Navigate to dashboard
2. Open Settings → Appearance
3. Click "Dark Mode" toggle
4. Verify: All dashboard elements use dark colors
5. Refresh page → Verify: Dark mode persists
6. Toggle back to Light Mode → Verify: Light colors restored

## Screenshots

**Before** (Light mode only):
![light-mode](https://imgur.com/abc123.png)

**After** (Dark mode):
![dark-mode](https://imgur.com/def456.png)

**Settings panel**:
![settings](https://imgur.com/ghi789.png)

## Breaking Changes

None

## Checklist

- [x] Unit tests added for ThemeProvider
- [x] Integration tests for theme persistence
- [x] Accessibility audit completed (WCAG AA compliant)
- [x] Documentation updated (User Guide)
- [x] Reviewed by @design-team

Closes #456
```

**Why Good**:
- ✅ Complete summary with context
- ✅ Detailed test plan with specific steps
- ✅ Screenshots showing visual changes
- ✅ Breaking changes section (none, but documented)
- ✅ Checklist shows due diligence
- ✅ Issue reference and reviewers tagged

---

### Example 2: Bug Fix

```markdown
# Fix race condition in data fetching logic

## Summary

Resolves intermittent "data undefined" errors in dashboard when users navigate
quickly between views. The issue was caused by a race condition where new data
requests could complete before old requests were cancelled, resulting in stale
data overwriting fresh data.

## Root Cause

Previous implementation:
1. User navigates to View A → fetch starts
2. User quickly navigates to View B → fetch starts (A still pending)
3. Fetch B completes → data updated
4. Fetch A completes → data updated (overwrites B with stale A data)

## Solution

Added request cancellation using AbortController:
- Cancel pending requests when new requests start
- Track request timestamps to ignore stale responses
- Add loading state tracking per view

## Test Plan

**Manual**:
1. Navigate to Dashboard → View A
2. Immediately navigate to View B (before A loads)
3. Verify: View B shows correct data (not View A data)
4. Repeat 10 times quickly
5. Verify: No console errors, correct data always shown

**Automated**:
- New integration test: `DashboardDataFetch.test.ts:125`
- Simulates rapid navigation and verifies data integrity

## Related Issues

Fixes #789
Related to #345 (general data fetching improvements)

## Reviewers

@backend-team for API interaction review
@frontend-team for state management review
```

**Why Good**:
- ✅ Explains root cause clearly
- ✅ Solution approach documented
- ✅ Both manual and automated test plans
- ✅ References specific test files
- ✅ Tags appropriate reviewers

---

## Good PR Review Comments

### Example 1: Constructive Feedback

```markdown
Nice work on the authentication refactoring! The dependency injection
approach is much cleaner.

**Tested**:
- [x] Login flow works correctly
- [x] Token refresh functions as expected
- [x] Session expiration handled gracefully

**Suggestions** (non-blocking):

1. **AuthService.ts:45** - Consider adding retry logic for refresh token
   failures. Current implementation fails immediately, but network blips
   could cause unnecessary logouts.
   ```typescript
   // Suggestion:
   const result = await retryWithBackoff(() => refreshToken(), 3);
   ```

2. **AuthService.test.ts:89** - Test could be more specific about error
   handling. Current test only checks that error is thrown, not the error
   message or type.

**Minor note**: Line 234 has a console.log that should probably be removed.

Overall LGTM! The code is well-structured and the tests cover the important
cases. Once the console.log is removed, happy to approve.
```

**Why Good**:
- ✅ Acknowledges good work
- ✅ Lists what was tested
- ✅ Specific file:line references
- ✅ Explains why suggestions matter
- ✅ Offers code examples
- ✅ Distinguishes blocking vs non-blocking issues

---

### Example 2: Simple Approval (Appropriate)

```markdown
LGTM! Changes are straightforward and tests pass.

Verified:
- Typo fixed in user guide (line 45)
- No other instances of the same typo
- Builds successfully
```

**Why Good**:
- ✅ Appropriate for trivial PR (documentation typo fix)
- ✅ Still notes what was verified
- ✅ Not just bare "LGTM"

---

## Good Ticket Descriptions

### Example 1: User Story with Clear Criteria

```markdown
# Add export functionality to dashboard

## User Story

As a dashboard user, I want to export my dashboard data to CSV so that I can
analyze it in Excel or share it with colleagues who don't have system access.

## Acceptance Criteria

- [ ] Export button visible on dashboard (top-right near settings)
- [ ] Clicking export generates CSV file with all visible data
- [ ] CSV includes column headers matching dashboard display
- [ ] File name format: `dashboard-export-YYYY-MM-DD.csv`
- [ ] Works with filtered/sorted data (exports current view, not all data)
- [ ] Loading indicator shown while export generates
- [ ] Error message if export fails (e.g., timeout, too much data)
- [ ] Works on Chrome 90+, Firefox 88+, Safari 14+

## Context

Users frequently request dashboard data for offline analysis. Current workflow
requires manual copy/paste which is error-prone and time-consuming. Export
feature will save users ~15 minutes per analysis session.

**Frequency**: 40% of users export data weekly (based on support requests)
**Priority**: High (top user request for Q2)

## Technical Notes

- Max export size: 10,000 rows (larger datasets need pagination warning)
- Use existing CSV library: `@grafana/csv-export`
- Data should match current view (respect filters, sorting, pagination)

## Dependencies

- Requires #456 (API endpoint for data export) to be completed first

## Design Mockup

[Figma link: https://figma.com/file/abc123]
```

**Why Good**:
- ✅ Complete user story format
- ✅ Specific, testable acceptance criteria
- ✅ Context explains business value
- ✅ Frequency/priority data included
- ✅ Technical constraints documented
- ✅ Dependencies linked
- ✅ Design reference included

---

### Example 2: Bug Report

```markdown
# Login button disabled after failed attempt

## Description

Login button remains disabled after a failed login attempt, preventing users
from retrying. Users must refresh the page to attempt login again.

## Steps to Reproduce

1. Navigate to /login
2. Enter invalid credentials
3. Click "Login"
4. See error message "Invalid credentials"
5. Update credentials to valid values
6. Bug: Login button remains disabled (gray, unclickable)

## Expected Behavior

Login button should re-enable after failed attempt, allowing immediate retry.

## Actual Behavior

Button stays disabled. User must refresh page to retry.

## Impact

- **Severity**: High
- **Frequency**: Affects all login failures (100% reproduction rate)
- **Workaround**: Refresh page (annoying but not blocking)

## Environment

- Browser: Chrome 120, Firefox 115 (both affected)
- Server: Prod (grafana.example.com)
- First observed: 2026-01-15 (after auth refactor deployment)

## Technical Analysis

Likely cause: Login button disabled in `handleSubmit()` but never re-enabled
after error response. Should be re-enabled in error handler.

File: `LoginForm.tsx:89-95`

## Related Issues

Introduced in #789 (auth refactor PR)
```

**Why Good**:
- ✅ Clear steps to reproduce
- ✅ Expected vs actual behavior
- ✅ Impact assessment (severity, frequency)
- ✅ Environment details
- ✅ Technical analysis with file reference
- ✅ Links to related issues

---

## Summary: What Makes These Good

**Commit Messages**:
- Specific, not vague ("Fix login timeout" not "fix bug")
- Imperative mood ("Add" not "Added")
- Body explains why, not just what
- Issue references included
- Context helps future maintainers

**PR Descriptions**:
- Complete summary with business context
- Actionable test plans with specific steps
- Screenshots/videos for visual changes
- Breaking changes documented
- Checklists show thoroughness

**PR Comments**:
- Constructive and specific
- File:line references
- Explains why, offers alternatives
- Acknowledges good work
- Distinguishes blocking vs optional

**Tickets**:
- User story format with clear benefit
- Testable acceptance criteria
- Context explains business value
- Dependencies and constraints noted
- Design/technical references included
