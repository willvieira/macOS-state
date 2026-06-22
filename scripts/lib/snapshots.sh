#!/usr/bin/env bash

# Shared snapshot destination resolver for sync scripts

SNAPSHOT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNAPSHOT_REPO_ROOT="$(cd "$SNAPSHOT_LIB_DIR/../.." && pwd)"
SNAPSHOT_CONFIG_FILE="${CONFIG_FILE:-$SNAPSHOT_REPO_ROOT/user.config.toml}"

snapshot_cfg() {
  if command -v dasel &>/dev/null && [[ -f "$SNAPSHOT_CONFIG_FILE" ]]; then
    dasel -f "$SNAPSHOT_CONFIG_FILE" --plain "$1" 2>/dev/null || echo "${2:-}"
  else
    echo "${2:-}"
  fi
}

snapshot_expand_path() {
  local path="$1"
  path="${path/#\~/$HOME}"
  path="${path//\$HOME/$HOME}"
  echo "$path"
}

snapshot_default_dir() {
  local icloud_dir="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
  if [[ -d "$icloud_dir" ]]; then
    echo "$icloud_dir/macOS State/snapshots"
  else
    echo "$HOME/Library/Application Support/macOS State/snapshots"
  fi
}

resolve_snapshots_dir() {
  local requested="${1:-}"

  if [[ -z "$requested" && -n "${SNAPSHOTS_DIR:-}" ]]; then
    requested="$SNAPSHOTS_DIR"
  fi

  if [[ -z "$requested" ]]; then
    requested="$(snapshot_cfg 'snapshots.path' '')"
  fi

  if [[ -z "$requested" ]]; then
    requested="$(snapshot_default_dir)"
  fi

  SNAPSHOTS_DIR="$(snapshot_expand_path "$requested")"
  mkdir -p "$SNAPSHOTS_DIR"
  export SNAPSHOTS_DIR
}
