---
name: implement-plan
description: "Implement a provided plan with minimal, safe, validated changes"
agent: "SWE"
argument-hint: "Plan or implementation brief"
---

# Implement Plan

Preferred custom agent: SWE.

Implement this plan or implementation brief:

${input:plan:Paste the approved implementation plan or task brief}

Requirements:

- Make the smallest safe set of changes required.
- Preserve existing style and patterns.
- Run relevant verification commands before finishing.

Output format:

1. What changed
   - Concise summary paragraph.

2. Files touched table:

| File | Change Type | Purpose |
| ---- | ----------- | ------- |

3. Validation performed table:

| Check | Command/Method | Result |
| ----- | -------------- | ------ |

4. Residual risks or follow-ups
