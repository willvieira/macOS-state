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
  "monokai.theme-monokai-pro-vscode"           # Monokai Pro
  "teabyii.ayu"                                # Ayu
  "arcticicestudio.nord-visual-studio-code"    # Nord
  "jdinhlife.gruvbox"                          # Gruvbox
  "robbowen.synthwave-vscode"                  # SynthWave '84
  "atomiks.moonlight"                          # Moonlight
  "johnpapa.winteriscoming"                    # Winter is Coming
)

EXTENSIONS=(
  # --- General / base ---
  "eamodio.gitlens"                              # GitLens — git blame, history, lens
  "mhutchie.git-graph"                           # Git Graph — visual branch history
  "usernamehw.errorlens"                         # Error Lens — inline diagnostics
  "streetsidesoftware.code-spell-checker"        # Spell checker
  "gruntfuggly.todo-tree"                        # TODO/FIXME tree
  "editorconfig.editorconfig"                    # EditorConfig support
  "christian-kohler.path-intellisense"           # Path autocomplete
  "pkief.material-icon-theme"                    # File icon theme
  "xyz.local-history"                            # Local History
  "redhat.vscode-yaml"                           # YAML support
  "mechatroner.rainbow-csv"                      # CSV column coloring
  "yzhang.markdown-all-in-one"                   # Markdown editing & preview

  # --- Shell ---
  "timonwong.shellcheck"                         # ShellCheck linter
  "foxundermoon.shell-format"                    # Shell formatter

  # --- R / Quarto ---
  "reditorsupport.r"                             # R language support
  "rdebugger.r-debugger"                         # R debugger
  "quarto.quarto"                                # Quarto (R/Python notebooks & docs)

  # --- Python / data science / Jupyter ---
  "ms-python.python"                             # Python official extension
  "ms-python.vscode-pylance"                     # Pylance type checker
  "ms-toolsai.jupyter"                           # Jupyter notebooks
  "ms-python.black-formatter"                    # Black formatter
  "ms-python.isort"                              # isort import sorter

  # --- Docker ---
  "ms-azuretools.vscode-docker"                  # Docker support
  "ms-vscode-remote.remote-containers"           # Dev Containers
)

echo "Installing VSCode themes..."
for ext in "${THEMES[@]}"; do
  code --install-extension "$ext" --force
done

echo "Installing VSCode extensions..."
for ext in "${EXTENSIONS[@]}"; do
  code --install-extension "$ext" --force
done

echo "VSCode setup done."
echo "Pick a theme via Cmd+Shift+P → Color Theme"
