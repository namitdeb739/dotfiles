---
name: dependabot-maintenance
description: 'Create or optimize Dependabot configuration for safer, lower-noise updates'
agent: agent
argument-hint: 'Repository paths/ecosystems and update policy goals'
---

# Dependabot Maintenance

Preferred custom agent: se-gitops-ci-specialist.

Review and optimize Dependabot setup for this repository:

${input:scope:Describe ecosystems, directories, and update-policy goals}

Requirements:
- Use the dependabot skill guidance.
- Detect all relevant dependency ecosystems and manifest locations.
- Propose grouped updates, schedules, labels, and review-friendly PR behavior.
- Minimize noisy PR churn while preserving security responsiveness.

Output format:
1. Detected ecosystems and directories
2. Proposed dependabot.yml changes
3. Grouping and schedule rationale
4. Security update handling approach
5. Rollout checklist
