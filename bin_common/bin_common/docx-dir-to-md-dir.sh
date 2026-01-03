#!/usr/bin/env bash
set -euo pipefail

# convert-docx-to-md-outdir.sh
# Recursively convert .docx files to .md using pandoc, writing outputs to OUT_DIR.
# Media is extracted to OUT_DIR/attachments/<relative-path>/<basename>
#
# Usage:
#   ./convert-docx-to-md-outdir.sh OUT_DIR [SOURCE_DIR]
# Example:
#   ./convert-docx-to-md-outdir.sh ./out ./docs

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 OUT_DIR [SOURCE_DIR]" >&2
  exit 1
fi

OUT_DIR="$1"
SOURCE_DIR="${2:-.}"

# Verify pandoc is installed
if ! command -v pandoc >/dev/null 2>&1; then
  echo "Error: pandoc not found. Please install pandoc and re-run." >&2
  exit 1
fi

# Ensure out directory exists
mkdir -p "$OUT_DIR"

# Work from the source directory so relative paths are consistent
cd "$SOURCE_DIR"

# Find all .docx files (case-insensitive), skipping temporary Office files (~$*)
# Use null-delimited output to safely handle spaces and special characters
find . -type f \( -iname '*.docx' -a -not -name '~$*' \) -print0 |
while IFS= read -r -d '' file; do
  # Strip leading "./" to form a clean relative path
  rel="${file#./}"
  dir="$(dirname "$rel")"
  name="$(basename "$rel")"
  base="${name%.*}"

  # Output paths in OUT_DIR, preserving relative directory structure
  out_md="$OUT_DIR/$dir/$base.md"
  media_dir="$OUT_DIR/attachments/$dir/$base"

  # Create parent directories
  mkdir -p "$(dirname "$out_md")"
  mkdir -p "$media_dir"

  # Skip if output already exists; remove this check if you want to overwrite
  if [[ -e "$out_md" ]]; then
    echo "Skipping (exists): $out_md"
    continue
  fi

  echo "Converting: $file -> $out_md"
  pandoc \
    -t markdown_strict \
    --extract-media="$media_dir" \
    "$file" \
    -o "$out_md"
done

echo "Done. Markdown in: $OUT_DIR; attachments in: $OUT_DIR/attachments"