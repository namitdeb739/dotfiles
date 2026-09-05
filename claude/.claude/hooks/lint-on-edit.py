#!/usr/bin/env python3
"""PostToolUse hook: fast, advisory lint feedback on the file just edited.

Replaces the old `verify-python.py` Stop hook, which ran the full pytest suite
and `mypy --strict .` (up to 240s) at the end of every turn and blocked the turn
on failure. That cost wall-clock time on every single turn and produced retry
loops on unrelated pre-existing failures.

This runs instead on the one file that changed, takes well under a second, and
never blocks: it exits 0 always. The agent sees the diagnostics on stderr and
can act on them, but nothing is gated on it.

Full-suite verification is on demand via the `check` skill, not automatic.
"""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path

TIMEOUT_S = 15

# suffix -> argv prefix producing diagnostics for a single file
LINTERS: dict[str, list[str]] = {
    ".py": ["ruff", "check", "--no-fix", "--quiet"],
    ".sh": ["shellcheck", "--severity=warning"],
    ".bash": ["shellcheck", "--severity=warning"],
}


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0

    raw = (event.get("tool_input") or {}).get("file_path")
    if not raw:
        return 0

    path = Path(raw)
    if not path.is_file():
        return 0

    argv = LINTERS.get(path.suffix)
    if not argv or not shutil.which(argv[0]):
        return 0

    try:
        p = subprocess.run(
            [*argv, str(path)],
            capture_output=True,
            text=True,
            timeout=TIMEOUT_S,
            check=False,
        )
    except (subprocess.TimeoutExpired, OSError):
        return 0

    if p.returncode == 0:
        return 0

    output = (p.stdout + p.stderr).strip()
    if output:
        print(f"\n{argv[0]} on {path.name}:\n{output[:2000]}", file=sys.stderr)

    # Advisory only. Never block.
    return 0


if __name__ == "__main__":
    sys.exit(main())
