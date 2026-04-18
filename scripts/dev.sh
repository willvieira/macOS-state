#!/usr/bin/env bash
set -euo pipefail

# Dev tooling setup — languages, version managers, CLI tools.
# Add steps here as you configure your dev environment.

echo "Setting up dev environment..."

# Git
CONFIG_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/user.config.toml"

GIT_NAME=$(dasel -f "$CONFIG_FILE" --plain 'git.name' 2>/dev/null || echo "")
GIT_EMAIL=$(dasel -f "$CONFIG_FILE" --plain 'git.email' 2>/dev/null || echo "")
GIT_SIGN=$(dasel -f "$CONFIG_FILE" --plain 'git.signing_key' 2>/dev/null || echo "")

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
