#!/usr/bin/env python3
"""Regenerate lua/snippets/tex/data.lua from the Obsidian LaTeX Suite config.

The plugin stores its snippets as a JavaScript string inside data.json, with
regex-literal triggers and arrow-function replacements, so a JS runtime does the
parsing. Generator snippets (function replacements) are skipped -- those live
hand-written in lua/snippets/tex/matrices.lua.

Usage: python3 latex_suite_to_luasnip.py
"""

import json
import pathlib
import subprocess
import sys
import tempfile

VAULT = pathlib.Path.home() / "Obsidian"
DATA_JSON = VAULT / ".obsidian/plugins/obsidian-latex-suite/data.json"
OUT = pathlib.Path(__file__).resolve().parent.parent / ".config/nvim/lua/snippets/tex/data.lua"

EXTRACT_JS = """
import { readFileSync, writeFileSync } from "node:fs";
const src = readFileSync(process.argv[2], "utf8");
const mod = await import("data:text/javascript;base64," + Buffer.from(src).toString("base64"));
writeFileSync(process.argv[3], JSON.stringify(mod.default.map((s) => ({
  trigger: s.trigger instanceof RegExp
    ? { kind: "regex", source: s.trigger.source }
    : { kind: "string", value: s.trigger },
  replacement: typeof s.replacement === "function"
    ? { kind: "fn" } : { kind: "str", value: s.replacement },
  options: s.options ?? "",
  priority: s.priority ?? null,
}))));
"""

SKIP_TRIGGERS = {"cbl"}  # Obsidian code fence; no .tex analogue


def to_tex_mode(repl):
    """Text-mode replacements wrap math in $$…$$ / $…$ for Obsidian markdown.
    In .tex those are \\[…\\] and \\(…\\). Returns None if it is not math at all."""
    if repl.startswith("$$\n") and repl.endswith("\n$$"):
        return "\\[\n" + repl[3:-3] + "\n\\]"
    if repl.startswith("$$") and repl.endswith("$$"):
        return "\\[" + repl[2:-2] + "\\]"
    if repl.startswith("$") and repl.endswith("$"):
        return "\\(" + repl[1:-1] + "\\)"
    return None


def lua_str(s):
    return '"' + (s.replace("\\", "\\\\").replace('"', '\\"')
                   .replace("\n", "\\n").replace("\t", "\\t")) + '"'


def main():
    snippets_js = json.loads(DATA_JSON.read_text())["snippets"]

    with tempfile.TemporaryDirectory() as tmp:
        tmp = pathlib.Path(tmp)
        (tmp / "snippets.mjs").write_text(snippets_js)
        (tmp / "extract.mjs").write_text(EXTRACT_JS)
        subprocess.run(
            ["node", tmp / "extract.mjs", tmp / "snippets.mjs", tmp / "out.json"],
            check=True,
        )
        data = json.loads((tmp / "out.json").read_text())

    rows, skipped = [], []
    for sn in data:
        opts, trig = sn["options"], sn["trigger"]
        is_regex = trig["kind"] == "regex" or "r" in opts
        trigger = trig.get("source") or trig.get("value")

        if sn["replacement"]["kind"] == "fn":
            skipped.append((trigger, "generator, see matrices.lua"))
            continue

        repl = sn["replacement"]["value"]
        if "t" in opts:
            converted = None if (trigger in SKIP_TRIGGERS or is_regex) else to_tex_mode(repl)
            if converted is None:
                skipped.append((trigger, "markdown-only"))
                continue
            repl = converted

        mode = ("display" if "M" in opts else "inline" if "n" in opts
                else "text" if "t" in opts else "math")

        rows.append(
            "  { trig = %s, repl = %s, mode = %s, auto = %s, word = %s, "
            "regex = %s, visual = %s%s }," % (
                lua_str(trigger), lua_str(repl), lua_str(mode),
                str("A" in opts).lower(), str("w" in opts).lower(),
                str(is_regex).lower(), str("v" in opts).lower(),
                ", prio = %d" % sn["priority"] if sn["priority"] is not None else "",
            )
        )

    OUT.write_text(
        "-- Generated from Obsidian LaTeX Suite data.json -- do not edit by hand.\n"
        "-- Regenerate: python3 nvim/scripts/latex_suite_to_luasnip.py\n\n"
        "return {\n" + "\n".join(rows) + "\n}\n"
    )

    print("wrote %s (%d snippets, %d skipped)" % (OUT, len(rows), len(skipped)), file=sys.stderr)
    for trigger, why in skipped:
        print("  skipped %r -- %s" % (trigger, why), file=sys.stderr)


if __name__ == "__main__":
    main()
