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

1. Executive summary (3-5 bullets):

- What is being decided
- What is most likely true
- Why it matters now

2. Problem framing (bullet list)
3. Relevant files/components table:

| File/Component | Files Affected | Why It Matters | Confidence |
| -------------- | -------------- | -------------- | ---------- |

4. Key findings table (ordered by impact):

| Finding | Files Affected | Evidence | Impact |
| ------- | -------------- | -------- | ------ |

5. Risks and constraints (bullet list)
6. Open questions (bullet list)
7. Recommended direction (numbered list, 3-6 items)

8. Final user-visible summary (mandatory):

- Top 3 findings (bullets)
- Recommendation verdict (single line)
- 2-4 practical next steps (numbered list)
