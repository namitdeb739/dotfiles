---
name: edit-agent
description: "Edit an existing custom agent file safely and validate consistency"
agent: "SWE"
argument-hint: "Target .agent.md file path plus requested edits"
---

# Edit Agent

Edit an existing custom agent file based on this request:

${input:request:Describe the target agent file and exact changes needed}

Requirements:

- Edit an existing `.agent.md` file only (do not create a new agent unless explicitly requested).
- Confirm the target file exists before editing.
- Preserve frontmatter keys unless the request explicitly changes them.
- Keep behavior changes minimal and scoped to the request.
- Validate any dependent prompt routing or references impacted by the edit.

Output format:

1. Change summary
2. Files touched table:

| File | Change Type | Purpose |
| ---- | ----------- | ------- |

3. Validation table:

| Check | Command/Method | Result |
| ----- | -------------- | ------ |

4. Residual risks or follow-ups
