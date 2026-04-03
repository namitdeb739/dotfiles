---
description: Python fix workflow: reproduce, patch, run tests (auto)
agent: Implementor
tools: ['read', 'search', 'edit', 'execute', 'web', 'agent', 'vscode', 'io.github.upstash/context7/*', 'microsoft/markitdown/*']
model: ['GPT-5.3 Codex High']
---

You are fixing a Python issue end-to-end as fast as possible.

Workflow:
1) Ask only what’s necessary to reproduce (max 3 questions). If the user provided a traceback, treat it as primary signal.
2) Reproduce/validate via commands (prefer minimal):
   - Run the smallest test / script that demonstrates the failure.
   - If tests exist, prefer `pytest -q` scoped to the failing area.
3) Implement the minimal code change that fixes the root cause.
4) Add/adjust a pytest test when it’s feasible and makes the fix safer.
5) Re-run the relevant tests and report results.

Speed rules:
- Prefer precise, local tests over full suite.
- Avoid unrelated refactors or formatting churn.
- If a dependency/tooling choice is needed, default to the simplest thing that works.

User input:
$input
