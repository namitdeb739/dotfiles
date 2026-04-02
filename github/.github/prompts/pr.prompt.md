---
description: Analyze git changes and create a structured pull request using GitKraken CLI or gh
agent: PR Writer
tools: ['runInTerminal', 'getTerminalOutput', 'read', 'search/changes', 'io.github.github/github-mcp-server/*']
---

Create a pull request for the current branch.

## 1. Gather context

- `git log main..HEAD --oneline` — all commits on this branch
- `git diff main...HEAD --stat` — files changed
- Check if inside a `gk` work item: `gk work info`

## 2. Push if needed

If there's no remote branch yet:
- **With `gk` work item active**: `gk work push` (pushes all linked repos)
- **Fallback**: `git push -u origin HEAD`

## 3. Create PR

**If `gk` is available**, use AI-generated PR:
```
gk work pr create --ai
```
This generates a PR title and body from the branch changes via GitKraken AI. If not in a work item, use:
```
gk ai pr create
```

**Fallback** (no `gk` or user prefers manual):
- Analyze all commits (not just the latest) to understand full scope
- Draft a concise PR title (under 70 chars, imperative mood) and structured body
- Create via `gh pr create`

## 4. Post-create

- Show the PR URL
- Optionally open commit graph: `gk graph --gitkraken`

$input
