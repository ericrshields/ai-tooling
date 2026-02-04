# Enterprise Development Workflow

Guide for developing enterprise features in the Grafana dual-repository setup.

## Repository Architecture

Grafana Enterprise uses a dual-repository architecture:
- **grafana-enterprise**: Source of truth for enterprise code
- **grafana**: OSS repository where enterprise code is synced during development and build

See [grafana-enterprise README](https://github.com/grafana/grafana-enterprise/blob/main/README.md) for complete architecture details.

---

## Critical: Git Operations

### NEVER Run Git Commands on Enterprise Repo While Watcher Running

**⚠️ MUST stop `make enterprise-dev` before ANY git operations on grafana-enterprise ⚠️**

**Why**: The file watcher syncs code FROM enterprise TO OSS `/extensions`. Git operations during sync cause conflicts and lost changes.

**Correct sequence**:
```bash
# In grafana/grafana directory
Ctrl+C                               # 1. Stop make enterprise-dev FIRST
cd ../grafana-enterprise             # 2. Switch to enterprise
git checkout <branch>                # 3. Now safe to run git commands
cd ../grafana                        # 4. Back to OSS
make enterprise-dev                  # 5. Restart watcher
```

**Git operations in OSS repo are safe** (but never commit `/extensions` code - it's gitignored)

---

## Pull Request Workflow

### When to Create OSS PRs

**1. Enterprise-only code changes**: NO OSS PR needed
   - If ALL changes are in `/src/public/` or `/src/pkg/extensions/`
   - Enterprise PR is sufficient
   - Example: New UI component, backend service

**2. OSS changes required**: CREATE OSS PR
   - Feature flags (`pkg/services/featuremgmt/`)
   - Settings, configuration files
   - Non-enterprise infrastructure changes
   - Example: Adding a feature toggle, updating settings

**3. CI pinning (optional)**: Push OSS branch with same name
   - Enterprise CI tests against matching OSS branch name
   - If no matching OSS branch exists, CI uses OSS `main`
   - Can use empty commit: `git commit --allow-empty -m "CI pin"`
   - **Branch alone is sufficient** - don't need to create PR just for pinning

### Branch Naming

**MUST use identical branch names** across both repos when you have changes in both:

```bash
# Both repos
eshields/feature/my-feature
```

**Benefits**:
- Enterprise CI automatically tests against your OSS changes
- Clear correspondence between related PRs
- Simpler tracking and review

### PR Descriptions

**For paired PRs**, include cross-reference:

**OSS PR**:
```markdown
**Sync with Enterprise:**
This PR has a matching enterprise PR: grafana/grafana-enterprise#XXXXX

Both branches use the same name for automatic CI pinning.
```

**Enterprise PR**:
```markdown
**Sync with OSS:**
This PR has a matching OSS PR: grafana/grafana#XXXXX

Both branches use the same name to enable enterprise CI to test against the OSS changes.
```

### Labels

**Feature Flag PRs** (OSS only):
- `add to changelog`
- `type/feature-request`
- `area/secrets` (or relevant area)
- **NOT** `area/frontend` or `area/backend` (flags are neither)
- **NOT** `area/security` (reserved for vulnerability fixes)

**Feature Implementation PRs**:
- `add to changelog`
- `enhancement` (enterprise) or `type/feature-request` (OSS)
- `area/frontend` (if UI code) or `area/backend` (if backend code)
- `area/secrets` (or relevant area)

---

## Common Mistakes to Avoid

### ❌ Committing Enterprise Code to OSS

**NEVER force-add enterprise code to OSS**:
```bash
# WRONG - bypasses gitignore
git add -f public/app/extensions/my-feature/Component.tsx
```

**Why wrong**:
- `/public/app/extensions` is gitignored for a reason
- Enterprise code syncs to OSS during build, not via git
- Creates confusion about source of truth

**If you accidentally push enterprise code to OSS**:
1. Close the PR immediately
2. Delete the branch
3. If code is sensitive, contact #security to wipe the PR

**What should be in OSS commits**:
- Only `/public/app/extensions/index.ts` if it doesn't exist on main
- Actually, check if file exists on main first: `git show origin/main:path/to/file`
- If it doesn't exist on main, it's enterprise code - don't commit it

### ❌ Running Git Commands During Sync

**NEVER run git operations on enterprise repo while `make enterprise-dev` is active**:
```bash
# WRONG - watcher is running
cd ~/projects/grafana-enterprise
git checkout other-branch  # ❌ WILL CAUSE CONFLICTS
```

**Correct**:
```bash
# In OSS repo
Ctrl+C                     # Stop watcher first
cd ../grafana-enterprise
git checkout other-branch  # ✅ Now safe
cd ../grafana
make enterprise-dev        # Restart
```

### ❌ Mismatched Branch Names

**Don't use different names when you have changes in both repos**:
```bash
# WRONG
OSS: eshields/feature/add-flag
Enterprise: eshields/feature/ui-implementation

# RIGHT
Both: eshields/feature/ui-implementation
```

**Why**: Enterprise CI won't find your OSS branch, will test against `main` instead

---

## Development Workflow Summary

### Standard Enterprise Feature Workflow

1. **Setup**:
   ```bash
   cd ~/projects/grafana
   make enterprise-dev  # Start watcher
   ```

2. **Development**:
   - Work in OSS repo (code syncs from enterprise automatically)
   - Make changes - they appear in `/public/app/extensions/`
   - Test in OSS repo

3. **Committing** (STOP WATCHER FIRST):
   ```bash
   Ctrl+C  # Stop make enterprise-dev

   # Commit to enterprise repo
   cd ~/projects/grafana-enterprise
   git add src/public/my-feature/
   git commit -m "Add feature"
   git push origin eshields/feature/my-feature

   # If OSS changes needed (feature flags, etc.)
   cd ~/projects/grafana
   git add pkg/services/featuremgmt/
   git commit -m "Add feature flag"
   git push origin eshields/feature/my-feature  # Same branch name!

   # Restart watcher
   make enterprise-dev
   ```

4. **Pull Requests**:
   - Create enterprise PR (always)
   - Create OSS PR only if OSS changes exist
   - Use identical branch names
   - Add cross-references in PR descriptions
   - Label appropriately

5. **Review and Merge**:
   - Enterprise CI tests against your OSS branch automatically (if names match)
   - Merge OSS PR first (if exists)
   - Then merge enterprise PR

---

## Quick Reference

### When Do I Need an OSS PR?

| Scenario | OSS PR Needed? | Enterprise PR Needed? |
|----------|----------------|----------------------|
| New UI component only | No | Yes |
| New backend service only | No | Yes |
| New feature flag | Yes | No |
| Feature + feature flag | Yes (flag) | Yes (feature) |
| OSS infrastructure change | Yes | No |
| Update enterprise + OSS settings | Yes | Yes |

### What Goes Where?

| Code Location | Committed To | Synced During |
|--------------|--------------|---------------|
| `/src/public/*` (enterprise) | grafana-enterprise | `make enterprise-dev` |
| `/src/pkg/extensions/*` (enterprise) | grafana-enterprise | `make enterprise-dev` |
| `/public/app/extensions/*` (OSS) | **DO NOT COMMIT** (gitignored) | Build time |
| `/pkg/services/featuremgmt/*` (OSS) | grafana | N/A (OSS code) |
| Settings, configs (OSS) | grafana | N/A (OSS code) |

---

## See Also

- [grafana-enterprise README](https://github.com/grafana/grafana-enterprise/blob/main/README.md) - Complete dual-repo architecture
- [feature-toggles.md](./feature-toggles.md) - Feature flag guidelines
- [create-pull-request.md](./create-pull-request.md) - General PR guidelines
