---
description: Review current changes for code quality issues and auto-fix them
agent: Code Reviewer
tools: ['read', 'search', 'edit', 'execute', 'io.github.github/github-mcp-server/*']
---

Review all changes on the current branch compared to main, then fix any Critical or Major issues found.

## 1. Understand the changes

- Use `gk ai explain branch` to get an AI summary of what this branch does
- Run `git diff main...HEAD` for the full diff
- Check `search/changes` for uncommitted work on top of committed changes

## 2. Review

- Evaluate against SOLID, security (OWASP top 10), and clean code principles
- Check the VS Code Problems panel (`read/problems`) for any diagnostics from Error Lens / linters
- Report all findings by severity: Critical, Major, Minor, Suggestion

## 3. Fix

- Automatically fix Critical and Major issues
- Re-run review to confirm fixes are clean
- Report what was fixed and what remains as Minor/Suggestion

$input
