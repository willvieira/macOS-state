#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$REPO_ROOT/user.config.toml"
PROFILES_DIR="$REPO_ROOT/profiles"

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

source "$REPO_ROOT/scripts/lib/config.sh"
ensure_dasel

module_enabled() {
  local module_key="$1" default="$2"
  local enabled
  enabled=$(cfg "modules.$module_key" "$default")
  [[ "$enabled" == "true" ]]
}

apply_profile() {
  local label="$1" file="$2"
  if [[ ! -f "$file" ]]; then
    echo "  [missing] $label ($file) — skipping"
    return 0
  fi
  echo ""
  echo "--> Homebrew profile: $label"
  brew bundle --file="$file"
}

apply_profile_if_enabled() {
  local label="$1" module_key="$2" default="$3" file="$4"
  if module_enabled "$module_key" "$default"; then
    apply_profile "$label" "$file"
  else
    echo "--> [skipped] Homebrew profile: $label"
  fi
}

echo "Updating Homebrew..."
brew update

apply_profile_if_enabled "base"          "homebrew"      true  "$PROFILES_DIR/base/Brewfile"
apply_profile_if_enabled "terminal"      "terminal"      false "$PROFILES_DIR/terminal/Brewfile"
apply_profile_if_enabled "python"        "python"        false "$PROFILES_DIR/languages/python.Brewfile"
apply_profile_if_enabled "r"             "r"             false "$PROFILES_DIR/languages/r.Brewfile"
apply_profile_if_enabled "node"          "node"          false "$PROFILES_DIR/languages/node.Brewfile"
apply_profile_if_enabled "browsers"      "browser"       false "$PROFILES_DIR/apps/browsers.Brewfile"
apply_profile_if_enabled "productivity"  "productivity"  false "$PROFILES_DIR/apps/productivity.Brewfile"
apply_profile_if_enabled "vscode"        "vscode"        false "$PROFILES_DIR/vscode/base.Brewfile"
apply_profile_if_enabled "vscode themes" "vscode_themes" false "$PROFILES_DIR/vscode/themes.Brewfile"
apply_profile_if_enabled "vscode python" "python"        false "$PROFILES_DIR/vscode/python.Brewfile"
apply_profile_if_enabled "vscode r"      "r"             false "$PROFILES_DIR/vscode/r.Brewfile"
apply_profile_if_enabled "ai agents"     "ai_agents"    false "$PROFILES_DIR/ai/agents.Brewfile"
