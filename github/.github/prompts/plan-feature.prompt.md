---
name: plan-feature
description: 'Create a phased implementation plan for a feature or refactor request'
agent: agent
argument-hint: 'Feature request, issue, or refactor goal'
---

# Plan Feature

Preferred custom agent: plan.

Create a practical implementation plan for this request:

${input:request:Describe the feature, bugfix, or refactor goal}

Requirements:
- Inspect relevant files before finalizing the plan.
- Keep the plan implementation-focused and concrete.
- Explicitly call out assumptions, risks, and validation steps.

Output format:
1. Goal
2. Scope
3. Assumptions
4. Phased plan
5. Risks and mitigations
6. Validation checklist
