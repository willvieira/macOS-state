#!/usr/bin/env python3
"""Compare a captured Homebrew Brewfile with committed profile Brewfiles.

The snapshot is observed machine state. The profile files are desired state.
This script is intentionally generic: it does not contain a package catalog.
Promotion suggestions come from `# reconcile:` hints in the profile files.
"""

from __future__ import annotations

import argparse
import re
import shlex
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

ENTRY_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_-]*)\s+(.+)$")
QUOTED_RE = re.compile(r'"((?:[^"\\]|\\.)*)"')
MAS_ID_RE = re.compile(r"\bid:\s*(\d+)")
RECONCILE_RE = re.compile(r"^#\s*reconcile:\s*(.+)$")

PROFILE_ORDER = [
    "profiles/base/Brewfile",
    "profiles/terminal/Brewfile",
    "profiles/languages/python.Brewfile",
    "profiles/languages/r.Brewfile",
    "profiles/languages/node.Brewfile",
    "profiles/apps/browsers.Brewfile",
    "profiles/apps/productivity.Brewfile",
    "profiles/vscode/base.Brewfile",
    "profiles/vscode/themes.Brewfile",
    "profiles/vscode/python.Brewfile",
    "profiles/vscode/r.Brewfile",
    "profiles/ai/claude.Brewfile",
]


@dataclass(frozen=True)
class Entry:
    kind: str
    name: str
    key: str
    line: str
    source: Path
    line_number: int


@dataclass(frozen=True)
class Rule:
    target: Path
    kind: str
    pattern: Optional[re.Pattern[str]]
    default: bool
    line_number: int


def repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def unescape_quoted(value: str) -> str:
    return bytes(value, "utf-8").decode("unicode_escape")


def parse_entry(raw_line: str, source: Path, line_number: int) -> Optional[Entry]:
    stripped = raw_line.strip()
    if not stripped or stripped.startswith("#"):
        return None
    match = ENTRY_RE.match(stripped)
    if not match:
        return None
    kind, rest = match.groups()
    quoted = QUOTED_RE.search(rest)
    if not quoted:
        return None
    name = unescape_quoted(quoted.group(1))
    if kind == "mas":
        id_match = MAS_ID_RE.search(rest)
        key = f"mas:{id_match.group(1)}" if id_match else f"mas:{name.lower()}"
    else:
        key = f"{kind}:{name.lower()}"
    return Entry(kind=kind, name=name, key=key, line=stripped, source=source, line_number=line_number)


def read_entries(path: Path) -> List[Entry]:
    if not path.exists():
        return []
    entries: List[Entry] = []
    for line_number, raw_line in enumerate(path.read_text().splitlines(), 1):
        entry = parse_entry(raw_line, path, line_number)
        if entry:
            entries.append(entry)
    return entries


def parse_reconcile_rule(raw_line: str, source: Path, line_number: int) -> Optional[Rule]:
    match = RECONCILE_RE.match(raw_line.strip())
    if not match:
        return None

    try:
        parts = shlex.split(match.group(1))
    except ValueError as exc:
        raise SystemExit(f"{source}:{line_number}: invalid reconcile rule: {exc}")

    values: Dict[str, str] = {}
    default = False
    for part in parts:
        if part == "default":
            default = True
            continue
        if "=" not in part:
            raise SystemExit(f"{source}:{line_number}: expected key=value or default in reconcile rule")
        key, value = part.split("=", 1)
        values[key] = value

    kind = values.get("kind")
    if not kind:
        raise SystemExit(f"{source}:{line_number}: reconcile rule needs kind=<brew|cask|mas|npm|tap|vscode>")

    pattern_text = values.get("pattern")
    pattern = re.compile(pattern_text, re.IGNORECASE) if pattern_text else None
    if pattern is None and not default:
        raise SystemExit(f"{source}:{line_number}: reconcile rule needs pattern=<regex> or default")

    return Rule(target=source, kind=kind, pattern=pattern, default=default, line_number=line_number)


def read_rules(path: Path) -> List[Rule]:
    if not path.exists():
        return []
    rules: List[Rule] = []
    for line_number, raw_line in enumerate(path.read_text().splitlines(), 1):
        rule = parse_reconcile_rule(raw_line, path, line_number)
        if rule:
            rules.append(rule)
    return rules


def profile_files(root: Path) -> List[Path]:
    files = []
    for relative in PROFILE_ORDER:
        path = root / relative
        if path.exists():
            files.append(path)
    seen = {p.resolve() for p in files}
    for path in sorted((root / "profiles").rglob("*")):
        if not path.is_file():
            continue
        if path.name != "Brewfile" and path.suffix != ".Brewfile":
            continue
        resolved = path.resolve()
        if resolved not in seen:
            files.append(path)
            seen.add(resolved)
    return files


def index_entries(entries: Iterable[Entry]) -> Dict[str, List[Entry]]:
    indexed: Dict[str, List[Entry]] = {}
    for entry in entries:
        indexed.setdefault(entry.key, []).append(entry)
    return indexed


def relative(path: Path, root: Path) -> str:
    try:
        return str(path.relative_to(root))
    except ValueError:
        return str(path)


def suggest_profile(entry: Entry, rules: Sequence[Rule], root: Path) -> Optional[str]:
    defaults: List[Rule] = []
    searchable = f"{entry.kind}:{entry.name}\n{entry.line}"
    for rule in rules:
        if rule.kind != entry.kind:
            continue
        if rule.default:
            defaults.append(rule)
            continue
        if rule.pattern and rule.pattern.search(searchable):
            return relative(rule.target, root)
    if defaults:
        return relative(defaults[0].target, root)
    return None


def append_entries(root: Path, assignments: Sequence[Tuple[Entry, str]]) -> None:
    by_target: Dict[str, List[Entry]] = {}
    for entry, target in assignments:
        by_target.setdefault(target, []).append(entry)

    for target, entries in by_target.items():
        path = root / target
        path.parent.mkdir(parents=True, exist_ok=True)
        existing = path.read_text() if path.exists() else ""
        with path.open("a") as handle:
            if existing and not existing.endswith("\n"):
                handle.write("\n")
            if existing.strip():
                handle.write("\n")
            handle.write("# Promoted from Homebrew snapshot\n")
            for entry in sorted(entries, key=lambda e: (e.kind, e.name.lower(), e.line)):
                handle.write(entry.line + "\n")


def print_entries(title: str, entries: Sequence[Entry], root: Path, rules: Sequence[Rule], include_suggestions: bool = False) -> None:
    print(title)
    if not entries:
        print("  none")
        return
    for entry in sorted(entries, key=lambda e: (e.kind, e.name.lower(), e.line)):
        location = f"{relative(entry.source, root)}:{entry.line_number}"
        suffix = ""
        if include_suggestions:
            suggestion = suggest_profile(entry, rules, root)
            suffix = f" -> {suggestion}" if suggestion else " -> review manually"
        print(f"  {entry.line}  ({location}){suffix}")


def main(argv: Optional[Sequence[str]] = None) -> int:
    root = repo_root()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot", type=Path, default=root / "snapshots" / "Brewfile", help="Captured Brewfile to compare")
    parser.add_argument("--apply-suggestions", action="store_true", help="Append snapshot-only entries with recognized target profiles")
    parser.add_argument("--yes", action="store_true", help="Do not prompt before applying suggestions")
    args = parser.parse_args(argv)

    snapshot = args.snapshot.expanduser()
    if not snapshot.exists():
        print(f"Snapshot Brewfile not found: {snapshot}", file=sys.stderr)
        print("Run ./sync.sh first, or pass --snapshot PATH", file=sys.stderr)
        return 2

    profiles = profile_files(root)
    snapshot_entries = read_entries(snapshot)
    profile_entries = [entry for path in profiles for entry in read_entries(path)]
    rules = [rule for path in profiles for rule in read_rules(path)]
    snapshot_index = index_entries(snapshot_entries)
    profile_index = index_entries(profile_entries)

    snapshot_only = [entries[0] for key, entries in snapshot_index.items() if key not in profile_index]
    profile_only = [entries[0] for key, entries in profile_index.items() if key not in snapshot_index]
    duplicates = [entries for entries in profile_index.values() if len({e.source for e in entries}) > 1]
    assignments = [(entry, suggest_profile(entry, rules, root)) for entry in snapshot_only]
    assignments = [(entry, target) for entry, target in assignments if target]

    print(f"Snapshot: {snapshot}")
    print(f"Profiles: {len(profiles)} files")
    print(f"Reconcile rules: {len(rules)} from profile comments")
    print(f"Snapshot entries: {len(snapshot_index)}")
    print(f"Profile entries: {len(profile_index)}")
    print()
    print_entries("Snapshot-only entries", snapshot_only, root, rules, include_suggestions=True)
    print()
    print_entries("Profile-only entries", profile_only, root, rules)
    print()
    print("Duplicate profile entries")
    if not duplicates:
        print("  none")
    else:
        for entries in duplicates:
            print(f"  {entries[0].line}")
            for entry in entries:
                print(f"    - {relative(entry.source, root)}:{entry.line_number}")

    if not args.apply_suggestions:
        if assignments:
            print()
            print("To append suggested snapshot-only entries into profiles, rerun with --apply-suggestions")
        return 0

    if not assignments:
        print()
        print("No suggested entries to apply")
        return 0

    print()
    print("Will append:")
    for entry, target in assignments:
        print(f"  {entry.line} -> {target}")

    if not args.yes:
        answer = input("Apply these suggestions? [y/N] ").strip().lower()
        if answer not in {"y", "yes"}:
            print("Aborted")
            return 1

    append_entries(root, assignments)
    print("Applied suggestions")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
