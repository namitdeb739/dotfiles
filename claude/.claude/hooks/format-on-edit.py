#!/usr/bin/env python3
"""PostToolUse hook: format files immediately after Claude edits them.

Replaces prose rules with enforcement. A CLAUDE.md line saying "use ruff
format" is a request; this is a guarantee, and it costs zero context because
hooks only consume tokens when they produce output.

Silent on success. Never blocks: a formatter being absent or unhappy must not
stop a turn, so every failure path exits 0.
"""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path

# suffix -> list of argv prefixes, run in order against the file
FORMATTERS: dict[str, list[list[str]]] = {
    ".py": [["ruff", "format"], ["ruff", "check", "--fix", "--quiet"]],
    ".c": [["clang-format", "-i"]],
    ".h": [["clang-format", "-i"]],
    ".cpp": [["clang-format", "-i"]],
    ".hpp": [["clang-format", "-i"]],
    ".cc": [["clang-format", "-i"]],
    ".ino": [["clang-format", "-i"]],
}

TIMEOUT_S = 20


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0

    raw = (event.get("tool_input") or {}).get("file_path")
    if not raw:
        return 0

    path = Path(raw)
    # The edit may have been to a path that no longer exists (rename, delete).
    if not path.is_file():
        return 0

    commands = FORMATTERS.get(path.suffix)
    if not commands:
        return 0

    for argv in commands:
        if not shutil.which(argv[0]):
            # Formatter not installed on this machine; nothing to enforce.
            continue
        try:
            subprocess.run(
                [*argv, str(path)],
                capture_output=True,
                timeout=TIMEOUT_S,
                check=False,
            )
        except (subprocess.TimeoutExpired, OSError):
            # A formatter hanging or missing must never cost the user a turn.
            continue

    return 0


if __name__ == "__main__":
    sys.exit(main())
