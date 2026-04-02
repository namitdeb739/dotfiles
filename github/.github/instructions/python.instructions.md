---
name: Python Standards
description: Type hints, docstrings, pytest conventions, PEP 8 for Python files
applyTo: '**/*.py'
---

# Python Conventions

## Type Hints
- Use type hints on all function signatures (parameters and return types)
- Use `from __future__ import annotations` for modern syntax in older Python versions
- Prefer `X | None` over `Optional[X]`, `list[str]` over `List[str]`
- Use `TypeAlias` for complex types

## Docstrings
- Use Google-style docstrings for public functions, classes, and modules
- Include Args, Returns, and Raises sections where applicable
- Skip docstrings for private helpers where the name and type hints are self-documenting

## Imports
- Order: stdlib → third-party → local, with blank lines between groups
- Use absolute imports over relative imports
- Avoid wildcard imports (`from module import *`)

## Testing (pytest)
- Use `pytest` conventions: `test_` prefixed functions, `conftest.py` for shared fixtures
- Prefer fixtures over setup/teardown methods
- Use parametrize for testing multiple inputs
- Use `tmp_path` fixture for file operations, not manual tempfile management
- Mock external dependencies, not internal logic

## Style
- Follow PEP 8, enforced by Ruff
- Max line length: 88 (Black/Ruff default)
- Use f-strings over `.format()` or `%` formatting
- Use pathlib.Path over os.path for file operations
- Use dataclasses or Pydantic models over plain dicts for structured data
- Use context managers (`with`) for resource management
