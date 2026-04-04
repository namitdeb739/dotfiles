# Hooks in This Repo

This repository contains a curated set of hook packs imported from github/awesome-copilot for safety and compliance in coding-agent sessions.

## Installed Hooks

| Hook | Purpose | Trigger Events |
| --- | --- | --- |
| [tool-guardian](../hooks/tool-guardian/README.md) | Blocks high-risk operations before execution (destructive file ops, force pushes, dangerous DB commands). | `preToolUse` |
| [secrets-scanner](../hooks/secrets-scanner/README.md) | Scans modified files for leaked secrets and credentials. | `sessionEnd` |
| [dependency-license-checker](../hooks/dependency-license-checker/README.md) | Flags newly added dependencies with blocked licenses (GPL/AGPL/etc.). | `sessionEnd` |
| [governance-audit](../hooks/governance-audit/README.md) | Scans prompts for dangerous patterns (injection, exfiltration, escalation) and blocks threats in strict mode. | `sessionStart`, `userPromptSubmitted`, `sessionEnd` |

## Why This Subset

- Prioritizes practical guardrails for your workflow without noisy behavior.
- Excludes session logging and auto-commit hooks to avoid noisy logs and unexpected write side effects.
- Keeps enforcement focused on security and compliance checks that matter across your dotfiles and Python-heavy repos.

## Notes

- Source: github/awesome-copilot (selected subset).
- Each hook folder includes its own `hooks.json` and executable script(s).
- Keep this file updated whenever hook folders are added or removed.
