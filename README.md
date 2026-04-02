# Dotfiles

Personal development environment configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Stow Packages

Each directory is an independent stow package that mirrors `~/` structure:

| Package | Contents | Target |
|---------|----------|--------|
| `git/` | `.gitconfig`, `.gitignore_global` | `~/` |
| `github/` | `.github/` — Copilot agents, hooks, instructions, prompts | `~/` |
| `zsh/` | `.zshrc`, Starship config, aliases, functions | `~/` |
| `vscode/` | `settings.json`, `keybindings.json`, `extensions.json` | Platform-specific VSCode User dir |
| `brew/` | `Brewfile` for Homebrew tools | Not stowed — run `brew bundle` manually |
| `mcp/` | `.mcp.json` MCP server config template | `~/` |

## Setup on a New Machine

```bash
# Clone to your preferred location
git clone https://github.com/namitdeb739/dotfiles.git ~/Developer/dotfiles

# Bootstrap: installs stow, stows all packages, backs up conflicts
~/Developer/dotfiles/bootstrap.sh
```

The script:
1. Installs GNU Stow if missing (via Homebrew or apt)
2. Backs up any existing files that would conflict
3. Creates symlinks for each non-empty package
4. Handles VSCode's platform-specific paths separately
5. Verifies `~/.github` integrity

## Selective Install

Install only what you need:

```bash
cd ~/Developer/dotfiles

# Just git config on a server
stow -t ~ git

# Full desktop setup
stow -t ~ git github zsh mcp
```

## Uninstall a Package

```bash
cd ~/Developer/dotfiles
stow -t ~ -D zsh   # Removes all zsh symlinks
```

## Syncing Changes

```bash
cd ~/Developer/dotfiles && git pull
```

Stow symlinks point to the repo, so pulling updates takes effect immediately.

## Verify ~/.github Integrity

```bash
./check-github-managed.sh
```

Exits non-zero if any file under `~/.github` is not tracked by this repo.
