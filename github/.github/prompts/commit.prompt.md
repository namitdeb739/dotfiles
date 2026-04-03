---
description: Stage, commit, and push with AI-generated Conventional Commit messages
tools: ['execute', 'read', 'search']
model: ['GPT-5.3 Codex High']
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

## 4. Optional follow-up actions

Offer these follow-up actions after a successful push:

- **Create PR**: run `/pr`
- **Visualize**: `git log --oneline --graph -10`

## Notes

- `pre-commit` hooks may reject the commit — if they fail, fix the reported issue, re-stage, and commit again (do NOT use `--no-verify` unless the user explicitly requests it)
- If the user provides a commit message in the input, use that instead of generating one

$input
