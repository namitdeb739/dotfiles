---
name: sync-branch
description: "Sync a working branch with latest main and report conflicts"
agent: "GitHub Ops Executor"
argument-hint: "Branch name and preferred sync strategy (rebase or merge)"
---

# Sync Branch

Preferred custom agent: GitHub Ops Executor.

Sync a working branch with latest `main`.

${input:details:Provide target branch and optional strategy override}

Requirements:

- Verify target branch exists.
- Default strategy: rebase branch onto `origin/main`.
- If user requests merge strategy, use merge from `origin/main`.
- If conflicts occur, stop, report conflicted files, and avoid silent conflict resolution.

Output format:

1. Pre-sync table:

| Branch | Strategy | Base Reference | Clean Working Tree |
| ------ | -------- | -------------- | ------------------ |

2. Sync result table:

| Command Path | Result | Conflicts | Notes |
| ------------ | ------ | --------- | ----- |

3. Next actions:

- If successful: push guidance.
- If conflicted: explicit conflict-resolution follow-up.
