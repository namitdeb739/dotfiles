---
allowed-tools: Bash(gh pr view:*), Bash(gh pr checks:*), Bash(gh pr merge:*), Bash(gh api:*), Bash(git checkout:*), Bash(git pull:*), Bash(git branch:*)
description: Merge a pull request once it is genuinely ready
---

# Merge a Pull Request

Merge a PR safely, only when it is actually ready.

1. Check status: `gh pr view --json mergeStateStatus,mergeable,reviewDecision`
   and `gh pr checks`.
2. Require green checks. If checks are still running, wait
   (`gh pr checks --watch`) rather than merging blind. If checks *failed*, use
   `/fix-ci` first — don't merge red.
3. If `mergeStateStatus` is `BLOCKED` even though checks pass, find out why before
   forcing anything:
   - Inspect protection: `gh api repos/{owner}/{repo}/branches/<base>/protection`.
     A frequent cause is **required status-check contexts that don't match the
     actual job names**, so nothing ever satisfies them. Fix the required contexts
     to the real ones rather than bypassing.
   - It may also need an up-to-date branch (`strict`) or a review.
   - **Do not use `--admin` to bypass required review/checks unless the user
     explicitly authorizes it** — surface the blocker and let them decide.
4. Merge with squash + delete the branch (the user's default):
   `gh pr merge <n> --squash --delete-branch`, with a clean Conventional-Commits
   squash subject and a short summary body.
5. Sync local: `git checkout main && git pull --ff-only`, then delete the merged
   local branch.
6. Confirm the merged state and report.
