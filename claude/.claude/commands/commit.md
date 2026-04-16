---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*)
description: Create a git commit
---

Create a thoughtful git commit following these steps:

1. Run `git status` to see what files have changed.
2. Run `git diff` (or `git diff --cached`) to understand the changes in detail.
3. Stage relevant files with `git add`. Prefer specific file paths over `git add -A`. Never stage `.env`, credential files, or secrets.
4. Craft a commit message following **Conventional Commits**:
   - Format: `type(scope): description`
   - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
   - Subject line: ≤ 72 characters, imperative mood ("add" not "added")
   - Add a body for non-trivial changes explaining **what** changed and **why**
5. Commit with `git commit -m "..."` (use a HEREDOC for multi-line messages).

Do not amend previous commits. If a pre-commit hook fails, fix the underlying issue and create a new commit.
