#!/usr/bin/env python3
"""Validate VS Code JSONC files (comments + trailing commas allowed)."""

from __future__ import annotations

import json
import sys
from pathlib import Path


def strip_jsonc_comments(text: str) -> str:
    out: list[str] = []
    i = 0
    in_string = False
    escape = False

    while i < len(text):
        ch = text[i]

        if in_string:
            out.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if ch == '"':
            in_string = True
            out.append(ch)
            i += 1
            continue

        if ch == "/" and i + 1 < len(text) and text[i + 1] == "/":
            i += 2
            while i < len(text) and text[i] not in "\r\n":
                i += 1
            continue

        if ch == "/" and i + 1 < len(text) and text[i + 1] == "*":
            i += 2
            while i + 1 < len(text) and not (text[i] == "*" and text[i + 1] == "/"):
                i += 1
            i += 2
            continue

        out.append(ch)
        i += 1

    return "".join(out)


def remove_trailing_commas(text: str) -> str:
    out: list[str] = []
    i = 0
    in_string = False
    escape = False

    while i < len(text):
        ch = text[i]

        if in_string:
            out.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if ch == '"':
            in_string = True
            out.append(ch)
            i += 1
            continue

        if ch == ",":
            j = i + 1
            while j < len(text) and text[j] in " \t\r\n":
                j += 1
            if j < len(text) and text[j] in "]}":
                i += 1
                continue

        out.append(ch)
        i += 1

    return "".join(out)


def validate_jsonc(path: Path) -> None:
    raw = path.read_text(encoding="utf-8")
    cleaned = remove_trailing_commas(strip_jsonc_comments(raw))
    json.loads(cleaned)


def main() -> int:
    files = [
        Path("vscode/settings.json"),
        Path("vscode/keybindings.json"),
        Path("vscode/extensions.json"),
    ]

    for path in files:
        if not path.exists():
            print(f"ERROR: missing file {path}", file=sys.stderr)
            return 1

    for path in files:
        validate_jsonc(path)
        print(f"OK: {path} is valid JSONC")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
