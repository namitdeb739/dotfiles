---
name: edit-instruction
description: "Edit an existing Copilot instruction file while preserving scope and frontmatter"
agent: "SWE"
argument-hint: "Instruction file path and requested rule updates"
---

# Edit Instruction

Edit an existing instruction file using this request:

${input:request:Describe the instruction file and the exact changes}

Requirements:

- Edit an existing `*.instructions.md` file only.
- Preserve frontmatter structure (`description`, `applyTo`, and related metadata) unless explicitly changed.
- Keep rule changes precise and avoid broad rewrites.
- Ensure updated instructions remain internally consistent and unambiguous.

Output format:

1. Change summary
2. Files touched table:

| File | Change Type | Purpose |
| ---- | ----------- | ------- |

3. Validation table:

| Check | Command/Method | Result |
| ----- | -------------- | ------ |

4. Residual risks or follow-ups
