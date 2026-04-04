---
name: agent-safety-audit
description: 'Audit agent/tool governance for least-privilege and fail-closed behavior'
agent: agent
argument-hint: 'Agent files, hook configs, or governance scope to assess'
---

# Agent Safety Audit

Preferred custom agent: se-security-reviewer.

Audit agent governance and safety controls for this scope:

${input:scope:Provide agent files, instructions, workflows, or hook configs}

Requirements:
- Apply the agent-safety instruction guidance.
- Evaluate tool allowlists, high-risk action controls, and escalation paths.
- Flag areas that violate least privilege or fail-open patterns.
- Recommend concrete policy and configuration hardening actions.

Output format:
1. Scope and assumptions
2. Critical governance risks
3. High/medium governance risks
4. Recommended remediations
5. Verification checklist
