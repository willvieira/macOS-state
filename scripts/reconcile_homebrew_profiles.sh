#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/scripts/lib/snapshots.sh"
resolve_snapshots_dir

exec python3 "$REPO_ROOT/scripts/reconcile_homebrew_profiles.py" --snapshot "$SNAPSHOTS_DIR/Brewfile" "$@"
