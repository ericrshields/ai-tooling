# Codebase Explorer Agent - Research & Design Notes

**Status**: Future implementation (Agent idea)
**Purpose**: Intelligent codebase exploration that determines what code needs to be read for a given explore task
**Last Updated**: 2026-01-30

---

## Overview

Agent to solve the exploration scope problem: Claude often doesn't explore widely enough to find important code in other areas of the codebase, but also should not attempt to ingest the entire codebase. This agent determines the optimal set of files to read for a given exploration task.

---

## Problem Statement

### Current Challenges

**Under-exploration**:
- Claude often stops searching after finding initial matches
- Misses important related code in other directories
- Doesn't follow dependency chains deeply enough
- Fails to discover similar patterns in parallel modules

**Over-exploration**:
- Attempting to read entire codebase wastes tokens
- Reduces available context for actual analysis
- Slows down exploration significantly
- Creates noise that obscures relevant findings

**Context Budget**:
- 200K token limit requires intelligent file selection
- Each unnecessary file read reduces space for analysis
- Need to maximize signal-to-noise ratio in exploration results

### Impact

- **Incomplete Understanding**: Missing critical code leads to flawed implementations
- **Wasted Context**: Reading irrelevant files consumes tokens without value
- **Slow Iterations**: Poor exploration requires multiple back-and-forth cycles
- **Plan Quality**: Incomplete exploration produces incomplete plans (current ~85% accuracy)

---

## Agent Objectives

### Primary Goal
Determine the minimal set of files that provides complete understanding for a given exploration task, balancing breadth (finding all relevant code) with depth (understanding critical implementations).

### Success Criteria

**Precision**:
- 90%+ of recommended files are relevant to the task
- Minimal false positives (irrelevant files)

**Recall**:
- 95%+ of critical files are included in recommendations
- Minimal false negatives (missing important code)

**Efficiency**:
- Token usage: 20-30% less than manual exploration
- Exploration time: <5 minutes for typical codebase
- Context preserved: 60%+ of budget available for analysis after exploration

**Completeness**:
- All architectural layers touched (UI, API, data, utils)
- All related modules discovered (not just direct matches)
- Dependency chains followed to logical boundaries

---

## Exploration Strategies

### 1. Query Analysis

**Input**: User's exploration query (e.g., "How does authentication work?")

**Actions**:
- Extract key concepts: "authentication", "login", "auth"
- Identify scope: specific feature vs. general pattern
- Determine breadth: narrow (single component) vs. wide (entire flow)
- Classify type: implementation detail, architecture, data flow, integration

**Output**: Structured exploration plan with focus areas

### 2. Tiered Search Strategy

**Tier 1: Entry Points** (Always Read)
- Main implementations matching query keywords
- Public APIs and interfaces
- Configuration and constants

**Tier 2: Dependencies** (Conditional Read)
- Direct imports and exports
- Parent and child components
- Shared utilities and helpers

**Tier 3: Related Patterns** (Heuristic Read)
- Similar naming patterns in other modules
- Parallel implementations (e.g., multiple auth providers)
- Test files (reveal usage patterns)

**Tier 4: Context** (Rarely Read)
- Documentation files
- Historical implementations (deprecated)
- Edge case handling

### 3. Dependency Graph Analysis

**Build Lightweight Graph**:
```typescript
interface FileNode {
  path: string
  imports: string[]
  exports: string[]
  relevanceScore: number
  tier: 1 | 2 | 3 | 4
}
```

**Traversal Strategy**:
- Start from Tier 1 matches (keyword search results)
- Follow imports/exports up to 2-3 hops
- Score each file by:
  - Keyword frequency (higher = more relevant)
  - Centrality in dependency graph (high in-degree = important)
  - Path similarity to known matches (same directory = likely related)
  - File size (exclude very large files unless critical)

**Pruning Rules**:
- Skip files with relevance score < threshold
- Stop at architectural boundaries (e.g., don't cross from frontend to backend unless query requires)
- Exclude node_modules, build outputs, test fixtures
- De-duplicate similar files (e.g., multiple test files for same component)

### 4. Pattern Matching

**Identify Related Code by Patterns**:
- Naming conventions: `AuthService`, `AuthProvider`, `AuthContext`
- Directory structure: All files in `auth/` directory
- Import patterns: Files importing the same utilities
- Test co-location: Tests revealing component interactions

**Example**:
```
Query: "How does authentication work?"

Pattern matches:
- Naming: *Auth*, *Login*, *Session*
- Directories: src/auth/, src/services/auth/, src/hooks/useAuth*
- Imports: Files importing 'jwt-decode', '@auth/core'
- Tests: *.test.ts files in auth directories
```

### 5. Incremental Refinement

**Initial Pass** (Fast, ~2 minutes):
- Keyword search for obvious matches
- Read top 5-10 most relevant files
- Build initial dependency map

**Refinement Pass** (If Needed):
- User clarifies what's still unclear
- Agent identifies gaps in current understanding
- Targeted search for specific missing pieces

**Advantages**:
- Fast initial results
- User-guided depth control
- Avoids over-exploration upfront

---

## Agent Workflow

### Phase 1: Query Understanding

**Input**: User's exploration request

**Actions**:
1. Parse query for key concepts and scope
2. Classify exploration type (implementation, architecture, data flow, integration)
3. Estimate required breadth (single file, module, cross-module, full-stack)
4. Set token budget for exploration (e.g., 20K tokens = ~40-50 files)

**Output**: Exploration plan with focus areas and constraints

### Phase 2: Initial Discovery

**Actions**:
1. Keyword search across codebase (Grep with multiple patterns)
2. Find entry points (main implementations, public APIs)
3. Score and rank matches by relevance
4. Select top N files for Tier 1 (typically 5-15 files)

**Output**: Tier 1 file list with relevance scores

### Phase 3: Dependency Analysis

**Actions**:
1. Read Tier 1 files to extract imports/exports
2. Build dependency graph (2-3 hops deep)
3. Score dependent files by centrality and keyword overlap
4. Select Tier 2 files (typically 10-20 files)

**Output**: Tier 2 file list with dependency justification

### Phase 4: Pattern Expansion

**Actions**:
1. Identify naming and structural patterns from Tiers 1-2
2. Search for similar patterns in parallel modules
3. Find test files that reveal usage patterns
4. Select Tier 3 files (typically 5-10 files)

**Output**: Tier 3 file list with pattern justification

### Phase 5: Recommendation Generation

**Actions**:
1. Consolidate all tiers into prioritized reading list
2. Estimate token usage and context impact
3. Identify gaps (areas likely missing but uncertain)
4. Provide rationale for each file's inclusion

**Output**: Structured recommendation report

**Report Format**:
```markdown
# Codebase Exploration Recommendation

**Query**: [User's exploration request]
**Estimated Token Usage**: 25K tokens (40 files)
**Context Remaining**: 75% (150K tokens available for analysis)

---

## Tier 1: Entry Points (MUST READ)
1. src/auth/AuthService.ts (relevance: 95%)
   - Main authentication service implementation
   - Handles login, logout, session management

2. src/auth/AuthContext.tsx (relevance: 90%)
   - React context providing auth state
   - Used by all protected components

## Tier 2: Dependencies (SHOULD READ)
3. src/hooks/useAuth.ts (relevance: 85%)
   - Hook consuming AuthContext
   - Shows usage patterns

## Tier 3: Related Patterns (COULD READ)
10. src/services/oauth/OAuthProvider.ts (relevance: 70%)
    - Alternative auth method
    - Parallel implementation pattern

## Gaps Identified
- Backend auth validation logic not found (may be in separate service)
- Token refresh mechanism unclear (check interceptors)

## Recommended Next Steps
1. Read Tier 1 files first (5 files, ~10K tokens)
2. If authentication flow still unclear, read Tier 2 (10 files, ~15K tokens)
3. For OAuth specifics, read Tier 3 as needed
```

---

## Integration Points

### With Explore Agent

**Current Explore Agent**:
- User provides query
- Explore agent searches broadly
- Reads many files
- Synthesizes findings

**With Codebase Explorer Agent**:
- User provides query
- **Codebase Explorer determines what to read**
- Explore agent reads recommended files only
- Synthesizes findings with complete context

**Workflow**:
```bash
# User query
"How does the dashboard caching work?"

# Codebase Explorer Agent determines files
claude agent run codebase-explorer --query "dashboard caching"
# Returns: 12 files to read (src/dashboard/cache/, src/services/cacheManager.ts, etc.)

# Explore Agent reads recommended files only
claude agent run explore --files [recommended list] --focus "caching strategy"
# Synthesizes complete answer from targeted file set
```

### With Planning Workflow

**Phase 2: Explore Codebase** (Current):
- Manual file discovery
- May miss related code
- May read too much

**Phase 2: Explore Codebase** (With Agent):
- Codebase Explorer determines exploration scope
- Targeted file reading
- Complete coverage with minimal waste

### With Question Resolver

**Question Resolver** determines what to search for (keywords, patterns)
**Codebase Explorer** determines which files to read (scope, dependencies)

**Combined**:
```
Question: "Where is External ID generated?"

Question Resolver:
- Search for: "External ID", "externalID", "generateExternal"
- Expected locations: keeper package, AWS provider

Codebase Explorer:
- Tier 1: pkg/secrets/keeper/aws.go (keyword match)
- Tier 2: pkg/secrets/keeper/types.go (dependency)
- Tier 3: pkg/secrets/keeper/aws_test.go (usage pattern)
- Recommendation: Read 3 files for complete answer
```

---

## Advanced Techniques

### 1. Semantic Similarity (Future Enhancement)

Use embeddings to find semantically related code even without keyword matches:
- Embed function/class docstrings and names
- Find similar embeddings (cosine similarity > 0.7)
- Discover related code by meaning, not just keywords

**Example**:
```
Query: "authentication"
Semantic matches:
- "user verification" (no keyword match but semantically similar)
- "access control" (related concept)
```

### 2. Historical Analysis (Future Enhancement)

Learn from past explorations:
- Track which files were actually useful in previous explorations
- Build confidence scores based on historical relevance
- Improve recommendations over time

**Example**:
```
Query: "How does feature X work?"
Historical data shows:
- 80% of similar queries needed src/features/X/service.ts
- 60% also needed src/hooks/useX.ts
- 20% needed src/utils/Xhelper.ts (often missed in initial search)

Recommendation: Include all three in Tier 1
```

### 3. User Feedback Loop

After exploration, ask user:
- "Did you find what you needed?"
- "Were any files irrelevant?"
- "What was still unclear?"

Use feedback to refine:
- Relevance scoring thresholds
- Dependency hop depth
- Pattern matching rules

---

## Success Metrics

**Exploration Quality**:
- Precision: 90%+ of recommended files are relevant
- Recall: 95%+ of critical files are included
- User satisfaction: "Exploration was complete" (subjective survey)

**Efficiency**:
- Token reduction: 20-30% less than manual exploration
- Time reduction: 40-50% faster exploration phase
- Context preservation: 60%+ of budget available after exploration

**Plan Accuracy** (Downstream Impact):
- Plan accuracy improves from 85% → 95% (better exploration = better plans)
- Open questions reduce from 5 → 2 (fewer unknowns after exploration)

---

## Challenges & Mitigations

### Challenge 1: Dynamic Imports

**Problem**: Static analysis can't find dynamic imports
```typescript
const module = await import(`./plugins/${pluginName}`)
```

**Mitigation**:
- Heuristic search for plugin directories
- Pattern matching on dynamic import strings
- User confirmation: "Check plugins directory for additional implementations?"

### Challenge 2: Monorepos

**Problem**: Related code may span multiple packages
```
packages/
  frontend/
  backend/
  shared/
```

**Mitigation**:
- Detect monorepo structure (lerna.json, package.json workspaces)
- Search across packages when query suggests cross-package concern
- Respect package boundaries (don't cross unless necessary)

### Challenge 3: Large Files

**Problem**: Some files are thousands of lines (token expensive)

**Mitigation**:
- Check file size before recommending
- For large files, recommend specific functions/classes instead of full file
- Use grep with context lines to preview relevant sections

### Challenge 4: Generated Code

**Problem**: Build outputs, generated types, compiled code

**Mitigation**:
- Exclude common generated paths (dist/, build/, .next/, node_modules/)
- Check for generation markers (comments like "AUTO-GENERATED")
- Prefer source files over generated equivalents

---

## Related Agents

- **Explore Agent**: Consumes Codebase Explorer recommendations to synthesize findings
- **Question Resolver**: Uses Codebase Explorer to find evidence for open questions
- **Document Analyzer**: May use Codebase Explorer to validate implementation matches design docs

---

## Next Steps (When Implementing)

1. **Prototype**: Build basic keyword + dependency graph approach
2. **Evaluate**: Test on 10-20 real exploration queries, measure precision/recall
3. **Refine**: Adjust scoring thresholds based on evaluation results
4. **Integrate**: Connect with Explore agent and Question Resolver
5. **Iterate**: Add semantic similarity and historical learning over time

---

**Related Documentation**:
- [question-resolver-agent.md](~/.ai-context-store/user-wide/rules/question-resolver-agent.md) - Evidence gathering patterns
- [planning-workflow.md](~/.ai-context-store/user-wide/rules/planning-workflow.md) - Phase 2: Explore Codebase integration
- [Explore Agent](https://code.claude.com/docs/en/agents) - Official Explore agent documentation
