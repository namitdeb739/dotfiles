---
name: ship
description: >-
  Commit, push, and optionally open a pull request. Use whenever the user asks
  to commit, stage, push, "ship it", "save this", open a PR, or otherwise get
  finished work into git or onto GitHub. Handles branch creation, Conventional
  Commits messages, upstream setup, and PR body authoring.
allowed-tools: Bash(git *), Bash(gh pr create:*), Bash(gh pr view:*), Bash(gh repo view:*)
---

# Ship

Get the current work committed, pushed, and — when asked — onto a PR.

## Decide the destination first

Read `git status` and `git diff` before anything else. Then:

- **On a feature branch** → commit and push there.
- **On `main`** → check whether that is actually fine. For a personal repo with
  no collaborators and no branch protection, committing straight to `main` is the
  documented workflow and needs no confirmation. Check with
  `gh repo view --json defaultBranchRef,isPrivate` and
  `gh api repos/{owner}/{repo}/branches/main/protection` (a 404 means unprotected).
  If it is protected or shared, branch first:
  `git checkout -b <type>/<short-description>`.

Never ask for confirmation on a non-`main` branch.

## Commit

Stage specific paths. Never `git add -A`, and never stage `.env`, credentials,
or anything matching the deny rules.

Message follows Conventional Commits:

- `type(scope): description` — subject ≤ 72 chars, imperative mood
- types: `feat` `fix` `docs` `style` `refactor` `perf` `test` `build` `ci`
  `chore` `revert`
- body for anything non-trivial: what changed and **why**

Use a heredoc for multi-line messages. Commits are unsigned and
`sandbox.excludedCommands` is empty, so `git commit` runs fully inside the
sandbox with pre-commit hooks. `git -C <dir> commit` works too.

Do not amend. If a pre-commit hook fails, fix the underlying cause and make a
new commit — never `--no-verify`.

## Push

- No upstream yet → `git push -u origin HEAD`
- Otherwise → `git push`

## Pull request — only when asked

`gh pr create --base main`, title mirroring the commit subject, body via
`--body-file`:

```markdown
## Summary
- <what changed and why>

## Test plan
- <how to verify>
```

Output the PR URL and stop. Do not merge — that is the `merge-pr` skill, and it
has its own readiness checks.
