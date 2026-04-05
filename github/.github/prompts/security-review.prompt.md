---
name: security-review
description: "Run a focused security review and prioritize issues by severity"
agent: "SE: Security"
argument-hint: "Files, diff, or feature area to review"
---

# Security Review

Preferred custom agent: SE: Security.

Review this scope for security issues:

${input:scope:Provide file paths, diff summary, or feature area}

Requirements:

- Prioritize critical and high-risk findings.
- Explain exploitability and potential impact.
- Recommend concrete fixes and mitigations.

Output format:

1. Critical findings
2. High findings
3. Medium/low findings
4. Recommended fixes
5. Security validation checklist
