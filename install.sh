#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$REPO_ROOT/scripts"
CONFIG_FILE="$REPO_ROOT/user.config.toml"

echo "==> macOS setup starting"

# Guard: config file must exist before proceeding
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: user.config.toml not found." >&2
  echo "  cp user.config.toml.example user.config.toml" >&2
  echo "  Then fill in your details before running install.sh." >&2
  exit 1
fi

source "$REPO_ROOT/scripts/lib/config.sh"
ensure_dasel

# Run a module script only if its toggle is enabled
run_if_enabled() {
  local label="$1" key="$2" script="$3" default="${4:-true}"
  local enabled
  enabled=$(cfg "$key" "$default")
  if [[ "$enabled" == "true" ]]; then
    echo ""
    echo "--> $label"
    bash "$SCRIPTS_DIR/$script"
  else
    echo "--> [skipped] $label (disabled in user.config.toml)"
  fi
}

run_if_enabled "Homebrew & packages" "modules.homebrew" homebrew.sh         true
run_if_enabled "macOS preferences"   "modules.macos"    macos.sh           true
run_if_enabled "Dev environment"     "modules.dev"      dev.sh             true
run_if_enabled "R packages"          "modules.r"        r_packages.sh      false
run_if_enabled "Python packages"     "modules.python"   python_packages.sh false
run_if_enabled "Terminal setup"      "modules.terminal" terminal.sh        false
run_if_enabled "Dotfiles"            "modules.dotfiles" dotfiles.sh         true
run_if_enabled "AI agents"           "modules.ai_agents" ai_agents.sh       false

echo ""
echo "==> Done. Restart your Mac for all settings to take effect."
