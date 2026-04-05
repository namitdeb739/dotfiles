---
name: update-issue
description: "Update issue metadata or body while preserving unchanged fields"
agent: "GitHub Ops Executor"
argument-hint: "Issue number/URL and requested updates"
---

# Update Issue

Preferred custom agent: GitHub Ops Executor.

Update an existing issue with minimal, explicit field changes.

${input:details:Provide issue number/URL and required updates (title/body/type/labels/assignees/state)}

Requirements:

- Resolve target issue first and capture current values.
- Modify only fields requested by the user.
- Preserve existing metadata when no change is requested.
- Use a body-file workflow for markdown body edits.
- Return updated issue URL and a concise diff summary.

Output format:

1. Issue target table:

| Issue | Current State | Current Title | URL |
| ----- | ------------- | ------------- | --- |

2. Applied changes table:

| Field | Previous | Updated | Result |
| ----- | -------- | ------- | ------ |

3. Command result table:

| Command Category | Result | Notes |
| ---------------- | ------ | ----- |

4. Follow-ups (if any)
