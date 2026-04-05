# Prompts in This Repo

This repository includes task-launch prompt files aligned with the installed agent set.

## Installed Prompts

| Prompt | Recommended Custom Agent | Purpose |
| --- | --- | --- |
| [../prompts/help.prompt.md](../prompts/help.prompt.md) | `context-architect` | Summarize available built-in, custom, and MCP/plugin prompt commands in a single help table. |
| [../prompts/commit-push.prompt.md](../prompts/commit-push.prompt.md) | `swe-subagent` | Split unrelated diffs into logical commits, generate standards-compliant messages, and push. |
| [../prompts/plan-feature.prompt.md](../prompts/plan-feature.prompt.md) | `plan` | Build phased implementation plans for features/refactors. |
| [../prompts/research-task.prompt.md](../prompts/research-task.prompt.md) | `task-researcher` | Deep task/problem research before planning or coding. |
| [../prompts/task-plan.prompt.md](../prompts/task-plan.prompt.md) | `task-planner` | Convert research into executable implementation steps. |
| [../prompts/implement-plan.prompt.md](../prompts/implement-plan.prompt.md) | `swe-subagent` | Implement approved plans with minimal validated changes. |
| [../prompts/security-review.prompt.md](../prompts/security-review.prompt.md) | `se-security-reviewer` | Security-focused review with prioritized findings. |
| [../prompts/ci-hardening.prompt.md](../prompts/ci-hardening.prompt.md) | `github-actions-expert` | Harden GitHub Actions pipelines and improve reliability. |
| [../prompts/dependabot-maintenance.prompt.md](../prompts/dependabot-maintenance.prompt.md) | `se-gitops-ci-specialist` | Configure and optimize Dependabot updates for low-noise, secure dependency management. |
| [../prompts/address-pr-comments.prompt.md](../prompts/address-pr-comments.prompt.md) | `address-comments` | Resolve review comments and summarize outcomes. |
| [../prompts/write-dev-docs.prompt.md](../prompts/write-dev-docs.prompt.md) | `se-technical-writer` | Create/update developer docs from code changes. |
| [../prompts/generate-tests.prompt.md](../prompts/generate-tests.prompt.md) | `polyglot-test-generator` | Generate practical tests using the polyglot pipeline. |
| [../prompts/pytest-coverage.prompt.md](../prompts/pytest-coverage.prompt.md) | `polyglot-test-generator` | Increase coverage by targeting uncovered lines with focused pytest additions. |
| [../prompts/ruff-recursive-fix.prompt.md](../prompts/ruff-recursive-fix.prompt.md) | `swe-subagent` | Run iterative Ruff remediation with controlled autofix and manual cleanup loops. |
| [../prompts/tdd-red.prompt.md](../prompts/tdd-red.prompt.md) | `tdd-red` | Write failing tests first (TDD red phase). |
| [../prompts/tdd-green.prompt.md](../prompts/tdd-green.prompt.md) | `tdd-green` | Implement minimal changes to pass tests (TDD green phase). |
| [../prompts/tdd-refactor.prompt.md](../prompts/tdd-refactor.prompt.md) | `tdd-refactor` | Refactor safely with tests remaining green. |
| [../prompts/technical-spike.prompt.md](../prompts/technical-spike.prompt.md) | `research-technical-spike` | Run a structured technical spike with recommendation output. |
| [../prompts/cleanup-tech-debt.prompt.md](../prompts/cleanup-tech-debt.prompt.md) | `janitor` | Targeted behavior-preserving cleanup and debt reduction. |
| [../prompts/map-context.prompt.md](../prompts/map-context.prompt.md) | `context-architect` | Map dependencies/files before planning or implementation. |
| [../prompts/agent-safety-audit.prompt.md](../prompts/agent-safety-audit.prompt.md) | `se-security-reviewer` | Audit agent governance controls for least privilege and fail-closed behavior. |
| [../prompts/pr-duplicate-check.prompt.md](../prompts/pr-duplicate-check.prompt.md) | `github-actions-expert` | Set up or refine duplicate-resource checks for pull requests. |
| [../prompts/resource-staleness-report.prompt.md](../prompts/resource-staleness-report.prompt.md) | `github-actions-expert` | Set up or refine periodic staleness reporting for Copilot resources. |

## Notes

- Prompts are designed as thin task launchers; broader standards remain in instruction files.
- Keep this file updated whenever prompt files are added or removed.
