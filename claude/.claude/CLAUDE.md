# Global Claude Instructions

## Communication

- Be direct. No preamble, no filler phrases ("Certainly!", "Of course!").
- No trailing summaries — the diff speaks for itself.
- Ask before assuming on ambiguous requirements. One focused question beats a wrong implementation.
- Prefer terse responses; expand only when explanation adds real value.

## Code

- Read files before editing them. Never guess at structure.
- Minimal diffs — change only what the task requires. No opportunistic cleanup.
- No speculative abstractions. Three similar lines beat a premature helper.
- No hardcoded secrets, tokens, or credentials — ever.
- No added error handling for impossible states. Trust framework guarantees.
- No feature flags or compatibility shims when you can just change the code.

## Python Stack

| Concern | Use | Avoid |
| ----------- | ----------- | ----------- |
| Package mgr | `uv` | pip, poetry, pipenv |
| Formatting | `ruff format` | black, autopep8 |
| Linting | `ruff check` | flake8, pylint |
| Type check | `mypy --strict` | pyright (unless repo uses it) |
| Testing | `pytest` | unittest |
| Security | `bandit`, `pip-audit` | — |
| Web API | FastAPI | Flask (unless existing) |
| CLI | Typer | argparse (unless existing) |

Always use `uv run`, `uv add`, `uv sync`. Never `pip install` in a uv project.

## Shell

- Always open with `set -euo pipefail`.
- Double-quote all variable expansions: `"$var"`, `"${arr[@]}"`.
- Use `jq` / `yq` for structured data — never parse with `awk`/`sed` on JSON/YAML.
- Prefer `command -v` over `which` for existence checks.

## Git

- Commit messages follow Conventional Commits: `type(scope): description`
  - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
  - Subject ≤ 72 characters, imperative mood
  - Add body for non-trivial changes (what + why)
- Default merge: squash + delete branch.
- Branch from `main`, PR to `main`.

## Tool Preferences

| Prefer | Over |
| ------ | ---- |
| `fd` | `find` |
| `rg` | `grep -r` |
| `bat` | `cat` |
| `eza` | `ls` |
| `uv` | `pip` / `poetry` |
| `fnm` | `nvm` |
| `gh` | GitHub web UI |

## Security

- No secrets in output, logs, or commit messages.
- Parameterized queries only — no string interpolation in SQL.
- Validate URLs before outbound requests (SSRF prevention).
- Be aware of OWASP Top 10: injection, broken auth, XSS, insecure deserialization, etc.
- Flag any `eval()`, `shell=True`, `pickle`, `innerHTML =` patterns for review.
