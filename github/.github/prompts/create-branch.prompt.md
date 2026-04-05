---
name: create-branch
description: "Create a new working branch from main using semantic naming"
agent: "GitHub Ops Executor"
argument-hint: "Branch intent, optional issue number, and naming preferences"
---

# Create Branch

Preferred custom agent: GitHub Ops Executor.

Create a semantic working branch from `main`.

${input:details:Describe change intent and optional issue number}

Requirements:

- Fetch latest `origin/main` and ensure local `main` is up to date.
- Infer branch prefix from intent (`feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`).
- Use kebab-case naming.
- If an issue number is provided, include it in branch name.
- If branch exists, propose a safe alternative.

Output format:

1. Preflight table:

| Check | Result | Notes |
| ----- | ------ | ----- |

2. Branch decision table:

| Intent | Prefix | Branch Name | Source Branch |
| ------ | ------ | ----------- | ------------- |

3. Creation result table:

| Action | Result | Current Branch |
| ------ | ------ | -------------- |

4. Follow-ups (if needed)
