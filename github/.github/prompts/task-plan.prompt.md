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
- Always present the final plan directly to the user in-chat using the format below (do not only write planning files).
- Use concise bullets for narrative sections and markdown tables for operational sections.

Output format:

1. Objective
2. Constraints
3. Step-by-step plan table:

| Phase | Step | Files Affected | Dependency | Outcome |
| ----- | ---- | -------------- | ---------- | ------- |

4. Verification gates table:

| Phase | Verification Gate | Files Affected | Command/Method | Pass Criteria |
| ----- | ----------------- | -------------- | -------------- | ------------- |

5. Rollback/fallback strategy table:

| Trigger | Files Affected | Fallback Action | Recovery Verification |
| ------- | -------------- | --------------- | --------------------- |

6. Final user-visible summary (mandatory):

- Brief readiness verdict (ready/not-ready to implement).
- 3-5 bullets highlighting key sequencing decisions.
- Explicit request for implementation approval.
