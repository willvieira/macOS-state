#!/usr/bin/env bash
set -euo pipefail

# macOS system preferences
# Run `defaults read` on a configured machine to find the keys you want to capture.

echo "Setting macOS preferences..."

CONFIG_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/user.config.toml"

cfg() {
  dasel -f "$CONFIG_FILE" --plain "macos.$1" 2>/dev/null || echo "${2:-}"
}

DISPLAY_SLEEP=$(cfg display_sleep "")
IDLE_TIMEOUT=$(cfg idle_timeout "")
DEFAULT_BROWSER=$(cfg default_browser "")
DOCK_AUTOHIDE=$(cfg dock_autohide true)
DOCK_SHOW_RECENTS=$(cfg dock_show_recents false)
DOCK_TILESIZE=$(cfg dock_tilesize 48)
FINDER_SHOW_PATHBAR=$(cfg finder_show_pathbar true)
FINDER_SHOW_STATUS_BAR=$(cfg finder_show_status_bar true)
FINDER_PREFERRED_VIEW_STYLE=$(cfg finder_preferred_view_style Nlsv)
FINDER_DEFAULT_SEARCH_SCOPE=$(cfg finder_default_search_scope SCcf)
FINDER_SHOW_ALL_FILES=$(cfg finder_show_all_files true)
SHOW_ALL_EXTENSIONS=$(cfg show_all_extensions true)
KEY_REPEAT=$(cfg key_repeat 2)
INITIAL_KEY_REPEAT=$(cfg initial_key_repeat 15)
PRESS_AND_HOLD_ENABLED=$(cfg press_and_hold_enabled false)
TRACKPAD_CLICKING=$(cfg trackpad_clicking true)
TAP_TO_CLICK=$(cfg tap_to_click 1)
SCREENSHOT_LOCATION=$(cfg screenshot_location '$HOME/Desktop')
SCREENSHOT_TYPE=$(cfg screenshot_type png)
SCREENSHOT_DISABLE_SHADOW=$(cfg screenshot_disable_shadow true)
INTERFACE_STYLE=$(cfg interface_style Dark)

current_default_browser() {
  python3 - <<'PYEOF'
import plistlib
from pathlib import Path

browser_ids = {
    "com.brave.browser": "brave",
    "com.google.Chrome": "chrome",
    "org.mozilla.firefox": "firefox",
    "com.apple.Safari": "safari",
}

plist_path = Path.home() / "Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
try:
    data = plistlib.load(plist_path.open("rb"))
except Exception:
    raise SystemExit(0)

for handler in data.get("LSHandlers", []):
    if handler.get("LSHandlerURLScheme") in {"https", "http"}:
        browser = browser_ids.get(handler.get("LSHandlerRoleAll"))
        if browser:
            print(browser)
            break
PYEOF
}

expand_user_path() {
  local value="$1"
  value="${value/#\$HOME/$HOME}"
  value="${value/#\~/$HOME}"
  printf '%s\n' "$value"
}

# Power settings (requires sudo; bash will prompt automatically)
if [[ -n "$DISPLAY_SLEEP" ]]; then
  CURRENT_DISPLAYSLEEP=$(pmset -g | awk '/displaysleep/ {print $2}')
  if [[ "$CURRENT_DISPLAYSLEEP" != "$DISPLAY_SLEEP" ]]; then
    sudo pmset -a displaysleep "$DISPLAY_SLEEP"
  else
    echo "  displaysleep already $DISPLAY_SLEEP — skipping"
  fi
fi

if [[ -n "$IDLE_TIMEOUT" ]]; then
  CURRENT_SLEEP=$(pmset -g | awk '/^[[:space:]]+sleep[[:space:]]/ {print $2}')
  if [[ "$CURRENT_SLEEP" != "$IDLE_TIMEOUT" ]]; then
    sudo pmset -a sleep "$IDLE_TIMEOUT"
  else
    echo "  sleep timeout already $IDLE_TIMEOUT — skipping"
  fi
fi

# Default browser (installed by homebrew.sh; guarded in case not yet available)
# macOS Sequoia shows a confirmation dialog when this runs — user must click to confirm
if [[ -n "$DEFAULT_BROWSER" ]] && command -v defaultbrowser &>/dev/null; then
  CURRENT_BROWSER=$(current_default_browser)
  if [[ "$CURRENT_BROWSER" != "$DEFAULT_BROWSER" ]]; then
    defaultbrowser "$DEFAULT_BROWSER"
  else
    echo "  default browser already $DEFAULT_BROWSER — skipping"
  fi
fi

# Dock
defaults write com.apple.dock autohide -bool "$DOCK_AUTOHIDE"
defaults write com.apple.dock show-recents -bool "$DOCK_SHOW_RECENTS"
defaults write com.apple.dock tilesize -int "$DOCK_TILESIZE"

# Finder
defaults write com.apple.finder ShowPathbar -bool "$FINDER_SHOW_PATHBAR"
defaults write com.apple.finder ShowStatusBar -bool "$FINDER_SHOW_STATUS_BAR"
defaults write com.apple.finder FXPreferredViewStyle -string "$FINDER_PREFERRED_VIEW_STYLE"
defaults write com.apple.finder FXDefaultSearchScope -string "$FINDER_DEFAULT_SEARCH_SCOPE"
defaults write com.apple.finder AppleShowAllFiles -bool "$FINDER_SHOW_ALL_FILES"
defaults write NSGlobalDomain AppleShowAllExtensions -bool "$SHOW_ALL_EXTENSIONS"

# Keyboard
defaults write NSGlobalDomain KeyRepeat -int "$KEY_REPEAT"
defaults write NSGlobalDomain InitialKeyRepeat -int "$INITIAL_KEY_REPEAT"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool "$PRESS_AND_HOLD_ENABLED"

# Trackpad
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool "$TRACKPAD_CLICKING"
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int "$TAP_TO_CLICK"

# Screenshots
defaults write com.apple.screencapture location -string "$(expand_user_path "$SCREENSHOT_LOCATION")"
defaults write com.apple.screencapture type -string "$SCREENSHOT_TYPE"
defaults write com.apple.screencapture disable-shadow -bool "$SCREENSHOT_DISABLE_SHADOW"

# Menu bar
if [[ "$INTERFACE_STYLE" == "Light" ]]; then
  defaults delete NSGlobalDomain AppleInterfaceStyle &>/dev/null || true
else
  defaults write NSGlobalDomain AppleInterfaceStyle -string "$INTERFACE_STYLE"
fi

# Restart affected apps
for app in Finder Dock SystemUIServer; do
  killall "$app" &>/dev/null || true
done

echo "macOS preferences applied."
