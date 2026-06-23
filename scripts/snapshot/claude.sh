#!/usr/bin/env bash
set -euo pipefail

# NOTE: snapshots/claude-settings.json is a verbatim copy of ~/.claude/settings.json
# and may contain API tokens or other sensitive data depending on the user's setup.
# Keep the repo private if settings.json contains secrets.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SETTINGS="$HOME/.claude/settings.json"
source "$REPO_ROOT/scripts/lib/snapshots.sh"
resolve_snapshots_dir

if [[ ! -f "$SETTINGS" ]]; then
  echo "  ~/.claude/settings.json not found — skipping"
  exit 0
fi

cp "$SETTINGS" "$SNAPSHOTS_DIR/claude-settings.json"
echo "  settings.json captured -> $SNAPSHOTS_DIR/claude-settings.json"

python3 - "$SETTINGS" "$SNAPSHOTS_DIR/claude-plugins.txt" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    cfg = json.load(f)
plugins = cfg.get("enabledPlugins", {})
with open(sys.argv[2], "w") as out:
    for key in sorted(plugins.keys()):
        out.write(key + "\n")
print(f"  {len(plugins)} plugins captured -> {sys.argv[2]}")
PYEOF
