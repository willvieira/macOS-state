#!/usr/bin/env bash
set -euo pipefail

# macOS system preferences
# Run `defaults read` on a configured machine to find the keys you want to capture.

echo "Setting macOS preferences..."

CONFIG_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/user.config.toml"

DISPLAY_SLEEP=$(dasel -f "$CONFIG_FILE" --plain 'macos.display_sleep' 2>/dev/null || echo "")
IDLE_TIMEOUT=$(dasel -f "$CONFIG_FILE" --plain 'macos.idle_timeout' 2>/dev/null || echo "")
DEFAULT_BROWSER=$(dasel -f "$CONFIG_FILE" --plain 'macos.default_browser' 2>/dev/null || echo "")

# Power settings (requires sudo; bash will prompt automatically)
if [[ -n "$DISPLAY_SLEEP" ]]; then
  sudo pmset -a displaysleep "$DISPLAY_SLEEP"
fi
if [[ -n "$IDLE_TIMEOUT" ]]; then
  sudo pmset -a sleep "$IDLE_TIMEOUT"
fi

# Default browser (installed by homebrew.sh; guarded in case not yet available)
# macOS Sequoia shows a confirmation dialog when this runs — user must click to confirm
if [[ -n "$DEFAULT_BROWSER" ]] && command -v defaultbrowser &>/dev/null; then
  defaultbrowser "$DEFAULT_BROWSER"
fi

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 48

# Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # search current folder
defaults write com.apple.finder AppleShowAllFiles -bool true           # show hidden files
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Keyboard
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Trackpad
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1       # tap to click

# Screenshots
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Menu bar
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Restart affected apps
for app in Finder Dock SystemUIServer; do
  killall "$app" &>/dev/null || true
done

echo "macOS preferences applied."
