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

Clone anywhere you like, then run the bootstrap script:

```bash
# Clone to your preferred location
git clone https://github.com/namitdeb739/dotfiles.git ~/Developer/dotfiles

# Bootstrap links with safe backup behavior
~/Developer/dotfiles/bootstrap.sh
```

The script safely backs up existing `~/.github` and `~/.gitconfig` before creating symlinks.

## Syncing changes

```bash
cd ~/Developer/dotfiles && git pull
```

## Verify `~/.github` is dotfiles-managed

```bash
cd ~/Developer/dotfiles
chmod +x check-github-managed.sh
./check-github-managed.sh
```

The command exits with non-zero status if any file under `~/.github`
is not tracked by this repository.
