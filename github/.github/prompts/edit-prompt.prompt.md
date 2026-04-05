---
name: edit-prompt
description: "Edit an existing prompt file and verify routing/format consistency"
agent: "SWE"
argument-hint: "Prompt file path and requested prompt behavior changes"
---

# Edit Prompt

Edit an existing prompt file based on this request:

${input:request:Describe the target prompt file and exact updates}

Requirements:

- Edit an existing `*.prompt.md` file only.
- Preserve frontmatter and command intent unless explicitly changed.
- Keep prompt body clear, deterministic, and scoped.
- Re-run prompt routing validation if agent/frontmatter fields change.

Output format:

1. Change summary
2. Files touched table:

| File | Change Type | Purpose |
| ---- | ----------- | ------- |

3. Validation table:

| Check | Command/Method | Result |
| ----- | -------------- | ------ |

4. Residual risks or follow-ups
