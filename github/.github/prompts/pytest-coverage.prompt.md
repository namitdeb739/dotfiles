---
name: pytest-coverage
description: "Increase pytest coverage with targeted tests for uncovered lines"
agent: "Polyglot Test Generator"
argument-hint: "Module or package to improve coverage for"
---

# Pytest Coverage

Preferred custom agent: Polyglot Test Generator.

Improve coverage for this target:

${input:target:Module, package, or test scope}

Requirements:

- Use the pytest-coverage skill workflow.
- Generate coverage output and identify uncovered lines before writing tests.
- Add minimal, maintainable tests that match repository patterns.
- Re-run tests and coverage after each test batch.

Output format:

1. Scope and baseline coverage
2. Uncovered areas found
3. Tests added or updated
4. Final coverage results
5. Remaining gaps
