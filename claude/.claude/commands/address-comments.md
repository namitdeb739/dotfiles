---
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh api:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*)
description: Fetch and resolve review comments on the current branch's pull request
---

# Address PR Review Comments

Resolve reviewer feedback on the current branch's PR consistently.

1. Find the PR: `gh pr view --json number,url,reviewDecision`.
2. Fetch every comment thread — human reviewers and bots (CodeRabbit, etc.):
   - Inline review comments: `gh api repos/{owner}/{repo}/pulls/<n>/comments`.
   - Review summaries and top-level comments: `gh pr view --json reviews,comments`.
3. For each comment, decide: **implement** or **push back with reasoning**.
   Verify every suggestion against the actual code first — reviewers, especially
   bots, are sometimes wrong. Don't apply a change you can't justify.
4. Make the fixes as a minimal diff, grouped into logical commits
   (Conventional Commits). Don't bundle unrelated cleanup.
5. Reply on each thread with what you changed, or why you disagree. Resolve the
   threads you've addressed (GraphQL `resolveReviewThread`, or leave for the
   author in the UI if the API isn't available).
6. Push. Summarize which comments were addressed and which were deferred/declined
   (with reasons).
