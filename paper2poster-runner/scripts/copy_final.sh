#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PAPER_FOLDER="${1:-my_paper}"
MODEL_TAG="${2:-4o_4o}"
SEARCH_ROOT="${3:-$ROOT/outputs}"
VERSION_ID="${4:-}"
VERSION_DIR="${5:-}"

SOURCE=""

if [ -f "$SEARCH_ROOT/Paper2Poster-data/$PAPER_FOLDER/poster.pptx" ]; then
  SOURCE="$SEARCH_ROOT/Paper2Poster-data/$PAPER_FOLDER/poster.pptx"
elif [ -f "$SEARCH_ROOT/$PAPER_FOLDER/poster.pptx" ]; then
  SOURCE="$SEARCH_ROOT/$PAPER_FOLDER/poster.pptx"
else
  SOURCE="$(find "$SEARCH_ROOT" -type f -name poster.pptx 2>/dev/null | grep "$PAPER_FOLDER" | head -n 1 || true)"
fi

if [ -z "$SOURCE" ]; then
  echo "poster.pptx not found under $SEARCH_ROOT for paper folder '$PAPER_FOLDER'." >&2
  exit 1
fi

mkdir -p "$ROOT/outputs/final"
if [ -n "$VERSION_ID" ]; then
  DEST="$ROOT/outputs/final/${PAPER_FOLDER}-${VERSION_ID}-${MODEL_TAG}.pptx"
else
  DEST="$ROOT/outputs/final/${PAPER_FOLDER}-${MODEL_TAG}.pptx"
fi
LATEST_DEST="$ROOT/outputs/final/${PAPER_FOLDER}-latest.pptx"
cp "$SOURCE" "$DEST"
cp "$SOURCE" "$LATEST_DEST"

if [ -n "$VERSION_DIR" ]; then
  mkdir -p "$VERSION_DIR/output"
  cp "$SOURCE" "$VERSION_DIR/output/poster.pptx"
fi

echo "Copied versioned PPTX to $DEST"
echo "Updated latest PPTX at $LATEST_DEST"
echo "$DEST"
