---
name: edit-hook
description: "Edit an existing Copilot hook configuration and revalidate JSON"
agent: "SWE"
argument-hint: "Hook file path plus behavior/config changes"
---

# Edit Hook

Edit an existing hook configuration based on this request:

${input:request:Describe the target hook file and required updates}

Requirements:

- Edit existing hook files under `github/.github/hooks/`.
- Preserve hook schema and existing safety controls unless explicitly requested otherwise.
- Keep changes minimal and avoid unrelated reformatting.
- Re-run JSON validation for modified hook files before finishing.

Output format:

1. Change summary
2. Files touched table:

| File | Change Type | Purpose |
| ---- | ----------- | ------- |

3. Validation table:

| Check | Command/Method | Result |
| ----- | -------------- | ------ |

4. Residual risks or follow-ups
