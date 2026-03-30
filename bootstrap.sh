#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

link_with_backup() {
  local source_path="$1"
  local target_path="$2"

  if [[ ! -e "$source_path" ]]; then
    echo "Source missing: $source_path"
    exit 1
  fi

  if [[ -L "$target_path" ]]; then
    local current_target
    current_target="$(readlink "$target_path")"
    if [[ "$current_target" == "$source_path" ]]; then
      echo "Already linked: $target_path -> $source_path"
      return
    fi

    local backup_path="${target_path}.backup-${TIMESTAMP}"
    echo "Backing up existing symlink: $target_path -> $backup_path"
    mv "$target_path" "$backup_path"
  elif [[ -e "$target_path" ]]; then
    local backup_path="${target_path}.backup-${TIMESTAMP}"
    echo "Backing up existing path: $target_path -> $backup_path"
    mv "$target_path" "$backup_path"
  fi

  ln -s "$source_path" "$target_path"
  echo "Linked: $target_path -> $source_path"
}

link_with_backup "$REPO_DIR/.github" "$HOME/.github"
link_with_backup "$REPO_DIR/.gitconfig" "$HOME/.gitconfig"

if [[ -f "$REPO_DIR/check-github-managed.sh" ]]; then
  echo "Running ~/.github management verification..."
  bash "$REPO_DIR/check-github-managed.sh"
fi

echo "Dotfiles bootstrap complete."