#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSIONS_ROOT="$ROOT/versions"
PAPER_FOLDER="${1:-}"

if [ ! -d "$VERSIONS_ROOT" ]; then
  echo "No versions directory exists yet."
  exit 0
fi

if [ -n "$PAPER_FOLDER" ]; then
  find "$VERSIONS_ROOT/$PAPER_FOLDER" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort
else
  find "$VERSIONS_ROOT" -mindepth 2 -maxdepth 2 -type d 2>/dev/null | sort
fi

