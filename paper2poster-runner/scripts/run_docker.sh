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
DOCKER_CONFIG_DIR="$ROOT/.docker-config"

mkdir -p "$DOCKER_CONFIG_DIR"
export DOCKER_CONFIG="${DOCKER_CONFIG:-$DOCKER_CONFIG_DIR}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed or not on PATH." >&2
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

set -a
source "$ENV_FILE"
set +a

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "OPENAI_API_KEY missing from .env" >&2
  exit 1
fi

mkdir -p "$OUTPUTS_DIR"

cd "$REPO_DIR"
docker build -t paper2poster .

docker_args=(
  run
  --rm
  -e "OPENAI_API_KEY=$OPENAI_API_KEY"
)

if [ -n "${GOOGLE_SEARCH_API_KEY:-}" ]; then
  docker_args+=(-e "GOOGLE_SEARCH_API_KEY=$GOOGLE_SEARCH_API_KEY")
fi

if [ -n "${GOOGLE_SEARCH_ENGINE_ID:-}" ]; then
  docker_args+=(-e "GOOGLE_SEARCH_ENGINE_ID=$GOOGLE_SEARCH_ENGINE_ID")
fi

docker_args+=(
  -v "$DATA_DIR:/Paper2Poster-data"
  -v "$OUTPUTS_DIR:/app/${MODEL_TAG}_generated_posters"
  paper2poster
  python -m PosterAgent.new_pipeline
  "--poster_path=/Paper2Poster-data/$PAPER_FOLDER/paper.pdf"
  "--model_name_t=$TEXT_MODEL"
  "--model_name_v=$VISION_MODEL"
  "--poster_width_inches=$POSTER_WIDTH"
  "--poster_height_inches=$POSTER_HEIGHT"
)

docker "${docker_args[@]}"

"$ROOT/scripts/copy_final.sh" "$PAPER_FOLDER" "$MODEL_TAG" "$OUTPUTS_DIR"
