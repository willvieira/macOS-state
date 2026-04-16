#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="$REPO_ROOT/dotfiles"

if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "No dotfiles directory found — skipping"
  exit 0
fi

echo "Symlinking dotfiles..."

# Format: "src_relative_to_dotfiles|dest_absolute"
LINKS=(
  # "gitconfig|$HOME/.gitconfig"
  # "gitignore_global|$HOME/.gitignore_global"
  "zsh/.zshrc|$HOME/.zshrc"
  "zsh/.p10k.zsh|$HOME/.p10k.zsh"
  "vscode/settings.json|$HOME/Library/Application Support/Code/User/settings.json"
)

for entry in "${LINKS[@]}"; do
  src_name="${entry%%|*}"
  dest="${entry#*|}"
  src="$DOTFILES_DIR/$src_name"

  if [[ ! -f "$src" ]]; then
    echo "  [missing] $src — skipping"
    continue
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" ]]; then
    echo "  [already linked] $dest"
  elif [[ -f "$dest" ]]; then
    echo "  [backing up] $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
    ln -s "$src" "$dest"
  else
    ln -s "$src" "$dest"
    echo "  [linked] $dest"
  fi
done

echo "Dotfiles done."
