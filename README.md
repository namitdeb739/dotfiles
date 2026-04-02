# Dotfiles

Personal development environment configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

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

The bootstrap script runs these steps automatically:

1. **Prerequisites** — installs GNU Stow via Homebrew
2. **Brewfile** — installs all CLI tools, casks, and fonts (`brew bundle`)
3. **Stow packages** — symlinks git, github, zsh configs into `~/`
4. **VSCode** — symlinks settings, keybindings into the platform-specific VSCode User dir
5. **Starship prompt** — interactive preset chooser (Tokyo Night default, or pick from 9 presets)
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

### Copilot AI Agents

11 specialized agents with role-based tool grants, MCP server access, and workflow handoffs:

| Agent | Model Tier | Purpose | MCP Servers |
| ------- | ----------- | --------- | ------------- |
| Code Reviewer | Opus | SOLID/security review, severity reporting | GitHub, Context7 |
| Debugger | Sonnet | Read-only root cause investigation | GitHub, Context7 |
| DevOps | Sonnet | CI/CD, Docker, GitHub Actions | GitHub, Context7, Playwright |
| Doc Writer | Sonnet | READMEs, API docs, architecture docs | Context7, MarkItDown, Notion |
| Dotfiles Editor | Opus | Maintains this repo | GitHub |
| Implementor | Opus | Full-autonomy task execution | All (wildcard) |
| Planner | Opus | Codebase exploration, implementation planning | GitHub, Context7 |
| PR Writer | Sonnet | Structured PR creation from git changes | GitHub |
| Refactorer | Sonnet | Behavior-preserving code restructuring | Context7 |
| Security Auditor | Opus | OWASP, secrets, dependency vulnerability scan | GitHub |
| Testing Expert | Sonnet | Coverage gap analysis, test writing | Context7 |

**Workflow handoffs**: Planner → Implementor → Code Reviewer / Testing Expert. Debugger → Implementor. Refactorer → Testing Expert.

### Copilot Hooks

7 safety and quality hooks:

| Hook | Event | Behavior |
| ------ | ------- | ---------- |
| Secrets Guard | PreToolUse | Blocks commits containing `.env`, `.pem`, `.key`, credentials |
| Dangerous Git Guard | PreToolUse | Blocks `push --force`, `reset --hard`, `clean -f`, `branch -D` |
| Commit Message Standards | PreToolUse | Blocks non-Conventional-Commits messages |
| Branch Name Validator | PreToolUse | Warns on non-standard branch names |
| Pre-commit Format | PreToolUse | Auto-runs `ruff format` / `prettier` before commits |
| Commit Reminder | PostToolUse | Reminds to commit after 5+ uncommitted file changes |
| Test Reminder | PostToolUse | Reminds to run tests after 5+ file edits |

### Copilot Prompts (Slash Commands)

| Command | Routes to | Purpose |
| --------- | ----------- | --------- |
| `/check` | (inline) | Run tests, diagnostics, report project health |
| `/commit` | (inline) | Smart commit with GitKraken AI or plain git |
| `/do` | Implementor | Full-autonomy task execution |
| `/dotfiles` | Dotfiles Editor | Edit this dotfiles repo |
| `/plan` | Planner | Implementation planning without code changes |
| `/pr` | PR Writer | Create a structured PR |
| `/review` | Code Reviewer | Review + auto-fix critical/major issues |

### Copilot Instructions

Context-aware instruction files auto-applied by file pattern:

| File | Applies to | Content |
| ------ | ----------- | --------- |
| `copilot-instructions.md` | Always | Global coding standards, SOLID, security, git conventions |
| `python.instructions.md` | `**/*.py` | Type hints, Google docstrings, pytest, Ruff style |
| `ml.instructions.md` | `**/*.ipynb`, `**/ml/**` | Reproducibility, data splitting, experiment tracking |
| `docker-infra.instructions.md` | `**/Dockerfile*`, `**/docker-compose*`, `**/*.tf` | Image pinning, layer ordering, no secrets |
| `markdown.instructions.md` | `**/*.md` | Heading structure, active voice, code block language tags |

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
│   ├── agents/                      # 11 custom Copilot agents
│   ├── hooks/                       # 7 safety/quality hooks
│   ├── instructions/                # 4 context-aware instruction files
│   └── prompts/                     # 7 slash commands
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
