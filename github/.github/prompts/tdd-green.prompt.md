---
name: tdd-green
description: "Implement the minimal code needed to make red tests pass"
agent: agent
argument-hint: "Failing tests and implementation target"
---

# TDD Green

Preferred custom agent: tdd-green.

Make the current failing tests pass for:

${input:scope:Provide failing test context and target code area}

Requirements:

- Implement the smallest working change set.
- Avoid broad refactors in this phase.
- Re-run tests and report pass status.
