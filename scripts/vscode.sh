#!/usr/bin/env bash
set -euo pipefail

echo "Setting up VSCode..."

if ! command -v code &>/dev/null; then
  echo "VSCode 'code' CLI not found — open VSCode and run 'Shell Command: Install code command in PATH' first"
  exit 1
fi

# Top 15 themes
THEMES=(
  "zhuangtongfa.material-theme"                # One Dark Pro
  "dracula-theme.theme-dracula"                # Dracula Official
  "sdras.night-owl"                            # Night Owl
  "enkia.tokyo-night"                          # Tokyo Night
  "catppuccin.catppuccin-vsc"                  # Catppuccin
  "github.github-vscode-theme"                 # GitHub Theme
  "equinusocio.vsc-material-theme"             # Material Theme
  "monokai.theme-monokai-pro-vscode"           # Monokai Pro
  "teabyii.ayu"                                # Ayu
  "arcticicestudio.nord-visual-studio-code"    # Nord
  "jdinhlife.gruvbox"                          # Gruvbox
  "robbowen.synthwave-vscode"                  # SynthWave '84
  "atomiks.moonlight"                          # Moonlight
  "johnpapa.winteriscoming"                    # Winter is Coming
  "antfu.vitesse"                              # Vitesse
)

echo "Installing VSCode themes..."
for ext in "${THEMES[@]}"; do
  code --install-extension "$ext" --force
done

echo "VSCode setup done."
echo "Pick a theme via Cmd+Shift+P → Color Theme"
