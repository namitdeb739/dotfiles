# Dotfiles

Personal development environment configuration, managed with [GNU
Stow](https://www.gnu.org/software/stow/).

One command sets up a new machine: shell, git, editor, AI tooling, CLI tools, and prompt theme.

## Prerequisites

- macOS with [Homebrew](https://brew.sh/) installed
- [Nerd Font](https://www.nerdfonts.com/) in your terminal (bootstrap installs JetBrains Mono and
  Fira Code Nerd Fonts via Brewfile)

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

The bootstrap script runs these steps automatically and prints a phase-by-phase status summary at
the end:

1. **Prerequisites** — installs GNU Stow via Homebrew
2. **SSH Key** — interactive: generates `~/.ssh/id_ed25519` if missing, optionally uploads to GitHub
3. **Cleanup** — removes superseded tooling (oh-my-zsh, p10k, nvm, sdkman)
4. **Brew Packages** — installs all CLI tools, casks, and fonts (`brew bundle`)
5. **Stow Packages** — symlinks git, github, zsh, atuin, starship, nvim, ghostty, bin, launchd into
   `~/`
6. **VS Code Linking** — stows settings, keybindings into the platform-specific VSCode User dir
7. **Claude Config** — stows `claude/` to `~/.claude/`; makes `statusline.sh` and
   every `hooks/*.py` and `hooks/*.sh` executable; registers MCP servers
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

Stow symlinks point into the repo, so `git pull` applies changes immediately. Re-run
`./bootstrap.sh` only if new Brew packages or VS Code extensions were added.

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
| `ssh/` | `config` — host defaults, Keychain, connection reuse | `~/.ssh/` |
| `lazygit/` | `config.yml` — delta pager, Catppuccin, conventional-commit prompt | `~/Library/Application Support/lazygit/` |
| `act/` | `.actrc` — Apple Silicon runner defaults | `~/` |
| `tmux/` | `tmux.conf` — session persistence, Catppuccin, vi copy-mode | `~/.config/tmux/` |
| `karabiner/` | `karabiner.json` — key remapping | `~/.config/karabiner/` |
| `gh/` | `config.yml` — aliases and protocol (not `hosts.yml`) | `~/.config/gh/` |
| `vscode/` | `settings.json`, `keybindings.json`, `extensions.json` | Platform-specific VSCode User dir |
| `claude/` | `.claude/` — CLAUDE.md, settings.json, statusline.sh, hooks, agents, commands | `~/` |
| `brew/` | `Brewfile` | Not stowed — used by `brew bundle` directly |

### Shell (zsh)

- **Plugin manager**: [antidote](https://antidote.sh/) — bootstrap pre-compiles plugins to
  `~/.zsh_plugins.zsh` for fast static loading; falls back to dynamic load if the file is missing
- **Prompt**: [Starship](https://starship.rs/) with the Catppuccin Mocha palette — shows directory,
  git, python, node, docker, package version, command duration
- **Plugins**: zsh-autosuggestions, fast-syntax-highlighting, zsh-completions, fzf-tab
- **Modular config**: `~/.zsh/aliases.zsh`, `functions.zsh`, `path.zsh`
- **Tool integrations**: zoxide (smart cd), atuin (shell history), fnm (node), uv (python), direnv,
  fzf
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

### macOS Defaults

`macos.sh` configures the OS itself — everything else in this repo configures
tools. Run by bootstrap, idempotent, and safe to re-run.

```bash
./macos.sh --dry-run   # print every change, write nothing
./macos.sh             # apply
```

Covers fast key repeat (and disabling the accent picker, which otherwise breaks
held-key navigation), disabling smart quotes and dashes, Finder showing
extensions and hidden files, Dock autohide with no delay, and screenshots as
shadowless PNGs in `~/Pictures/Screenshots`.

It deliberately does **not** touch FileVault, Gatekeeper or SIP, and needs no
`sudo` — those are manual decisions.

### SSH

`ssh/.ssh/config` sets Keychain-backed key loading, `IdentitiesOnly` (so ssh
does not burn through a server's `MaxAuthTries` offering every key), keepalives,
and connection multiplexing via `~/.ssh/sockets`.

Machine-specific hosts go in `~/.ssh/config.local`, which is included first and
never committed. **Keys are never in this repo** — only this config.

### tmux

Ghostty deliberately has no session persistence, so a crash or restart loses
every running process. tmux fills that gap.

Deliberately plugin-free — no TPM, nothing to bootstrap or update. Prefix is
`C-a` (`C-b` collides with vim's page-up), splits are `|` and `-` opening in the
current directory and matching nvim's `splitright`/`splitbelow`, and copy-mode is
vi-style piping to `pbcopy`.

Like lazygit, the theme is fixed to Catppuccin Mocha — tmux cannot follow the
system appearance.

```bash
tmux new -A -s main    # attach or create
# prefix r             # reload config
```

### Git

- Shell aliases: `gs`, `gco`, `glog`, `gd`, `gds` (in `aliases.zsh`)
- Git config aliases: `cm`, `ca`, `cp`, `ll`, `undo`, `unstage`, `wip`, `cleanup` (unique shorthands
  only — no duplication of shell aliases)
- Defaults: `push.default=current`, `pull.rebase=true`, `init.defaultBranch=main`,
  `autoSetupRemote=true`
- Pager: [delta](https://github.com/dandavison/delta) for better diffs
- Credential helper: GitHub CLI (`gh auth git-credential`)
- Global `.gitignore_global` for OS/editor/Python/Node/secrets cruft

### Neovim

Config lives at `nvim/.config/nvim/` and is stowed to `~/.config/nvim/`.

- **Plugin manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) — self-bootstraps on first
  launch, lazy-loads everything
- **Theme**: `catppuccin/nvim` with `flavour = "auto"` — Latte in light, Mocha in dark, following
  the same system appearance signal as VS Code and Ghostty
- **Treesitter**: pinned to the `main` branch (the only one supporting Neovim 0.11+); parsers are
  compiled by the `tree-sitter-cli` formula from the Brewfile
- **LSP**: configured via `vim.lsp.config` / `vim.lsp.enable`, not the deprecated
  `require("lspconfig")` framework removed in nvim-lspconfig v3
- **Plugins**: treesitter, telescope + fzf-native, lualine, nvim-tree, indent-blankline, which-key,
  gitsigns, mason + lspconfig (lua, bash, python LSP auto-installed), nvim-cmp + luasnip,
  nvim-autopairs, Comment.nvim
- **Key mappings**: `<leader>` is `<Space>`; `<leader>ff/fg/fb` for telescope; `gcc` to comment;
  `<leader>e` for file tree

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

- Catppuccin Latte/Mocha via `window.autoDetectColorScheme`, Material Icon Theme with extensive
  file/folder associations
- Format on save with Ruff (Python) and Prettier (JSON)
- Full Copilot/AI configuration: agent mode, MCP auto-start, terminal auto-approve lists, custom
  instructions/agents/prompts locations, commit message generation
- Extensions synced via `extensions.json`

### Copilot AI Configuration

This repository manages Copilot customizations as code under `github/.github` (stowed to
`~/.github`).

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

Managed under `claude/.claude/` (stowed to `~/.claude/`). Bootstrap runs `setup_claude()` which
stows the package, makes `statusline.sh` and every `hooks/*.py` and `hooks/*.sh` executable, and
registers MCP servers.

| File | Purpose |
| ---- | ------- |
| `CLAUDE.md` | Global rules: communication, code style, shell, lookup routing, git, compaction |
| `settings.json` | Permissions, hook wiring, enabled plugins, sandbox, autoMode, tool search |
| `settings.local.json` | Machine-local permission and autoMode overrides |
| `statusline.sh` | Status bar: `folder \| branch \| model \| ctx%` with colour-coded context usage |
| `rules/python.md` | Path-scoped Python stack rules (`paths:` frontmatter) |
| `rules/shell.md` | Path-scoped shell rules |
| `hooks/security-guidance.py` | PreToolUse on edits — warns once per file on `eval()`, `shell=True`, `innerHTML`, GHA injection |
| `hooks/format-on-edit.py` | PostToolUse on edits — `ruff format` / `clang-format -i`, never blocks |
| `hooks/verify-python.py` | Stop — refuses to end a turn on unverified Python (`pytest`, `mypy --strict`) |
| `hooks/no-cd.py` | PreToolUse on Bash — warns once per session against `cd`; never blocks |
| `hooks/prefer-native-tools.py` | PreToolUse on Bash — routes `cat`/`grep`/`find`/`sed -i` to Read/Grep/Glob/Edit; never blocks |
| `hooks/notify-on-stop.sh` | Stop — macOS notification when a response completes |
| `hooks/notify-on-question.sh` | PreToolUse on AskUserQuestion — macOS notification when Claude waits on an answer |
| `hooks/notify.sh` | Shared notifier both use; attributes the banner to the terminal hosting the session |
| `skills/uv-python-quality/` | The uv quality gate, run proactively before `verify-python.py` fires |
| `agents/discuss.md` | Research subagent: web search, source synthesis, opinionated verdicts |
| `commands/implement.md` | Implement a task: read context, plan, execute, verify |
| `commands/spec.md` | Interview on hard decisions, write `SPEC.md`, stop without implementing |
| `commands/discuss.md` | Delegates to the `discuss` agent |
| `commands/commit-push.md` | Conventional Commits + push |
| `commands/commit-push-pr.md` | Commit + push + open PR via `gh` |
| `commands/merge-pr.md` | Merge only when green; investigates `BLOCKED` merge state |
| `commands/fix-ci.md` | Triage a failing GH Actions run, ruling out infra first |
| `commands/latex-suite.md` | Edit Obsidian LaTeX Suite snippets and keep the cheat sheet in sync |

#### Notifications

Claude Code's built-in notification channels are all terminal escape sequences
(iTerm2, kitty, Ghostty), which the VS Code terminal does not implement — hence
`notify-on-stop.sh`. `AskUserQuestion` additionally never fires the `Notification`
hook at all ([#59908](https://github.com/anthropics/claude-code/issues/59908)), so
`notify-on-question.sh` rides on `PreToolUse` instead.

macOS attributes a notification to the bundle of the process that posts it, and
the UserNotifications framework refuses bundle-id spoofing — this is why
`terminal-notifier` dropped `-sender` in 3.0 and why bare `osascript` shows up as
Script Editor. So `notify.sh` posts from a per-host app bundle wrapping a copy of
`osascript`, generated on first use under `~/.claude/notifiers/` and carrying the
host terminal's own icon. A VS Code session notifies as VS Code, a Ghostty session
as Ghostty. The bundles are generated, not stowed; delete the directory to rebuild.

Plugins are enabled in `settings.json` under `enabledPlugins`, all from
`claude-plugins-official`: `superpowers` (the skill backbone), `code-review`,
`code-simplifier`, `commit-commands`, `hookify`, `claude-md-management`, and the
LSP plugins `clangd-lsp` and `pyright-lsp`. `typescript-lsp` and
`pr-review-toolkit` are present but disabled.

MCP servers are registered at user scope via `setup_claude()`. They live in
`~/.claude.json` (not stowed) and are registered idempotently on each run.

| MCP | Package | Purpose |
| --- | ------- | ------- |
| `chrome-devtools` | `chrome-devtools-mcp` | Browser automation and page inspection |

Notion is **not** registered here — it arrives as the claude.ai connector
(OAuth, synced from the account), so a `claude mcp add` entry would duplicate
every tool. Reconnect it at claude.ai/settings/connectors.

The rule is **if there is a good CLI, use the CLI**. MCP earns a slot only for
services with no local CLI and real auth complexity. `github`, `filesystem`,
`sequential-thinking`, `docker` and `context7` were deliberately removed; see the
comment in `setup_claude()` for the measured reasoning behind each.

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
- **VS Code JSONC validation** — validates `vscode/settings.json`, `vscode/keybindings.json`, and
  `vscode/extensions.json` via `scripts/validate_vscode_jsonc.py`
- **Bootstrap smoke test** — runs full bootstrap on macOS runner, verifies symlinks
- **Bootstrap Linux sanity** — verifies bootstrap script syntax/help and argument guard behavior on
  Ubuntu

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

## Managing Secrets

See [Secrets](#secrets) above — credentials live in the macOS login Keychain
and are managed with the `secret` command. A plaintext `~/.secrets` is **not**
sourced; if one exists the shell warns on startup so it gets migrated rather
than silently relied on.

## Verify Stow Integrity

```bash
./check-stow-integrity.sh
```

Exits non-zero if any file under a stow target is not a symlink pointing into this repo.

## VS Code Config Validation Policy

VS Code user config files under `vscode/` are validated in CI using JSONC-aware parsing (comments
and trailing commas allowed).

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
│   ├── settings.local.json
│   ├── statusline.sh
│   ├── rules/
│   │   ├── python.md
│   │   └── shell.md
│   ├── hooks/
│   │   ├── security-guidance.py
│   │   ├── format-on-edit.py
│   │   ├── verify-python.py
│   │   ├── no-cd.py
│   │   ├── prefer-native-tools.py
│   │   ├── notify.sh
│   │   ├── notify-on-stop.sh
│   │   └── notify-on-question.sh
│   ├── skills/
│   │   └── uv-python-quality/SKILL.md
│   ├── agents/
│   │   └── discuss.md
│   └── commands/
│       ├── implement.md
│       ├── spec.md
│       ├── discuss.md
│       ├── commit-push.md
│       ├── commit-push-pr.md
│       ├── merge-pr.md
│       ├── fix-ci.md
│       └── latex-suite.md
└── zsh/
    ├── .zshrc
    ├── .zsh_plugins.txt
    └── .zsh/
        ├── aliases.zsh
        ├── functions.zsh
        └── path.zsh
```
