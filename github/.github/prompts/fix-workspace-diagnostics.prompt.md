---
name: fix-workspace-diagnostics
description: "Scan repository diagnostics (lint/compile/problems) and apply safe fixes iteratively"
agent: "SWE"
argument-hint: "Optional scope path and fix policy (safe-only or include risky fixes)"
---

# Fix Workspace Diagnostics

Inspect the workspace for diagnostics and address them iteratively:

${input:scope:Optional path or file scope; leave blank for whole repo}

Optional policy:
${input:policy:Default safe-only fixes. Add include-risky to allow riskier refactors}

Requirements:

- Discover diagnostics from available sources (Problems view equivalents, lint, type checks, compile checks, and workflow/schema validation).
- Prioritize errors before warnings.
- Apply the smallest safe fixes first.
- Re-run relevant checks after each fix cycle.
- Stop with a clear report if remaining issues require product or policy decisions.

Output format:

1. Scope and checks selected
2. Diagnostics summary table:

| Source | Error Count | Warning Count | Notes |
| ------ | ----------- | ------------- | ----- |

3. Fixes applied table:

| File | Issue | Fix | Risk |
| ---- | ----- | --- | ---- |

4. Validation rerun table:

| Check | Command/Method | Result |
| ----- | -------------- | ------ |

5. Remaining diagnostics and next actions
