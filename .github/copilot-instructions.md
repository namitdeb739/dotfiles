# Project Guidelines

## Code Style

- Keep changes minimal and scoped to the requested task.
- Preserve existing shell style in [bootstrap.sh](../bootstrap.sh) and [check-stow-integrity.sh](../check-stow-integrity.sh): `set -euo pipefail`, explicit guards, and readable function boundaries.
- Follow specialized instruction files instead of repeating those rules here:
  - [github/.github/instructions/shell.instructions.md](../github/.github/instructions/shell.instructions.md)
  - [github/.github/instructions/markdown.instructions.md](../github/.github/instructions/markdown.instructions.md)
  - [github/.github/instructions/containerization-docker-best-practices.instructions.md](../github/.github/instructions/containerization-docker-best-practices.instructions.md)
  - [github/.github/instructions/security-and-owasp.instructions.md](../github/.github/instructions/security-and-owasp.instructions.md)

## Architecture

- This repository is a GNU Stow-managed dotfiles source of truth. Edit repo files, not generated/symlinked files in home directories.
- Core orchestration lives in [bootstrap.sh](../bootstrap.sh), which installs prerequisites, runs Brewfile installs, stows packages, links VS Code settings, configures Starship, installs extensions, initializes zsh plugins, and runs verification.
- Integrity checks live in [check-stow-integrity.sh](../check-stow-integrity.sh), which validates that all stow-managed files across every package resolve to tracked repository files.
- Stowed AI configuration content is under [github/.github](../github/.github) (agents, hooks, prompts, and instructions).
- For the full package map and targets, link to [README.md](../README.md) instead of re-describing each package.

## Build and Test

- Prefer targeted validation commands first:
  - `bash check-stow-integrity.sh`
  - `python3 -c "import json; json.load(open('github/.github/hooks/secrets-guard.json')); json.load(open('github/.github/hooks/dangerous-git-guard.json'))"`
- CI reference is [.github/workflows/ci.yml](workflows/ci.yml) (ShellCheck, JSON validation, bootstrap smoke test).
- Run full bootstrap only when needed and call out side effects first:
  - `chmod +x bootstrap.sh check-stow-integrity.sh && ./bootstrap.sh`
- Before running bootstrap in automation, note it can install packages and modify symlinks in the user home directory.

## Conventions

- Preserve idempotency in bootstrap flows: re-runs should be safe and should not break existing setups.
- Do not remove backup/safety behavior in [bootstrap.sh](../bootstrap.sh):
  - backup existing conflicting files into `~/.dotfiles_backup`
  - ignore `*.backup-*` files during stow
  - keep non-interactive fallback behavior for Starship selection
- Keep platform handling intact for VS Code user directories (macOS/Linux/Windows code paths).
- When updating docs, prefer linking to [README.md](../README.md) sections and avoid duplicating operational content.
