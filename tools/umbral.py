#!/usr/bin/env python3
"""Milestone 000 repository bootstrap and validation utility.

This tool owns structural checks only. It does not generate gameplay content,
world data, engine files, or design decisions.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parent.parent
REQUIRED_DIRECTORIES = (
    ".github/ISSUE_TEMPLATE",
    ".github/workflows",
    "assets",
    "docs/design",
    "docs/development",
    "docs/operations",
    "docs/reference",
    "game",
    "prompts",
    "scripts",
    "server",
    "shared",
    "tools",
)
REQUIRED_FILES = (
    ".editorconfig",
    ".gitignore",
    "CHANGELOG.md",
    "CODE_OF_CONDUCT.md",
    "CONTRIBUTING.md",
    "DECISIONS.md",
    "README.md",
    "ROADMAP.md",
    "TODO.md",
    "docs/00_STUDIO_CHARTER.md",
    "docs/development/STANDARDS.md",
    ".github/PULL_REQUEST_TEMPLATE.md",
    ".github/workflows/validate.yml",
)


def check(root: Path) -> int:
    """Report missing Milestone 000 repository contract entries."""
    missing = [entry for entry in REQUIRED_DIRECTORIES if not (root / entry).is_dir()]
    missing.extend(entry for entry in REQUIRED_FILES if not (root / entry).is_file())
    if missing:
        print("Repository contract is incomplete:")
        for entry in missing:
            print(f"  - {entry}")
        return 1
    print("Repository contract is valid.")
    return 0


def bootstrap(root: Path) -> int:
    """Create missing structural directories; never overwrite files."""
    for entry in REQUIRED_DIRECTORIES:
        (root / entry).mkdir(parents=True, exist_ok=True)
    print("Created missing repository directories. Existing files were not changed.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("check", "bootstrap"), nargs="?", default="check")
    parser.add_argument("--root", type=Path, default=ROOT, help="Repository root to inspect.")
    args = parser.parse_args()
    root = args.root.resolve()
    return bootstrap(root) if args.command == "bootstrap" else check(root)


if __name__ == "__main__":
    sys.exit(main())
