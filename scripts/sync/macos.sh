#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SNAPSHOTS_DIR="$REPO_ROOT/snapshots"
CONFIG_FILE="$REPO_ROOT/user.config.toml"
EXAMPLE_CONFIG_FILE="$REPO_ROOT/user.config.toml.example"

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

python3 - "$EXAMPLE_CONFIG_FILE" "$CONFIG_FILE" "$SNAPSHOTS_DIR/macos.toml" "$DISPLAY_SLEEP" "$SLEEP" "$DEFAULT_BROWSER" <<'PYEOF'
import re
import subprocess
import sys
from pathlib import Path

example_path = Path(sys.argv[1])
config_path = Path(sys.argv[2])
output_path = Path(sys.argv[3])
display_sleep = sys.argv[4]
idle_timeout = sys.argv[5]
default_browser = sys.argv[6]


def strip_comment(value):
    in_string = False
    escaped = False
    result = []
    for char in value:
        if escaped:
            result.append(char)
            escaped = False
            continue
        if char == "\\" and in_string:
            result.append(char)
            escaped = True
            continue
        if char == '"':
            in_string = not in_string
        if char == "#" and not in_string:
            break
        result.append(char)
    return "".join(result).strip()


def read_macos_values(path):
    values = {}
    if not path.exists():
        return values
    in_macos = False
    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("[") and line.endswith("]"):
            in_macos = line == "[macos]"
            continue
        if not in_macos or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        if re.fullmatch(r"[A-Za-z0-9_-]+", key):
            values[key] = strip_comment(value)
    return values


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


values = {}
for source in (example_path, config_path):
    values.update(read_macos_values(source))

values.update(
    {
        "display_sleep": display_sleep,
        "idle_timeout": idle_timeout,
        "default_browser": toml_string(default_browser),
        "dock_autohide": toml_bool(defaults_read("com.apple.dock", "autohide"), "false"),
        "dock_show_recents": toml_bool(defaults_read("com.apple.dock", "show-recents"), "true"),
        "dock_tilesize": toml_int(defaults_read("com.apple.dock", "tilesize"), "64"),
        "finder_show_pathbar": toml_bool(defaults_read("com.apple.finder", "ShowPathbar"), "false"),
        "finder_show_status_bar": toml_bool(defaults_read("com.apple.finder", "ShowStatusBar"), "false"),
        "finder_preferred_view_style": toml_default_string(
            defaults_read("com.apple.finder", "FXPreferredViewStyle"), "icnv"
        ),
        "finder_default_search_scope": toml_default_string(
            defaults_read("com.apple.finder", "FXDefaultSearchScope"), "SCev"
        ),
        "finder_show_all_files": toml_bool(defaults_read("com.apple.finder", "AppleShowAllFiles"), "false"),
        "show_all_extensions": toml_bool(defaults_read("NSGlobalDomain", "AppleShowAllExtensions"), "false"),
        "key_repeat": toml_int(defaults_read("NSGlobalDomain", "KeyRepeat"), "6"),
        "initial_key_repeat": toml_int(defaults_read("NSGlobalDomain", "InitialKeyRepeat"), "25"),
        "press_and_hold_enabled": toml_bool(
            defaults_read("NSGlobalDomain", "ApplePressAndHoldEnabled"), "true"
        ),
        "trackpad_clicking": toml_bool(
            defaults_read("com.apple.driver.AppleBluetoothMultitouch.trackpad", "Clicking"), "false"
        ),
        "tap_to_click": toml_int(defaults_read("NSGlobalDomain", "com.apple.mouse.tapBehavior"), "0"),
        "screenshot_location": toml_default_string(
            defaults_read("com.apple.screencapture", "location"), str(Path.home() / "Desktop")
        ),
        "screenshot_type": toml_default_string(defaults_read("com.apple.screencapture", "type"), "png"),
        "screenshot_disable_shadow": toml_bool(
            defaults_read("com.apple.screencapture", "disable-shadow"), "false"
        ),
        "interface_style": toml_default_string(defaults_read("NSGlobalDomain", "AppleInterfaceStyle"), "Light"),
    }
)

ordered_keys = []
for source in (example_path, config_path):
    for key in read_macos_values(source):
        if key not in ordered_keys:
            ordered_keys.append(key)

for key in values:
    if key not in ordered_keys:
        ordered_keys.append(key)

width = max(len(key) for key in ordered_keys)
lines = ["[macos]"]
for key in ordered_keys:
    lines.append(f"{key.ljust(width)} = {values[key]}")
output_path.write_text("\n".join(lines) + "\n")
PYEOF

echo "  macOS prefs captured -> snapshots/macos.toml"
