#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SCRIPTS_DIR="$REPO_ROOT/scripts/sync"
CONFIG_FILE="$REPO_ROOT/user.config.toml"
SNAPSHOTS_DIR_ARG=""

usage() {
  cat <<EOF
Usage: ./sync.sh [--snapshots-dir PATH]

Options:
  --snapshots-dir PATH  Write generated snapshots to PATH for this run
  -h, --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --snapshots-dir)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --snapshots-dir requires a path" >&2
        exit 1
      fi
      SNAPSHOTS_DIR_ARG="$2"
      shift 2
      ;;
    --snapshots-dir=*)
      SNAPSHOTS_DIR_ARG="${1#*=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

echo "==> macOS sync starting"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: user.config.toml not found." >&2
  echo "  cp user.config.toml.example user.config.toml" >&2
  echo "  Then fill in your details before running sync.sh." >&2
  exit 1
fi

source "$REPO_ROOT/scripts/lib/snapshots.sh"
resolve_snapshots_dir "$SNAPSHOTS_DIR_ARG"
echo "Snapshots destination: $SNAPSHOTS_DIR"

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
run_if_enabled "R packages"          "modules.r"        r.sh
run_if_enabled "Python packages"     "modules.python"   python.sh
run_if_enabled "Claude Code config"  "modules.claude"   claude.sh
run_if_enabled "Browser extensions"       "modules.browser"         browser.sh
run_if_enabled "iTerm2 profile"           "modules.iterm2"          iterm2.sh
run_if_enabled "Raycast settings"         "modules.raycast"         raycast.sh
run_if_enabled "Alfred preferences"       "modules.alfred"          alfred.sh
run_if_enabled "BetterTouchTool presets"  "modules.bettertouchtool" bettertouchtool.sh

echo ""
echo "==> Sync complete. Snapshots saved to $SNAPSHOTS_DIR"
