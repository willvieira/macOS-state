#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SNAPSHOTS_DIR="$REPO_ROOT/snapshots"

DISPLAY_SLEEP=$(pmset -g | awk '/displaysleep/ {print $2}')
SLEEP=$(pmset -g | awk '/^[[:space:]]+sleep[[:space:]]/ {print $2}')

DEFAULT_BROWSER=""
if command -v defaultbrowser &>/dev/null; then
  DEFAULT_BROWSER=$(defaultbrowser 2>/dev/null | grep -oE '[^ ]+(?= \*)' || echo "")
fi

cat > "$SNAPSHOTS_DIR/macos.toml" <<EOF
[macos]
display_sleep   = $DISPLAY_SLEEP
idle_timeout    = $SLEEP
default_browser = "$DEFAULT_BROWSER"
EOF

echo "  macOS prefs captured -> snapshots/macos.toml"
