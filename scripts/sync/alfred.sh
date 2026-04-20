#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SNAPSHOTS_DIR="$REPO_ROOT/snapshots"

ALFRED_DIR="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences"

if [[ ! -d "$ALFRED_DIR" ]]; then
  echo "  Alfred preferences not found — skipping"
  exit 0
fi

rsync -a --delete "$ALFRED_DIR/" "$SNAPSHOTS_DIR/alfred/"
echo "  Alfred preferences captured -> snapshots/alfred/"
