---
name: commit-push
description: "Stage changes, split unrelated diffs into separate commits, push safely, and open a well-formatted PR when needed"
agent: "SWE"
argument-hint: "Optional branch or scope notes"
---

# Commit Push

Preferred custom agent: SWE.

Create one or more high-quality commits from current changes, then push.

${input:context:Optional scope constraints, branch notes, or special commit requirements}

Requirements:

- Inspect current git state first: branch, status, staged vs unstaged, and diff.
- Detect unrelated change groups and split them into separate commits.
- If multiple files appear unrelated, do not force a single commit.
- Keep each commit logically cohesive and minimal.
- Present the proposed grouping plan, then proceed automatically using best judgment unless explicitly instructed to stop.
- Before each commit:
  - Stage only files and hunks relevant to that commit.
  - Generate a commit message from the actual diff.
  - Follow repository commit message standards.
- Determine commit message standards in this order:
  1. Explicit repo config or docs (commitlint, contributing docs, hooks, templates).
  2. Existing commit history conventions.
  3. Fallback to Conventional Commits with type and optional scope.
- After commits are created, push current branch to its upstream automatically.
- If direct push to default branch is rejected by protection rules, create or update a pull request instead of stopping.
- For any PR create/update action, generate body content using this exact markdown structure:

  ```markdown
  ## Summary

  - <concise change 1>
  - <concise change 2>

  ## Validation

  - <check 1>
  - <check 2>

  ## Residual Risks

  - <risk or "None noted">
  ```

- Ensure a blank line exists between each heading and list for consistent rendering.
- Use `gh pr create --body-file <file>` or `gh pr edit --body-file <file>` (never shell-escaped inline multiline body strings) to preserve markdown formatting.
- Never include unrelated temporary files unless explicitly requested.

Grouping guidance:

- Group by intent first, then by file paths.
- Typical separate groups include:
  - docs-only updates
  - prompt/agent/instruction metadata updates
  - code behavior changes
  - tests-only changes
  - tooling/CI configuration updates

Output format:

1. Git state summary table:

| Branch | Staged Files | Unstaged Files | Untracked Files | Ahead/Behind |
| ------ | ------------ | -------------- | --------------- | ------------ |

2. Proposed commit groups table:

| Group | Intent | Files/Hunks Included | Rationale |
| ----- | ------ | -------------------- | --------- |

3. Commits created table:

| Hash | Message | Files Included |
| ---- | ------- | -------------- |

4. Push result table:

| Remote | Branch | Result | Details |
| ------ | ------ | ------ | ------- |

5. PR result table (if PR was created or updated):

| PR | Action | Result | Details |
| -- | ------ | ------ | ------- |

6. Follow-ups (if any changes remain uncommitted)
