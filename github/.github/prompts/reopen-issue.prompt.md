---
name: reopen-issue
description: "Reopen a closed issue and verify state transition"
agent: "GitHub Ops Executor"
argument-hint: "Issue number/URL to reopen"
---

# Reopen Issue

Preferred custom agent: GitHub Ops Executor.

Reopen a closed issue.

${input:details:Provide issue number/URL and optional reopen rationale}

Requirements:

- Verify issue is currently closed.
- Reopen and confirm final state is open.
- Return issue URL and reopen result.

Output format:

1. Target table:

| Issue | Prior State | URL |
| ----- | ----------- | --- |

2. Reopen result table:

| Action | Final State | Result | Notes |
| ------ | ----------- | ------ | ----- |

3. Follow-ups (if needed)
