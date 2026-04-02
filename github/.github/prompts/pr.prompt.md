---
description: Analyze git changes and create a structured pull request
agent: PR Writer
tools: ['execute', 'read', 'search', 'io.github.github/github-mcp-server/*']
---

Create a pull request for the current branch.

## 1. Gather context

- `git log main..HEAD --oneline` — all commits on this branch
- `git diff main...HEAD --stat` — files changed
- Use the GitHub MCP server to check for linked issues if available

## 2. Push if needed

If there's no remote branch yet:
```
git push -u origin HEAD
```

## 3. Create PR

- Analyze all commits on the branch (not just the latest) to understand the full scope
- Draft a concise PR title (under 70 chars, imperative mood)
- Draft a structured body:
  - **Summary**: 1-3 bullet points of what changed and why
  - **Type of Change**: feature / fix / refactor / docs / etc.
  - **Test Plan**: how to verify the changes
  - **Linked Issues**: reference any related issues
- Create via `gh pr create --title "..." --body "..."`

**Important**: Do NOT use `gk` CLI commands — they require interactive prompts that cannot be answered in agent mode. Always use `gh` directly.

## 4. Post-create

- Show the PR URL
- Suggest next steps (request review, add labels, etc.)

$input
