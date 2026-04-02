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

  # No existing config: link dotfiles default and return.
  if [[ ! -e "$config" ]]; then
    if [[ -f "$dotfiles_config" ]]; then
      ln -sf "$dotfiles_config" "$config"
      echo "Starship configured (dotfiles default)."
    fi
    return 0
  fi

  echo "--- Starship ---"
  echo "Found existing config at: $config"
  if [[ -L "$config" ]]; then
    echo "Current symlink target: $(readlink "$config")"
  fi

  if [[ ! -t 0 ]]; then
    echo "Non-interactive shell detected — unable to prompt."
    echo "Keeping existing Starship config. Re-run interactively to change it."
    return 0
  fi

  echo "Choose Starship config:"
  echo "  0) Keep existing"
  echo "  1) Use dotfiles default"
  echo "  2) Choose a preset (1-9)"

  local choice
  read -rp "> " choice

  case "$choice" in
    0)
      echo "Keeping existing Starship config."
      return 0
      ;;
    1)
      if [[ ! -f "$dotfiles_config" ]]; then
        echo "Dotfiles Starship config not found: $dotfiles_config"
        return 0
      fi

      local backup="$BACKUP_DIR/starship.toml.${TIMESTAMP}"
      mv "$config" "$backup"
      ln -sf "$dotfiles_config" "$config"
      echo "Starship configured (dotfiles default)."
      echo "Backed up: $backup"
      return 0
      ;;
    2)
      mapfile -t _starship_presets < <(starship preset --list 2>/dev/null | sed '/^\s*$/d' | head -n 9)

      if (( ${#_starship_presets[@]} == 0 )); then
        echo "No presets found (does your Starship support 'starship preset --list'?)."
        return 0
      fi

      echo "Select a preset:"
      local i
      for i in "${!_starship_presets[@]}"; do
        printf "  %d) %s\n" "$((i + 1))" "${_starship_presets[$i]}"
      done

      local preset_num
      read -rp "> " preset_num

      if [[ ! "$preset_num" =~ ^[1-9]$ ]]; then
        echo "Invalid preset selection."
        return 0
      fi

      local preset_index=$((preset_num - 1))
      if (( preset_index >= ${#_starship_presets[@]} )); then
        echo "Preset $preset_num is not available on this system."
        return 0
      fi

      local preset_name="${_starship_presets[$preset_index]}"
      local backup="$BACKUP_DIR/starship.toml.${TIMESTAMP}"
      mv "$config" "$backup"
      starship preset "$preset_name" > "$config"
      echo "Starship configured (preset: $preset_name)."
      echo "Backed up: $backup"
      return 0
      ;;
    *)
      echo "Invalid selection. Keeping existing Starship config."
      return 0
      ;;
  esac
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
