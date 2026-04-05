---
name: create-pr
description: "Create or update a pull request from the current branch with policy-safe defaults"
agent: "GitHub Ops Executor"
argument-hint: "PR context, issue link, and optional base/head overrides"
---

# Create Pull Request

Preferred custom agent: GitHub Ops Executor.

Create a pull request for the current branch using repository conventions.

${input:details:Summarize the change, linked issue, and any title/body requirements}

Requirements:

- Run preflight checks (`gh auth status`, `git status --short --branch`, `gh repo view --json name,defaultBranchRef`).
- Default to base branch `main` and head as the current branch.
- If a PR already exists for the current branch, update it instead of creating a duplicate.
- Build PR markdown in a file and use `--body-file` for create/edit commands.
- Preserve heading/list spacing in markdown body.
- Include issue linkage (`Closes #<number>` or `Related #<number>`) when provided.

Output format:

1. Preflight table:

| Check | Result | Notes |
| ----- | ------ | ----- |

2. PR operation table:

| Action | Base | Head | PR URL/Number | Result |
| ------ | ---- | ---- | ------------- | ------ |

3. Body summary:

| Section | Included | Notes |
| ------- | -------- | ----- |

4. Follow-ups (if needed)
