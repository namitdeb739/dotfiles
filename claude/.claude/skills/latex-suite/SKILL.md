---
name: latex-suite
description: >-
  Add, edit, or remove Obsidian LaTeX Suite snippets and keep the three
  dependent files in sync. Use when the user mentions LaTeX snippets, Obsidian
  snippet triggers, autofire/tabout snippet settings, or wants a new maths
  shortcut in their vault.
---

# Obsidian LaTeX Suite snippets

## The three files that must stay in sync

- **Plugin config** —
  `/Users/namit/Obsidian/.obsidian/plugins/obsidian-latex-suite/data.json`
  - `"snippets"` holds a **JavaScript string** (`export default [...]`), not raw
    JSON. Edit the JS inside the string value, minding JSON escaping: newlines
    → `\n`, backslashes → `\\`, quotes → `\"`.
  - `"snippetVariables"` holds the regex groups used as `${GREEK}`, `${SYMBOL}`.
  - Options flags: `m` math mode, `t` text mode, `A` auto-fire, `r` regex
    trigger, `w` word boundary, `v` visual selection, `M` block math only,
    `n` inline math only.
- **Reference doc** — `/Users/namit/Obsidian/_latex-snippets.md`
  - Cheat-sheet: `##` category headers, 3-column tables
    (`Trigger | Name | Renders as`).
- **Trigger conflict index** — `/Users/namit/Obsidian/latex-trigger-index.txt`
  - Sorted list of every auto-firing trigger (options containing `A`).
  - Tab-only snippets are absent by design — they cannot fire unintentionally.

## Steps

1. **Read all three files** before changing anything.

2. **Conflict check** (adds and modifications only):
   - Read `latex-trigger-index.txt`.
   - Flag if the new trigger is a substring of an existing entry, or an existing
     entry is a substring of it.
   - On a conflict, report it and ask before proceeding. Never silently insert a
     conflicting trigger.
   - Regex triggers (`r` in options) need checking only against other regex
     triggers with overlapping match domains — use judgement.

3. **Apply**:
   - *Add* — insert into the right category block in the JS string; add a row to
     the matching table in `_latex-snippets.md`; insert into
     `latex-trigger-index.txt` in sorted position if auto-firing.
   - *Modify* — update `data.json` and the corresponding doc row; update the
     index if the trigger changed.
   - *Remove* — delete from all three files.
   - *Settings only* (`tabout`, `autofractions`, …) — edit the top-level key in
     `data.json`; the other two files are untouched.

4. **Validate** that `data.json` is still valid JSON after editing. The JS string
   inside it is not validated automatically.

5. Report what changed in each file — one sentence per file.
