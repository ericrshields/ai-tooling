# Git Branch Workflow

Comprehensive guide to branch management, naming conventions, and merge strategies for maintaining clean git history.

**Last Updated**: 2026-01-28

---

## Core Principles

### 1. Feature Branch Workflow

**Always create a dedicated branch** for each high-level task:
- One branch per feature, bugfix, or refactor
- Keeps main branch stable and deployable
- Enables parallel work on multiple features
- Allows easy rollback of incomplete work
- Creates clean, reviewable units of change

**When to create a branch:**
- New features (any functionality addition)
- Bug fixes (more than trivial one-liners)
- Refactoring (code structure changes)
- Documentation updates (significant changes)
- Experiments (trying new approaches)

**When NOT to create a branch:**
- Trivial typo fixes in documentation
- Single-line obvious bug fixes
- Formatting-only changes (if you must commit these separately)

### 2. Branch Tracking

**CRITICAL: Always track origin/main**

When creating branches, ensure they track `origin/main`:
```bash
# Create branch tracking origin/main
git checkout -b feature/my-feature --track origin/main

# Or set tracking after creation
git branch --set-upstream-to=origin/main feature/my-feature
```

**Why this matters:**
- Keeps branch synchronized with remote
- Prevents divergence from main
- Enables easy rebasing and conflict resolution
- Makes collaboration smoother
- Ensures `git pull` updates from correct upstream

**Verify tracking:**
```bash
git branch -vv  # Shows tracking relationships
```

### 3. Branch Lifecycle

**Standard flow:**
```
1. Create branch from main (tracking origin/main)
2. Work on feature (multiple commits OK)
3. Complete task checklist
4. Ask: "Does this conclude the feature?"
5. If yes → Squash and merge to main
6. Delete branch after merge
```

**Squash timing questions:**
- "Are all acceptance criteria met?"
- "Is this feature complete and ready for main?"
- "Should we wrap up this branch or continue working?"
- "Is this a good stopping point to merge?"

**Benefits of squashing:**
- Keeps main branch history clean and readable
- One commit per feature (easy to revert)
- Prevents commit log from growing excessively
- Makes git log tell a story of features, not individual edits

### 4. Branch Cleanup

**Always delete branches after merge:**
```bash
# Delete local branch
git branch -d feature/user-auth

# Delete remote branch (if pushed)
git push origin --delete feature/user-auth
```

**Automation tip:** Configure git to auto-prune deleted remote branches:
```bash
git config --global fetch.prune true
git config --global pull.rebase true
```

---

## Branch Naming Conventions

### Standard Format

**Pattern:** `<type>/<description>`

- **type**: Category of work (see types below)
- **description**: Hyphen-separated, lowercase, descriptive (under 50 chars)

**Examples:**
- `feature/user-authentication`
- `bugfix/login-timeout-error`
- `hotfix/payment-processing-crash`
- `refactor/api-client-module`
- `docs/api-documentation`
- `test/integration-coverage`
- `chore/update-dependencies`

### Branch Types

| Type | Purpose | When to Use |
|------|---------|-------------|
| **feature/** | New functionality | Adding new features, capabilities, or user-facing changes |
| **bugfix/** | Bug fixes | Fixing defects in existing features |
| **hotfix/** | Urgent fixes | Critical production issues requiring immediate deployment |
| **refactor/** | Code improvements | Restructuring code without changing behavior |
| **docs/** | Documentation | README, guides, comments, API docs |
| **test/** | Testing | Adding or improving tests |
| **chore/** | Maintenance | Dependencies, build config, tooling, CI/CD |
| **perf/** | Performance | Optimization work |
| **style/** | Formatting | Code style, linting fixes (use sparingly) |
| **revert/** | Reverting changes | Rolling back previous commits |

### Naming Best Practices

**DO:**
- Use lowercase throughout
- Separate words with hyphens (kebab-case)
- Be specific and descriptive
- Keep under 50 characters when possible
- Include ticket/issue ID if available: `feature/GH-123-user-auth`
- Use present tense or imperative: `add-login` not `added-login`
- Make the description grep-able and searchable

**DON'T:**
- Use spaces or underscores
- Use CamelCase or UPPERCASE
- Be vague: `fix-bug` (what bug?), `update-code`, `changes`
- Use developer initials (except in project-specific formats)
- Include dates or version numbers
- Use abbreviations that aren't obvious

### With Ticket Systems

When using issue trackers:
- `feature/JIRA-1234-user-authentication`
- `bugfix/GH-567-memory-leak`
- `hotfix/TICKET-999-payment-failure`

---

## Project-Specific Overrides

### Grafana Repository

**Branch Format:** `<username>/<component>/<task>`

**Pattern:** `eshields/<project>/<description>`

**Examples:**
- `eshields/scopes/add-default-path`
- `eshields/dashboard/fix-panel-resize`
- `eshields/plugins/datasource-auth`
- `eshields/alerting/refactor-notification-service`

**Merge Requirements:**
- **MUST go through Pull Request** (no local merge to main)
- **MUST track origin/main** when creating branch
- PR must pass CI checks
- Code review required
- Squash merge on GitHub when approved

**Workflow:**
```bash
# 1. Create branch tracking origin/main
git checkout -b eshields/scopes/add-default-path --track origin/main

# 2. Work and push
git push -u origin eshields/scopes/add-default-path

# 3. Create PR
gh pr create --title "Add default path for scopes" --body "..."

# 4. After approval, squash merge via GitHub UI

# 5. Clean up local
git checkout main
git pull
git branch -d eshields/scopes/add-default-path
```

**Rationale:** Multi-contributor OSS project requires review process and maintains higher quality bar.

### Personal/Small Repositories

**Branch Format:** Standard `<type>/<description>`

**Examples:**
- `~/.ai` - Research repository
- `~/.ai-context-store` - Configuration management
- `~/env` - Environment scripts

**Merge Strategy:**
- Can merge locally (for now)
- Squash before merging to main
- Delete branch after merge
- Track origin/main (or origin/master)
- May add PR requirement later as projects grow

**Workflow:**
```bash
# 1. Create branch tracking origin/main
git checkout -b feature/add-workflow-docs --track origin/main

# 2. Work and commit
git add workflows/git-branch-workflow.md
git commit -m "Add comprehensive git workflow documentation"

# 3. Squash merge locally
git checkout main
git pull
git merge --squash feature/add-workflow-docs
git commit -m "Add git branch workflow documentation with naming conventions and merge strategies"

# 4. Push and clean up
git push
git branch -d feature/add-workflow-docs
```

---

## Merge Strategies

### When to Squash

**Always squash when:**
- Feature branch has multiple WIP commits
- Commits contain fixes to earlier commits in same branch
- Commit messages are messy ("wip", "fix typo", "oops")
- You want main to have one commit per feature
- Working on personal/small repos (default strategy)

**Squash format:**
```bash
# Interactive rebase to squash
git rebase -i main

# Or squash merge
git checkout main
git merge --squash feature/user-auth
git commit -m "Add user authentication system"
```

### When to Keep Commits

**Consider preserving commits when:**
- Each commit is clean, atomic, and well-documented
- Commits represent logical progression that's valuable to preserve
- Working on very large features where history aids understanding
- Team/project convention prefers detailed history

---

## Workflow Integration

### With Task Management

**Create branch when:**
- Starting work on a task marked `in_progress`
- Task is non-trivial (>3 steps or >30 minutes work)

**Complete branch when:**
- Task marked `completed`
- All acceptance criteria met
- Tests passing

### With Planning Workflow

**Branch creation timing:**
- After plan approval
- Before starting implementation
- One branch per plan (unless plan is very large)

**Branch scope:**
- Should align with plan scope
- If plan is too large, consider splitting into multiple branches

### AI Agent Behavior

**When working with users:**
- **MUST create feature branch** before starting non-trivial tasks
- **MUST set branch to track origin/main** when creating
- **SHOULD ask before squash-merging:** "This feature is complete. Should I squash these commits and merge to main?"
- **MUST delete branch** after successful merge (unless user says otherwise)
- **SHOULD remind** about PR requirement for Grafana repositories
- **SHOULD verify** branch tracking with `git branch -vv` if issues arise

---

## Common Workflows

### Standard Feature Development

```bash
# 1. Create and switch to feature branch tracking origin/main
git checkout -b feature/user-dashboard --track origin/main

# 2. Work and commit iteratively
git add src/dashboard.tsx
git commit -m "Add dashboard component skeleton"
# ... more commits ...

# 3. When feature complete, squash and merge
git checkout main
git pull
git merge --squash feature/user-dashboard
git commit -m "Add user dashboard with analytics"

# 4. Push and clean up
git push
git branch -d feature/user-dashboard
git push origin --delete feature/user-dashboard  # if remote exists
```

### Grafana PR Workflow

```bash
# 1. Create branch tracking origin/main
git checkout -b eshields/scopes/add-default-path --track origin/main

# 2. Work and push
git add .
git commit -m "Implement default scope path"
git push -u origin eshields/scopes/add-default-path

# 3. Create PR
gh pr create --title "Add default path for scopes" --body "..."

# 4. After approval, squash merge via GitHub UI

# 5. Clean up local
git checkout main
git pull
git branch -d eshields/scopes/add-default-path
```

### Quick Bugfix

```bash
# 1. Create bugfix branch tracking origin/main
git checkout -b bugfix/null-pointer-login --track origin/main

# 2. Fix and commit
git add src/auth.ts
git commit -m "Fix null pointer in login validation"

# 3. Merge to main (if not Grafana)
git checkout main
git pull
git merge --squash bugfix/null-pointer-login
git commit -m "Fix null pointer exception in login validation"

# 4. Push and clean up
git push
git branch -d bugfix/null-pointer-login
```

---

## Best Practices Summary

### Branch Creation
- Create branch for each high-level task
- Use descriptive names following conventions
- Base on latest main
- **Always set to track origin/main**
- Keep branches short-lived (days, not weeks)

### Branch Maintenance
- Keep branch up-to-date with main (rebase or merge)
- Push regularly if collaborating
- Don't let branches go stale
- Verify tracking relationship if sync issues occur

### Merging
- Squash commits before merging to main (default)
- Write clear squash commit messages
- Ask user before merging if uncertain
- Verify tests pass before merge
- Update main from origin before merging

### Cleanup
- Delete branches immediately after merge
- Delete remote branches if they exist
- Prune remote-tracking branches regularly
- Keep workspace clean

---

## Anti-Patterns

### ❌ Working Directly on Main

```bash
# BAD: Committing directly to main
git checkout main
git add feature.ts
git commit -m "Add feature"
```

**Why bad:** Makes main unstable, hard to revert, no isolation

### ❌ Not Tracking Upstream

```bash
# BAD: Creating branch without tracking
git checkout -b feature/new-thing  # No --track flag
```

**Why bad:** Branch doesn't sync with origin/main, harder to stay up-to-date

### ❌ Vague Branch Names

```bash
# BAD: Non-descriptive names
git checkout -b fix
git checkout -b update
git checkout -b new-stuff
```

**Why bad:** Impossible to understand purpose from name alone

### ❌ Long-Lived Feature Branches

```bash
# BAD: Branch open for weeks
git checkout -b feature/big-refactor  # 3 weeks later...
```

**Why bad:** Merge conflicts accumulate, gets out of sync with main

### ❌ Never Squashing

**Why bad:** Main branch cluttered with "wip", "fix typo", "forgot file" commits

---

## Research Sources

This workflow synthesizes best practices from industry-standard conventions:

- **Conventional Commits**: Used for commit messages, "feat/fix/chore" categorization
- **GitHub Flow**: Simple feature branch workflow
- **Git Flow**: Branch type categorization (feature, hotfix, release)
- **Trunk-Based Development**: Short-lived branches, frequent merging

**References:**
- [Git Branch Naming Conventions: Best Practices | Pull Panda](https://pullpanda.io/blog/git-branch-naming-conventions-best-practices)
- [A Simplified Convention for Naming Branches and Commits in Git](https://dev.to/varbsan/a-simplified-convention-for-naming-branches-and-commits-in-git-il4)
- [Naming conventions for Git Branches — a Cheatsheet | Medium](https://medium.com/@abhay.pixolo/naming-conventions-for-git-branches-a-cheatsheet-8549feca2534)
- [Best practices for naming Git branches | Graphite](https://graphite.com/guides/git-branch-naming-conventions)
- [Conventional Branch Names | GitHub Gist](https://gist.github.com/seunggabi/87f8c722d35cd07deb3f649d45a31082)
- [Conventional Branch Naming](https://conventional-branch.github.io/)

---

## Project-Specific Extensions

See individual project configurations for overrides:
- **Grafana OSS**: `~/.ai-context-store/proj-grafana-*/` - PR required, username-based naming
- **Enterprise projects**: May require additional review processes
- **Personal repos**: Can use simplified local merge workflow
