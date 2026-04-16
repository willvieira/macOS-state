#!/usr/bin/env bash
set -euo pipefail

# Dev tooling setup — languages, version managers, CLI tools.
# Add steps here as you configure your dev environment.

echo "Setting up dev environment..."

# Git
source "./config.env"
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

# Example: install mise (universal version manager for Node, Python, Ruby, etc.)
# if ! command -v mise &>/dev/null; then
#   brew install mise
#   echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
# fi

# Example: install a Node version
# mise install node@lts

echo "Dev environment done."
