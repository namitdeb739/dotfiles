---
name: research-task
description: "Research a task deeply and summarize findings before planning or coding"
agent: "Task Researcher Instructions"
argument-hint: "Task or problem statement to research"
---

# Research Task

Preferred custom agent: Task Researcher Instructions.

Research this task comprehensively before implementation:

${input:task:Describe the task, problem, or decision to research}

Requirements:

- Identify affected areas, dependencies, and constraints.
- Highlight unknowns and competing approaches.
- Keep recommendations grounded in repository context.
- Always present the final findings directly to the user in-chat using structured bullets/tables (do not only write research files).

Output format:

1. Problem framing (bullet list)
2. Relevant files/components table:

| File/Component | Files Affected | Why It Matters | Confidence |
| -------------- | -------------- | -------------- | ---------- |

3. Key findings table:

| Finding | Files Affected | Evidence | Impact |
| ------- | -------------- | -------- | ------ |

4. Open questions (bullet list)
5. Recommended direction (bullet list)

6. Final user-visible summary (mandatory):

- Top 3 findings (bullets)
- Recommendation verdict (single line)
- 2-4 practical next steps (bullets)
