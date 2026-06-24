#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_BREWFILE="$REPO_ROOT/profiles/ai/agents.Brewfile"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

if [[ ! -f "$AI_BREWFILE" ]]; then
  echo "  $AI_BREWFILE not found — skipping Claude plugin setup"
  exit 0
fi

echo "  Installing AI tools from profiles/ai/agents.Brewfile..."
brew bundle install --file "$AI_BREWFILE"

# Refresh Bash's command lookup after package installation.
hash -r

CLAUDE_BIN="$(command -v claude || true)"

if [[ -z "$CLAUDE_BIN" ]]; then
  echo "  Claude Code CLI was not found after installation." >&2
  echo "  Check the Claude Code package installation and your PATH." >&2
  exit 1
fi

if ! "$CLAUDE_BIN" --version; then
  echo "  Claude CLI exists but is not executable: $CLAUDE_BIN" >&2
  echo "  Inspect it with: file \"$CLAUDE_BIN\"" >&2
  exit 1
fi

echo "  Applying Claude Code plugin setup from profiles/ai/agents.Brewfile..."
python3 "$REPO_ROOT/scripts/apply_ai_profile.py" \
  --brewfile "$AI_BREWFILE" \
  --settings "$CLAUDE_SETTINGS"

echo "  Run /reload-plugins inside Claude Code to activate plugin changes"
