---
name: pr-duplicate-check
description: "Set up or refine workflow checks for duplicate resource additions in PRs"
agent: agent
argument-hint: "PR quality goals and resource directories to protect"
---

# PR Duplicate Check

Preferred custom agent: github-actions-expert.

Set up or refine duplicate-resource detection in pull requests:

${input:scope:Describe PR duplicate-check goals and protected resource directories}

Requirements:

- Use the pr-duplicate-check workflow as the baseline.
- Ensure changed agents, instructions, skills, and workflows are analyzed for overlap.
- Keep false positives low and feedback actionable.
- Preserve advisory behavior so maintainers keep final control.

Output format:

1. Existing state summary
2. Proposed workflow or policy changes
3. Duplicate-detection criteria
4. False-positive mitigation strategy
5. Validation plan
