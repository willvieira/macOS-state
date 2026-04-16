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

# Set ZSH_THEME in .zshrc
if grep -q 'ZSH_THEME=' "$HOME/.zshrc" 2>/dev/null; then
  sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
else
  echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
fi

# Enable zsh-autosuggestions and zsh-syntax-highlighting plugins
if grep -q '^plugins=' "$HOME/.zshrc" 2>/dev/null; then
  sed -i '' 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
else
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$HOME/.zshrc"
fi

echo ""
echo "Terminal setup done."
echo "Next: set MesloLGS NF as the font in iTerm2 → Preferences → Profiles → Text"
echo "Then restart iTerm2 and run 'p10k configure' to customise your prompt."
