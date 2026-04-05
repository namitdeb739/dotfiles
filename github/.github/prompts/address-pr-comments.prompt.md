---
name: address-pr-comments
description: "Resolve and summarize pull request review comments"
agent: agent
argument-hint: "PR context and comment scope"
---

# Address PR Comments

Preferred custom agent: address-comments.

Address review comments for this pull request scope:

${input:scope:PR link or summary of unresolved comments}

Requirements:

- Resolve comments with targeted code or documentation updates.
- Preserve behavior unless change is explicitly requested.
- Summarize what was addressed and what remains open.

Output format:

1. Comments addressed
2. Changes made
3. Remaining open items
4. Suggested reviewer follow-up
