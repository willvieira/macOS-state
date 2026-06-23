#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$REPO_ROOT/scripts/lib/snapshots.sh"
resolve_snapshots_dir

OUTPUT="$SNAPSHOTS_DIR/manual-apps.toml"

python3 - "$REPO_ROOT" "$SNAPSHOTS_DIR" "$OUTPUT" <<'PYEOF'
from __future__ import annotations

import glob
import json
import os
import plistlib
import re
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
snapshots_dir = Path(sys.argv[2])
output = Path(sys.argv[3])

app_roots = [Path("/Applications"), Path.home() / "Applications"]
homebrew_prefixes = [Path("/opt/homebrew"), Path("/usr/local")]

# Apple/system apps can appear in /Applications even though they are not manual state
DEFAULT_APP_NAMES = {
    "App Store",
    "Automator",
    "Books",
    "Calculator",
    "Calendar",
    "Chess",
    "Contacts",
    "Dictionary",
    "FaceTime",
    "Find My",
    "Font Book",
    "Freeform",
    "Image Capture",
    "Launchpad",
    "Mail",
    "Maps",
    "Messages",
    "Mission Control",
    "Music",
    "News",
    "Notes",
    "Photo Booth",
    "Photos",
    "Podcasts",
    "Preview",
    "QuickTime Player",
    "Reminders",
    "Safari",
    "Shortcuts",
    "Siri",
    "Stickies",
    "Stocks",
    "System Settings",
    "TextEdit",
    "Time Machine",
    "TV",
    "Voice Memos",
    "Weather",
}

CASK_APP_OVERRIDES = {
    "adobe-acrobat-reader": ["Adobe Acrobat Reader"],
    "brave-browser": ["Brave Browser"],
    "docker-desktop": ["Docker"],
    "flux-app": ["Flux"],
    "iterm2": ["iTerm"],
    "visual-studio-code": ["Visual Studio Code"],
    "vlc": ["VLC"],
}


def app_name(path: Path) -> str:
    name = path.name
    return name[:-4] if name.endswith(".app") else name


def toml_escape(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def read_plist(path: Path) -> dict:
    plist_path = path / "Contents" / "Info.plist"
    if not plist_path.exists():
        return {}
    try:
        with plist_path.open("rb") as handle:
            return plistlib.load(handle)
    except Exception:
        return {}


def has_app_store_receipt(path: Path) -> bool:
    return (path / "Contents" / "_MASReceipt" / "receipt").exists()


def cask_token_to_names(token: str) -> set[str]:
    names = set(CASK_APP_OVERRIDES.get(token, []))
    words = token.replace("@", " ").replace("-", " ").replace("_", " ")
    names.add(" ".join(part.upper() if len(part) <= 3 else part.capitalize() for part in words.split()))
    names.add(words.title())
    names.add(token)
    return {name for name in names if name}


def brewfile_cask_names() -> dict[str, str]:
    names: dict[str, str] = {}
    brewfiles = list((repo_root / "profiles").glob("**/Brewfile"))
    snapshot_brewfile = snapshots_dir / "Brewfile"
    if snapshot_brewfile.exists():
        brewfiles.append(snapshot_brewfile)

    cask_pattern = re.compile(r'^\s*cask\s+["\']([^"\']+)["\']')
    for brewfile in brewfiles:
        try:
            for line in brewfile.read_text().splitlines():
                match = cask_pattern.match(line)
                if not match:
                    continue
                token = match.group(1)
                for name in cask_token_to_names(token):
                    names.setdefault(name, f"Homebrew cask {token}")
        except OSError:
            continue
    return names


def caskroom_app_names() -> dict[str, str]:
    names: dict[str, str] = {}
    for prefix in homebrew_prefixes:
        caskroom = prefix / "Caskroom"
        if not caskroom.exists():
            continue
        for token_dir in caskroom.iterdir():
            if not token_dir.is_dir():
                continue
            token = token_dir.name
            for name in cask_token_to_names(token):
                names.setdefault(name, f"Homebrew cask {token}")
            for json_path in token_dir.glob(".metadata/**/Casks/*.json"):
                try:
                    data = json.loads(json_path.read_text())
                except Exception:
                    continue
                for artifact in data.get("artifacts", []):
                    app_entries = artifact.get("app") if isinstance(artifact, dict) else None
                    if not app_entries:
                        continue
                    for entry in app_entries:
                        if isinstance(entry, list) and entry:
                            candidate = Path(str(entry[0])).name
                        elif isinstance(entry, str):
                            candidate = Path(entry).name
                        else:
                            continue
                        names.setdefault(app_name(Path(candidate)), f"Homebrew cask {token}")
    return names


def app_record(path: Path) -> dict[str, str | bool]:
    plist = read_plist(path)
    display_name = (
        plist.get("CFBundleDisplayName")
        or plist.get("CFBundleName")
        or app_name(path)
    )
    return {
        "name": str(display_name),
        "app_name": app_name(path),
        "path": str(path),
        "bundle_id": str(plist.get("CFBundleIdentifier", "")),
        "version": str(plist.get("CFBundleShortVersionString") or plist.get("CFBundleVersion") or ""),
        "app_store": has_app_store_receipt(path),
    }


managed_names = brewfile_cask_names()
managed_names.update(caskroom_app_names())
managed_lookup = {name.casefold(): source for name, source in managed_names.items()}
manual_apps: list[dict[str, str | bool]] = []
skipped: dict[str, int] = {
    "apple_default": 0,
    "app_store": 0,
    "homebrew": 0,
}

for root in app_roots:
    if not root.exists():
        continue
    for path in sorted(root.glob("*.app"), key=lambda item: item.name.lower()):
        record = app_record(path)
        name = str(record["name"])
        simple_name = str(record["app_name"])
        bundle_id = str(record["bundle_id"])

        if simple_name in DEFAULT_APP_NAMES or bundle_id.startswith("com.apple."):
            skipped["apple_default"] += 1
            continue
        if record["app_store"]:
            skipped["app_store"] += 1
            continue
        if simple_name.casefold() in managed_lookup or name.casefold() in managed_lookup:
            skipped["homebrew"] += 1
            continue

        record["reason"] = "Not matched by Homebrew cask, App Store receipt, or Apple default app"
        record["install"] = "Install manually from the vendor, then copy the app to this path"
        manual_apps.append(record)

output.parent.mkdir(parents=True, exist_ok=True)
with output.open("w", encoding="utf-8") as handle:
    handle.write("# Manual Applications snapshot\n")
    handle.write("# Apps listed here appear to need manual installation on a fresh Mac\n")
    handle.write("# Excludes Apple defaults, App Store apps, and apps matched to Homebrew casks\n")
    handle.write("\n")
    handle.write("[summary]\n")
    handle.write(f"manual_count = {len(manual_apps)}\n")
    for key, value in skipped.items():
        handle.write(f"skipped_{key} = {value}\n")
    handle.write("\n")

    for app in manual_apps:
        handle.write("[[apps]]\n")
        for key in ["name", "path", "bundle_id", "version", "reason", "install"]:
            handle.write(f"{key} = {toml_escape(str(app[key]))}\n")
        handle.write("\n")

print(f"  manual Applications snapshot captured -> {output}")
print(f"  manual app candidates: {len(manual_apps)}")
PYEOF
