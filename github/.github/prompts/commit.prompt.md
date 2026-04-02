---
description: Stage, commit, and optionally push using GitKraken CLI for AI messages and issue linking
tools: ['execute', 'read', 'search']
---

Create a commit for the current changes using GitKraken CLI (`gk`) when available, with fallback to plain git.

## 0. Check Problems panel

- Read the VS Code Problems panel (`read/problems`) for errors and warnings
- If there are any **errors**, warn the user before proceeding — a broken commit may fail CI or `pre-commit` hooks
- If only warnings, proceed but mention them in the commit notes

## 1. Assess state

- Run `git status` and `git diff --staged` to see what's changed
- Check if inside a `gk` work item: `gk work info`
- If nothing is staged, stage all modified/new files with `git add -A`

## 2. Generate commit message

**If `gk` is available**, use AI-generated commit message:
```
gk ai commit -d
```
This stages, generates a Conventional Commit message from the diff via GitKraken AI, and commits — all in one step. Review the proposed message before confirming.

**Fallback** (no `gk` or user prefers manual):
- Analyze the diff and generate a message following Conventional Commits:
  - Format: `type(scope): description`
  - Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
  - Subject: imperative mood, under 72 chars, no period
  - Add a body if the change is non-trivial (explain what and why)
- Run `git commit -m "message"`

## 3. Post-commit (optional, based on user input)

Offer these follow-up actions after a successful commit:

- **Push**: `gk work push` (pushes all repos in active work item) or `git push`
- **Push + create PR**: `gk work push --create-pr` (pushes and opens PR in one step)
- **AI PR**: `gk work pr create --ai` (AI-generated PR title and body from changes)
- **Visualize**: `gk graph` (terminal commit graph) or `gk graph --gitkraken` (open in GitKraken Desktop)

## Notes

- If a `gk` work item is active (`gk work info` succeeds), prefer `gk work commit --ai` over `gk ai commit` — it commits across all linked repos in the work item
- To link an issue before committing: `gk work start -i <ISSUE-KEY>` (creates work item + branch from Jira/GitHub/GitLab issue)
- `gk ai commit -d` adds an AI-generated description body; without `-d` it generates subject line only
- Use `-f` / `--force` flag to skip confirmation prompts if the user requests it
- `pre-commit` hooks may reject the commit — if they fail, fix the reported issue, re-stage, and commit again (do NOT use `--no-verify` unless the user explicitly requests it)

$input
