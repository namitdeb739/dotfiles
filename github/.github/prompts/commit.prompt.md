---
description: Stage, commit, and push with AI-generated Conventional Commit messages
tools: ["execute", "read", "search", "io.github.github/github-mcp-server/*"]
model: ["GPT-5.3 Codex High"]
---

Create a commit for the current changes.

## 0. Pre-flight

- Read the VS Code Problems panel (`read/problems`) for errors and warnings
- If there are any **errors**, warn the user before proceeding
- If only warnings, proceed but mention them

## 1. Assess state

- Run `git status` and `git diff --staged` to see what's changed
- If nothing is staged, stage all modified/new files with `git add -A`

## 2. Generate commit message and commit

Analyze the staged diff and generate a Conventional Commit message:

- Format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
- Subject: imperative mood, under 72 chars, no period
- Add a body if the change is non-trivial (explain what and why)

Then commit with `git commit -m "message"`.

**Important**: Do NOT use `gk ai commit` or any interactive CLI commands — they require y/n confirmation prompts that cannot be answered in agent mode. Always use `git commit -m` directly.

## 3. Push after commit (default behavior)

After a successful commit, push immediately:

- First try `git push`
- If the branch has no upstream, run `git push -u origin HEAD`

If push fails, report the error and stop.

## 4. CI/CD checks after push (default behavior)

After a successful push, check whether CI/CD ran for the pushed commit.

- Determine:
	- `branch=$(git rev-parse --abbrev-ref HEAD)`
	- `sha=$(git rev-parse HEAD)`
- If `gh` is not available (`command -v gh` fails), say so and skip CI/CD polling.
- If `gh` is available, try to find the newest GitHub Actions run for this branch whose `headSha` matches `sha`:
	- Use `gh run list --branch "$branch" --limit 20 --json databaseId,headSha,status,conclusion,workflowName,htmlURL,createdAt,event`
	- Select the first run where `headSha == sha` (prefer `event == "push"` when multiple match).
- If no matching run is found, report: “No CI/CD workflow run detected for this push” and continue.

### Polling strategy

If a matching run is found, poll its status at decreasing frequency (short intervals first, then longer):

- Poll via `gh run view <run_id> --json status,conclusion,htmlURL,workflowName,headSha`
- Use a schedule like: 5s, 5s, 10s, 10s, 20s, 30s, 45s, 60s, 90s, 120s (repeat 120s thereafter)
- Stop polling when `status == "completed"`, or after ~20 minutes and report a timeout.

Run this non-interactive polling snippet (it reports pass/fail/timeout without failing the command):

```bash
python3 - <<'PY'
import json
import subprocess
import sys
import time


def sh(cmd: list[str]) -> str:
	return subprocess.check_output(cmd, text=True).strip()


branch = sh(["git", "rev-parse", "--abbrev-ref", "HEAD"])
sha = sh(["git", "rev-parse", "HEAD"])

try:
	subprocess.check_output(["gh", "--version"], text=True)
except Exception:
	print("CI/CD: `gh` not available; skipping workflow polling.")
	raise SystemExit(0)

runs_raw = subprocess.check_output(
	[
		"gh",
		"run",
		"list",
		"--branch",
		branch,
		"--limit",
		"20",
		"--json",
		"databaseId,headSha,status,conclusion,workflowName,htmlURL,createdAt,event",
	],
	text=True,
)
runs = json.loads(runs_raw or "[]")

matches = [r for r in runs if r.get("headSha") == sha]
if not matches:
	print(f"CI/CD: no workflow run detected for {branch}@{sha[:7]} (skipping).")
	raise SystemExit(0)

# `gh run list` returns newest-first; prefer a push-triggered run when multiple match.
run = next((r for r in matches if r.get("event") == "push"), matches[0])
run_id = str(run["databaseId"])
run_url = run.get("htmlURL") or "(no url)"
workflow = run.get("workflowName") or "(workflow)"

print(f"CI/CD: watching {workflow} — {run_url}")

schedule_seconds = [5, 5, 10, 10, 20, 30, 45, 60, 90, 120]
deadline = time.time() + (20 * 60)
poll_index = 0

while True:
	view_raw = subprocess.check_output(
		["gh", "run", "view", run_id, "--json", "status,conclusion,htmlURL,workflowName"],
		text=True,
	)
	view = json.loads(view_raw or "{}")
	status = view.get("status")
	conclusion = view.get("conclusion")
	view_url = view.get("htmlURL") or run_url
	view_workflow = view.get("workflowName") or workflow

	if status == "completed":
		if conclusion == "success":
			print(f"CI/CD PASSED: {view_workflow} — {view_url}")
			raise SystemExit(0)

		print(
			"CI/CD FAILED: "
			f"{view_workflow} — conclusion={conclusion or 'unknown'} — {view_url}"
		)
		raise SystemExit(0)

	if time.time() >= deadline:
		print(f"CI/CD TIMEOUT: {view_workflow} still {status!r}. Check: {view_url}")
		raise SystemExit(0)

	sleep_for = (
		schedule_seconds[poll_index]
		if poll_index < len(schedule_seconds)
		else schedule_seconds[-1]
	)
	poll_index += 1
	time.sleep(sleep_for)
PY
```

### Reporting

- Always print the workflow name and run URL.
- If the run completes with success (`conclusion == "success"`), report that CI/CD passed.
- If it completes with any other conclusion (failure/cancelled/timed_out/etc.), report that CI/CD failed and summarize:
	- conclusion
	- run URL
	- next action suggestion: call `/review` (or your review agent) to address CI failures.

If the polling snippet prints `CI/CD FAILED` or `CI/CD TIMEOUT`, stop after reporting (do not proceed to other follow-ups).

## 5. Optional follow-up actions

Offer these follow-up actions after a successful push:

- **Create PR**: run `/pr`
- **Visualize**: `git log --oneline --graph -10`

## Notes

- `pre-commit` hooks may reject the commit — if they fail, fix the reported issue, re-stage, and commit again (do NOT use `--no-verify` unless the user explicitly requests it)
- If the user provides a commit message in the input, use that instead of generating one

$input
