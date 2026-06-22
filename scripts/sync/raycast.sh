#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_ROOT/scripts/lib/snapshots.sh"
resolve_snapshots_dir

RAYCAST_DIR="$HOME/Library/Application Support/com.raycast.macos"

if [[ ! -d "$RAYCAST_DIR" ]]; then
  echo "  Raycast config not found — skipping"
  exit 0
fi

rsync -a --delete "$RAYCAST_DIR/" "$SNAPSHOTS_DIR/raycast/"
echo "  Raycast settings captured -> $SNAPSHOTS_DIR/raycast/"
