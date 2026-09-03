---
allowed-tools: Bash(git checkout:*), Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git push:*), Bash(git commit:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(git log:*), Bash(git branch:*)
description: Commit, push, and open a pull request
disable-model-invocation: true
---

# Commit, Push, and Open a Pull Request

Commit all staged changes, push to a remote branch, and open a pull request:

1. Run `git status` and `git diff` to understand what will be committed.
2. If not already on a feature branch, create one: `git checkout -b <type>/<short-description>` branching from `main`.
3. Stage files with `git add` (specific paths, never secrets or `.env`).
4. Write a commit message following **Conventional Commits**:
   - Format: `type(scope): description`
   - Subject ≤ 72 characters, imperative mood
   - Add body for non-trivial changes
5. Commit, then push: `git commit` as its own call, then `git push -u origin HEAD` as
   another. **Issue `git commit` bare and alone** — no `git -C <dir>` prefix, and never
   chained behind `git add ... &&`. Commits are SSH-signed, and the sandbox denies both
   `~/.ssh` and the ssh-agent socket, so signing works only because `git commit *` is in
   `sandbox.excludedCommands`. That pattern is a *prefix* match with a trailing wildcard:
   `git -C <dir> commit ...` and `git add x && git commit ...` both miss it, run
   sandboxed, and fail with `Couldn't load public key` then `failed to write commit
   object`.
6. Open a PR with `gh pr create`:
   - Title: mirrors the commit subject
   - Body (use `--body-file`):

     ```markdown
     ## Summary
     - <bullet points of what changed and why>

     ## Test plan
     - <checklist of how to verify the change>
     ```

   - Target branch: `main`
7. Output the PR URL.

Confirm with the user before pushing if the current branch is `main`.
