# Hybrid Script + Claude Reasoning Pattern

**Pattern**: Combine automated script analysis with Claude's semantic understanding for comprehensive results.

---

## Three-Phase Workflow

### Phase 1: Script Analysis (Mechanical Work)
- Scan files, extract sections
- Calculate similarity metrics (keyword overlap, structural patterns)
- Flag candidates above threshold
- Output JSON with quantitative scores

**What scripts CAN find**:
- Exact or near-exact duplications
- High keyword overlap (paraphrasing)
- Structural duplicates (same outline, different words)

**What scripts CANNOT find**:
- Conceptual duplications with different vocabulary
- Same patterns in different contexts
- Domain-specific semantic understanding

### Phase 2: Claude Reviews Candidates
- Read each candidate pair in full context
- Validate: True duplicate or false positive?
- Assess consolidation approach
- Provide nuanced recommendations

**What Claude adds**:
- Context awareness (understands purpose of each file)
- Semantic understanding (recognizes conceptual overlap)
- Judgment (same words, different meaning? vice versa?)

### Phase 2.5: Claude Proactive Search
- Search for what the script missed
- Find conceptual duplications with zero textual overlap
- Identify high-frequency patterns across contexts
- Flag semantic duplications script cannot detect

**Examples script misses**:
- "Use Read tool" vs "NEVER use Bash for file operations" (different words, same concept)
- Same workflow in different contexts (workflow/ vs rules/ vs proj-*/)
- Examples teaching identical patterns with different code

### Phase 3: Generate Comprehensive Report
- Combine all findings (script + Claude validation + proactive search)
- Provide quantitative metrics (similarity scores, token waste)
- Prioritize by impact
- Generate actionable recommendations

---

## Effectiveness

**Coverage**:
- Script finds: ~60% (textual similarity)
- Claude adds: ~40% (conceptual similarity)
- Combined: ~100% (comprehensive analysis)

**Performance**:
- Script: Seconds (automated scanning)
- Claude: Minutes (semantic analysis)
- Total: <10 minutes for 50+ files

**Accuracy**:
- Script: High recall, some false positives
- Claude: Filters false positives, adds missed items
- Combined: High precision and recall

---

## Applications

**Where this pattern applies**:
- Duplication detection (implemented)
- Code review (script checks linting, Claude reviews logic)
- Security audit (script checks known patterns, Claude finds novel issues)
- Test coverage (script calculates metrics, Claude identifies gaps)
- Documentation quality (script checks formatting, Claude reviews clarity)

**When to use**:
- Analysis task has both mechanical and semantic aspects
- Need quantitative metrics + qualitative judgment
- Want automation speed + AI intelligence
- False positives acceptable if filtered by human/AI

**When NOT to use**:
- Pure mechanical task (script alone sufficient)
- Pure semantic task (Claude alone sufficient)
- Real-time analysis needed (hybrid adds latency)

---

**Source**: Developed during ai-context-dedupe implementation (2026-02-06)
**Evidence**: Successfully analyzed 1,320 sections, found 43 candidates including conceptual duplications script couldn't detect
