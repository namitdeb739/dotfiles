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

# --- Prerequisites ---

if ! command_exists stow; then
  echo "GNU Stow is not installed."
  if command_exists brew; then
    echo "Installing via Homebrew..."
    brew install stow
  elif command_exists apt-get; then
    echo "Installing via apt..."
    sudo apt-get install -y stow
  else
    echo "Please install GNU Stow manually: https://www.gnu.org/software/stow/"
    exit 1
  fi
fi

# --- Stow packages ---
# Each subdirectory mirrors ~ structure and is independently installable

echo "=== Dotfiles Bootstrap ==="

stow_package "git"
stow_package "github"
stow_package "zsh"
stow_package "mcp"

# VSCode needs special handling (platform-specific paths with spaces)
link_vscode

# Brewfile isn't stowed — it stays in the repo, run `brew bundle` manually
if [[ -f "$REPO_DIR/brew/Brewfile" ]]; then
  echo ""
  echo "Brewfile available at: $REPO_DIR/brew/Brewfile"
  echo "Run 'brew bundle --file=$REPO_DIR/brew/Brewfile' to install tools."
fi

# --- Verification ---

if [[ -f "$REPO_DIR/check-github-managed.sh" ]]; then
  echo ""
  echo "Running ~/.github management verification..."
  bash "$REPO_DIR/check-github-managed.sh"
fi

echo ""
echo "Dotfiles bootstrap complete."
