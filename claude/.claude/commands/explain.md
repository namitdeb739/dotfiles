---
description: Explain an unfamiliar codebase or area — structure, entry points, and conventions
---

# Explain the Codebase

Orient quickly in an unfamiliar codebase or area: `$ARGUMENTS` (a path, module, or
feature to focus on; default to the whole repo). Read-only — do not edit.

1. Map the layout: top-level structure, language(s), and where the real code
   lives vs. config/generated. Use Glob/Grep; read `README`, `CLAUDE.md`, and
   manifest files (`package.json`, `pyproject.toml`, `go.mod`, etc.).
2. Identify **entry points** — CLI mains, server/app bootstrap, route tables, job
   workers — and the **build / test / run** commands.
3. Trace the primary flow for the focus area: how a request/command travels
   through the key modules, and where state/data lives.
4. Note the conventions that matter for making changes: how code is layered,
   naming, error handling, testing patterns, and any house rules in `CLAUDE.md`.
5. Deliver a concise orientation: a short prose overview + a `file:line` map of
   the handful of places that matter, and the commands to build/test/run. Flag
   anything surprising or risky. Keep it skimmable — this is a map, not an audit.
