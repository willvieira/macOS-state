#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SNAPSHOTS_DIR="$REPO_ROOT/snapshots"

if ! command -v Rscript &>/dev/null; then
  echo "  Rscript not found — skipping"
  exit 0
fi

Rscript -e "cat(installed.packages()[,'Package'], sep='\n')" > "$SNAPSHOTS_DIR/r-packages.txt"
echo "  R packages captured -> snapshots/r-packages.txt"
