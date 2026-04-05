---
name: delete-branch
description: "Delete local and/or remote branches with explicit confirmation gates"
agent: "GitHub Ops Executor"
argument-hint: "Branch name, local/remote delete scope, and explicit confirmation"
---

# Delete Branch

Preferred custom agent: GitHub Ops Executor.

Delete a branch only after explicit confirmation and safety checks.

${input:details:Provide branch name, delete scope (local/remote/both), and explicit confirmation phrase}

Requirements:

- Detect default branch and block deletion if target matches it.
- Require explicit confirmation phrase before deletion.
- Delete local branch safely first (`-d`), then remote only if requested.
- If branch is unmerged and safe delete fails, stop and ask user before force deletion.

Output format:

1. Safety gate table:

| Target Branch | Is Default Branch | Confirmation Provided | Gate Result |
| ------------- | ----------------- | --------------------- | ----------- |

2. Deletion result table:

| Scope | Command Result | Outcome |
| ----- | -------------- | ------- |

3. Recovery notes:

- Local recovery and remote recovery guidance, if applicable.
