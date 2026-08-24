---
name: uv-python-quality
description: Use before finishing any turn that edited Python in a uv project (one with a pyproject.toml). Gives the exact uv run invocations for pytest, mypy, ruff, bandit and pip-audit and their pass criteria, so the checks are run proactively instead of after the verify-python.py Stop hook blocks the turn.
---

# uv Python quality gate

The `verify-python.py` **Stop** hook blocks the end of any turn where a `.py`
file changed in a project with a `pyproject.toml` and the checks do not pass.
Run these *before* finishing, not after being blocked — that is the whole point
of this skill.

## Run in this order

```sh
uv run ruff check --fix        # lint; --fix handles the mechanical findings
uv run mypy --strict .         # types; the hook runs exactly this
uv run pytest -q --no-header   # tests; the hook runs exactly this
```

`ruff format` is **not** in the list — `format-on-edit.py` already applied it as
a PostToolUse hook. Running it by hand is redundant.

## Pass criteria (these match the hook exactly)

| Check | Passes when | Note |
| --- | --- | --- |
| `pytest` | exit 0, **or exit 5** | 5 = no tests collected, treated as OK |
| `mypy --strict` | exit 0 | only run if `[tool.mypy]` is in pyproject.toml |
| `ruff check` | exit 0 | |

The hook only runs a tool the project opted into (`[tool.pytest]` or a `tests/`
directory; `[tool.mypy]`) *and* that is actually runnable. If `uv` is missing or
a check times out at 240s, the hook passes — but the code is still unverified,
so say so rather than claiming it passed.

## Security checks

Not run by the Stop hook. Run them when touching dependencies, subprocess calls,
deserialization, or anything network-facing:

```sh
uv run bandit -r <pkg> -q
uv run pip-audit
uv run semgrep --config auto --error
```

## Rules

- Always `uv run`, `uv add`, `uv sync`. Never `pip install` in a uv project.
- Never `--no-verify` a commit to get past a failing check.
- If a check fails for a reason unrelated to the change, say so explicitly
  rather than silently skipping it.
