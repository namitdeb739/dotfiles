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

- Discover diagnostics from all available sources (Problems view equivalents, lint, type checks, compile checks, and workflow/schema validation).
- Run editor diagnostics first via `get_errors` (workspace-wide or requested scope). Treat this as mandatory, not optional.
- Prioritize errors before warnings.
- Apply the smallest safe fixes first.
- Re-run relevant checks after each fix cycle, including `get_errors`.
- Stop with a clear report if remaining issues require product or policy decisions.

Mandatory execution protocol:

1. Gather baseline diagnostics:
   - Run `get_errors` for the full workspace (or requested scope).
   - Capture each issue with resource path, owner, severity, message, and line.
2. Reproduce each error with a source-specific check when possible:
   - YAML/JSON parse errors: run targeted parser/validator.
   - Shell/Python/Type errors: run syntax/type commands for affected files.
   - Markdown link/file warnings: verify resolved paths from the source file directory.
3. Fix one logical group at a time with minimal diffs.
4. Validate after each group:
   - Re-run reproducer commands for touched files.
   - Re-run `get_errors` to confirm editor diagnostics are cleared.
5. Do not declare completion while any error-level diagnostics remain in `get_errors` for scope.

False-positive handling:

- If a diagnostic appears inconsistent with filesystem reality, verify the exact file currently opened by the user and then the canonical workspace file path.
- If a warning is determined to be stale/tooling-state related, explicitly report it as `unreproduced` with evidence (command output) and provide the exact refresh/reindex step.

Output format:

1. Scope and checks selected
2. Diagnostics summary table:

| Source/Owner | Error Count | Warning Count | Notes |
| ------------ | ----------- | ------------- | ----- |

3. Fixes applied table:

| File | Issue | Fix | Risk |
| ---- | ----- | --- | ---- |

4. Validation rerun table:

| Check | Command/Method | Result |
| ----- | -------------- | ------ |

5. Remaining diagnostics and next actions (explicitly mark each as fixed, unreproduced, or blocked)
