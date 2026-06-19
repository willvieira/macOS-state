#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SNAPSHOTS_DIR="$REPO_ROOT/snapshots"

if ! command -v uv &>/dev/null; then
  echo "  uv not found — skipping"
  exit 0
fi

VENV_PATH="${VENV_PATH:-$HOME/.venv}"
uv pip freeze --python "${VENV_PATH}/bin/python" > "$SNAPSHOTS_DIR/python-packages.txt"
echo "  Python packages captured -> snapshots/python-packages.txt"
