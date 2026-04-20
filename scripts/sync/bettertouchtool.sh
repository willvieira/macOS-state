#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SNAPSHOTS_DIR="$REPO_ROOT/snapshots"

BTT_DATA="$HOME/Library/Application Support/BetterTouchTool/bttdata2"

if [[ ! -f "$BTT_DATA" ]]; then
  echo "  BetterTouchTool data not found — skipping"
  exit 0
fi

cp "$BTT_DATA" "$SNAPSHOTS_DIR/btt-presets.bttdata2"
echo "  BetterTouchTool presets captured -> snapshots/btt-presets.bttdata2"
