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

# Bootstrap dasel (TOML parser) — must run before any module script
bootstrap_dasel() {
  if command -v dasel &>/dev/null; then
    echo "dasel already installed"
    return 0
  fi
  echo "==> Bootstrapping dasel (TOML parser)..."
  local arch asset url
  arch=$(uname -m)
  if [[ "$arch" == "arm64" ]]; then
    asset="darwin_arm64"
  else
    asset="darwin_amd64"
  fi
  url=$(curl -sSLf https://api.github.com/repos/tomwright/dasel/releases/latest \
    | grep browser_download_url \
    | grep -v ".gz" \
    | grep "$asset" \
    | cut -d'"' -f4)
  if [[ -z "$url" ]]; then
    echo "ERROR: could not determine dasel download URL" >&2
    exit 1
  fi
  curl -sSLf "$url" -o /usr/local/bin/dasel
  chmod +x /usr/local/bin/dasel
  echo "dasel installed: $(/usr/local/bin/dasel --version 2>/dev/null || echo 'version unknown')"
}
bootstrap_dasel

# Config reader with safe fallback (handles set -euo pipefail + missing keys)
cfg() {
  dasel -f "$CONFIG_FILE" --plain "$1" 2>/dev/null || echo "${2:-}"
}

# Run a module script only if its toggle is enabled (default: true when key absent)
run_if_enabled() {
  local label="$1" key="$2" script="$3"
  local enabled
  enabled=$(cfg "$key" "true")
  if [[ "$enabled" == "true" ]]; then
    echo ""
    echo "--> $label"
    bash "$SCRIPTS_DIR/$script"
  else
    echo "--> [skipped] $label (disabled in user.config.toml)"
  fi
}

run_if_enabled "Homebrew & packages" "modules.homebrew" homebrew.sh
run_if_enabled "macOS preferences"   "modules.macos"    macos.sh
run_if_enabled "Dev environment"     "modules.dev"      dev.sh
run_if_enabled "R packages"          "modules.r"        r_packages.sh
run_if_enabled "Python packages"     "modules.python"   python_packages.sh
run_if_enabled "Terminal setup"      "modules.terminal" terminal.sh
run_if_enabled "VSCode"              "modules.vscode"   vscode.sh
run_if_enabled "Dotfiles"            "modules.dotfiles" dotfiles.sh
run_if_enabled "Claude Code plugins" "modules.claude"   claude.sh

echo ""
echo "==> Done. Restart your Mac for all settings to take effect."
