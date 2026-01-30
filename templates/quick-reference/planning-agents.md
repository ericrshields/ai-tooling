# Quick Reference: Planning Agents

One-page guide for using Document Analyzer and Question Resolver agents in planning workflows.

---

## Document Analyzer Agent

**Purpose**: Extract and synthesize information from multiple documents with conflict detection

**When to Use**:
- 2+ source documents need review
- Documents are long (>1000 lines each)
- Need conflict detection between documents
- Want 50% token reduction vs manual review

**Usage**:
```bash
claude agent run document-analyzer \
  --documents="design-doc.md,requirements.md,plan.md" \
  --focus="requirements,architecture,constraints,conflicts" \
  --output-format="structured-summary"
```

**Output**:
- Requirements categorized (MUST/SHOULD/COULD)
- Architecture decisions extracted
- Conflicts detected with severity
- Open questions identified
- Key quotes with source attribution (file:line)

**Expected Performance**:
- Token reduction: 40-50% (40K → 20K typical)
- Processing time: <5 minutes for 3 documents
- Conflict detection: 100% recall on major conflicts

**Full Documentation**: `~/.ai/instructions/document-analyzer-agent.md`

---

## Question Resolver Agent

**Purpose**: Auto-resolve open questions in plans through codebase exploration

**When to Use**:
- Plan has 3+ open questions
- Questions are about codebase (not product decisions)
- Want to reduce planning iterations
- Before user review to minimize back-and-forth

**Usage**:
```bash
claude agent run question-resolver \
  --plan-file="plan.md" \
  --strategy="comprehensive" \
  --confidence-threshold=0.8
```

**Search Strategies**:
- `quick`: Grep only (<2 minutes)
- `targeted`: Grep + Read files (<4 minutes)
- `comprehensive`: Grep + Read + Explore agents (<8 minutes)

**Output**:
- Resolved questions with evidence (file:line)
- Confidence scores (90-100%, 70-89%, 50-69%)
- Partial answers with gaps identified
- Unresolvable questions flagged (needs human input)

**Expected Performance**:
- Resolution rate: 60%+ of answerable questions
- Precision: >95% (no false positives)
- Processing time: <5 minutes for typical plan
- Token usage: 10-15K

**Full Documentation**: `~/.ai/instructions/question-resolver-agent.md`

---

## Sequential Workflow

Use both agents together for maximum planning acceleration:

```bash
# 1. Document Analysis (Phase 1 of planning)
claude agent run document-analyzer \
  --documents="design-doc.md,requirements.md,existing-plan.md" \
  --focus="requirements,architecture,constraints,conflicts"

# 2. Review document analysis output
# 3. Explore codebase (Phase 2)
# 4. Design solution (Phase 3)
# 5. Write initial implementation plan (Phase 4)

# 6. Question Resolution (Phase 4 of planning)
claude agent run question-resolver \
  --plan-file="plan.md" \
  --strategy="comprehensive" \
  --confidence-threshold=0.8

# 7. Review resolved questions
# 8. Address remaining open questions
# 9. Use ExitPlanMode for approval (Phase 5)
```

---

## Expected Overall Impact

When using both agents in planning:

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Planning Time | 2 hours | 1 hour | 50% reduction |
| Token Usage | 110K | 60K | 45% reduction |
| Plan Accuracy | 85% | 95% | 10% improvement |
| Open Questions | 5 | 2 | 60% reduction |

---

## When to Skip

**Skip Document Analyzer if**:
- Only 1 source document
- Documents are short (<500 lines)
- User already knows all requirements

**Skip Question Resolver if**:
- Only 1-2 questions
- All questions need product/team input (not codebase answers)
- Questions are philosophical/architectural decisions

---

## Integration with Planning Workflow

Agents integrate into the five-phase planning pattern:

**Phase 1: Understand Requirements**
- ✅ Use document-analyzer for multi-document synthesis
- ✅ Automatically detects conflicts
- ✅ Pre-categorizes requirements

**Phase 4: Create Implementation Plan**
- ✅ Use question-resolver after initial draft
- ✅ Reduces open questions by 60%
- ✅ Provides evidence-based answers

**See**: `~/.ai-context-store/user-wide/rules/planning-workflow.md`

---

## Troubleshooting

**Document Analyzer: No conflicts detected**
- Expected: Not all documents have conflicts
- If conflicts expected: Check focus areas include relevant sections

**Question Resolver: Low resolution rate (<40%)**
- Common: Questions may require team/product knowledge
- Try: Run with `--strategy=comprehensive` for deeper search
- Check: Are questions about codebase or product decisions?

**High token usage**
- Document Analyzer: Large documents (>3000 lines) may need Opus model
- Question Resolver: Use `quick` or `targeted` strategy for faster/cheaper results

---

**Related Documentation**:
- [~/.ai/instructions/document-analyzer-agent.md](../../instructions/document-analyzer-agent.md) - Full agent definition
- [~/.ai/instructions/question-resolver-agent.md](../../instructions/question-resolver-agent.md) - Full agent definition
- [~/.ai-context-store/user-wide/rules/planning-workflow.md](../../../.ai-context-store/user-wide/rules/planning-workflow.md) - Planning integration
- [~/.ai-context-store/plans/ai-tooling-improvements-secrets-keeper-retrospective.md](../../../.ai-context-store/plans/ai-tooling-improvements-secrets-keeper-retrospective.md) - Original recommendations
