# Workflows in This Repo

This repository currently includes a targeted set of agentic workflows imported from github/awesome-copilot.

## Installed Workflows

| Workflow | Purpose | Trigger |
| --- | --- | --- |
| [../workflows/relevance-check.md](../workflows/relevance-check.md) | Evaluate whether an issue or pull request is still relevant and post a structured recommendation comment. | `slash_command` (`/relevance-check`), repository roles |
| [../workflows/pr-duplicate-check.md](../workflows/pr-duplicate-check.md) | Review changed resources in pull requests and flag potential duplicates across agents, instructions, skills, and workflows. | Pull request events (`opened`, `synchronize`, `reopened`) |
| [../workflows/resource-staleness-report.md](../workflows/resource-staleness-report.md) | Generate a periodic report of stale or aging resource files to keep the Copilot configuration maintained. | Scheduled weekly run |

## Notes

- Source: github/awesome-copilot (selected subset).
- This is a markdown-defined workflow designed for the `gh aw` toolchain.
- For additional OSPO/reporting workflows, import from upstream as needed.
