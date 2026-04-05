---
description: 'Policy and safety defaults for GitHub pull request, issue, and branch lifecycle operations in this repository.'
applyTo: 'github/.github/prompts/*-pr.prompt.md,github/.github/prompts/*-issue.prompt.md,github/.github/prompts/*-branch.prompt.md,github/.github/agents/github-ops-executor.agent.md'
---

# GitHub Operations Policy

Use these rules for PR, issue, and branch operations.

## Branch Strategy

- Create working branches from `main`.
- Target pull requests to `main`.
- Use short-lived, descriptive branch names with a clear prefix (`feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`).

## PR Defaults

- Generate PR markdown body using a file-based workflow.
- Use `gh pr create --body-file <path>` and `gh pr edit --body-file <path>`.
- Default merge strategy is `gh pr merge --squash --delete-branch`.
- Use `--admin` merge only when explicitly requested by the user.

## Issue Defaults

- Prefer issue types over labels when types are available.
- Discover issue types using `gh api graphql` when org context is available.
- Fall back to labels if types cannot be discovered or are unavailable.
- Include structured content in issue body (context, expected behavior/outcome, acceptance criteria).

## Safety Gates

- Require explicit confirmation before destructive operations:
  - `gh issue delete`
  - remote branch deletion (`git push origin --delete ...`)
  - force pushes or force branch updates
- Never delete the default branch.
- If command outcome is ambiguous, fail closed and ask for confirmation.

## Required Preflight Checks

Run and evaluate before write operations:

```bash
gh auth status
git status --short --branch
gh repo view --json name,defaultBranchRef
```

## Output Requirements

Every operation response should include:

- The action performed.
- The target entity (PR number, issue number, branch name).
- Result link or identifier.
- Any rollback or follow-up guidance.
