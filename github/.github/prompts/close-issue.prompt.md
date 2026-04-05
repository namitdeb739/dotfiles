---
name: close-issue
description: "Close an issue with optional closure context"
agent: "GitHub Ops Executor"
argument-hint: "Issue number/URL and optional close reason"
---

# Close Issue

Preferred custom agent: GitHub Ops Executor.

Close an open issue.

${input:details:Provide issue number/URL and optional close reason/comment}

Requirements:

- Verify issue exists and is open.
- If provided, add closure context comment.
- Close with the minimal required command path.
- Return final state and URL.

Output format:

1. Target table:

| Issue | Prior State | URL |
| ----- | ----------- | --- |

2. Close result table:

| Action | Comment Added | Final State | Result |
| ------ | ------------- | ----------- | ------ |

3. Follow-ups (if needed)
