#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.dotfiles_backup"

mkdir -p "$BACKUP_DIR"

# Prevent stow from touching backup files
export STOW_IGNORE='\.backup-'

# --- Helpers ---

command_exists() { command -v "$1" &>/dev/null; }

backup_conflicts() {
  local pkg="$1"
  local pkg_dir="$REPO_DIR/$pkg"

  while IFS= read -r -d '' file; do
    local rel="${file#"$pkg_dir"/}"
    local target="$HOME/$rel"

    # Skip backup files entirely
    [[ "$(basename "$rel")" == *.backup-* ]] && continue

    # If symlink
    if [[ -L "$target" ]]; then
      local link_target
      link_target="$(readlink "$target")"

      # Already correct → skip
      if [[ "$link_target" == *"$pkg_dir"* ]]; then
        continue
      fi

      echo "Removing stale symlink: $target -> $link_target"
      rm -f "$target"
      continue
    fi

    # If real file exists → back up once
    if [[ -e "$target" ]]; then
      local backup="$BACKUP_DIR/${rel}.${TIMESTAMP}"
      mkdir -p "$(dirname "$backup")"

      echo "Backing up: $target -> $backup"
      mv "$target" "$backup"
    fi

  done < <(find "$pkg_dir" -type f ! -name "*.backup-*" -print0)
}

stow_package() {
  local pkg="$1"
  local pkg_dir="$REPO_DIR/$pkg"

  if [[ ! -d "$pkg_dir" ]] || [[ -z "$(ls -A "$pkg_dir" 2>/dev/null)" ]]; then
    echo "Skipping $pkg (empty)"
    return
  fi

  echo "Processing package: $pkg"

  backup_conflicts "$pkg"

  stow \
    --dir="$REPO_DIR" \
    --target="$HOME" \
    --restow \
    --no-folding \
    "$pkg"

  echo "Stowed: $pkg"
}

link_vscode() {
  local vscode_src="$REPO_DIR/vscode"
  [[ ! -d "$vscode_src" ]] && return

  local vscode_target
  case "$(uname -s)" in
    Darwin) vscode_target="$HOME/Library/Application Support/Code/User" ;;
    Linux)  vscode_target="$HOME/.config/Code/User" ;;
    *)      vscode_target="$APPDATA/Code/User" ;;
  esac

  mkdir -p "$vscode_target"

  for file in "$vscode_src"/*.json; do
    [[ -f "$file" ]] || continue

    local name
    name="$(basename "$file")"
    local target="$vscode_target/$name"

    if [[ -L "$target" ]]; then
      if [[ "$(readlink "$target")" == "$file" ]]; then
        continue
      fi
      rm "$target"
    elif [[ -e "$target" ]]; then
      local backup="$BACKUP_DIR/vscode/${name}.${TIMESTAMP}"
      mkdir -p "$(dirname "$backup")"
      mv "$target" "$backup"
    fi

    ln -sf "$file" "$target"
    echo "Linked: $target -> $file"
  done
}

install_vscode_extensions() {
  local extensions_file="$REPO_DIR/vscode/extensions.json"
  [[ ! -f "$extensions_file" ]] && return

  if ! command_exists code; then
    echo "VS Code CLI not found — skipping extensions"
    return
  fi

  echo "--- VS Code Extensions ---"

  local installed
  installed="$(code --list-extensions 2>/dev/null)"

  while IFS= read -r ext; do
    if ! echo "$installed" | grep -qi "^${ext}$"; then
      echo "Installing: $ext"
      code --install-extension "$ext" --force || true
    fi
  done < <(python3 -c "import json; [print(e) for e in json.load(open('$extensions_file'))['recommendations']]")
}

install_brew_packages() {
  local brewfile="$REPO_DIR/brew/Brewfile"
  [[ ! -f "$brewfile" ]] && return

  if ! command_exists brew; then
    echo "Homebrew not found. Install it first."
    exit 1
  fi

  echo "--- Homebrew Packages ---"
  brew bundle --file="$brewfile"
}

configure_starship() {
  command_exists starship || return 0

  local config="$HOME/.config/starship.toml"
  local dotfiles_config="$REPO_DIR/starship/starship.toml"

  mkdir -p "$(dirname "$config")"

  if [[ -L "$config" ]]; then
    if [[ "$(readlink "$config")" == "$dotfiles_config" ]]; then
      echo "Starship already configured."
      return
    fi
    rm "$config"
  elif [[ -f "$config" ]]; then
    local backup="$BACKUP_DIR/starship.toml.${TIMESTAMP}"
    mv "$config" "$backup"
  fi

  if [[ -f "$dotfiles_config" ]]; then
    ln -sf "$dotfiles_config" "$config"
    echo "Starship configured."
  fi
}

init_zsh_plugins() {
  local antidote_path
  antidote_path="$(brew --prefix 2>/dev/null)/opt/antidote/share/antidote/antidote.zsh" || true

  if [[ -f "$antidote_path" && -f "$HOME/.zsh_plugins.txt" ]]; then
    echo "--- Zsh Plugins ---"
    zsh -c "source '$antidote_path' && antidote bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.zsh" || true
  fi
}

cleanup_legacy() {
  [[ -d "$HOME/.oh-my-zsh" ]] && rm -rf "$HOME/.oh-my-zsh"
  [[ -f "$HOME/.p10k.zsh" ]] && rm -f "$HOME/.p10k.zsh"
  [[ -d "$HOME/.nvm" ]] && rm -rf "$HOME/.nvm"
  [[ -d "$HOME/.sdkman" ]] && rm -rf "$HOME/.sdkman"

  return 0
}

# ===========================================================
# Main
# ===========================================================

echo "=== Dotfiles Bootstrap ==="

echo "--- Prerequisites ---"

if ! command_exists brew; then
  echo "Homebrew required. Install it first."
  exit 1
fi

if ! command_exists stow; then
  brew install stow
fi

echo "--- Cleanup ---"
cleanup_legacy

install_brew_packages

echo "--- Stow Packages ---"
stow_package "git"
stow_package "github"
stow_package "zsh"

link_vscode
configure_starship
install_vscode_extensions
init_zsh_plugins

if [[ -f "$REPO_DIR/check-github-managed.sh" ]]; then
  echo "--- Verification ---"
  bash "$REPO_DIR/check-github-managed.sh"
fi

echo "=== Bootstrap Complete ==="
