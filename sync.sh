#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SCRIPTS_DIR="$REPO_ROOT/scripts/sync"
CONFIG_FILE="$REPO_ROOT/user.config.toml"
SNAPSHOTS_DIR="$REPO_ROOT/snapshots"

echo "==> macOS sync starting"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: user.config.toml not found." >&2
  echo "  cp user.config.toml.example user.config.toml" >&2
  echo "  Then fill in your details before running sync.sh." >&2
  exit 1
fi

mkdir -p "$SNAPSHOTS_DIR"

cfg() {
  dasel -f "$CONFIG_FILE" --plain "$1" 2>/dev/null || echo "${2:-}"
}

run_if_enabled() {
  local label="$1" key="$2" script="$3"
  local enabled
  enabled=$(cfg "$key" "true")
  if [[ "$enabled" == "true" ]]; then
    echo ""
    echo "--> $label"
    bash "$SYNC_SCRIPTS_DIR/$script"
  else
    echo "--> [skipped] $label (disabled in user.config.toml)"
  fi
}

run_if_enabled "Homebrew packages"   "modules.homebrew" brew.sh
run_if_enabled "Dotfiles"            "modules.dotfiles" dotfiles.sh
run_if_enabled "macOS preferences"   "modules.macos"    macos.sh
# NOTE: Plan 02 extends this dispatch with vscode, r, python, claude

echo ""
echo "==> Sync complete. Snapshots saved to snapshots/"
