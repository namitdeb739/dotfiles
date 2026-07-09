---
allowed-tools: Bash(git fetch:*), Bash(git status:*), Bash(git branch:*), Bash(git rebase:*), Bash(git merge:*), Bash(git push:*), Bash(git log:*), Bash(git diff:*)
description: Update the current feature branch with the latest base branch
---

# Sync Branch with Base

Bring the current feature branch up to date with `main` (or the PR base).

1. Run `git status`. If the tree is dirty, stop — commit or stash first.
2. `git fetch origin`. Show how far behind/ahead the branch is
   (`git log --oneline --left-right origin/main...HEAD`).
3. Rebase onto the base by default: `git rebase origin/main`. (Use `git merge`
   instead only if the user prefers merge commits or the branch is shared.)
4. If there are conflicts, resolve them file by file — understand both sides
   before choosing; don't blindly accept one. Re-run `git rebase --continue`.
5. Run the project's checks (lint + type + test) after resolving, to confirm the
   integration didn't break anything.
6. Push. After a rebase, use `git push --force-with-lease` (never plain
   `--force`). Report the new state.
