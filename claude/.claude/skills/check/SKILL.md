---
name: check
description: >-
  Run this project's real verification suite — lint, typecheck, and tests — and
  fix what fails. Use before claiming work is done, before pushing, when the user
  asks to "check", "verify", "run the tests", "make sure it works", or when a
  change is complete and needs confirming. Nothing in the harness verifies
  automatically, so this is how "done" gets earned.
allowed-tools: Bash(just *), Bash(uv *), Bash(npm *), Bash(git *), Bash(make *)
---

# Check

Verification is on demand, not automatic. There is deliberately no Stop hook
gating the end of a turn — it cost too much wall-clock time on every turn. The
tradeoff is that verifying is now an explicit step, and skipping it silently is
not acceptable.

## Find the project's own command first

Do not invent a check command. In order of preference:

1. `just --list` — if there is a `check` recipe, that is the answer. Run it.
2. `package.json` scripts — `npm run check` / `lint` / `test`.
3. `Makefile` — a `check` or `test` target.
4. `pyproject.toml` — fall back to the tools it actually configures.

Only if none of those exist, assemble from what the project configures:

| Concern | Python | TS/JS |
| --- | --- | --- |
| Lint | `uv run ruff check .` | `npx eslint .` |
| Types | `uv run mypy --strict .` | `npx tsc --noEmit` |
| Tests | `uv run pytest -q` | `npm test` |

Skip a tool the project has not opted into. A repo with no `mypy` section in
`pyproject.toml` is not asking for `mypy --strict`, and running it produces
noise, not signal.

## Report honestly

- Green → say so, naming the exact command that passed.
- Red → show the actual failing output, not a paraphrase. Fix the root cause
  with a minimal diff, then re-run.
- Pre-existing failures unrelated to the current change → say that explicitly and
  do not silently absorb them into your change. Ask whether to fix them.
- Could not run it at all → say that. Never imply verification happened.
