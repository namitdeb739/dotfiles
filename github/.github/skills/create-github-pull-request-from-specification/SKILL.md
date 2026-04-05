---
name: create-github-pull-request-from-specification
description: 'Create or update a GitHub pull request from a specification by applying repository PR template structure and body-file markdown handling.'
---

# Create Pull Request From Specification

Use this skill when the user provides a spec/plan and asks to create or update a PR.

## Inputs

- Specification file or approved implementation brief.
- Target base branch (default: `main`).
- Current head branch.

## Process

1. Read repository PR template structure (if present).
2. Check whether a PR already exists for the current head branch.
3. If no PR exists, create a draft-quality title/body from the specification and create PR.
4. If PR exists, update PR title/body using the specification and template structure.
5. Confirm PR URL/number and summarize final PR content.

## Commands

```bash
# Check existing PR for branch
gh pr list --head <branch> --json number,url,title --jq '.[0]'

# Create
gh pr create --base <base> --head <branch> --title "<title>" --body-file <path>

# Update
gh pr edit <number-or-url> --title "<title>" --body-file <path>
```

## Requirements

- Single PR per specification scope unless the user requests split PRs.
- PR body aligns to repository template headings/sections.
- Markdown body is written through `--body-file`.
- Existing PR is reused instead of duplicated when head branch already has an open PR.

## Safety Rules

- If PR template is missing, use repository style from existing PR history.
- If required context is missing (base branch, issue reference), ask user rather than guessing.
- Do not merge from this skill unless explicitly requested.

## Output

- PR URL and number.
- Whether PR was created or updated.
- Final title and key body sections included.
