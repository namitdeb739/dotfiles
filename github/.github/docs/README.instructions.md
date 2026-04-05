# Instructions in This Repo

This repository contains a curated set of instruction files imported from github/awesome-copilot for practical day-to-day workflows in dotfiles and Python-heavy projects.

## Installed Instructions

| File                                                                                                                                             | Description                                                   | Why It Is Included                                                                                   |
| ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| [../instructions/agents.instructions.md](../instructions/agents.instructions.md)                                                                 | Guidelines for creating custom agent files for GitHub Copilot | This repo actively maintains custom agents and needs consistent authoring rules.                     |
| [../instructions/agent-safety.instructions.md](../instructions/agent-safety.instructions.md)                                                     | Safety and governance guidance for tool-using agents          | Important for fail-closed behavior and least-privilege controls in autonomous agent workflows.       |
| [../instructions/containerization-docker-best-practices.instructions.md](../instructions/containerization-docker-best-practices.instructions.md) | Docker and containerization best practices                    | Relevant for Dockerfile and compose changes in app repos that this setup supports.                   |
| [../instructions/github-actions-ci-cd-best-practices.instructions.md](../instructions/github-actions-ci-cd-best-practices.instructions.md)       | Secure and maintainable GitHub Actions guidance               | Matches your CI-heavy workflow in Python template projects.                                          |
| [../instructions/instructions.instructions.md](../instructions/instructions.instructions.md)                                                     | Guidelines for creating custom instruction files              | Helps maintain clean and consistent .instructions.md files in this config repo.                      |
| [../instructions/markdown-accessibility.instructions.md](../instructions/markdown-accessibility.instructions.md)                                 | Accessibility-focused markdown review rules                   | Useful for README and docs quality across repositories.                                              |
| [../instructions/markdown.instructions.md](../instructions/markdown.instructions.md)                                                             | CommonMark markdown conventions                               | Improves consistency for markdown docs and prompts.                                                  |
| [../instructions/no-heredoc.instructions.md](../instructions/no-heredoc.instructions.md)                                                         | Forbids heredoc-style file writes in terminal workflows       | Prevents file corruption from shell redirection patterns in editor-integrated terminals.             |
| [../instructions/prompt.instructions.md](../instructions/prompt.instructions.md)                                                                 | Guidelines for writing custom prompt files                    | This repo manages reusable prompt assets and benefits from consistent prompt metadata and structure. |
| [../instructions/security-and-owasp.instructions.md](../instructions/security-and-owasp.instructions.md)                                         | OWASP-oriented secure coding guidance                         | Adds broad secure-by-default guardrails across languages and frameworks.                             |
| [../instructions/shell.instructions.md](../instructions/shell.instructions.md)                                                                   | Shell scripting best practices                                | Directly relevant to bootstrap and verification shell scripts in this repo.                          |

## Notes

- Source: github/awesome-copilot (selected subset).
- Files are stored under github/.github so they stow into ~/.github.
- Keep this document updated whenever instruction files are added or removed.
