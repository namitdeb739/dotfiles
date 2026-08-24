---
paths:
  - "**/*.py"
  - "**/*.pyi"
  - "**/pyproject.toml"
---

# Python

Always `uv run`, `uv add`, `uv sync`. Never `pip install` in a uv project.

| Concern | Use | Not |
| --- | --- | --- |
| Formatting | `ruff format` | black, autopep8 |
| Linting | `ruff check` | flake8, pylint |
| Types | `mypy --strict` | pyright, unless the repo already uses it |
| Tests | `pytest` | unittest |
| Security | `bandit`, `pip-audit` | — |
| Web API | FastAPI | Flask, unless the repo already uses it |
| CLI | Typer | argparse, unless the repo already uses it |

Formatting is applied automatically by the `format-on-edit.py` PostToolUse
hook, so do not run `ruff format` by hand after an edit.
