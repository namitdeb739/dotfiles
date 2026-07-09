---
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git log:*), Bash(git diff:*), Bash(git push:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(gh pr edit:*)
description: Open (or update) a pull request for the current branch's committed work
---

# Open a Pull Request

Open a PR for work that is **already committed** on the current branch. To also
commit and push in one step, use `/commit-push-pr` instead.

1. Run `git status`. If there are uncommitted changes, stop and tell the user to
   commit first (or use `/commit-push-pr`) — don't silently include them.
2. Determine the branch. If on `main`, stop: a PR needs a feature branch. Offer
   to move the commits onto `<type>/<short-description>` branched from `main`.
3. Ensure the branch has an upstream and is pushed: `git push -u origin HEAD`.
4. If a PR already exists for the branch (`gh pr view`), update its title/body
   with `gh pr edit` rather than creating a duplicate.
5. Review the **whole** branch diff against the base (`git log --oneline main..HEAD`,
   `git diff main...HEAD`) so the description covers every commit, not just the last.
6. Create the PR with `gh pr create --base main` (add `--draft` if incomplete):
   - Title: Conventional-Commits style, mirroring the primary change (≤ 72 chars).
   - Body via `--body-file`:

     ```markdown
     ## Summary
     - <what changed and why>

     ## Test plan
     - <how it was verified>
     ```

7. Output the PR URL.
