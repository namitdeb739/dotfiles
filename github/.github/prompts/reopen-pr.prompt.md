---
name: reopen-pr
description: "Reopen a closed pull request and verify updated state"
agent: "GitHub Ops Executor"
argument-hint: "PR number/URL to reopen"
---

# Reopen Pull Request

Preferred custom agent: GitHub Ops Executor.

Reopen a closed pull request.

${input:details:Provide PR number or URL and any context for reopening}

Requirements:

- Verify PR is currently closed.
- Reopen with `gh pr reopen`.
- Report updated state and URL.
- If reopen fails due to repository policy, report blocker clearly.

Output format:

1. Target table:

| PR | Prior State | URL |
| -- | ----------- | --- |

2. Reopen result table:

| Action | Final State | Result | Notes |
| ------ | ----------- | ------ | ----- |

3. Follow-ups (if needed)
