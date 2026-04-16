#!/usr/bin/env bash
set -euo pipefail

# iTerm2 + Oh My Zsh + Powerlevel10k
# Reference: https://gist.github.com/kevin-smets/8568070

echo "Setting up terminal..."

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed"
fi

# Powerlevel10k theme
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "Powerlevel10k already installed"
fi

# Set JetBrains Mono as the default font in iTerm2 via plist
ITERM_PREFS="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
if [[ -f "$ITERM_PREFS" ]]; then
  echo "Setting JetBrains Mono as iTerm2 default font..."
  /usr/libexec/PlistBuddy -c \
    "Set :'New Bookmarks':0:'Normal Font' 'JetBrainsMono-Regular 13'" \
    "$ITERM_PREFS" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c \
    "Add :'New Bookmarks':0:'Normal Font' string 'JetBrainsMono-Regular 13'" \
    "$ITERM_PREFS"
  # Keep MesloLGS NF for non-ASCII (Powerlevel10k icons)
  /usr/libexec/PlistBuddy -c \
    "Set :'New Bookmarks':0:'Non Ascii Font' 'MesloLGS-NF-Regular 13'" \
    "$ITERM_PREFS" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c \
    "Add :'New Bookmarks':0:'Non Ascii Font' string 'MesloLGS-NF-Regular 13'" \
    "$ITERM_PREFS"
  /usr/libexec/PlistBuddy -c \
    "Set :'New Bookmarks':0:'Use Non-ASCII Font' true" \
    "$ITERM_PREFS" 2>/dev/null || true
  defaults read com.googlecode.iterm2 &>/dev/null  # flush plist cache
else
  echo "iTerm2 prefs not found — open iTerm2 once before running this script"
fi

echo ""
echo "Terminal setup done."
echo "Next: set MesloLGS NF as the font in iTerm2 → Preferences → Profiles → Text"
echo "Then restart iTerm2 and run 'p10k configure' to customise your prompt."
