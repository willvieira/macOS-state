#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOTFILES_DIR="$REPO_ROOT/dotfiles"

LINKS=(
  "gitignore_global|$HOME/.gitignore_global"
  "zsh/.zshrc|$HOME/.zshrc"
  "zsh/.p10k.zsh|$HOME/.p10k.zsh"
  "vscode/settings.json|$HOME/Library/Application Support/Code/User/settings.json"
)

for entry in "${LINKS[@]}"; do
  src_name="${entry%%|*}"
  dest="${entry#*|}"
  repo_file="$DOTFILES_DIR/$src_name"

  if [[ -L "$dest" ]]; then
    echo "  [symlinked] $dest — no action needed"
  elif [[ -f "$dest" ]]; then
    mkdir -p "$(dirname "$repo_file")"
    cp "$dest" "$repo_file"
    echo "  [copied] $dest -> $repo_file"
    echo "  WARNING: $dest is not symlinked. Run install.sh to set up symlinks." >&2
  else
    echo "  [missing] $dest — skipping"
  fi
done
