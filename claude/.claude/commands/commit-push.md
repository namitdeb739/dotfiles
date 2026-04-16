---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*), Bash(git push:*), Bash(git log:*)
description: Commit and push to remote
---

# Commit and Push

Commit all relevant changes and push to the remote branch:

1. Run `git status` and `git diff` (or `git diff --cached`) to understand the changes.
2. Stage relevant files with `git add`. Prefer specific file paths over `git add -A`. Never stage `.env`, credential files, or secrets.
3. Craft a commit message following **Conventional Commits**:
   - Format: `type(scope): description`
   - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
   - Subject line: ≤ 72 characters, imperative mood ("add" not "added")
   - Add a body for non-trivial changes explaining **what** changed and **why**
4. Commit with `git commit -m "..."` (use a HEREDOC for multi-line messages).
5. Determine the push command intelligently:
   - If the branch has no upstream yet, use `git push -u origin HEAD`.
   - Otherwise, use `git push`.
   - Only ask the user before pushing if the current branch is `main` AND the repo has branch protection or required status checks (check with `gh repo view --json defaultBranchRef` or `git remote -v`). If it's a personal repo with no collaborators or CI gates, push directly.
   - Never ask for confirmation on non-main branches.

Do not amend previous commits. If a pre-commit hook fails, fix the underlying issue and create a new commit.
