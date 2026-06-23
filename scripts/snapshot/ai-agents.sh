#!/usr/bin/env bash
set -euo pipefail

# NOTE: captured Claude config files may contain sensitive values depending on local setup
# Keep generated snapshots private if these files contain secrets

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_ROOT/scripts/lib/snapshots.sh"
resolve_snapshots_dir

OUT="$SNAPSHOTS_DIR/ai-agents.txt"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

{
  echo "# AI agents"
  echo ""
  for command_name in claude codex hermes; do
    if command -v "$command_name" &>/dev/null; then
      version_output=$("$command_name" --version 2>&1 | head -n 1 || true)
      echo "$command_name: $(command -v "$command_name")"
      echo "$command_name version: ${version_output:-unknown}"
    else
      echo "$command_name: missing"
    fi
    echo ""
  done

  echo "# Claude skills"
  echo "claude: $HOME/.claude/skills"
  echo ""

  if [[ -d "$HOME/.claude/skills" ]]; then
    find "$HOME/.claude/skills" -maxdepth 2 -name SKILL.md -print | sort
  else
    echo "missing"
  fi
} > "$OUT"

echo "  AI agent versions and Claude skills captured -> $OUT"

if [[ -f "$CLAUDE_SETTINGS" ]]; then
  cp "$CLAUDE_SETTINGS" "$SNAPSHOTS_DIR/ai-agents-claude-settings.json"
  echo "  Claude settings captured -> $SNAPSHOTS_DIR/ai-agents-claude-settings.json"

  python3 - "$CLAUDE_SETTINGS" "$SNAPSHOTS_DIR/ai-agents-claude-plugins.txt" <<'PYEOF'
import json
import sys

with open(sys.argv[1]) as f:
    cfg = json.load(f)
plugins = cfg.get("enabledPlugins", {})
with open(sys.argv[2], "w") as out:
    for key in sorted(plugins.keys()):
        out.write(key + "\n")
print(f"  {len(plugins)} Claude plugins captured -> {sys.argv[2]}")
PYEOF
else
  echo "  ~/.claude/settings.json not found — skipping Claude settings capture"
fi
