# Dotfiles

Personal development environment configuration.

## Contents

- `.github/` — VS Code Copilot customization files
  - `copilot-instructions.md` — Global AI coding instructions (always-on)
  - `instructions/` — Conditional instruction files (auto-apply by file pattern)
  - `agents/` — Custom Copilot agent personas
  - `prompts/` — Reusable slash commands
  - `hooks/` — Agent lifecycle hooks (safety guards, formatters)
- `.gitconfig` — Git configuration

## Setup on a new machine

```bash
git clone git@github.com:namitdeb739/dotfiles.git ~/dotfiles

# Symlink .github into home directory
ln -sf ~/dotfiles/.github ~/.github

# Symlink .gitconfig
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
```

## Syncing changes

```bash
cd ~/dotfiles && git pull
```
