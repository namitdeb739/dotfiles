---
name: cleanup-tech-debt
description: "Clean up code quality and reduce technical debt with low-risk changes"
agent: agent
argument-hint: "Module or file set with debt to clean up"
---

# Cleanup Tech Debt

Preferred custom agent: janitor.

Perform targeted cleanup on this scope:

${input:scope:Files/modules and debt symptoms to address}

Requirements:

- Prefer low-risk, behavior-preserving improvements.
- Remove dead code and simplify complex hotspots.
- Report measurable before/after outcomes.

Output format:

1. Debt found
2. Improvements applied
3. Risk level
4. Validation results
