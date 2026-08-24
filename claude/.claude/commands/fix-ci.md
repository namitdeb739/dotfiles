---
allowed-tools: Bash(gh run list:*), Bash(gh run view:*), Bash(gh run rerun:*), Bash(gh pr checks:*), Bash(gh pr view:*), Bash(gh api:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*)
description: Triage and fix a failing GitHub Actions / CI run
---

# Fix Failing CI

Diagnose and fix a failing GitHub Actions run. **Read the actual logs before
proposing any fix** — never guess from the job name.

1. Identify the failing run: `gh pr checks` (for a PR) or
   `gh run list --branch <branch> --limit 5`. Note exactly which jobs failed.
2. **Rule out infrastructure before touching code:**
   - Inspect a failed job: `gh api repos/{owner}/{repo}/actions/jobs/<job-id>`.
     If `conclusion` is `cancelled`, `runner` is empty, and `steps` is `[]`, no
     code ran — it's a queue/runner problem, not your change. Uniform, abnormally
     long durations across jobs are the same tell.
   - Check <https://www.githubstatus.com> for an active Actions incident.
   - If infra is the cause, **re-run rather than edit code**:
     `gh run rerun <run-id>` (or `gh run rerun <run-id> --failed`).
3. For genuine failures, read the real error:
   `gh run view --job=<job-id> --log` and grep for `error`/`Traceback`/`FAIL`/`-->`.
   Quote the actual failing step; don't infer.
4. Reproduce locally where possible (run the same lint/test/build command) before
   editing — CI often differs from local (newer Python/dependency, fresh cache,
   different OS). Watch for that environment drift and align/pin rather than mask it.
5. Fix the root cause with a minimal diff.
6. Commit (Conventional Commits) and push — CI re-runs on push. If nothing changed
   in code, `gh run rerun` instead.
7. Watch the new run (`gh pr checks --watch`, or poll) and confirm green. Report
   what failed and what fixed it (and whether it was infra vs. code).
