---
name: merge-pr
description: >-
  Merge a pull request once it is genuinely ready. Use when the user asks to
  merge a PR, land a branch, or says a PR looks good to go. Verifies checks are
  green, diagnoses BLOCKED merge states, squash-merges, and syncs local main.
allowed-tools: Bash(gh *), Bash(git *)
---

# Merge a pull request

Merge safely, and only when it is actually ready.

## 1. Establish readiness

`gh pr view --json mergeStateStatus,mergeable,reviewDecision` and `gh pr checks`.

- Checks still running → wait (`gh pr checks --watch`). Do not merge blind.
- Checks failed → use the `fix-ci` skill first. Never merge red.

## 2. If BLOCKED despite green checks

Find out why before forcing anything:

- `gh api repos/{owner}/{repo}/branches/<base>/protection`
- The most frequent cause is **required status-check contexts that do not match
  the actual job names**, so nothing can ever satisfy them. Fix the required
  contexts to the real job names rather than bypassing the rule.
- It may instead need an up-to-date branch (`strict`) or a review.
- **Do not use `--admin` to bypass required reviews or checks unless the user
  explicitly authorises it.** Surface the blocker and let them decide.

## 3. Merge

`gh pr merge <n> --squash --delete-branch`, with a clean Conventional Commits
squash subject and a short body. Squash + delete is the default here.

## 4. Sync local

`git checkout main && git pull --ff-only`, then delete the merged local branch.
Confirm the merged state and report.
