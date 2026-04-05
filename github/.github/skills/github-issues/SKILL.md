---
name: github-issues
description: 'Create, update, and manage GitHub issues using read tools plus gh issue/gh api write paths with issue-type preference and safe lifecycle controls.'
---

# GitHub Issues

Manage GitHub issues with a type-first workflow and explicit lifecycle reporting.

## Available Tools

### Read Operations

- Issue and project read/search tools for discovery and state checks.

### Write Operations

- `gh issue` for standard create/edit/close/reopen/delete flows.
- `gh api` for issue type support and advanced metadata updates.

Note: `gh issue create` does not support issue type directly; use `gh api` when `type` is required.

## Workflow

1. Determine action: create, update, close, reopen, or delete.
2. Confirm repository context and gather current issue metadata when updating.
3. Discover available issue types where org context exists.
4. Build structured title and markdown body.
5. Execute write operation with `gh issue` or `gh api` based on required fields.
6. Confirm resulting issue state and return URL/number.

## Type-First Policy

- Prefer issue types (for example: `Bug`, `Feature`, `Task`) when available.
- Fall back to labels when issue types are unavailable.

Type discovery example:

```bash
gh api graphql \
  -f query='query($owner:String!){ organization(login:$owner){ issueTypes(first:20){ nodes { name } } } }' \
  -F owner=<org-login> \
  --jq '.data.organization.issueTypes.nodes[].name'
```

## Core Commands

```bash
# Create with issue type via API (preferred for type support)
gh api repos/<owner>/<repo>/issues \
  -X POST \
  -f title="<title>" \
  -f body="<markdown-body>" \
  -f type="<type>"

# Create with labels (fallback path)
gh issue create --title "<title>" --body-file <path> --label "<label>"

# Update fields
gh issue edit <number> --title "<title>" --body-file <path>

# Close, reopen, delete
gh issue close <number> --comment "<reason>"
gh issue reopen <number>
gh issue delete <number> --yes
```

## Optional Metadata

```bash
# Optional API fields for create/update
-f labels[]="bug"
-f assignees[]="username"
-f milestone=1
```

## Content Rules

- Title should be specific and action-oriented.
- Body should include context, problem/request, and acceptance criteria.
- If closing an issue, include reason or resolution reference.

## Safety Rules

- Deletion requires explicit user confirmation.
- If type discovery fails, continue with label fallback and report that fallback.
- Do not guess milestone/assignee/label values when ambiguous.

## Output Format

- Action summary with target repository.
- Issue identifier (`#number`) and URL.
- Final state and metadata updates (type/labels/assignees).
