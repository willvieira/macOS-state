#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_ROOT/scripts/lib/snapshots.sh"
resolve_snapshots_dir

BTT_DATA="$HOME/Library/Application Support/BetterTouchTool/bttdata2"

if [[ ! -f "$BTT_DATA" ]]; then
  echo "  BetterTouchTool data not found — skipping"
  exit 0
fi

cp "$BTT_DATA" "$SNAPSHOTS_DIR/btt-presets.bttdata2"
echo "  BetterTouchTool presets captured -> $SNAPSHOTS_DIR/btt-presets.bttdata2"
