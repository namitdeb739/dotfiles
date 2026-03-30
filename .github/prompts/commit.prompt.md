---
description: Stage changes, generate a conventional commit message, and commit
tools: ['runInTerminal']
---

Create a commit for the current changes.

1. Run `git status` and `git diff --staged` to see what's changed
2. If nothing is staged, stage all modified/new files with `git add -A`
3. Analyze the changes and generate a commit message following Conventional Commits:
   - Format: `type(scope): description`
   - Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
   - Subject: imperative mood, under 72 chars, no period
   - Add a body if the change is non-trivial (explain what and why)
4. Run `git commit -m "message"`
5. Show the commit hash and summary

$input
