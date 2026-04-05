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

1. Severity summary table:

| Severity | Count | Highest-Risk Area |
| -------- | ----- | ----------------- |

2. Findings table (group by severity):

| Severity | File/Scope | Issue | Exploitability | Impact |
| -------- | ---------- | ----- | -------------- | ------ |

3. Recommended fixes table:

| Priority | Fix | Target File/Area | Verification |
| -------- | --- | ---------------- | ------------ |

4. Security validation checklist

5. Residual risks (if unresolved)
