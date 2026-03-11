#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$ROOT/Paper2Poster"
TEMP_DIR="$ROOT/Paper2Poster-main"
TEMP_ZIP="$ROOT/Paper2Poster-main.zip"
URL="https://codeload.github.com/Paper2Poster/Paper2Poster/zip/refs/heads/main"
DOCKER_CONFIG_DIR="$ROOT/.docker-config"

mkdir -p "$DOCKER_CONFIG_DIR"
export DOCKER_CONFIG="${DOCKER_CONFIG:-$DOCKER_CONFIG_DIR}"

if [ -f "$REPO_DIR/README.md" ]; then
  echo "Paper2Poster already exists at $REPO_DIR"
  exit 0
fi

rm -rf "$REPO_DIR" "$TEMP_DIR" "$TEMP_ZIP"

echo "Downloading upstream Paper2Poster zip..."
curl \
  --fail \
  --location \
  --continue-at - \
  --retry 5 \
  --retry-all-errors \
  --retry-delay 5 \
  --connect-timeout 30 \
  "$URL" \
  -o "$TEMP_ZIP"

echo "Extracting archive..."
unzip -q "$TEMP_ZIP" -d "$ROOT"
mv "$TEMP_DIR" "$REPO_DIR"
rm -f "$TEMP_ZIP"

echo "Upstream Paper2Poster is ready at $REPO_DIR"
