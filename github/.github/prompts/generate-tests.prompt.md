---
name: generate-tests
description: "Generate practical tests using the polyglot test pipeline"
agent: agent
argument-hint: "Code area to test and test goals"
---

# Generate Tests

Preferred custom agent: polyglot-test-generator.

Generate tests for this scope:

${input:scope:Files, module, or feature to test}

Requirements:

- Use repository testing conventions and existing patterns.
- Cover happy path, edge cases, and error paths.
- Ensure generated tests compile and run.

Output format:

1. Scope and assumptions
2. Test plan summary
3. Generated test files
4. Build/test results
5. Remaining gaps
