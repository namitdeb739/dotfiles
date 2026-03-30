---
description: Detect test framework and run the project's test suite
tools: ['runInTerminal', 'search/codebase']
---

Detect the test framework for this project and run the test suite.

## Detection order
1. Check for `pytest.ini`, `pyproject.toml [tool.pytest]`, or `conftest.py` → run `pytest -v`
2. Check for `package.json` with test script → run `npm test`
3. Check for `go.mod` → run `go test ./...`
4. Check for `Cargo.toml` → run `cargo test`
5. Check for `*.csproj` with test references → run `dotnet test`
6. If none found, report that no test framework was detected

## After running
- Report pass/fail count
- If there are failures, show the failing test names and error messages
- Suggest fixes for any failures if the cause is obvious

$input
