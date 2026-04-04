---
name: ruff-recursive-fix
description: 'Run iterative Ruff autofix and manual cleanup until findings are resolved'
agent: agent
argument-hint: 'Target path plus optional Ruff rule overrides'
---

# Ruff Recursive Fix

Preferred custom agent: swe-subagent.

Run an iterative Ruff remediation workflow for this scope:

${input:scope:Provide folder or file path, or leave blank for whole repo}

Optional overrides:
${input:options:Optional flags such as --select, --ignore, or no-unsafe-fixes}

Requirements:
- Use the ruff-recursive-fix skill workflow.
- Prefer project Ruff configuration unless explicit overrides are provided.
- Apply safe fixes first, then unsafe fixes only if requested or clearly safe.
- Re-run Ruff checks after each fix iteration.

Output format:
1. Scope and options used
2. Iterations performed
3. Autofixes applied
4. Manual fixes applied
5. Remaining findings and decisions needed
