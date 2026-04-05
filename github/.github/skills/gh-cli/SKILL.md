---
name: gh-cli
description: 'Comprehensive GitHub CLI reference for repository, issue, pull request, and branch workflows with safe operational defaults.'
---

# GitHub CLI (gh)

Comprehensive reference for GitHub CLI workflows used in this repository.

## Prerequisites

### Authentication and Repository Context

```bash
gh --version
gh auth status
git status --short --branch
gh repo view --json name,defaultBranchRef
```

If authentication or repo detection fails, stop and ask for user confirmation before write operations.

## Core Command Surface

### Pull Requests (`gh pr`)

```bash
# Create with markdown preserved via body-file
gh pr create --base main --head <branch> --title "<title>" --body-file <path>

# Edit metadata and body
gh pr edit <number-or-url> --title "<title>" --body-file <path>

# Merge with default strategy
gh pr merge <number-or-url> --squash --delete-branch

# Lifecycle operations
gh pr close <number-or-url> --comment "<reason>"
gh pr reopen <number-or-url>
gh pr update-branch <number-or-url>
```

### Issues (`gh issue` and `gh api`)

```bash
# Basic issue creation
gh issue create --title "<title>" --body-file <path> --label "<label>"

# Issue type-aware creation (REST API)
gh api repos/<owner>/<repo>/issues \
  -X POST \
  -f title="<title>" \
  -f body="<markdown-body>" \
  -f type="<type>"

# Update issue metadata/content
gh issue edit <number> --title "<title>" --body-file <path>

# Lifecycle operations
gh issue close <number> --comment "<reason>"
gh issue reopen <number>
gh issue delete <number> --yes

# Branch from issue
gh issue develop <number> --base main --branch <branch-name>
```

### Repository and Branch Operations

```bash
# Refresh and branch from main
git fetch origin
git switch main
git pull --ff-only origin main
git switch -c <type>/<short-name>

# Sync working branch
git fetch origin
git rebase origin/main

# Delete branch (guarded)
git branch -d <branch>
git push origin --delete <branch>
```

## Output Formatting and Querying

Use structured output for deterministic automation:

```bash
# JSON output
gh pr list --json number,title,state,url

# jq filtering
gh pr list --json number,title --jq '.[] | [.number, .title]'

# repository override
gh pr list --repo <owner>/<repo>
```

## Best Practices

- Prefer `--body-file` over inline multiline strings for markdown bodies.
- Use JSON plus `--jq` when downstream parsing is required.
- Prefer safe merge default (`--squash --delete-branch`) unless user requests otherwise.
- Require explicit confirmation before destructive commands.
- Never delete the detected default branch.

## References

- Official CLI manual: https://cli.github.com/manual/
- GitHub CLI docs: https://docs.github.com/en/github-cli
