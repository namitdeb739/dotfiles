---
description: Implement a task: read context, plan, execute, verify
---

Implement the following task: $ARGUMENTS

Follow these steps:

1. **Understand the task** — if the requirement is ambiguous, ask one focused question before proceeding.

2. **Read relevant files** — never guess at structure. Use Glob/Grep to locate files, then Read them before editing.

3. **Plan** — briefly state what you will change and why. For non-trivial tasks, list the files and specific changes before touching anything.

4. **Implement** — make the minimal diff that satisfies the requirement:
   - No opportunistic cleanup or refactoring beyond the task scope.
   - No speculative abstractions or helpers for hypothetical future use.
   - No added comments, docstrings, or type annotations on unchanged code.

5. **Verify** — after implementing, run whatever is appropriate for the project:
   - Type check: `mypy --strict` (Python) or `tsc --noEmit` (TypeScript)
   - Lint: `ruff check` (Python) or `eslint` (JS/TS)
   - Tests: `pytest` / `npm test` / project-specific test command
   - If none of these apply, do a final read of changed files to catch obvious errors.

6. **Report** — state what was changed. No trailing summaries if the diff is self-evident.
