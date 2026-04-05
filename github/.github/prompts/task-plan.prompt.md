---
name: task-plan
description: "Convert researched context into an actionable execution plan"
agent: "Task Planner Instructions"
argument-hint: "Task details or research notes"
---

# Task Plan

Preferred custom agent: Task Planner Instructions.

Create an execution plan for:

${input:task:Task details, issue context, or research summary}

Requirements:

- Break work into ordered, atomic steps.
- Include dependencies and sequencing constraints.
- Include test/verification gates per phase.

Output format:

1. Objective
2. Constraints
3. Step-by-step plan table:

| Phase | Step | Dependency | Outcome |
| ----- | ---- | ---------- | ------- |

4. Verification gates table:

| Phase | Verification Gate | Command/Method | Pass Criteria |
| ----- | ----------------- | -------------- | ------------- |

5. Rollback/fallback strategy table:

| Trigger | Fallback Action | Recovery Verification |
| ------- | --------------- | --------------------- |
