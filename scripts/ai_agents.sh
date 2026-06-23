#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_BREWFILE="$REPO_ROOT/profiles/ai/agents.Brewfile"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

if [[ ! -f "$AI_BREWFILE" ]]; then
  echo "  $AI_BREWFILE not found — skipping Claude plugin setup"
  exit 0
fi

echo "  Applying Claude Code plugin setup from profiles/ai/agents.Brewfile..."
python3 "$REPO_ROOT/scripts/apply_claude_plugin_selection.py" \
  --brewfile "$AI_BREWFILE" \
  --settings "$CLAUDE_SETTINGS"

echo "  Run /reload-plugins inside Claude Code to activate plugin changes"
