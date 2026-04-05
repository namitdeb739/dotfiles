---
name: create-issue
description: "Create a GitHub issue with type-first policy and structured markdown body"
agent: "GitHub Ops Executor"
argument-hint: "Issue request, repo context, and optional type/labels"
---

# Create Issue

Preferred custom agent: GitHub Ops Executor.

Create a new GitHub issue using structured content and repository policy.

${input:details:Describe the issue goal, expected type, labels, assignees, and acceptance criteria}

Requirements:

- Confirm repository context before creating the issue.
- Prefer issue types when available; fall back to labels when types are unavailable.
- Generate issue body in markdown with clear sections.
- Use CLI or API path that supports requested metadata.
- Return issue number and URL.

Output format:

1. Context table:

| Repository | Type Discovery | Type Used | Labels Used |
| ---------- | -------------- | --------- | ----------- |

2. Issue creation table:

| Title | Assignees | Milestone | Issue URL/Number | Result |
| ----- | --------- | --------- | ---------------- | ------ |

3. Body sections table:

| Section | Included | Notes |
| ------- | -------- | ----- |

4. Follow-ups (if any)
