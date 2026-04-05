---
name: merge-pr
description: "Merge a pull request using safe default strategy and report outcome"
agent: "GitHub Ops Executor"
argument-hint: "PR number/URL and optional strategy override"
---

# Merge Pull Request

Preferred custom agent: GitHub Ops Executor.

Merge a pull request with repository-safe defaults.

${input:details:Provide PR number or URL and optional merge strategy override}

Requirements:

- Verify PR state and checks before merging.
- Default merge command: `gh pr merge <pr> --squash --delete-branch`.
- Only use non-default strategies (`--merge`, `--rebase`, `--admin`) when explicitly requested.
- If merge is blocked, report blocker and do not force merge automatically.
- Confirm merged state and resulting commit/URL.

Output format:

1. Pre-merge status table:

| PR | State | Checks | Mergeable | Notes |
| -- | ----- | ------ | --------- | ----- |

2. Merge action table:

| Strategy | Delete Branch | Command Result | Merged PR URL |
| -------- | ------------- | -------------- | ------------- |

3. Post-merge table:

| PR State | Target Branch | Source Branch Status | Notes |
| -------- | ------------- | -------------------- | ----- |

4. Fallback guidance (if merge did not complete)
