---
name: update-pr
description: "Update pull request metadata and body with markdown-safe body-file flow"
agent: "GitHub Ops Executor"
argument-hint: "PR number/URL and requested updates"
---

# Update Pull Request

Preferred custom agent: GitHub Ops Executor.

Update an existing pull request title/body/metadata.

${input:details:Provide PR number or URL and what should change}

Requirements:

- Resolve and verify target PR first.
- Keep unchanged fields intact unless user asks otherwise.
- Use `gh pr edit` with `--body-file` for markdown body changes.
- If adding labels/assignees/reviewers, avoid removing existing values unless requested.
- Summarize exactly what changed.

Output format:

1. PR target table:

| PR | Current Title | State | URL |
| -- | ------------- | ----- | --- |

2. Changes applied table:

| Field | Previous | Updated | Result |
| ----- | -------- | ------- | ------ |

3. Command result table:

| Command Category | Result | Notes |
| ---------------- | ------ | ----- |

4. Follow-ups (if any)
