#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_ROOT/scripts/lib/snapshots.sh"
resolve_snapshots_dir

BRAVE_PROFILE="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"
CHROME_PROFILE="$HOME/Library/Application Support/Google/Chrome"
FIREFOX_PROFILE="$HOME/Library/Application Support/Firefox"

found=0

# --- Brave ---
if [[ ! -d "$BRAVE_PROFILE/Default/Extensions" ]]; then
  echo "  Brave not installed — skipping"
else
  {
    for ext_dir in "$BRAVE_PROFILE/Default/Extensions"/*/; do
      ext_id="$(basename "$ext_dir")"
      version_dir="$(ls -d "$ext_dir"*/ 2>/dev/null | head -1)"
      if [[ -n "$version_dir" && -f "$version_dir/manifest.json" ]]; then
        name="$(grep -m1 '"name"' "$version_dir/manifest.json" 2>/dev/null | awk -F'"' '{print $4}')"
      else
        name=""
      fi
      if [[ -n "$name" ]]; then
        echo -e "$ext_id\t$name"
      else
        echo "$ext_id"
      fi
    done
  } > "$SNAPSHOTS_DIR/brave-extensions.txt"
  found=1
  echo "  Brave extensions captured -> $SNAPSHOTS_DIR/brave-extensions.txt"
fi

# --- Chrome ---
if [[ ! -d "$CHROME_PROFILE/Default/Extensions" ]]; then
  echo "  Chrome not installed — skipping"
else
  {
    for ext_dir in "$CHROME_PROFILE/Default/Extensions"/*/; do
      ext_id="$(basename "$ext_dir")"
      version_dir="$(ls -d "$ext_dir"*/ 2>/dev/null | head -1)"
      if [[ -n "$version_dir" && -f "$version_dir/manifest.json" ]]; then
        name="$(grep -m1 '"name"' "$version_dir/manifest.json" 2>/dev/null | awk -F'"' '{print $4}')"
      else
        name=""
      fi
      if [[ -n "$name" ]]; then
        echo -e "$ext_id\t$name"
      else
        echo "$ext_id"
      fi
    done
  } > "$SNAPSHOTS_DIR/chrome-extensions.txt"
  found=1
  echo "  Chrome extensions captured -> $SNAPSHOTS_DIR/chrome-extensions.txt"
fi

# --- Firefox ---
if [[ ! -f "$FIREFOX_PROFILE/profiles.ini" ]]; then
  echo "  Firefox not installed — skipping"
else
  profile_path=$(grep -m1 '^Path=' "$FIREFOX_PROFILE/profiles.ini" | cut -d= -f2)
  if [[ ! -f "$FIREFOX_PROFILE/$profile_path/extensions.json" ]]; then
    echo "  Firefox not installed — skipping"
  else
    python3 - "$FIREFOX_PROFILE/$profile_path/extensions.json" "$SNAPSHOTS_DIR/firefox-extensions.txt" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
names = [a.get("name") or a.get("id") or "unknown" for a in data.get("addons", [])]
with open(sys.argv[2], "w") as f:
    f.write("\n".join(names) + "\n")
PYEOF
    found=1
    echo "  Firefox extensions captured -> $SNAPSHOTS_DIR/firefox-extensions.txt"
  fi
fi

if [[ "$found" -eq 0 ]]; then
  echo "  No supported browsers detected — skipping"
fi
