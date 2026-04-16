#!/usr/bin/env python3
"""
PreToolUse security guidance hook for Claude Code.
Warns once per file per session when editing files that contain
high-risk patterns. Exits 2 (block + show message) on first encounter;
exits 0 on subsequent encounters for the same file.
"""

import json
import os
import re
import sys
import tempfile
from pathlib import Path

# --- Patterns that warrant a security warning ---

# Map of pattern description → regex
DANGEROUS_PATTERNS: dict[str, str] = {
    "eval() call": r"\beval\s*\(",
    "new Function() constructor": r"\bnew\s+Function\s*\(",
    "dangerouslySetInnerHTML": r"dangerouslySetInnerHTML",
    "innerHTML assignment": r"\.innerHTML\s*=",
    "os.system() call": r"\bos\.system\s*\(",
    "subprocess with shell=True": r"subprocess\.(call|run|Popen)\s*\([^)]*shell\s*=\s*True",
    "pickle (insecure deserialization)": r"\bpickle\.(loads?|dumps?)\s*\(",
    "child_process.exec": r"child_process\.exec\s*\(",
}

# Files matching these globs get an extra GitHub Actions warning
GITHUB_ACTIONS_GLOB = re.compile(r"\.github/workflows/.*\.(yml|yaml)$")

GITHUB_ACTIONS_WARNING = (
    "GitHub Actions workflow files can be vulnerable to command injection via "
    "untrusted input in `run:` steps. Avoid interpolating ${{ github.event.* }} "
    "directly into shell commands. Use intermediate env vars instead."
)

# Session state file — tracks which files have already been warned about
_SESSION_FILE = Path(tempfile.gettempdir()) / f"claude_security_hook_{os.getpid()}.json"


def load_warned_files() -> set[str]:
    if _SESSION_FILE.exists():
        try:
            return set(json.loads(_SESSION_FILE.read_text()))
        except (json.JSONDecodeError, OSError):
            pass
    return set()


def save_warned_files(warned: set[str]) -> None:
    try:
        _SESSION_FILE.write_text(json.dumps(list(warned)))
    except OSError:
        pass


def check_content(content: str) -> list[str]:
    """Return list of matched pattern descriptions."""
    matches = []
    for description, pattern in DANGEROUS_PATTERNS.items():
        if re.search(pattern, content, re.MULTILINE):
            matches.append(description)
    return matches


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, OSError):
        return 0  # Can't parse input — don't block

    tool_name = payload.get("tool_name", "")
    tool_input = payload.get("tool_input", {})

    if tool_name not in ("Edit", "Write", "MultiEdit"):
        return 0

    file_path = tool_input.get("file_path", "") or tool_input.get("path", "")
    new_content = (
        tool_input.get("new_string", "")
        or tool_input.get("content", "")
        or ""
    )

    if not file_path:
        return 0

    warned_files = load_warned_files()

    if file_path in warned_files:
        return 0  # Already warned this session — let it through

    warnings: list[str] = []

    # Check for GitHub Actions workflow patterns
    if GITHUB_ACTIONS_GLOB.search(file_path):
        warnings.append(f"GitHub Actions workflow: {GITHUB_ACTIONS_WARNING}")

    # Check content for dangerous patterns
    if new_content:
        matches = check_content(new_content)
        for match in matches:
            warnings.append(f"Dangerous pattern detected — {match}")

    if not warnings:
        return 0

    # Record that we've warned about this file
    warned_files.add(file_path)
    save_warned_files(warned_files)

    # Output warning to stderr (visible to user)
    print(
        f"\n⚠️  Security guidance for: {file_path}",
        file=sys.stderr,
    )
    for warning in warnings:
        print(f"   • {warning}", file=sys.stderr)
    print(
        "\nReview carefully before proceeding. "
        "Edit will be blocked once — re-run to apply after review.",
        file=sys.stderr,
    )

    # Exit 2 = block the tool call and show stderr to user
    return 2


if __name__ == "__main__":
    sys.exit(main())
