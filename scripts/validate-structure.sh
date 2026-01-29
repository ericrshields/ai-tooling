#!/bin/bash
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

echo "=== Repository Structure Validation ==="
echo ""

ERRORS=0

# Check file lengths (exclude web-context research)
echo "1/3 Checking file lengths..."
LONG_FILES=$(find configs/ instructions/ templates/ workflows/ patterns/ guides/ -name "*.md" 2>/dev/null | \
  xargs wc -l 2>/dev/null | \
  awk '$1 > 550 && $2 != "total" { print $2" ("$1" lines)" }' || true)

if [ -n "$LONG_FILES" ]; then
  echo "  ERROR: Files exceeding 550 lines:"
  echo "$LONG_FILES" | sed 's/^/    /'
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ All files under 550 lines"
fi

# Check for version footers
echo "2/3 Checking for version footers..."
FOOTER_FILES=$(grep -r "^\*\*Version\*\*:" configs/ instructions/ templates/ workflows/ patterns/ guides/ --include="*.md" 2>/dev/null | cut -d: -f1 | sort -u || true)

if [ -n "$FOOTER_FILES" ]; then
  echo "  ERROR: Found version footers (git should handle versioning):"
  echo "$FOOTER_FILES" | sed 's/^/    /'
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ No version footers found"
fi

# Check section divider consistency
echo "3/3 Checking section dividers..."
NONSTANDARD=$(grep -r "^-\{4,\}$" configs/ instructions/ templates/ workflows/ patterns/ guides/ --include="*.md" 2>/dev/null || true)

if [ -n "$NONSTANDARD" ]; then
  echo "  WARNING: Found dividers with 4+ hyphens (should be exactly 3):"
  echo "$NONSTANDARD" | sed 's/^/    /' | head -5
else
  echo "  ✓ Section dividers standardized"
fi

echo ""
if [ $ERRORS -eq 0 ]; then
  echo "✓ Structure validation complete"
  exit 0
else
  echo "ERROR: Structure validation failed ($ERRORS issues)"
  exit 1
fi
