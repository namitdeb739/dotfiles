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
5. Push with `git push`. If the branch has no upstream yet, use `git push -u origin HEAD`.
   - If on `main`, confirm with the user before pushing.

Do not amend previous commits. If a pre-commit hook fails, fix the underlying issue and create a new commit.
