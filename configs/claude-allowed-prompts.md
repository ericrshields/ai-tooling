# Claude Code Allowed Prompts (Plan Mode Permissions)

Documentation for `allowedPrompts` - semantic, intent-based permissions for plan mode execution.

---

## Overview

**allowedPrompts** is a complementary permission system to static permissions (`claude-permissions.json`). While static permissions use explicit command patterns, allowedPrompts use semantic descriptions that match based on intent.

### Two Permission Systems

| Feature | Static Permissions | Allowed Prompts |
|---------|-------------------|-----------------|
| **File** | `settings.json` / `settings.local.json` | Requested via `ExitPlanMode` tool |
| **Scope** | Persistent across all sessions | Session-scoped (cleared when session ends) |
| **Matching** | Explicit patterns: `Bash(npm test:*)` | Semantic intent: "run tests" |
| **When Set** | Configuration time (manual) | Plan creation time (automatic) |
| **Flexibility** | Matches exact patterns | Matches any command with similar intent |
| **Use Case** | Common, repeated operations | Plan-specific operations |

### When to Use Each

**Static Permissions** (`claude-permissions.json`):
- Commands you run frequently across projects
- Standard development operations (build, test, lint)
- Read operations that are always safe
- Your personal workflow preferences

**Allowed Prompts** (plan mode):
- Commands specific to a plan's execution
- Operations needed for this particular task
- Temporary elevated permissions for plan duration
- Context-specific operations

---

## How Allowed Prompts Work

### Semantic Matching

When you approve a prompt like **"run tests"**, Claude Code matches commands by intent:

**Prompt**: `"run tests"`

**Matches**:
- `npm test`
- `npm run test:unit`
- `pytest`
- `go test`
- `bun test`
- `jest --coverage`

**Does NOT match**:
- `npm install` (different intent)
- `git push` (different intent)

### Requesting Prompts in Plan Mode

When exiting plan mode with `ExitPlanMode` tool, request permissions needed:

```json
{
  "allowedPrompts": [
    { "tool": "Bash", "prompt": "run tests" },
    { "tool": "Bash", "prompt": "install dependencies" },
    { "tool": "Bash", "prompt": "build the project" }
  ]
}
```

User sees these when approving the plan. Approved prompts allow matching commands to run without additional prompts during plan execution.

---

## Best Practices for Allowed Prompts

### 1. Scope Narrowly (Security-Conscious)

**❌ Too Broad**:
```json
{ "tool": "Bash", "prompt": "run commands" }
{ "tool": "Bash", "prompt": "deploy" }
{ "tool": "Bash", "prompt": "run database queries" }
```

**✅ Well-Scoped**:
```json
{ "tool": "Bash", "prompt": "run read-only database queries in dev environment" }
{ "tool": "Bash", "prompt": "deploy to staging environment only" }
{ "tool": "Bash", "prompt": "run unit and integration tests" }
```

### 2. Add Constraints

Always add constraints that limit scope:

**Environment Constraints**:
- "in development environment"
- "in staging namespace"
- "locally only"

**Action Constraints**:
- "read-only"
- "non-destructive"
- "without side effects"

**Scope Constraints**:
- "in src/ directory"
- "for feature X only"
- "in the test suite"

### 3. Split Actions

**❌ Combined Actions**:
```json
{ "tool": "Bash", "prompt": "build and deploy" }
{ "tool": "Bash", "prompt": "test and commit" }
```

**✅ Separate Permissions**:
```json
{ "tool": "Bash", "prompt": "build the project" },
{ "tool": "Bash", "prompt": "deploy to staging" }
```

**Why**: User can approve build but reject deploy if not ready.

### 4. Be Specific About What

**❌ Vague**:
```json
{ "tool": "Bash", "prompt": "make changes" }
{ "tool": "Bash", "prompt": "fix issues" }
```

**✅ Specific**:
```json
{ "tool": "Bash", "prompt": "format code with prettier" }
{ "tool": "Bash", "prompt": "fix lint errors automatically" }
```

---

## Example Allowed Prompts by Context

### Frontend Development

```json
{
  "allowedPrompts": [
    { "tool": "Bash", "prompt": "run unit tests in the project" },
    { "tool": "Bash", "prompt": "run end-to-end tests locally" },
    { "tool": "Bash", "prompt": "build production bundle" },
    { "tool": "Bash", "prompt": "check bundle size" },
    { "tool": "Bash", "prompt": "run linter with auto-fix" },
    { "tool": "Bash", "prompt": "format code with prettier" },
    { "tool": "Bash", "prompt": "run type checker" },
    { "tool": "Bash", "prompt": "start development server locally" }
  ]
}
```

### API Development

```json
{
  "allowedPrompts": [
    { "tool": "Bash", "prompt": "run API integration tests" },
    { "tool": "Bash", "prompt": "start local API server" },
    { "tool": "Bash", "prompt": "run database migrations in dev" },
    { "tool": "Bash", "prompt": "seed test database with fixtures" },
    { "tool": "Bash", "prompt": "make read-only API requests to staging" },
    { "tool": "Bash", "prompt": "validate OpenAPI schema" }
  ]
}
```

### DevOps / Infrastructure

```json
{
  "allowedPrompts": [
    { "tool": "Bash", "prompt": "validate terraform configuration" },
    { "tool": "Bash", "prompt": "plan infrastructure changes in staging" },
    { "tool": "Bash", "prompt": "list kubernetes pods in dev namespace" },
    { "tool": "Bash", "prompt": "view logs from staging environment" },
    { "tool": "Bash", "prompt": "check health endpoints for services" }
  ]
}
```

### Database Work

```json
{
  "allowedPrompts": [
    { "tool": "Bash", "prompt": "run read-only database queries on dev" },
    { "tool": "Bash", "prompt": "validate database schema" },
    { "tool": "Bash", "prompt": "run database tests locally" },
    { "tool": "Bash", "prompt": "create database backup in dev" }
  ]
}
```

### Component Development

```json
{
  "allowedPrompts": [
    { "tool": "Bash", "prompt": "run component tests" },
    { "tool": "Bash", "prompt": "generate component snapshot tests" },
    { "tool": "Bash", "prompt": "check component accessibility" },
    { "tool": "Bash", "prompt": "run visual regression tests" },
    { "tool": "Bash", "prompt": "build component documentation" }
  ]
}
```

---

## Anti-Patterns

### ❌ Overly Broad Permissions

```json
// BAD: Grants too much access
{ "tool": "Bash", "prompt": "run kubernetes commands" }
{ "tool": "Bash", "prompt": "access production" }
{ "tool": "Bash", "prompt": "run database commands" }
```

**Problem**: No constraints on what operations, which environment, or scope.

**Fix**: Add specific constraints:
```json
{ "tool": "Bash", "prompt": "list pods in dev namespace only" }
{ "tool": "Bash", "prompt": "read-only queries on staging database" }
```

### ❌ Redundant with Static Permissions

```json
// BAD: Already in static permissions
{ "tool": "Bash", "prompt": "run git status" }
{ "tool": "Bash", "prompt": "list files" }
{ "tool": "Bash", "prompt": "read package.json" }
```

**Problem**: These are already allowed via static permissions.

**Fix**: Only request prompts for operations NOT in static allow list.

### ❌ Missing Environment Constraints

```json
// BAD: Could affect production
{ "tool": "Bash", "prompt": "deploy application" }
{ "tool": "Bash", "prompt": "run migrations" }
{ "tool": "Bash", "prompt": "restart services" }
```

**Problem**: No environment specified - could be interpreted as production.

**Fix**: Always specify environment:
```json
{ "tool": "Bash", "prompt": "deploy to staging only" }
{ "tool": "Bash", "prompt": "run migrations on dev database" }
{ "tool": "Bash", "prompt": "restart services in local docker" }
```

### ❌ Action Verbs Without Read-Only Qualifier

```json
// BAD: Could be write operations
{ "tool": "Bash", "prompt": "query database" }
{ "tool": "Bash", "prompt": "access S3 bucket" }
{ "tool": "Bash", "prompt": "interact with API" }
```

**Problem**: Ambiguous - could include writes/deletes.

**Fix**: Explicitly state read-only when applicable:
```json
{ "tool": "Bash", "prompt": "run read-only database queries" }
{ "tool": "Bash", "prompt": "list S3 bucket contents only" }
{ "tool": "Bash", "prompt": "make read-only GET requests to API" }
```

---

## Integration with Static Permissions

### Layered Security Model

```
Layer 1: Static Deny List (claude-permissions.json)
         ↓ Block dangerous operations always

Layer 2: Static Allow List (claude-permissions.json)
         ↓ Common safe operations auto-approved

Layer 3: Allowed Prompts (plan mode)
         ↓ Plan-specific operations approved for session

Layer 4: Per-Command Approval
         ↓ Everything else requires case-by-case approval
```

### Decision Tree

```
Command requested
    ├─ In static deny? → ❌ Block
    ├─ In static allow? → ✅ Run
    ├─ Matches approved prompt? → ✅ Run
    └─ None of above? → ⚠️ Ask user
```

### Example Interaction

**Scenario**: Plan to add authentication feature

**Static Permissions** (already configured):
- ✅ `git status`, `git diff` (allowed)
- ✅ `npm test`, `npm run build` (allowed)
- ❌ `rm -rf` (denied)

**Allowed Prompts** (requested for this plan):
- ✅ "install authentication library" → matches `npm install bcrypt`
- ✅ "run authentication tests" → matches `npm run test:auth`
- ✅ "migrate user table in dev" → matches `npx knex migrate:latest`

**During Execution**:
- `npm test` → Runs (static permission)
- `npm install bcrypt` → Runs (matches prompt)
- `git commit` → Asks (not in static allow or prompts)
- `rm database.db` → Blocked (static deny)

---

## Requesting Good Prompts

### Template

```
[action verb] + [what] + [constraints]

Examples:
- "run" + "unit tests" + "in the project"
- "install" + "dependencies" + "from package.json"
- "build" + "production bundle" + "with optimization"
```

### Checklist Before Requesting

- [ ] Is this already in static allow list? (Don't duplicate)
- [ ] Is this in static deny list? (Won't be granted)
- [ ] Did I add environment constraints? (dev/staging/local)
- [ ] Did I add action constraints? (read-only/non-destructive)
- [ ] Did I split combined actions? (build AND deploy → separate)
- [ ] Is this the narrowest scope needed? (specific vs broad)
- [ ] Would I approve this if I saw it? (user perspective)

### Quality Levels

**Poor** (too broad):
```json
{ "tool": "Bash", "prompt": "run commands" }
```

**Better** (action specified):
```json
{ "tool": "Bash", "prompt": "run tests" }
```

**Good** (action + what):
```json
{ "tool": "Bash", "prompt": "run unit tests in src/" }
```

**Excellent** (action + what + constraints):
```json
{ "tool": "Bash", "prompt": "run unit tests in src/ with coverage report" }
```

---

## Maintenance

### Review Requested Prompts

When a plan requests prompts, review them:

1. **Are they necessary?** Already covered by static permissions?
2. **Are they scoped?** Environment, read-only, specific actions?
3. **Are they safe?** No production access, no destructive operations?
4. **Are they clear?** Understand exactly what will match?

### Update Static Permissions

If you frequently approve the same prompts across sessions:

**Signal**: Approving same prompt in 3+ different plans

**Action**: Consider adding to static allow list in `claude-permissions.json`

**Example**:
- Keep approving "install dependencies" → Add `Bash(npm install:*)` to static allow
- Keep approving "run e2e tests" → Add `Bash(npm run test:e2e:*)` to static allow

### Session Cleanup

allowedPrompts are automatically cleared when session ends. No manual cleanup needed.

---

## Comparison with Other Permission Systems

### vs Static Permissions

| | Static | Allowed Prompts |
|---|---|---|
| **Setup** | Manual config file | Automatic during plan |
| **Scope** | All sessions | Current session |
| **Matching** | Exact patterns | Semantic intent |
| **Best For** | Common operations | Plan-specific needs |

### vs Per-Command Approval

| | Allowed Prompts | Per-Command |
|---|---|---|
| **Friction** | Approved upfront | Prompt each time |
| **Visibility** | User sees list when approving plan | User sees one at a time |
| **Context** | Plan context clear | Limited context |
| **Best For** | Known plan needs | Unexpected operations |

---

## Related Documentation

- [claude-permissions.json](claude-permissions.json) - Static permission configuration
- [claude-permissions.md](claude-permissions.md) - Static permissions documentation
- [quality-gates.md](quality-gates.md) - Permission system patterns
- [agent-instruction-patterns.md](../templates/agent-instruction-patterns.md) - Agent autonomy rules

---

**Version**: 1.0.0 | **Created**: 2026-01-16

**Key Takeaway**: Allowed prompts are temporary, semantic permissions for plan execution. Use static permissions for common operations, allowed prompts for plan-specific needs, and scope both narrowly following security-conscious principles.
