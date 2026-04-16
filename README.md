# Dotfiles

Personal development environment configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

One command sets up a new machine: shell, git, editor, AI tooling, CLI tools, and prompt theme.

## Prerequisites

- macOS with [Homebrew](https://brew.sh/) installed
- [Nerd Font](https://www.nerdfonts.com/) in your terminal (bootstrap installs JetBrains Mono and Fira Code Nerd Fonts via Brewfile)

## Setup on a New Machine

```bash
# 1. Clone anywhere — the path does not need to match ~/Developer/dotfiles
git clone https://github.com/namitdeb739/dotfiles.git ~/Developer/dotfiles

# 2. Bootstrap (does everything)
cd ~/Developer/dotfiles
chmod +x bootstrap.sh check-stow-integrity.sh
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
2. **SSH Key** — interactive: generates `~/.ssh/id_ed25519` if missing, optionally uploads to GitHub
3. **Brewfile** — installs all CLI tools, casks, and fonts (`brew bundle`)
4. **Stow packages** — symlinks git, github, zsh, atuin, starship, nvim configs into `~/`
5. **VS Code** — stows settings, keybindings into the platform-specific VSCode User dir
6. **Claude Config** — stows `claude/` to `~/.claude/`; makes `statusline.sh` and `security-guidance.py` executable
7. **Starship prompt** — interactive preset chooser (Dracula default, or pick from 9 presets); non-interactive runs keep the existing config
8. **VS Code extensions** — installs any missing extensions from `extensions.json`
9. **Zsh plugins** — pre-compiles antidote plugins for fast first shell launch
10. **Verification** — confirms all stow symlinks are intact

## Syncing Updates

```bash
cd ~/Developer/dotfiles
git pull
```

Stow symlinks point into the repo, so `git pull` applies changes immediately. Re-run `./bootstrap.sh` only if new Brew packages or VS Code extensions were added.

## What's Included

### Stow Packages

Each directory is an independent stow package that mirrors `~/` structure:

| Package | Contents | Target |
| ------- | -------- | ------ |
| `git/` | `.gitconfig`, `.gitignore_global` | `~/` |
| `github/` | `.github/` — Copilot agents, hooks, instructions, prompts | `~/.github/` |
| `zsh/` | `.zshrc`, aliases, functions, PATH, plugin list | `~/` |
| `atuin/` | `config.toml` — fuzzy search, noise filter, preview | `~/.config/atuin/` |
| `starship/` | `starship.toml` — Dracula prompt config | `~/.config/starship/` |
| `nvim/` | Full neovim config — lazy.nvim, Dracula, LSP, telescope | `~/.config/nvim/` |
| `vscode/` | `settings.json`, `keybindings.json`, `extensions.json` | Platform-specific VSCode User dir |
| `claude/` | `.claude/` — CLAUDE.md, settings.json, statusline.sh, hooks, agents, commands | `~/` |
| `brew/` | `Brewfile` | Not stowed — used by `brew bundle` directly |

### Shell (zsh)

- **Plugin manager**: [antidote](https://antidote.sh/) — bootstrap pre-compiles plugins to `~/.zsh_plugins.zsh` for fast static loading; falls back to dynamic load if the file is missing
- **Prompt**: [Starship](https://starship.rs/) with Dracula theme — shows directory, git, python, node, docker, package version, command duration
- **Plugins**: zsh-autosuggestions, fast-syntax-highlighting, zsh-completions, fzf-tab
- **Modular config**: `~/.zsh/aliases.zsh`, `functions.zsh`, `path.zsh`
- **Tool integrations**: zoxide (smart cd), atuin (shell history), fnm (node), uv (python), direnv, fzf
- **Secrets**: `~/.secrets` is sourced silently if it exists — put API keys and tokens there; it is gitignored globally

### Git

- Shell aliases: `gs`, `gco`, `glog`, `gd`, `gds` (in `aliases.zsh`)
- Git config aliases: `cm`, `ca`, `cp`, `ll`, `undo`, `unstage`, `wip`, `cleanup` (unique shorthands only — no duplication of shell aliases)
- Defaults: `push.default=current`, `pull.rebase=true`, `init.defaultBranch=main`, `autoSetupRemote=true`
- Pager: [delta](https://github.com/dandavison/delta) for better diffs
- Credential helper: GitHub CLI (`gh auth git-credential`)
- Global `.gitignore_global` for OS/editor/Python/Node/secrets cruft

### Neovim

Config lives at `nvim/.config/nvim/` and is stowed to `~/.config/nvim/`.

- **Plugin manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) — self-bootstraps on first launch, lazy-loads everything
- **Theme**: `Mofiqul/dracula.nvim` with Dracula Soft background — matches VS Code + starship palette
- **Plugins**: treesitter, telescope + fzf-native, lualine, nvim-tree, indent-blankline, which-key, gitsigns, mason + lspconfig (lua, bash, python LSP auto-installed), nvim-cmp + luasnip, nvim-autopairs, Comment.nvim
- **Key mappings**: `<leader>` is `<Space>`; `<leader>ff/fg/fb` for telescope; `gcc` to comment; `<leader>e` for file tree

### VSCode

- Dracula Theme Soft, Material Icon Theme with extensive file/folder associations
- Format on save with Ruff (Python) and Prettier (JSON)
- Full Copilot/AI configuration: agent mode, MCP auto-start, terminal auto-approve lists, custom instructions/agents/prompts locations, commit message generation
- Extensions synced via `extensions.json`

### Copilot AI Configuration

This repository manages Copilot customizations as code under `github/.github` (stowed to `~/.github`).

Use these docs as the canonical inventories:

| Area | Canonical Inventory |
| ---- | ------------------- |
| Agents | [github/.github/docs/README.agents.md](github/.github/docs/README.agents.md) |
| Hooks | [github/.github/docs/README.hooks.md](github/.github/docs/README.hooks.md) |
| Prompts | [github/.github/docs/README.prompts.md](github/.github/docs/README.prompts.md) |
| Instructions | [github/.github/docs/README.instructions.md](github/.github/docs/README.instructions.md) |
| Skills | [github/.github/docs/README.skills.md](github/.github/docs/README.skills.md) |
| Workflows | [github/.github/docs/README.workflows.md](github/.github/docs/README.workflows.md) |

### Claude Code Configuration

Managed under `claude/.claude/` (stowed to `~/.claude/`). Bootstrap runs `setup_claude()` which stows the package and sets executable permissions on the statusline and hook scripts.

| File | Source | Purpose |
| ---- | ------ | ------- |
| `CLAUDE.md` | Authored | Global behavioral rules: communication, code style, Python stack, shell, git, security |
| `settings.json` | Authored | Permissions (allow/deny), PreToolUse security hook, status line command |
| `statusline.sh` | Authored | Status bar: `folder \| branch \| model \| ctx%` with color-coded context usage |
| `hooks/security-guidance.py` | Anthropic security-guidance plugin (adapted) | Warns once per file on dangerous patterns: `eval()`, `shell=True`, `innerHTML`, GitHub Actions injection |
| `agents/python-pro.md` | VoltAgent/awesome-claude-code-subagents (adapted) | Python specialist: uv, ruff, mypy strict, FastAPI, pytest, bandit |
| `agents/code-reviewer.md` | VoltAgent/awesome-claude-code-subagents | Multi-language code review: security, performance, correctness, maintainability |
| `agents/github-ops.md` | Ported from `github-ops-executor.agent.md` | GitHub PR/issue/branch lifecycle with safety gates |
| `commands/implement.md` | Authored | Implement a task: read context, plan, execute, verify |
| `commands/commit-push.md` | Authored | Conventional Commits + push to remote |
| `commands/commit-push-pr.md` | Authored | Commit + push + open PR via `gh` |
| `commands/tdd-cycle.md` | wshobson/commands | Full TDD: spec → red → green → refactor → integration |
| `commands/full-review.md` | wshobson/commands | Multi-agent review: quality, security, architecture, performance, coverage |
| `commands/security-scan.md` | wshobson/commands | bandit + semgrep + pip-audit with OWASP Top 10 coverage |
| `commands/feature-build.md` | wshobson/commands | End-to-end feature: design → backend → frontend → tests → deploy |
| `commands/smart-fix.md` | wshobson/commands | Auto-routes to debugger, perf engineer, DB optimizer, or modernizer |
| `commands/tech-debt.md` | wshobson/commands | Debt inventory with ROI-scored remediation plan |
| `commands/doc-write.md` | wshobson/commands | Generate API docs, architecture diagrams, user guides |

MCP servers are registered at user scope via `setup_claude()` in bootstrap. They are stored in `~/.claude.json` (not stowed) and registered idempotently on each bootstrap run.

| MCP | Package | Purpose |
| --- | ------- | ------- |
| `github` | `@modelcontextprotocol/server-github` | GitHub API: search code, read issues/PRs, manage repos |
| `context7` | `@upstash/context7-mcp` | Resolves current library docs at query time — prevents stale API usage |
| `sequential-thinking` | `@modelcontextprotocol/server-sequential-thinking` | Structured multi-step reasoning scratchpad |
| `filesystem` | `@modelcontextprotocol/server-filesystem` | Explicit file access rooted at `~/` |
| `docker` | `@modelcontextprotocol/server-docker` | Container and image management |

`GITHUB_TOKEN` is sourced from `gh auth token` at bootstrap time. If unavailable, register manually:

```bash
claude mcp add -s user -e GITHUB_TOKEN=$(gh auth token) github -- npx -y @modelcontextprotocol/server-github
```

### Brewfile (CLI Tools)

Installed via `brew bundle` during bootstrap:

| Category | Tools |
| -------- | ----- |
| Shell | stow, starship, antidote, zoxide, atuin, gum |
| Core CLI | git, gh, git-delta, fzf, fd, ripgrep, bat, eza, jq, tree, htop, tldr, direnv, shellcheck, neovim |
| Python | uv, ruff |
| Node | fnm |
| Build | just, pre-commit |
| Casks | VS Code, iTerm2, Raycast |
| Fonts | JetBrains Mono Nerd Font, Fira Code Nerd Font |

### CI

GitHub Actions workflow (`.github/workflows/ci.yml`):

- **ShellCheck** — lints `bootstrap.sh` and `check-stow-integrity.sh`
- **JSON validation** — validates all hook configs and MCP config
- **VS Code JSONC validation** — validates `vscode/settings.json`, `vscode/keybindings.json`, and `vscode/extensions.json` via `scripts/validate_vscode_jsonc.py`
- **Bootstrap smoke test** — runs full bootstrap on macOS runner, verifies symlinks
- **Bootstrap Linux sanity** — verifies bootstrap script syntax/help and argument guard behavior on Ubuntu

## Selective Install

Install only specific packages on a minimal machine (e.g., server):

```bash
cd ~/Developer/dotfiles
stow -t ~ git              # just git config
stow -t ~ git zsh          # git + shell
stow -t ~ git zsh atuin    # git + shell + history config
```

## Uninstall a Package

```bash
cd ~/Developer/dotfiles
stow -t ~ -D zsh     # removes all zsh symlinks from ~/
```

## Reconfigure Starship Prompt

```bash
# Re-run the preset chooser
./bootstrap.sh  # select a new preset at the Starship step

# Or manually apply any preset
starship preset dracula -o ~/.config/starship.toml
starship preset tokyo-night -o ~/.config/starship.toml

# Or edit directly
code ~/.config/starship.toml
```

## Secrets

Put API keys, tokens, and any credential that cannot be committed in `~/.secrets`:

```bash
# ~/.secrets — created manually on each machine, never committed
export OPENAI_API_KEY="sk-..."
export GITHUB_TOKEN="ghp_..."
```

The file is sourced silently by `.zshrc` on every shell start and is covered by `.gitignore_global`.

## Verify Stow Integrity

```bash
./check-stow-integrity.sh
```

Exits non-zero if any file under a stow target is not a symlink pointing into this repo.

## VS Code Config Validation Policy

VS Code user config files under `vscode/` are validated in CI using JSONC-aware parsing (comments and trailing commas allowed).

```bash
# Run the same JSONC validation locally
python3 scripts/validate_vscode_jsonc.py
```

## File Structure

```text
dotfiles/
├── .github/
│   ├── CODEOWNERS
│   ├── dependabot.yml
│   └── workflows/
│       └── ci.yml
├── SECURITY.md
├── bootstrap.sh                      # One-command setup script
├── check-stow-integrity.sh           # Verifies all stow symlinks are intact
├── brew/Brewfile                     # Homebrew packages, casks, fonts
├── scripts/validate_vscode_jsonc.py  # JSONC validation for VS Code config files
├── atuin/
│   └── .config/atuin/config.toml    # atuin history config
├── starship/
│   └── .config/starship.toml        # Dracula prompt config
├── nvim/
│   └── .config/nvim/
│       ├── init.lua
│       └── lua/
│           ├── config/              # options, keymaps, lazy bootstrap
│           └── plugins/             # one file per plugin group
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
├── github/.github/
│   ├── copilot-instructions.md
│   ├── agents/
│   ├── docs/
│   ├── hooks/
│   ├── instructions/
│   ├── prompts/
│   ├── skills/
│   └── workflows/
├── vscode/
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.json
├── claude/.claude/
│   ├── CLAUDE.md
│   ├── settings.json
│   ├── statusline.sh
│   ├── hooks/
│   │   └── security-guidance.py
│   ├── agents/
│   │   ├── python-pro.md
│   │   ├── code-reviewer.md
│   │   └── github-ops.md
│   └── commands/
│       ├── implement.md
│       ├── commit-push.md
│       ├── commit-push-pr.md
│       ├── tdd-cycle.md
│       ├── full-review.md
│       ├── security-scan.md
│       ├── feature-build.md
│       ├── smart-fix.md
│       ├── tech-debt.md
│       └── doc-write.md
└── zsh/
    ├── .zshrc
    ├── .zsh_plugins.txt
    └── .zsh/
        ├── aliases.zsh
        ├── functions.zsh
        └── path.zsh
```
