#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PAPER_FOLDER="${1:-my_paper}"
TEXT_MODEL="${TEXT_MODEL:-4o}"
VISION_MODEL="${VISION_MODEL:-4o}"
POSTER_WIDTH="${POSTER_WIDTH:-48}"
POSTER_HEIGHT="${POSTER_HEIGHT:-36}"
MODEL_TAG="${TEXT_MODEL}_${VISION_MODEL}"
REPO_DIR="$ROOT/Paper2Poster"
DATA_DIR="$ROOT/Paper2Poster-data"
OUTPUTS_DIR="$ROOT/outputs"
ENV_FILE="$ROOT/.env"
PAPER_PDF="$DATA_DIR/$PAPER_FOLDER/paper.pdf"

if ! command -v python >/dev/null 2>&1; then
  echo "python is not installed or not on PATH." >&2
  exit 1
fi

if [ ! -f "$REPO_DIR/README.md" ]; then
  echo "Upstream Paper2Poster is missing. Run ./scripts/bootstrap_upstream.sh first." >&2
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo ".env not found. Copy .env.example to .env first." >&2
  exit 1
fi

if [ ! -f "$PAPER_PDF" ]; then
  echo "Input paper not found at $PAPER_PDF" >&2
  exit 1
fi

if ! command -v soffice >/dev/null 2>&1; then
  echo "Warning: soffice is not on PATH. Local export may fail." >&2
fi

if ! command -v pdftoppm >/dev/null 2>&1; then
  echo "Warning: pdftoppm is not on PATH. Install poppler if local rendering fails." >&2
fi

set -a
source "$ENV_FILE"
set +a

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "OPENAI_API_KEY missing from .env" >&2
  exit 1
fi

mkdir -p "$OUTPUTS_DIR"
export PYTHONPATH="$REPO_DIR:${PYTHONPATH:-}"

cd "$REPO_DIR"
python -m PosterAgent.new_pipeline \
  --poster_path="$PAPER_PDF" \
  --model_name_t="$TEXT_MODEL" \
  --model_name_v="$VISION_MODEL" \
  --poster_width_inches="$POSTER_WIDTH" \
  --poster_height_inches="$POSTER_HEIGHT"

REPO_OUTPUT_DIR="$REPO_DIR/${MODEL_TAG}_generated_posters/Paper2Poster-data/$PAPER_FOLDER"
WRAPPER_OUTPUT_DIR="$OUTPUTS_DIR/Paper2Poster-data/$PAPER_FOLDER"

if [ -d "$REPO_OUTPUT_DIR" ]; then
  mkdir -p "$WRAPPER_OUTPUT_DIR"
  cp -R "$REPO_OUTPUT_DIR"/. "$WRAPPER_OUTPUT_DIR"/
fi

"$ROOT/scripts/copy_final.sh" "$PAPER_FOLDER" "$MODEL_TAG" "$OUTPUTS_DIR"

