---
description: Run tests, check diagnostics, and report project health
tools: ['execute', 'read', 'search']
---

Run the project's test suite and check for outstanding issues.

## 1. Run tests

Detect the test framework and run:
1. Check for `pytest.ini`, `pyproject.toml [tool.pytest]`, or `conftest.py` → run `pytest -v`
2. Check for `package.json` with test script → run `npm test`
3. Check for `go.mod` → run `go test ./...`
4. Check for `Cargo.toml` → run `cargo test`
5. Check for `*.csproj` with test references → run `dotnet test`
6. If none found, report that no test framework was detected

## 2. Check diagnostics

- Read the VS Code Problems panel (`read/problems`) for errors/warnings from linters and Error Lens
- Check for any failing test details via `execute/testFailure` if available
- Scan for TODO/FIXME comments in changed files (`search/textSearch` for `TODO|FIXME|HACK|XXX`)

## 3. Report

- Test pass/fail count
- Outstanding Problems panel errors/warnings (if any)
- TODO/FIXME items in recently changed files
- Suggest fixes for any failures if the cause is obvious

$input
