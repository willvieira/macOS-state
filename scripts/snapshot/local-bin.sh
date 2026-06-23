#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_ROOT/scripts/lib/snapshots.sh"
resolve_snapshots_dir

OUTPUT="$SNAPSHOTS_DIR/local-bin.txt"

{
  echo "# User-local command snapshot"
  echo "# Metadata only: command name, path, file type, and symlink target when applicable"
  echo "# Captured directories: ~/.local/bin, ~/bin, ~/.cargo/bin"
  echo ""
} > "$OUTPUT"

capture_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    return 0
  fi

  printf '[%s]\n' "$dir" >> "$OUTPUT"

  while IFS= read -r -d '' path; do
    local name type target executable
    name="$(basename "$path")"
    target=""
    executable="false"

    if [[ -L "$path" ]]; then
      type="symlink"
      target=" -> $(readlink "$path")"
    elif [[ -d "$path" ]]; then
      type="directory"
    elif [[ -f "$path" ]]; then
      type="file"
    else
      type="other"
    fi

    if [[ -x "$path" ]]; then
      executable="true"
    fi

    printf '%s\t%s\texecutable=%s%s\n' "$name" "$type" "$executable" "$target" >> "$OUTPUT"
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0 | sort -z)

  echo "" >> "$OUTPUT"
}

capture_dir "$HOME/.local/bin"
capture_dir "$HOME/bin"
capture_dir "$HOME/.cargo/bin"

echo "  local bin tools captured -> $OUTPUT"
