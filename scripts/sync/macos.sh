#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_ROOT/scripts/lib/snapshots.sh"
resolve_snapshots_dir

DISPLAY_SLEEP=$(pmset -g | awk '/displaysleep/ {print $2}')
SLEEP=$(pmset -g | awk '/^[[:space:]]+sleep[[:space:]]/ {print $2}')

DEFAULT_BROWSER=$(python3 - <<'PYEOF'
import plistlib
from pathlib import Path

browser_ids = {
    "com.brave.browser": "brave",
    "com.google.Chrome": "chrome",
    "org.mozilla.firefox": "firefox",
    "com.apple.Safari": "safari",
}

plist_path = Path.home() / "Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
try:
    data = plistlib.load(plist_path.open("rb"))
except Exception:
    raise SystemExit(0)

for handler in data.get("LSHandlers", []):
    if handler.get("LSHandlerURLScheme") in {"https", "http"}:
        browser = browser_ids.get(handler.get("LSHandlerRoleAll"))
        if browser:
            print(browser)
            break
PYEOF
)

python3 - "$SNAPSHOTS_DIR/macos.toml" "$DISPLAY_SLEEP" "$SLEEP" "$DEFAULT_BROWSER" <<'PYEOF'
import subprocess
import sys
from pathlib import Path

output_path = Path(sys.argv[1])
display_sleep = sys.argv[2]
idle_timeout = sys.argv[3]
default_browser = sys.argv[4]


def toml_string(value):
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def defaults_read(domain, key):
    result = subprocess.run(
        ["defaults", "read", domain, key],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def toml_bool(value, fallback):
    if value is None or value == "":
        return fallback
    return "true" if value.lower() in {"1", "true", "yes"} else "false"


def toml_int(value, fallback):
    if value is None or value == "":
        return fallback
    return value


def toml_default_string(value, fallback):
    if value is None or value == "":
        value = fallback
    return toml_string(value)


auto_appearance = defaults_read("NSGlobalDomain", "AppleInterfaceStyleSwitchesAutomatically")
if toml_bool(auto_appearance, "false") == "true":
    appearance_style = "Auto"
else:
    appearance_style = defaults_read("NSGlobalDomain", "AppleInterfaceStyle") or "Light"

lines = [
    "# Captured macOS current state",
    "# Copy sections into user.config.toml if you want to promote them to desired state",
    "",
    "[macos.display]",
    f"display_sleep = {display_sleep}",
    f"idle_timeout  = {idle_timeout}",
    "",
    "[macos.browser]",
    f"default = {toml_string(default_browser)}",
    "",
    "[macos.dock]",
    f"autohide     = {toml_bool(defaults_read('com.apple.dock', 'autohide'), 'false')}",
    f"show_recents = {toml_bool(defaults_read('com.apple.dock', 'show-recents'), 'true')}",
    f"tilesize     = {toml_int(defaults_read('com.apple.dock', 'tilesize'), '64')}",
    "",
    "[macos.finder]",
    f"show_pathbar         = {toml_bool(defaults_read('com.apple.finder', 'ShowPathbar'), 'false')}",
    f"show_status_bar      = {toml_bool(defaults_read('com.apple.finder', 'ShowStatusBar'), 'false')}",
    f"preferred_view_style = {toml_default_string(defaults_read('com.apple.finder', 'FXPreferredViewStyle'), 'icnv')}",
    f"default_search_scope = {toml_default_string(defaults_read('com.apple.finder', 'FXDefaultSearchScope'), 'SCev')}",
    f"show_all_files       = {toml_bool(defaults_read('com.apple.finder', 'AppleShowAllFiles'), 'false')}",
    f"show_all_extensions  = {toml_bool(defaults_read('NSGlobalDomain', 'AppleShowAllExtensions'), 'false')}",
    "",
    "[macos.keyboard]",
    f"key_repeat             = {toml_int(defaults_read('NSGlobalDomain', 'KeyRepeat'), '6')}",
    f"initial_key_repeat     = {toml_int(defaults_read('NSGlobalDomain', 'InitialKeyRepeat'), '25')}",
    f"press_and_hold_enabled = {toml_bool(defaults_read('NSGlobalDomain', 'ApplePressAndHoldEnabled'), 'true')}",
    "",
    "[macos.trackpad]",
    f"clicking     = {toml_bool(defaults_read('com.apple.driver.AppleBluetoothMultitouch.trackpad', 'Clicking'), 'false')}",
    f"tap_to_click = {toml_int(defaults_read('NSGlobalDomain', 'com.apple.mouse.tapBehavior'), '0')}",
    "",
    "[macos.screenshots]",
    f"location       = {toml_default_string(defaults_read('com.apple.screencapture', 'location'), str(Path.home() / 'Desktop'))}",
    f"type           = {toml_default_string(defaults_read('com.apple.screencapture', 'type'), 'png')}",
    f"disable_shadow = {toml_bool(defaults_read('com.apple.screencapture', 'disable-shadow'), 'false')}",
    "",
    "[macos.appearance]",
    f"style = {toml_string(appearance_style)}",
]

output_path.write_text("\n".join(lines) + "\n")
PYEOF

echo "  macOS prefs captured -> $SNAPSHOTS_DIR/macos.toml"
