#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if ! command -v brew &>/dev/null; then
  echo "  brew not found — skipping"
  exit 0
fi

brew bundle dump --force --no-describe --file="$REPO_ROOT/Brewfile"
echo "  Brewfile updated -> Brewfile"
