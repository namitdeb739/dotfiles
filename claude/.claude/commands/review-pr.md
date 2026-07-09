---
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(gh pr review:*), Bash(gh api:*), Bash(git log:*)
description: Review a GitHub pull request by number
---

# Review a GitHub Pull Request

Review a remote PR: `$ARGUMENTS` (a PR number or URL; default to the current
branch's PR if omitted). For reviewing your own local, uncommitted changes, use
`/full-review` instead.

1. Load context: `gh pr view <n> --json title,body,author,files,additions,deletions`
   and the full diff `gh pr diff <n>`. Read the linked issue/description for intent.
2. Read the surrounding code (not just the diff) where the change interacts with
   existing behavior — a diff alone hides broken callers and assumptions.
3. Review across dimensions, most severe first:
   - **Correctness**: logic errors, edge cases, race conditions, error handling.
   - **Security**: injection, authz, secrets, unsafe deserialization, SSRF.
   - **Design & maintainability**: naming, duplication, unnecessary complexity.
   - **Tests**: do they cover the change and its failure modes?
4. Check CI: `gh pr checks <n>`. Note failing or missing checks.
5. Deliver the review. Prefer inline, line-anchored comments; distinguish
   blocking issues from nits. Submit with `gh pr review <n>`
   (`--approve` / `--comment` / `--request-changes`) — request changes only for
   real blockers. Be concrete: cite `file:line` and suggest the fix.
