#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_ROOT/scripts/lib/snapshots.sh"
resolve_snapshots_dir

if ! command -v brew &>/dev/null; then
  echo "  brew not found — skipping"
  exit 0
fi

brew bundle dump --force --no-describe --file="$SNAPSHOTS_DIR/Brewfile"
echo "  Homebrew state captured -> $SNAPSHOTS_DIR/Brewfile"
