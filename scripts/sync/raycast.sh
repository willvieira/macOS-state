#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SNAPSHOTS_DIR="$REPO_ROOT/snapshots"

RAYCAST_DIR="$HOME/Library/Application Support/com.raycast.macos"

if [[ ! -d "$RAYCAST_DIR" ]]; then
  echo "  Raycast config not found — skipping"
  exit 0
fi

rsync -a --delete "$RAYCAST_DIR/" "$SNAPSHOTS_DIR/raycast/"
echo "  Raycast settings captured -> snapshots/raycast/"
