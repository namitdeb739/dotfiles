---
name: task-plan
description: "Convert researched context into an actionable execution plan"
agent: agent
argument-hint: "Task details or research notes"
---

# Task Plan

Preferred custom agent: task-planner.

Create an execution plan for:

${input:task:Task details, issue context, or research summary}

Requirements:

- Break work into ordered, atomic steps.
- Include dependencies and sequencing constraints.
- Include test/verification gates per phase.

Output format:

1. Objective
2. Constraints
3. Step-by-step plan
4. Verification gates
5. Rollback/fallback strategy
