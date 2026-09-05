---
name: fix-ci
description: >-
  Triage and fix a failing GitHub Actions / CI run. Use when checks are red, a
  build or workflow failed, a PR is blocked on checks, or the user mentions CI
  failing, a broken pipeline, or a failed run. Distinguishes infrastructure
  flakes from genuine code failures before touching anything.
allowed-tools: Bash(gh *), Bash(git *), Bash(just *), Bash(uv *)
---

# Fix failing CI

**Read the actual logs before proposing any fix.** Never guess from the job name.

## 1. Identify the failing run

`gh pr checks` for a PR, or `gh run list --branch <branch> --limit 5`. Note
exactly which jobs failed.

## 2. Rule out infrastructure before touching code

This step exists because editing code to fix a runner outage wastes a whole
cycle and pollutes the diff.

- Inspect a failed job: `gh api repos/{owner}/{repo}/actions/jobs/<job-id>`.
  If `conclusion` is `cancelled`, `runner` is empty, and `steps` is `[]`, then
  no code ran — that is a queue or runner problem, not your change.
- Uniform, abnormally long durations across unrelated jobs are the same tell.
- Check <https://www.githubstatus.com> for an active Actions incident.
- If infra is the cause, **re-run instead of editing**:
  `gh run rerun <run-id>` or `gh run rerun <run-id> --failed`.

## 3. Read the real error

`gh run view --job=<job-id> --log`, then search for `error`, `Traceback`,
`FAIL`, `-->`. Quote the actual failing step. Do not infer it.

## 4. Reproduce locally

Run the same lint/test/build command locally before editing. CI often differs —
newer Python, fresh cache, different OS, different dependency resolution. When
you find environment drift, align or pin it rather than masking the symptom.

## 5. Fix, then confirm

- Minimal diff at the root cause.
- Commit with Conventional Commits and push; CI re-runs on push. If no code
  needed changing, `gh run rerun` instead.
- Watch the new run (`gh pr checks --watch`) and confirm green.
- Report what failed, what fixed it, and whether it was infra or code.
