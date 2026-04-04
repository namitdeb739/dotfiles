---
name: implement-plan
description: 'Implement a provided plan with minimal, safe, validated changes'
agent: agent
argument-hint: 'Plan or implementation brief'
---

# Implement Plan

Preferred custom agent: swe-subagent.

Implement this plan or implementation brief:

${input:plan:Paste the approved implementation plan or task brief}

Requirements:
- Make the smallest safe set of changes required.
- Preserve existing style and patterns.
- Run relevant verification commands before finishing.

Output format:
1. What changed
2. Files touched
3. Validation performed
4. Residual risks or follow-ups
