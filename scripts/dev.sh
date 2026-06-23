#!/usr/bin/env bash
set -euo pipefail

# Dev tooling setup — languages, version managers, CLI tools.
# Add steps here as you configure your dev environment.

echo "Setting up dev environment..."

# Git
CONFIG_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/user.config.toml"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$REPO_ROOT/scripts/lib/config.sh"
ensure_dasel

GIT_NAME=$(cfg 'git.name' "")
GIT_EMAIL=$(cfg 'git.email' "")
GIT_SIGN=$(cfg 'git.signing_key' "")

[[ -n "$GIT_NAME" ]]  && git config --global user.name "$GIT_NAME"
[[ -n "$GIT_EMAIL" ]] && git config --global user.email "$GIT_EMAIL"
[[ -n "$GIT_SIGN" ]]  && git config --global user.signingkey "$GIT_SIGN"
git config --global core.excludesFile ~/.gitignore_global

# Example: install mise (universal version manager for Node, Python, Ruby, etc.)
# if ! command -v mise &>/dev/null; then
#   brew install mise
#   echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
# fi

# Example: install a Node version
# mise install node@lts

echo "Dev environment done."
