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
3. **Cleanup** — removes superseded tooling (oh-my-zsh, p10k, nvm, sdkman)
4. **Brew Packages** — installs all CLI tools, casks, and fonts (`brew bundle`)
5. **Stow Packages** — symlinks git, github, zsh, atuin, starship, nvim, ghostty, bin, launchd into `~/`
6. **VS Code Linking** — stows settings, keybindings into the platform-specific VSCode User dir
7. **Claude Config** — stows `claude/` to `~/.claude/`; makes `statusline.sh` and `security-guidance.py` executable
8. **iTerm2 Colors** — imports `iterm2/colors/*.itermcolors` as iTerm2 presets
9. **VS Code Extensions** — installs any missing extensions from `extensions.json`
10. **Zsh Plugins** — pre-compiles antidote plugins for fast first shell launch
11. **Launch Agents** — loads every `com.namitdeb739.*` agent from `~/Library/LaunchAgents`
12. **Verification** — confirms all stow symlinks are intact

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
| `starship/` | `starship.toml` — Catppuccin Mocha prompt config | `~/.config/starship/` |
| `nvim/` | Full neovim config — lazy.nvim, Catppuccin, LSP, telescope | `~/.config/nvim/` |
| `ghostty/` | `config` — Ghostty terminal: Catppuccin Latte/Mocha, JetBrains Mono, keybinds | `~/.config/ghostty/` |
| `bin/` | `theme-toggle`, `dotfiles-update`, `secret` — personal scripts | `~/bin/` |
| `launchd/` | `com.namitdeb739.dotfiles-update.plist` — weekly maintenance job | `~/Library/LaunchAgents/` |
| `vscode/` | `settings.json`, `keybindings.json`, `extensions.json` | Platform-specific VSCode User dir |
| `claude/` | `.claude/` — CLAUDE.md, settings.json, statusline.sh, hooks, agents, commands | `~/` |
| `brew/` | `Brewfile` | Not stowed — used by `brew bundle` directly |

### Shell (zsh)

- **Plugin manager**: [antidote](https://antidote.sh/) — bootstrap pre-compiles plugins to `~/.zsh_plugins.zsh` for fast static loading; falls back to dynamic load if the file is missing
- **Prompt**: [Starship](https://starship.rs/) with the Catppuccin Mocha palette — shows directory, git, python, node, docker, package version, command duration
- **Plugins**: zsh-autosuggestions, fast-syntax-highlighting, zsh-completions, fzf-tab
- **Modular config**: `~/.zsh/aliases.zsh`, `functions.zsh`, `path.zsh`
- **Tool integrations**: zoxide (smart cd), atuin (shell history), fnm (node), uv (python), direnv, fzf
- **Secrets**: stored in the macOS login Keychain, not a plaintext file — see below

### Pre-commit Hooks

`pre-commit install` is run by bootstrap. The hooks are validation-only — nothing
reformats your files — and mirror what CI checks, so breakage surfaces at commit
time rather than after a push.

| Hook | Catches |
| ---- | ------- |
| `gitleaks` | Hardcoded secrets. Verified to catch a Notion `ntn_` token and a `ghp_` PAT. |
| `shellcheck` | Shell script bugs (uses the Brewfile binary, not Docker) |
| `check-yaml` / `check-json` | Malformed workflow and config files |
| `validate VS Code JSONC` | `vscode/*.json` (comments + trailing commas) |
| `validate plists` | `launchd/**/*.plist` via `plutil -lint` |
| `validate ghostty config` | `ghostty +validate-config` |
| `bootstrap.sh syntax` | `bash -n` on the top-level scripts |
| `check-symlinks` / `destroyed-symlinks` | Broken stow links |

```bash
pre-commit run --all-files    # run everything now
pre-commit autoupdate         # bump hook versions
```

### Secrets

Secrets live in the **macOS login Keychain**, so they are encrypted at rest and
backed up by iCloud Keychain sync. Nothing sensitive touches the repo or the
filesystem in plaintext.

```bash
secret set NOTION_TOKEN     # prompts, does not echo, does not hit shell history
secret list                 # names only, never values
secret get NOTION_TOKEN
secret rm  NOTION_TOKEN
```

`~/.zsh/secrets.zsh` exports them into every interactive shell (~30ms). A
plaintext `~/.secrets` is **not** sourced — silently reading credentials from an
unencrypted file is what this replaces, and a working fallback means it never
gets migrated. If one exists, the shell warns on startup. Migrate it with:

```bash
secret import ~/.secrets && secret list && rm -P ~/.secrets
```

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
- **Theme**: `catppuccin/nvim` with `flavour = "auto"` — Latte in light, Mocha in dark, following the same system appearance signal as VS Code and Ghostty
- **Treesitter**: pinned to the `main` branch (the only one supporting Neovim 0.11+); parsers are compiled by the `tree-sitter-cli` formula from the Brewfile
- **LSP**: configured via `vim.lsp.config` / `vim.lsp.enable`, not the deprecated `require("lspconfig")` framework removed in nvim-lspconfig v3
- **Plugins**: treesitter, telescope + fzf-native, lualine, nvim-tree, indent-blankline, which-key, gitsigns, mason + lspconfig (lua, bash, python LSP auto-installed), nvim-cmp + luasnip, nvim-autopairs, Comment.nvim
- **Key mappings**: `<leader>` is `<Space>`; `<leader>ff/fg/fb` for telescope; `gcc` to comment; `<leader>e` for file tree

### Terminal (Ghostty)

Config lives at `ghostty/.config/ghostty/config` and is stowed to `~/.config/ghostty/config`.

- **Theme**: `theme = light:Catppuccin Latte,dark:Catppuccin Mocha` — follows the macOS
  appearance setting, so `theme-toggle` switches the terminal in lockstep with VS Code's
  `window.autoDetectColorScheme`. The bundled themes are byte-identical to
  `iterm2/colors/catppuccin-{latte,mocha}.itermcolors`, so colours match iTerm2 exactly.
- **Font**: `JetBrainsMono Nerd Font Mono` at 14pt — installed by the Brewfile, and the
  source of the powerline separators and language glyphs in `starship.toml`.
- **Shell integration**: auto-injected for zsh (no `.zshrc` changes). Enables OSC 133 prompt
  marking, `cmd+↑`/`cmd+↓` prompt jumping, cwd inheritance for new tabs and splits, and
  terminfo fixes for `sudo` and `ssh`.
- **Matched to VS Code**: `copy-on-select`, blinking block cursor, and `minimum-contrast = 1`
  mirror the `terminal.integrated.*` settings in `vscode/settings.json`.
- **Splits**: `cmd+d` splits right and `cmd+shift+d` splits down, mirroring nvim's
  `splitright` / `splitbelow`.
- **Quick terminal**: `cmd+\`` drops down a Quake-style terminal. Needs Accessibility
  permission (System Settings → Privacy & Security → Accessibility).
- **Local overrides**: create `ghostty/.config/ghostty/local.conf` for per-machine tweaks —
  it is gitignored and included automatically.

Reload after editing with `cmd+shift+,`. Validate with `ghostty +validate-config`.
Full option reference for the installed version: `ghostty +show-config --default --docs`.

iTerm2 is kept installed as a fallback; its Catppuccin presets are still imported by the
`iterm2` bootstrap phase.

### Scheduled Maintenance

`bin/dotfiles-update` upgrades installed software and re-converges the machine onto
the repo. A launchd agent runs it **every Sunday at 10:00**; if the Mac is asleep,
launchd runs it once at next wake.

It deliberately **never touches git** — no pull, no commit, no push. The repo is the
source of truth and only changes when you change it.

What it does, in order:

| Step | Command |
| ---- | ------- |
| Refresh formulae | `brew update` |
| Upgrade | `brew upgrade` (not `--greedy`, so self-updating casks manage themselves) |
| Re-converge | `brew bundle --no-upgrade` — installs anything declared but missing |
| Reclaim disk | `brew cleanup --prune=30` |
| Report drift | packages installed by hand but never declared, and vice versa, plus apps in `/Applications` with no declared cask |
| Update plugins | `antidote update`, then regenerate `~/.zsh_plugins.zsh` |
| Repair symlinks | `stow --restow` for every package |
| Verify | `check-stow-integrity.sh` and `ghostty +validate-config` |

Mac App Store apps are skipped automatically (detected via `_MASReceipt`) since
Homebrew cannot manage them. Anything else with no cask can be silenced by adding
it to `brew/drift-ignore`, one app name per line.

**Brewfile drift** is report-only — it never uninstalls, so a deliberate one-off
install survives an unattended run. It compares `brew leaves --installed-on-request`
and `brew list --cask` against the Brewfile. `brew bundle cleanup` is deliberately
not used: it lists every transitive dependency too, which buries the entries that
actually matter (12 real items here versus ~60 of noise).

Reporting:

- **Silent on success.** A macOS notification fires only when a step fails, naming
  the step that broke.
- **Rotating log** at `~/.local/state/dotfiles-update/update.log` (8 archives kept).
- **Summary on next shell start** — the first new terminal after a run prints what
  upgraded, then deletes the summary so you see it exactly once.

```bash
dfu                  # run it now (alias for dotfiles-update)
dotfiles-update --dry-run   # show what it would do, change nothing
dfu-log              # page the log
```

Managing the schedule:

```bash
launchctl print gui/$(id -u)/com.namitdeb739.dotfiles-update   # status, next fire time
launchctl kickstart -k gui/$(id -u)/com.namitdeb739.dotfiles-update   # run now via launchd
launchctl bootout gui/$(id -u)/com.namitdeb739.dotfiles-update        # disable
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.namitdeb739.dotfiles-update.plist  # re-enable
```

To change the cadence, edit `StartCalendarInterval` in the plist, then re-run
`./bootstrap.sh` (its Launch Agents phase reloads every `com.namitdeb739.*` agent)
or bootout/bootstrap by hand — launchd caches the old schedule until you do.

### VSCode

- Catppuccin Latte/Mocha via `window.autoDetectColorScheme`, Material Icon Theme with extensive file/folder associations
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
| `agents/researcher.md` | VoltAgent/awesome-claude-code-subagents (adapted) | Deep research: web search, source synthesis, clarifying questions via AskUserQuestion |
| `commands/implement.md` | Authored | Implement a task: read context, plan, execute, verify |
| `commands/research.md` | Authored | Deep research and discussion with web-sourced, synthesised answers |
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
# Apply any upstream preset (overwrites the Catppuccin config in this repo)
starship preset catppuccin-powerline -o ~/.config/starship.toml
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
│   └── .config/starship.toml        # Catppuccin Mocha prompt config
├── ghostty/
│   └── .config/ghostty/config        # Catppuccin Latte/Mocha terminal config
├── bin/bin/
│   ├── theme-toggle                 # macOS light/dark switcher
│   ├── dotfiles-update              # weekly maintenance run
│   └── secret                       # Keychain-backed secret manager
├── launchd/Library/LaunchAgents/
│   └── com.namitdeb739.dotfiles-update.plist
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
│   │   ├── github-ops.md
│   │   └── researcher.md
│   └── commands/
│       ├── implement.md
│       ├── research.md
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
