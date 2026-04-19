#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SNAPSHOTS_DIR="$REPO_ROOT/snapshots"

if ! command -v code &>/dev/null; then
  echo "  VSCode 'code' CLI not found — skipping"
  exit 0
fi

code --list-extensions > "$SNAPSHOTS_DIR/vscode-extensions.txt"
echo "  VSCode extensions captured -> snapshots/vscode-extensions.txt"
