#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# --- Helpers ---

command_exists() { command -v "$1" &>/dev/null; }

backup_conflicts() {
  # Back up or remove any files/symlinks that would conflict with stow
  local pkg="$1"
  local pkg_dir="$REPO_DIR/$pkg"

  # Walk the package and check each target path
  while IFS= read -r -d '' file; do
    local rel="${file#"$pkg_dir"/}"
    local target="$HOME/$rel"
    if [[ -L "$target" ]]; then
      # Stale symlink (from old bootstrap or another tool) — remove it
      local link_target
      link_target="$(readlink "$target")"
      # Only remove if it doesn't already point into our stow package
      if [[ "$link_target" != *"$pkg_dir"* ]]; then
        echo "Removing stale symlink: $target -> $link_target"
        rm "$target"
      fi
    elif [[ -e "$target" ]]; then
      # Real file — back it up
      local backup="${target}.backup-${TIMESTAMP}"
      echo "Backing up: $target -> $backup"
      mv "$target" "$backup"
    fi
  done < <(find "$pkg_dir" -type f -print0)

  # Also handle directory-level conflicts (e.g., ~/.github/ is a symlink)
  while IFS= read -r -d '' dir; do
    local rel="${dir#"$pkg_dir"/}"
    local target="$HOME/$rel"
    if [[ -L "$target" ]]; then
      local link_target
      link_target="$(readlink "$target")"
      if [[ "$link_target" != *"$pkg_dir"* ]]; then
        echo "Removing stale directory symlink: $target -> $link_target"
        rm "$target"
      fi
    fi
  done < <(find "$pkg_dir" -mindepth 1 -type d -print0)
}

stow_package() {
  local pkg="$1"
  local pkg_dir="$REPO_DIR/$pkg"

  # Skip empty packages (no files yet)
  if [[ ! -d "$pkg_dir" ]] || [[ -z "$(ls -A "$pkg_dir" 2>/dev/null)" ]]; then
    echo "Skipping $pkg (empty)"
    return
  fi

  backup_conflicts "$pkg"
  stow -d "$REPO_DIR" -t "$HOME" --restow "$pkg"
  echo "Stowed: $pkg"
}

link_vscode() {
  # VSCode settings live in platform-specific paths with spaces — handle separately
  local vscode_src="$REPO_DIR/vscode"
  [[ ! -d "$vscode_src" ]] || [[ -z "$(ls -A "$vscode_src" 2>/dev/null)" ]] && return

  local vscode_target
  case "$(uname -s)" in
    Darwin) vscode_target="$HOME/Library/Application Support/Code/User" ;;
    Linux)  vscode_target="$HOME/.config/Code/User" ;;
    *)      vscode_target="$APPDATA/Code/User" ;;  # Windows (Git Bash/WSL)
  esac

  mkdir -p "$vscode_target"
  for file in "$vscode_src"/*.json; do
    [[ -f "$file" ]] || continue
    local name
    name="$(basename "$file")"
    local target="$vscode_target/$name"
    if [[ -e "$target" && ! -L "$target" ]]; then
      mv "$target" "${target}.backup-${TIMESTAMP}"
      echo "Backed up: $target"
    fi
    ln -sf "$file" "$target"
    echo "Linked: $target -> $file"
  done
}

install_vscode_extensions() {
  local extensions_file="$REPO_DIR/vscode/extensions.json"
  [[ ! -f "$extensions_file" ]] && return

  if ! command_exists code; then
    echo "VS Code CLI not found — skipping extension install"
    return
  fi

  echo ""
  echo "--- VS Code Extensions ---"

  # Get currently installed extensions
  local installed
  installed="$(code --list-extensions 2>/dev/null)"

  # Parse recommendations and install missing ones
  local count=0
  while IFS= read -r ext; do
    if ! echo "$installed" | grep -qi "^${ext}$"; then
      echo "Installing: $ext"
      code --install-extension "$ext" --force 2>/dev/null || echo "  Failed: $ext"
      count=$((count + 1))
    fi
  done < <(python3 -c "import json,sys; [print(e) for e in json.load(open('$extensions_file'))['recommendations']]" 2>/dev/null)

  if [[ $count -eq 0 ]]; then
    echo "All extensions already installed."
  else
    echo "Installed $count new extension(s)."
  fi
}

install_brew_packages() {
  local brewfile="$REPO_DIR/brew/Brewfile"
  [[ ! -f "$brewfile" ]] && return

  if ! command_exists brew; then
    echo ""
    echo "Homebrew not found. Install it first:"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    echo "Then re-run this script."
    return
  fi

  echo ""
  echo "--- Homebrew Packages ---"
  brew bundle --file="$brewfile"
  echo "Brewfile installed."
}

init_zsh_plugins() {
  # Source antidote once to generate the static plugin file
  local antidote_path
  antidote_path="$(brew --prefix 2>/dev/null)/opt/antidote/share/antidote/antidote.zsh" || true

  if [[ -f "$antidote_path" ]] && [[ -f "$HOME/.zsh_plugins.txt" ]]; then
    echo ""
    echo "--- Zsh Plugins ---"
    # Generate the static load file so the first shell launch is fast
    zsh -c "source '$antidote_path' && antidote bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.zsh" 2>/dev/null \
      && echo "Antidote plugins pre-compiled." \
      || echo "Antidote plugin pre-compile skipped (will compile on first shell launch)."
  fi
}

# ===========================================================
# Main
# ===========================================================

echo "=== Dotfiles Bootstrap ==="
echo ""

# --- 1. Prerequisites ---

echo "--- Prerequisites ---"

# Ensure Homebrew is available (needed for stow and everything else)
if ! command_exists brew; then
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "Homebrew not found. Install it first:"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    echo "Then re-run this script."
    exit 1
  fi
fi

if ! command_exists stow; then
  echo "Installing GNU Stow..."
  brew install stow
fi

echo "Prerequisites OK."

# --- 2. Brew packages (install tools before stowing, so stow/starship/etc. are available) ---

install_brew_packages

# --- 3. Stow packages ---

echo ""
echo "--- Stow Packages ---"

stow_package "git"
stow_package "github"
stow_package "zsh"

# VSCode needs special handling (platform-specific paths with spaces)
link_vscode

# --- 4. VS Code extensions ---

install_vscode_extensions

# --- 5. Zsh plugin pre-compile ---

init_zsh_plugins

# --- 6. Verification ---

if [[ -f "$REPO_DIR/check-github-managed.sh" ]]; then
  echo ""
  echo "--- Verification ---"
  bash "$REPO_DIR/check-github-managed.sh"
fi

# --- Done ---

echo ""
echo "=== Bootstrap Complete ==="
echo ""
echo "Open a new terminal to activate your new shell config."
echo "If Starship prompt doesn't appear, run: exec zsh"
