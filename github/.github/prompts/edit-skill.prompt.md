---
name: edit-skill
description: "Edit an existing skill definition or skill documentation with minimal risk"
agent: "SWE"
argument-hint: "Skill file path and requested edits"
---

# Edit Skill

Edit an existing skill asset using this request:

${input:request:Describe the target skill file and required updates}

Requirements:

- Edit existing skill assets only (for example `SKILL.md` and related skill docs/config).
- Preserve structure expected by skill consumers unless explicitly changing behavior.
- Keep examples and commands runnable and up to date.
- Verify links and references when skill docs are changed.

Output format:

1. Change summary
2. Files touched table:

| File | Change Type | Purpose |
| ---- | ----------- | ------- |

3. Validation table:

| Check | Command/Method | Result |
| ----- | -------------- | ------ |

4. Residual risks or follow-ups
