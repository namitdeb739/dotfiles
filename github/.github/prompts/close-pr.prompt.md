---
name: close-pr
description: "Close a pull request with optional context comment"
agent: "GitHub Ops Executor"
argument-hint: "PR number/URL and optional close reason"
---

# Close Pull Request

Preferred custom agent: GitHub Ops Executor.

Close a pull request without merging.

${input:details:Provide PR number or URL and optional close reason/comment}

Requirements:

- Verify target PR exists and is open.
- If a reason is provided, include it via `gh pr close --comment`.
- Do not delete branches unless explicitly requested in a separate operation.
- Return final state and URL.

Output format:

1. Target table:

| PR | Current State | URL |
| -- | ------------- | --- |

2. Close result table:

| Action | Comment Added | Final State | Result |
| ------ | ------------- | ----------- | ------ |

3. Follow-ups (if any)
