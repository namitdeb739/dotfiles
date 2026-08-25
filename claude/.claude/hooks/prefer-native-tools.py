#!/usr/bin/env python3
"""
PreToolUse hook that routes shell-based file access back to the native tools.

Measured over 48 transcripts: `cat` 77, `rg` 57, `grep` 45, `find` 9 — 188
shell reads/searches against 301 Read + 44 Grep + 27 Glob. That is ~38% of all
retrieval bypassing Read's truncation and Grep's structured output.

`sed -i` is the one that actually costs correctness: an in-place edit skips
format-on-edit.py and the LSP diagnostics loop entirely, so the file is left
unformatted and untyped-checked.

Warn-only: always exits 0. Composition is a legitimate reason to stay in Bash,
so anything containing a pipe, xargs, or command substitution is left alone.
"""

import json
import re
import sys
import tempfile
from pathlib import Path

# Command prefix → the native tool that should have been used.
SUGGESTIONS: dict[str, str] = {
    r"^(cat|head|tail|bat)\s": "Read (it takes an absolute path and truncates sensibly)",
    r"^(grep|rg|ag)\s": "Grep (structured output, no shell quoting to get wrong)",
    r"^(find|fd)\s": "Glob (pattern matching without find's argument syntax)",
    r"^sed\s+-i": "Edit — `sed -i` skips format-on-edit.py and LSP diagnostics",
}

# Composition is a real reason to stay in Bash; don't nag about it.
COMPOSITION = re.compile(r"[|]|\bxargs\b|\$\(|`")


def session_file(session_id: str) -> Path:
    safe = re.sub(r"[^A-Za-z0-9_-]", "", session_id) or "default"
    return Path(tempfile.gettempdir()) / f"claude_native_tools_hook_{safe}.json"


def load_warned(state_path: Path) -> set[str]:
    if state_path.exists():
        try:
            return set(json.loads(state_path.read_text()))
        except (json.JSONDecodeError, OSError):
            pass
    return set()


def save_warned(state_path: Path, warned: set[str]) -> None:
    try:
        state_path.write_text(json.dumps(list(warned)))
    except OSError:
        pass


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, OSError):
        return 0

    if payload.get("tool_name", "") != "Bash":
        return 0

    command = payload.get("tool_input", {}).get("command", "").strip()
    if not command or COMPOSITION.search(command):
        return 0

    for pattern, suggestion in SUGGESTIONS.items():
        if re.search(pattern, command):
            break
    else:
        return 0

    state_path = session_file(payload.get("session_id", ""))
    warned = load_warned(state_path)
    if pattern in warned:
        return 0
    warned.add(pattern)
    save_warned(state_path, warned)

    print(f"\n💡 Prefer {suggestion}.", file=sys.stderr)
    print("   This is a nudge, not a block — the command still ran.", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
