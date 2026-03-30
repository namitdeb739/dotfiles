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

Clone anywhere you like, then symlink into your home directory:

```bash
# Clone to your preferred location
git clone https://github.com/namitdeb739/dotfiles.git ~/Developer/dotfiles

# Symlink into home directory (VS Code reads from ~/.github/)
ln -sf ~/Developer/dotfiles/.github ~/.github
ln -sf ~/Developer/dotfiles/.gitconfig ~/.gitconfig
```

## Syncing changes

```bash
cd ~/Developer/dotfiles && git pull
```
