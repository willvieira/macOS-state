#!/usr/bin/env python3
"""Apply Claude Code plugin directives from profiles/ai/agents.Brewfile."""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any

BREWFILE_MARKETPLACE_RE = re.compile(
    r'^#\s*claude_marketplace\s+"([^"]+)"\s*,\s*source:\s*"([^"]+)"\s*$'
)
BREWFILE_PLUGIN_RE = re.compile(r'^#\s*claude_plugin\s+"([^"]+)"\s*$')


def parse_brewfile(path: Path) -> tuple[dict[str, str], list[str]]:
    marketplaces: dict[str, str] = {}
    enabled_plugins: list[str] = []

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.rstrip()

        marketplace_match = BREWFILE_MARKETPLACE_RE.match(line)
        if marketplace_match:
            marketplace, source = marketplace_match.groups()
            marketplaces[marketplace] = source
            continue

        plugin_match = BREWFILE_PLUGIN_RE.match(line)
        if plugin_match:
            enabled_plugins.append(plugin_match.group(1))
            continue

    for plugin in enabled_plugins:
        if "@" not in plugin:
            raise ValueError(f"Claude plugin must use plugin@marketplace form: {plugin}")
        marketplace = plugin.split("@", 1)[1]
        if marketplace not in marketplaces:
            raise ValueError(f"Missing # claude_marketplace directive for {marketplace}")

    return marketplaces, sorted(set(enabled_plugins))


def source_to_claude(source: str) -> str:
    if source.startswith("github:"):
        return source.removeprefix("github:")
    return source


def source_to_settings(source: str) -> dict[str, Any]:
    if source.startswith("github:"):
        return {"source": "github", "repo": source.removeprefix("github:")}
    if source.startswith("http://") or source.startswith("https://") or source.endswith(".git"):
        return {"source": "git", "url": source}
    if source:
        return {"source": "github", "repo": source}
    return {}


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=4) + "\n", encoding="utf-8")


def update_settings(settings_path: Path, marketplaces: dict[str, str], enabled_plugins: list[str]) -> None:
    cfg = load_json(settings_path)

    known = cfg.setdefault("extraKnownMarketplaces", {})
    for marketplace, source in marketplaces.items():
        settings_source = source_to_settings(source)
        if settings_source:
            known[marketplace] = {"source": settings_source}

    enabled = cfg.setdefault("enabledPlugins", {})
    for plugin in enabled_plugins:
        enabled[plugin] = True

    save_json(settings_path, cfg)


def run_command(command: list[str], dry_run: bool) -> bool:
    printable = " ".join(command)
    if dry_run:
        print(f"  [dry-run] {printable}")
        return True
    print(f"  {printable}")
    completed = subprocess.run(command, text=True)
    return completed.returncode == 0


def install_selected(marketplaces: dict[str, str], plugins: list[str], dry_run: bool) -> int:
    failures: list[str] = []

    for marketplace, source in sorted(marketplaces.items()):
        claude_source = source_to_claude(source)
        if not claude_source:
            continue
        if not run_command(["claude", "plugin", "marketplace", "add", claude_source], dry_run):
            print(f"  marketplace add failed or already exists: {marketplace}", file=sys.stderr)

    if marketplaces:
        run_command(["claude", "plugin", "marketplace", "update"], dry_run)

    for plugin in plugins:
        if run_command(["claude", "plugin", "install", "--scope", "user", plugin], dry_run):
            continue
        if run_command(["claude", "plugin", "enable", "--scope", "user", plugin], dry_run):
            continue
        failures.append(plugin)

    if failures:
        print("Failed to install/enable selected Claude plugins:", file=sys.stderr)
        for plugin in failures:
            print(f"  - {plugin}", file=sys.stderr)
        return 1
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--brewfile", required=True, type=Path, help="Brewfile containing # claude_* directives")
    parser.add_argument("--settings", default=Path.home() / ".claude" / "settings.json", type=Path)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--no-install", action="store_true", help="Only update settings.json")
    args = parser.parse_args()

    marketplaces, enabled_plugins = parse_brewfile(args.brewfile)
    update_settings(args.settings, marketplaces, enabled_plugins)
    print(f"  Claude settings updated from {args.brewfile}")
    print(f"  Claude marketplaces: {len(marketplaces)}")
    print(f"  Claude plugins enabled: {len(enabled_plugins)}")

    if args.no_install:
        return 0
    return install_selected(marketplaces, enabled_plugins, args.dry_run)


if __name__ == "__main__":
    raise SystemExit(main())
