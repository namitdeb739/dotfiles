---
name: delete-issue
description: "Delete an issue only after explicit confirmation"
agent: "GitHub Ops Executor"
argument-hint: "Issue number/URL and explicit confirmation text"
---

# Delete Issue

Preferred custom agent: GitHub Ops Executor.

Delete an issue only when explicitly authorized.

${input:details:Provide issue number/URL and explicit confirmation phrase}

Requirements:

- Require exact confirmation phrase before deletion.
- Verify target issue identity before execution.
- Use a non-interactive delete command only after confirmation.
- If confirmation is missing or ambiguous, stop and report no action.

Output format:

1. Confirmation gate table:

| Issue | Confirmation Provided | Gate Result |
| ----- | --------------------- | ----------- |

2. Delete action table:

| Action | Command Result | Outcome |
| ------ | -------------- | ------- |

3. Recovery notes:

- State whether restoration is possible (for example, reopen not possible after hard delete).
