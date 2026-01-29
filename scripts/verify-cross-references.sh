#!/bin/bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "Verifying cross-references..."

BROKEN=0

# Check each markdown file
for file in configs/*.md instructions/*.md templates/*.md templates/*/*.md workflows/*.md patterns/*/*.md guides/*/*.md; do
  [ -f "$file" ] || continue

  FILE_DIR=$(dirname "$file")

  # Extract markdown links - must have bracket before parenthesis
  while IFS= read -r link; do
    # Skip empty
    [ -z "$link" ] && continue

    # Skip URLs
    [[ "$link" =~ ^https?:// ]] && continue

    # Skip wildcards and regex patterns (not real file references)
    [[ "$link" =~ \*|\| ]] && continue

    # Remove anchor
    link="${link%#*}"

    # Resolve path
    if [[ "$link" == /* ]]; then
      target="$link"
    else
      target="$FILE_DIR/$link"
    fi

    # Check existence
    if [ ! -f "$target" ]; then
      echo "BROKEN: $file → $link"
      BROKEN=$((BROKEN + 1))
    fi
  done < <(grep -oP '\[([^\]]+)\]\(\K([^)]+\.md[^)]*)' "$file" 2>/dev/null || true)
done

if [ $BROKEN -eq 0 ]; then
  echo "✓ All cross-references valid"
  exit 0
else
  echo "ERROR: Found $BROKEN broken links"
  exit 1
fi
