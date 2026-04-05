# Dotfiles

Personal development environment configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

<!-- cspell:words Fira atuin direnv glog Refactorer docstrings pytest ipynb mkcd ghclone killport -->

One command sets up a new machine: shell, git, editor, AI tooling, CLI tools, and prompt theme.

## Prerequisites

- macOS with [Homebrew](https://brew.sh/) installed
- [Nerd Font](https://www.nerdfonts.com/) in your terminal (bootstrap installs JetBrains Mono and Fira Code Nerd Fonts via Brewfile)

## Setup on a New Machine

```bash
# 1. Clone
git clone https://github.com/namitdeb739/dotfiles.git ~/Developer/dotfiles

# 2. Bootstrap (does everything)
cd ~/Developer/dotfiles
chmod +x bootstrap.sh check-github-managed.sh
./bootstrap.sh

# 3. Open a new terminal
```

Common bootstrap modes:

```bash
# Non-interactive run (CI/automation friendly)
./bootstrap.sh --non-interactive

# Skip extension installs
./bootstrap.sh --skip-extensions

# Select sections to run (interactive shell)
./bootstrap.sh --select-sections

# Force plain output (disable gum-based UI enhancements)
./bootstrap.sh --ui=plain
```

The bootstrap script runs these steps automatically and prints a phase-by-phase status summary at the end:

1. **Prerequisites** — installs GNU Stow via Homebrew
2. **Brewfile** — installs all CLI tools, casks, and fonts (`brew bundle`)
3. **Stow packages** — symlinks git, github, zsh configs into `~/`
4. **VSCode** — symlinks settings, keybindings into the platform-specific VSCode User dir
5. **Starship prompt** — interactive preset chooser (Tokyo Night default, or pick from 9 presets); non-interactive runs keep the existing config
6. **VSCode extensions** — installs any missing extensions from `extensions.json`
7. **Zsh plugins** — pre-compiles antidote plugins for fast first shell launch
8. **Verification** — confirms `~/.github/` integrity

## Syncing Updates

```bash
cd ~/Developer/dotfiles
git pull
```

Stow symlinks point into the repo, so `git pull` applies changes immediately. Re-run `./bootstrap.sh` only if new Brew packages or VSCode extensions were added.

If the remote history was rewritten (force-push):

```bash
git fetch origin
git reset --hard origin/main
```

## What's Included

### Stow Packages

Each directory is an independent stow package that mirrors `~/` structure:

| Package | Contents | Target |
| --------- | ---------- | -------- |
| `git/` | `.gitconfig`, `.gitignore_global` | `~/` |
| `github/` | `.github/` — Copilot agents, hooks, instructions, prompts | `~/.github/` |
| `zsh/` | `.zshrc`, Starship config, aliases, functions, PATH | `~/` |
| `vscode/` | `settings.json`, `keybindings.json`, `extensions.json` | Platform-specific VSCode User dir |
| `brew/` | `Brewfile` | Not stowed — used by `brew bundle` directly |

### Shell (zsh)

- **Plugin manager**: [antidote](https://antidote.sh/) (fast, static plugin loading)
- **Prompt**: [Starship](https://starship.rs/) with Tokyo Night theme — shows directory, git, python, node, docker, package version, command duration
- **Plugins**: zsh-autosuggestions, fast-syntax-highlighting, zsh-completions, fzf-tab
- **Modular config**: `~/.zsh/aliases.zsh`, `functions.zsh`, `path.zsh`
- **Tool integrations**: zoxide (smart cd), atuin (shell history), fnm (node), uv (python), direnv, fzf

### Git

- Aliases: `gs`, `gco`, `glog`, `undo`, `wip`, `cleanup`
- Defaults: `push.default=current`, `pull.rebase=true`, `init.defaultBranch=main`
- Pager: [delta](https://github.com/dandavies/delta) for better diffs
- Credential helper: GitHub CLI (`gh auth git-credential`)
- Global `.gitignore_global` for OS/editor/Python/Node cruft

### VSCode

- Dracula Theme Soft, Material Icon Theme with extensive file/folder associations
- Format on save with Ruff (Python) and Prettier (JSON)
- Full Copilot/AI configuration: agent mode, MCP auto-start, terminal auto-approve lists, custom instructions/agents/prompts locations, commit message generation
- 44 extensions (synced via extensions.json)

### Copilot AI Configuration

This repository manages Copilot customizations as code under `github/.github` (stowed to `~/.github`).

Use these docs as the canonical inventories:

| Area | Canonical Inventory |
| --- | --- |
| Agents | [github/.github/docs/README.agents.md](github/.github/docs/README.agents.md) |
| Hooks | [github/.github/docs/README.hooks.md](github/.github/docs/README.hooks.md) |
| Prompts | [github/.github/docs/README.prompts.md](github/.github/docs/README.prompts.md) |
| Instructions | [github/.github/docs/README.instructions.md](github/.github/docs/README.instructions.md) |
| Skills | [github/.github/docs/README.skills.md](github/.github/docs/README.skills.md) |
| Workflows | [github/.github/docs/README.workflows.md](github/.github/docs/README.workflows.md) |

Built-in slash commands are client-version dependent and are intentionally not listed as repository-managed commands.

### Brewfile (CLI Tools)

Installed via `brew bundle` during bootstrap:

| Category | Tools |
| ---------- | ------- |
| Shell | stow, starship, antidote, zoxide, atuin |
| Core CLI | git, gh, git-delta, fzf, fd, ripgrep, bat, eza, jq, tree, htop, tldr, direnv |
| Python | uv, ruff |
| Node | fnm |
| Build | just, pre-commit |
| Casks | VS Code, iTerm2, Raycast |
| Fonts | JetBrains Mono Nerd Font, Fira Code Nerd Font |

### CI

GitHub Actions workflow (`.github/workflows/ci.yml`):

- **ShellCheck** — lints `bootstrap.sh` and `check-github-managed.sh`
- **JSON validation** — validates all hook configs and MCP config
- **Bootstrap smoke test** — runs full bootstrap on macOS runner, verifies symlinks

## Selective Install

Install only specific packages on a minimal machine (e.g., server):

```bash
cd ~/Developer/dotfiles
stow -t ~ git        # just git config
stow -t ~ git zsh    # git + shell
```

## Uninstall a Package

```bash
cd ~/Developer/dotfiles
stow -t ~ -D zsh     # removes all zsh symlinks from ~/
```

## Reconfigure Starship Prompt

```bash
# Re-run the preset chooser
./bootstrap.sh  # select a new preset at step 5

# Or manually apply any preset
starship preset tokyo-night -o ~/.config/starship.toml
starship preset gruvbox-rainbow -o ~/.config/starship.toml

# Or edit directly
code ~/.config/starship.toml
```

## Verify ~/.github Integrity

```bash
./check-github-managed.sh
```

Exits non-zero if any file under `~/.github/` is not tracked by this repo.

## File Structure

```text
dotfiles/
├── .github/workflows/ci.yml        # CI: ShellCheck, JSON validation, smoke test
├── bootstrap.sh                     # One-command setup script
├── check-github-managed.sh          # Verifies ~/.github/ integrity
├── brew/Brewfile                    # Homebrew packages, casks, fonts
├── starship/starship.toml           # Tokyo Night prompt config (managed by bootstrap)
├── git/
│   ├── .gitconfig                   # Git config (aliases, defaults, delta pager)
│   └── .gitignore_global            # Global gitignore (OS, editor, Python, Node)
├── github/.github/
│   ├── copilot-instructions.md      # Global Copilot instructions (always-on)
│   ├── agents/                      # Custom Copilot agents
│   ├── hooks/                       # Copilot hook packs
│   ├── instructions/                # Context-aware instruction files
│   └── prompts/                     # Custom slash-command prompts
├── vscode/
│   ├── settings.json                # Editor, AI, theme, formatter settings
│   ├── keybindings.json             # Custom keyboard shortcuts
│   └── extensions.json              # 44 recommended extensions
└── zsh/
    ├── .zshrc                       # Shell config (antidote, Starship, tool inits)
    ├── .zsh_plugins.txt             # Antidote plugin list
    └── .zsh/
        ├── aliases.zsh              # Git, navigation, Python, Docker aliases
        ├── functions.zsh            # mkcd, extract, ghclone, killport
        └── path.zsh                 # PATH, EDITOR, LANG
```
