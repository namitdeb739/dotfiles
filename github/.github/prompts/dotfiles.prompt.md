---
description: Edit dotfiles — agents, prompts, hooks, instructions, and global Copilot config
agent: Dotfiles Editor
tools: ['read', 'search', 'edit', 'execute', 'web', 'io.github.github/github-mcp-server/*']
model: ['GPT-5.3 Codex High']
---

Edit the dotfiles repository that manages global VS Code Copilot configuration.

The dotfiles repo is at `~/source/repos/dotfiles/` (symlinked to `~/.github/`).

If no specific request is given, list the current inventory:
- Agents in `.github/agents/` (name, description, tools, model)
- Prompts in `.github/prompts/` (description, agent routing)
- Instructions in `.github/instructions/` (name, applyTo glob)
- Hooks in `.github/hooks/` (event, what it checks)

Before you finalize any markdown edits:
- Verify all local markdown links resolve from the current file's directory.
- For files under `.github/`, use paths relative to `.github/` (for example `../README.md` and `workflows/ci.yml`).
- If any local link target does not exist, fix the path before returning results.

$input
