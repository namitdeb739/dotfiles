---
allowed-tools: Bash(git checkout:*), Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git push:*), Bash(git commit:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(git log:*), Bash(git branch:*)
description: Commit, push, and open a pull request
---

Commit all staged changes, push to a remote branch, and open a pull request:

1. Run `git status` and `git diff` to understand what will be committed.
2. If not already on a feature branch, create one: `git checkout -b <type>/<short-description>` branching from `main`.
3. Stage files with `git add` (specific paths, never secrets or `.env`).
4. Write a commit message following **Conventional Commits**:
   - Format: `type(scope): description`
   - Subject ≤ 72 characters, imperative mood
   - Add body for non-trivial changes
5. Commit and push: `git push -u origin HEAD`
6. Open a PR with `gh pr create`:
   - Title: mirrors the commit subject
   - Body (use `--body-file`):
     ```
     ## Summary
     - <bullet points of what changed and why>

     ## Test plan
     - <checklist of how to verify the change>
     ```
   - Target branch: `main`
7. Output the PR URL.

Confirm with the user before pushing if the current branch is `main`.
