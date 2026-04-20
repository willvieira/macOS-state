#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SNAPSHOTS_DIR="$REPO_ROOT/snapshots"

ITERM2_PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

if [[ ! -f "$ITERM2_PLIST" ]]; then
  echo "  iTerm2 preferences not found — skipping"
  exit 0
fi

cp "$ITERM2_PLIST" "$SNAPSHOTS_DIR/iterm2-profile.plist"
echo "  iTerm2 profile captured -> snapshots/iterm2-profile.plist"
