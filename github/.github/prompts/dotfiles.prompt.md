---
description: Edit dotfiles — agents, prompts, hooks, instructions, and global Copilot config
agent: Dotfiles Editor
tools: ['read', 'search', 'edit', 'execute', 'web']
---

Edit the dotfiles repository that manages global VS Code Copilot configuration.

The dotfiles repo is at `~/source/repos/dotfiles/` (symlinked to `~/.github/`).

If no specific request is given, list the current inventory:
- Agents in `.github/agents/` (name, description, tools, model)
- Prompts in `.github/prompts/` (description, agent routing)
- Instructions in `.github/instructions/` (name, applyTo glob)
- Hooks in `.github/hooks/` (event, what it checks)

$input
