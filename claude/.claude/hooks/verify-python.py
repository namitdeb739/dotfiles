#!/usr/bin/env python3
"""Stop hook: refuse to end a turn on unverified Python changes.

The point is to change the default from "looks done" to "verified done", so a
session can be left alone instead of watched. It blocks the turn (exit 2) and
hands the failure back to Claude, which then fixes it and tries again.

Deliberately conservative, because this runs on EVERY turn across every repo:

  * skips unless the project actually configures the tool (a repo with no
    pytest config or no mypy section is not opting in, and blocking there
    would make the hook unusable on the embedded C work)
  * skips when no Python file has been touched in the working tree
  * never blocks twice in a row (`stop_hook_active`), so a genuinely stuck
    failure cannot trap the session
  * treats a timeout as a pass, since a hung test suite must not cost the turn
"""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tomllib
from pathlib import Path

TIMEOUT_S = 240


def project_root(start: Path) -> Path | None:
    for parent in [start, *start.parents]:
        if (parent / "pyproject.toml").is_file():
            return parent
    return None


def changed_python(root: Path) -> bool:
    try:
        out = subprocess.run(
            ["git", "status", "--porcelain", "--untracked-files=all"],
            cwd=root, capture_output=True, text=True, timeout=15, check=False,
        )
    except (subprocess.TimeoutExpired, OSError):
        return False
    return any(line[3:].strip().endswith(".py") for line in out.stdout.splitlines())


def config(root: Path) -> dict:
    try:
        return tomllib.loads((root / "pyproject.toml").read_text())
    except (OSError, tomllib.TOMLDecodeError):
        return {}


def available(tool: str, root: Path) -> bool:
    """Is the tool actually runnable in this project's environment?

    Without this the hook blocks on `Failed to spawn: pytest` — a missing
    dependency, not a failing test — which would make every turn in every repo
    that does not depend on pytest unfinishable.
    """
    try:
        p = subprocess.run(
            ["uv", "run", "--quiet", tool, "--version"],
            cwd=root, capture_output=True, text=True, timeout=60, check=False,
        )
    except (subprocess.TimeoutExpired, OSError):
        return False
    return p.returncode == 0


def run(argv: list[str], root: Path, ok_codes: tuple[int, ...] = (0,)) -> tuple[bool, str]:
    """Return (ok, output). A timeout counts as ok — see module docstring."""
    try:
        p = subprocess.run(
            argv, cwd=root, capture_output=True, text=True,
            timeout=TIMEOUT_S, check=False,
        )
    except subprocess.TimeoutExpired:
        return True, ""
    except OSError:
        return True, ""
    if p.returncode in ok_codes:
        return True, ""
    return False, (p.stdout + p.stderr)[-3000:]


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0

    # Already blocked once this turn; let it end rather than loop.
    if event.get("stop_hook_active"):
        return 0

    root = project_root(Path.cwd())
    if root is None or not changed_python(root):
        return 0
    if not shutil.which("uv"):
        return 0

    cfg = config(root)
    tool = cfg.get("tool", {})
    failures: list[str] = []

    # Only run what the project has opted into by configuring it.
    has_tests = "pytest" in tool or (root / "tests").is_dir()
    if has_tests and available("pytest", root):
        # Exit 5 is "no tests collected", which is not a failure here.
        ok, out = run(["uv", "run", "pytest", "-q", "--no-header"], root, ok_codes=(0, 5))
        if not ok:
            failures.append(f"pytest failed:\n{out}")

    if "mypy" in tool and available("mypy", root):
        ok, out = run(["uv", "run", "mypy", "--strict", "."], root)
        if not ok:
            failures.append(f"mypy --strict failed:\n{out}")

    if not failures:
        return 0

    print(
        "Verification failed before ending the turn. Fix these, then finish:\n\n"
        + "\n\n".join(failures),
        file=sys.stderr,
    )
    return 2  # exit 2 blocks the Stop event and returns stderr to Claude


if __name__ == "__main__":
    sys.exit(main())
