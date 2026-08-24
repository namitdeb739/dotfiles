#!/usr/bin/env python3
"""
PreToolUse hook that discourages `cd` in Bash commands.

Measured over 48 transcripts, `cd` was 1319 of 2561 Bash calls — 51% of all
Bash and ~26% of every tool call made. Almost none of it was necessary: Read,
Grep, Glob and Edit all take absolute paths, and `just -f <path>` runs a recipe
from anywhere.

Warn-only by design: always exits 0. A blocking version would fight legitimate
uses — `(cd sub && make)`, heredocs, and compound commands where cwd genuinely
matters — and risks retry loops. The nudge is enough; the agent adapts.

Warns once per session, keyed on session_id rather than os.getpid() for the
reason documented in security-guidance.py.
"""

import json
import re
import sys
import tempfile
from pathlib import Path

# `cd` at the start of the command, or after a `&&`, `;`, or `|` separator.
CD_PATTERN = re.compile(r"(?:^|&&|;|\|)\s*cd\s+", re.MULTILINE)

GUIDANCE = """\
`cd` is rarely needed and is the single largest source of wasted tool calls here.
   • Read, Grep, Glob and Edit all take absolute paths — no cwd required.
   • Run recipes from anywhere with `just -f /abs/path/justfile <recipe>`.
   • For a one-off that truly needs a cwd, prefer `git -C <dir>` or a subshell.
This is a nudge, not a block — the command still ran."""


def session_file(session_id: str) -> Path:
    safe = re.sub(r"[^A-Za-z0-9_-]", "", session_id) or "default"
    return Path(tempfile.gettempdir()) / f"claude_no_cd_hook_{safe}.json"


def already_warned(state_path: Path) -> bool:
    return state_path.exists()


def mark_warned(state_path: Path) -> None:
    try:
        state_path.write_text(json.dumps(True))
    except OSError:
        pass


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, OSError):
        return 0

    if payload.get("tool_name", "") != "Bash":
        return 0

    command = payload.get("tool_input", {}).get("command", "")
    if not command or not CD_PATTERN.search(command):
        return 0

    state_path = session_file(payload.get("session_id", ""))
    if already_warned(state_path):
        return 0
    mark_warned(state_path)

    print(f"\n💡 {GUIDANCE}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
