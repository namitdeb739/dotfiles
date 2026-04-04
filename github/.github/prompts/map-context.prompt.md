---
name: map-context
description: 'Map all relevant files and dependencies before planning or implementation'
agent: agent
argument-hint: 'Task or feature to map'
---

# Map Context

Preferred custom agent: context-architect.

Map the repository context for this task:

${input:task:Describe the change to be made}

Requirements:
- Identify primary files, dependent files, and boundary files.
- Highlight hidden coupling and likely side effects.
- Provide a recommended edit order.

Output format:
1. Core files
2. Supporting files
3. Risk hotspots
4. Recommended edit sequence
