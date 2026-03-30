---
description: Analyze git changes and create a structured pull request
agent: PR Writer
tools: ['runInTerminal']
---

Create a pull request for the current branch.

1. Analyze all commits on this branch (not just the latest)
2. Draft a concise PR title and structured description
3. Create the PR via `gh pr create`

If there's no remote branch yet, push first with `git push -u origin HEAD`.

$input
