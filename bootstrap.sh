#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.dotfiles_backup"
START_EPOCH="$(date +%s)"

mkdir -p "$BACKUP_DIR"

# Prevent stow from touching backup files
export STOW_IGNORE='\.backup-'

# Runtime controls
FORCE_INTERACTIVE=0
FORCE_NONINTERACTIVE=0
INTERACTIVE_MODE=0
SELECT_SECTIONS=0
SKIP_EXTENSIONS=0
BOOTSTRAP_NONINTERACTIVE="${BOOTSTRAP_NONINTERACTIVE:-0}"
BOOTSTRAP_UI="${BOOTSTRAP_UI:-auto}"
GUM_AVAILABLE=0

# Section toggles
RUN_CLEANUP=1
RUN_BREW=1
RUN_STOW=1
RUN_VSCODE=1
RUN_EXTENSIONS=1
RUN_ZSH_PLUGINS=1
RUN_VERIFICATION=1
RUN_SSH_KEY=1
RUN_CLAUDE=1
RUN_ITERM2=1
RUN_LAUNCHD=1
RUN_MACOS=1

# Summary tracking
SUMMARY_PRINTED=0
PHASE_NAMES=()
PHASE_STATUSES=()
PHASE_SECONDS=()

# Colors and style
STYLE_RESET=""
STYLE_BOLD=""
COLOR_BLUE=""
COLOR_GREEN=""
COLOR_YELLOW=""
COLOR_RED=""

# --- Helpers ---

command_exists() { command -v "$1" &>/dev/null; }

setup_styles() {
  if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    STYLE_RESET="\033[0m"
    STYLE_BOLD="\033[1m"
    COLOR_BLUE="\033[34m"
    COLOR_GREEN="\033[32m"
    COLOR_YELLOW="\033[33m"
    COLOR_RED="\033[31m"
  fi
}

log_info() {
  printf "%b[INFO]%b %s\n" "$COLOR_BLUE" "$STYLE_RESET" "$*"
}

log_warn() {
  printf "%b[WARN]%b %s\n" "$COLOR_YELLOW" "$STYLE_RESET" "$*"
}

log_error() {
  printf "%b[ERROR]%b %s\n" "$COLOR_RED" "$STYLE_RESET" "$*" >&2
}

phase_start() {
  local name="$1"
  printf "\n%b==>%b %s\n" "$STYLE_BOLD" "$STYLE_RESET" "$name"
}

phase_end() {
  local name="$1"
  local status="$2"
  local elapsed="$3"
  local color="$COLOR_GREEN"

  if [[ "$status" == "SKIPPED" ]]; then
    color="$COLOR_YELLOW"
  elif [[ "$status" != "OK" ]]; then
    color="$COLOR_RED"
  fi

  printf "%b[%s]%b %s (%ss)\n" "$color" "$status" "$STYLE_RESET" "$name" "$elapsed"
}

record_phase() {
  local name="$1"
  local status="$2"
  local elapsed="$3"

  PHASE_NAMES+=("$name")
  PHASE_STATUSES+=("$status")
  PHASE_SECONDS+=("$elapsed")
}

run_phase() {
  local name="$1"
  shift

  local start_epoch
  local end_epoch
  local elapsed

  phase_start "$name"
  start_epoch="$(date +%s)"

  if "$@"; then
    end_epoch="$(date +%s)"
    elapsed=$((end_epoch - start_epoch))
    record_phase "$name" "OK" "$elapsed"
    phase_end "$name" "OK" "$elapsed"
    return 0
  fi

  local rc=$?
  end_epoch="$(date +%s)"
  elapsed=$((end_epoch - start_epoch))
  record_phase "$name" "FAILED(${rc})" "$elapsed"
  phase_end "$name" "FAILED(${rc})" "$elapsed"
  return "$rc"
}

skip_phase() {
  local name="$1"
  record_phase "$name" "SKIPPED" "0"
  phase_end "$name" "SKIPPED" "0"
}

print_usage() {
  echo "Usage: ./bootstrap.sh [options]"
  echo
  echo "Options:"
  echo "  --interactive       Force interactive behavior when TTY is available"
  echo "  --non-interactive   Disable all interactive prompts"
  echo "  --skip-extensions   Skip VS Code extension installation"
  echo "  --select-sections   Interactively select which sections to run"
  echo "  --ui=MODE           Output mode: auto|plain|gum (default: auto)"
  echo "  -h, --help          Show this help message"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --interactive)
        FORCE_INTERACTIVE=1
        ;;
      --non-interactive)
        FORCE_NONINTERACTIVE=1
        ;;
      --skip-extensions)
        SKIP_EXTENSIONS=1
        ;;
      --select-sections)
        SELECT_SECTIONS=1
        ;;
      --ui=*)
        BOOTSTRAP_UI="${1#*=}"
        ;;
      -h|--help)
        print_usage
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        print_usage
        exit 1
        ;;
    esac
    shift
  done

  if [[ "$FORCE_INTERACTIVE" -eq 1 && "$FORCE_NONINTERACTIVE" -eq 1 ]]; then
    log_error "Cannot use --interactive and --non-interactive together"
    exit 1
  fi

  case "$BOOTSTRAP_UI" in
    auto|plain|gum)
      ;;
    *)
      log_error "Invalid --ui mode: $BOOTSTRAP_UI (expected: auto|plain|gum)"
      exit 1
      ;;
  esac
}

detect_runtime_mode() {
  local has_tty=0

  if [[ -t 0 && -t 1 ]]; then
    has_tty=1
  fi

  if command_exists gum; then
    GUM_AVAILABLE=1
  fi

  if [[ "$FORCE_NONINTERACTIVE" -eq 1 ]]; then
    BOOTSTRAP_NONINTERACTIVE=1
  fi

  if [[ "$FORCE_INTERACTIVE" -eq 1 ]]; then
    if [[ "$has_tty" -eq 1 ]]; then
      INTERACTIVE_MODE=1
      BOOTSTRAP_NONINTERACTIVE=0
    else
      log_warn "--interactive requested without TTY; falling back to non-interactive mode"
      INTERACTIVE_MODE=0
      BOOTSTRAP_NONINTERACTIVE=1
    fi
    return
  fi

  if [[ "$BOOTSTRAP_NONINTERACTIVE" == "1" ]]; then
    INTERACTIVE_MODE=0
    return
  fi

  INTERACTIVE_MODE="$has_tty"
}

enable_all_sections() {
  RUN_CLEANUP=1
  RUN_BREW=1
  RUN_STOW=1
  RUN_VSCODE=1
  RUN_EXTENSIONS=1
  RUN_ZSH_PLUGINS=1
  RUN_VERIFICATION=1
  RUN_SSH_KEY=1
  RUN_CLAUDE=1
  RUN_ITERM2=1
  RUN_LAUNCHD=1
  RUN_MACOS=1
}

disable_all_sections() {
  RUN_CLEANUP=0
  RUN_BREW=0
  RUN_STOW=0
  RUN_VSCODE=0
  RUN_EXTENSIONS=0
  RUN_ZSH_PLUGINS=0
  RUN_VERIFICATION=0
  RUN_SSH_KEY=0
  RUN_CLAUDE=0
  RUN_ITERM2=0
  RUN_LAUNCHD=0
  RUN_MACOS=0
}

enable_section() {
  local section="$1"

  case "$section" in
    cleanup)
      RUN_CLEANUP=1
      ;;
    brew)
      RUN_BREW=1
      ;;
    stow)
      RUN_STOW=1
      ;;
    vscode)
      RUN_VSCODE=1
      ;;
    extensions)
      RUN_EXTENSIONS=1
      ;;
    zsh-plugins)
      RUN_ZSH_PLUGINS=1
      ;;
    verification)
      RUN_VERIFICATION=1
      ;;
    ssh-key)
      RUN_SSH_KEY=1
      ;;
    claude)
      RUN_CLAUDE=1
      ;;
    iterm2)
      RUN_ITERM2=1
      ;;
    launchd)
      RUN_LAUNCHD=1
      ;;
    macos)
      RUN_MACOS=1
      ;;
    *)
      log_warn "Unknown section '$section' ignored"
      ;;
  esac
}

apply_section_defaults() {
  if [[ "$SKIP_EXTENSIONS" -eq 1 ]]; then
    RUN_EXTENSIONS=0
  fi
}

prompt_section_selection() {
  local sections=("cleanup" "brew" "stow" "vscode" "extensions" "zsh-plugins" "verification" "ssh-key" "claude" "iterm2" "launchd" "macos")

  if [[ "$SELECT_SECTIONS" -ne 1 ]]; then
    return
  fi

  if [[ "$INTERACTIVE_MODE" -ne 1 ]]; then
    log_warn "--select-sections requested in non-interactive mode; using defaults"
    return
  fi

  disable_all_sections

  if [[ "$BOOTSTRAP_UI" != "plain" && "$GUM_AVAILABLE" -eq 1 ]]; then
    local picked
    picked="$(gum choose --no-limit "${sections[@]}" || true)"

    if [[ -z "$picked" ]]; then
      log_warn "No sections selected; running all sections"
      enable_all_sections
      return
    fi

    while IFS= read -r line; do
      [[ -n "$line" ]] && enable_section "$line"
    done <<< "$picked"
  else
    log_info "Select sections to run (comma-separated names or numbers, Enter for all):"
    echo "  1) cleanup"
    echo "  2) brew"
    echo "  3) stow"
    echo "  4) vscode"
    echo "  5) extensions"
    echo "  6) zsh-plugins"
    echo "  7) verification"
    echo "  8) ssh-key"
    echo "  9) claude"
    echo " 10) iterm2"

    local input
    read -rp "> " input

    if [[ -z "$input" ]]; then
      enable_all_sections
      return
    fi

    local item
    local picks=()
    IFS=',' read -r -a picks <<< "$input"

    for item in "${picks[@]}"; do
      item="${item//[[:space:]]/}"
      case "$item" in
        1|cleanup) enable_section "cleanup" ;;
        2|brew) enable_section "brew" ;;
        3|stow) enable_section "stow" ;;
        4|vscode) enable_section "vscode" ;;
        5|extensions) enable_section "extensions" ;;
        6|zsh-plugins) enable_section "zsh-plugins" ;;
        7|verification) enable_section "verification" ;;
        8|ssh-key) enable_section "ssh-key" ;;
        9|claude) enable_section "claude" ;;
        10|iterm2) enable_section "iterm2" ;;
        11|launchd) enable_section "launchd" ;;
        12|macos) enable_section "macos" ;;
        all) enable_all_sections ;;
        *) log_warn "Ignoring unknown selection: $item" ;;
      esac
    done
  fi

  if [[ "$SKIP_EXTENSIONS" -eq 1 ]]; then
    RUN_EXTENSIONS=0
  fi

  local selected_total
  selected_total=$((
    RUN_CLEANUP + RUN_BREW + RUN_STOW + RUN_VSCODE +
    RUN_EXTENSIONS + RUN_ZSH_PLUGINS + RUN_VERIFICATION + RUN_SSH_KEY + RUN_CLAUDE + RUN_ITERM2 +
    RUN_LAUNCHD + RUN_MACOS
  ))

  if [[ "$selected_total" -eq 0 ]]; then
    log_warn "No valid section selected; running all sections"
    enable_all_sections
    if [[ "$SKIP_EXTENSIONS" -eq 1 ]]; then
      RUN_EXTENSIONS=0
    fi
  fi
}

run_or_skip_phase() {
  local name="$1"
  local enabled="$2"
  shift 2

  if [[ "$enabled" -eq 1 ]]; then
    run_phase "$name" "$@"
    return $?
  fi

  skip_phase "$name"
  return 0
}

print_runtime_context() {
  local mode="non-interactive"
  if [[ "$INTERACTIVE_MODE" -eq 1 ]]; then
    mode="interactive"
  fi

  log_info "Mode: $mode"
  log_info "UI: $BOOTSTRAP_UI"
  if [[ "$SKIP_EXTENSIONS" -eq 1 ]]; then
    log_info "VS Code extensions: skipped by flag"
  fi
}

print_summary() {
  if [[ "$SUMMARY_PRINTED" -eq 1 ]]; then
    return
  fi

  SUMMARY_PRINTED=1

  local total_elapsed
  total_elapsed=$(( $(date +%s) - START_EPOCH ))

  local ok_count=0
  local skipped_count=0
  local failed_count=0
  local i

  echo
  printf "%b=== Bootstrap Summary ===%b\n" "$STYLE_BOLD" "$STYLE_RESET"
  printf "%-28s %-12s %s\n" "Phase" "Status" "Seconds"

  for i in "${!PHASE_NAMES[@]}"; do
    local status="${PHASE_STATUSES[$i]}"
    local color="$COLOR_GREEN"

    if [[ "$status" == "SKIPPED" ]]; then
      skipped_count=$((skipped_count + 1))
      color="$COLOR_YELLOW"
    elif [[ "$status" == OK* ]]; then
      ok_count=$((ok_count + 1))
      color="$COLOR_GREEN"
    else
      failed_count=$((failed_count + 1))
      color="$COLOR_RED"
    fi

    printf "%-28s %b%-12s%b %s\n" "${PHASE_NAMES[$i]}" "$color" "$status" "$STYLE_RESET" "${PHASE_SECONDS[$i]}"
  done

  echo
  printf "Completed: %s | Skipped: %s | Failed: %s\n" "$ok_count" "$skipped_count" "$failed_count"
  printf "Total time: %ss\n" "$total_elapsed"
  printf "Backup directory: %s\n" "$BACKUP_DIR"
}

ensure_prerequisites() {
  if ! command_exists brew; then
    log_error "Homebrew required. Install it first."
    return 1
  fi

  if ! command_exists stow; then
    brew install stow
  fi

  # Install this repo's own git hooks. Cheap and idempotent; pre-commit itself
  # comes from the Brewfile, so on a fresh machine this is a no-op on the first
  # pass and takes effect once the Brew phase has run.
  if command_exists pre-commit && [[ -f "$REPO_DIR/.pre-commit-config.yaml" ]]; then
    if (cd "$REPO_DIR" && pre-commit install --install-hooks >/dev/null 2>&1); then
      echo "pre-commit hooks installed"
    else
      log_warn "pre-commit install failed; run it manually in $REPO_DIR"
    fi
  fi

  return 0
}

stow_core_packages() {
  local manifest="$REPO_DIR/stow-packages.txt"
  if [[ ! -f "$manifest" ]]; then
    log_warn "stow-packages.txt not found; skipping stow"
    return 1
  fi

  local pkg
  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    stow_package "$pkg"
  done < "$manifest"
}

apply_macos_defaults() {
  [[ "$(uname -s)" != "Darwin" ]] && return 0

  if [[ ! -x "$REPO_DIR/macos.sh" ]]; then
    log_warn "macos.sh not found or not executable; skipping"
    return 0
  fi

  echo "--- macOS Defaults ---"
  "$REPO_DIR/macos.sh"
  return 0
}

load_launch_agents() {
  local agents_dir="$HOME/Library/LaunchAgents"
  local uid; uid="$(id -u)"
  local plist label

  [[ "$(uname -s)" != "Darwin" ]] && return 0
  [[ ! -d "$agents_dir" ]] && return 0

  echo "--- Launch Agents ---"
  for plist in "$agents_dir"/com.namitdeb739.*.plist; do
    [[ -e "$plist" ]] || continue
    label="$(basename "$plist" .plist)"
    # bootout first so an edited plist is reloaded rather than ignored.
    launchctl bootout "gui/$uid/$label" 2>/dev/null || true
    if launchctl bootstrap "gui/$uid" "$plist" 2>/dev/null; then
      echo "Loaded: $label"
    else
      log_warn "Could not load launch agent: $label"
    fi
  done

  return 0
}

run_verification() {
  if [[ -f "$REPO_DIR/check-stow-integrity.sh" ]]; then
    bash "$REPO_DIR/check-stow-integrity.sh"
    return 0
  fi

  log_warn "check-stow-integrity.sh not found; skipping verification"
  return 0
}

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
  [[ ! -d "$vscode_src" ]] && return 0

  local vscode_target
  case "$(uname -s)" in
    Darwin) vscode_target="$HOME/Library/Application Support/Code/User" ;;
    Linux)  vscode_target="$HOME/.config/Code/User" ;;
    *)
      log_warn "Unsupported platform for VS Code stow — skipping"
      return 0
      ;;
  esac

  mkdir -p "$vscode_target"

  # Back up conflicting real files before stow runs
  local file name target backup
  for file in "$vscode_src"/*.json; do
    [[ -f "$file" ]] || continue
    name="$(basename "$file")"
    target="$vscode_target/$name"

    if [[ -L "$target" ]]; then
      [[ "$(readlink "$target")" == "$file" ]] && continue
      rm "$target"
    elif [[ -e "$target" ]]; then
      backup="$BACKUP_DIR/vscode/${name}.${TIMESTAMP}"
      mkdir -p "$(dirname "$backup")"
      mv "$target" "$backup"
      echo "Backed up: $target -> $backup"
    fi
  done

  stow \
    --dir="$REPO_DIR" \
    --target="$vscode_target" \
    --restow \
    --no-folding \
    vscode

  echo "VS Code config stowed to: $vscode_target"
}

ensure_node() {
  if ! command_exists fnm; then
    log_warn "fnm not found — skipping Node setup"
    return 1
  fi

  eval "$(fnm env --shell bash 2>/dev/null)" || true

  if ! command_exists node; then
    log_info "Installing Node LTS via fnm..."
    fnm install --lts
    fnm use lts-latest
  fi
}

install_claude_cli() {
  if command_exists claude; then
    echo "Claude CLI already installed: $(command -v claude)"
    return 0
  fi

  log_info "Installing Claude Code CLI..."
  ensure_node || {
    log_warn "Node unavailable — cannot install Claude Code CLI"
    return 1
  }

  if ! command_exists npm; then
    log_warn "npm not found after Node setup — cannot install Claude Code CLI"
    return 1
  fi

  npm install -g @anthropic-ai/claude-code
  echo "Claude Code CLI installed: $(command -v claude)"
}

setup_claude() {
  stow_package "claude"
  local statusline="$HOME/.claude/statusline.sh"
  [[ -f "$statusline" ]] && chmod +x "$statusline" \
    && echo "Made statusline.sh executable"
  local hook
  for hook in "$HOME"/.claude/hooks/*.py; do
    [[ -f "$hook" ]] && chmod +x "$hook" \
      && echo "Made $(basename "$hook") executable"
  done

  install_claude_cli || true

  if ! command_exists claude; then
    log_warn "claude CLI not found — skipping MCP server registration"
    return 0
  fi

  echo "--- Claude MCP Servers ---"

  # Helper: register idempotently (remove then add).
  # Usage: _mcp_add <name> [mcp-add-options] -- <command> [args...]
  # The name is passed as the first positional arg to `claude mcp add`.
  _mcp_add() {
    local name="$1"; shift
    claude mcp remove --scope user "$name" &>/dev/null || true
    if claude mcp add --scope user "$name" "$@" 2>/dev/null; then
      echo "MCP registered: $name"
    else
      log_warn "MCP registration failed: $name"
    fi
  }

  # Only servers with no local CLI and real auth earn a slot. Measured over 48
  # transcripts, these were removed and must stay removed:
  #   github    — 7 MCP calls vs 32 `gh` calls in Bash. MCP costs 1.3x-80x more
  #               tokens than the CLI (44k vs 1.4k on a trivial repo query,
  #               nearly all tool schema), and `gh ... --json | jq` composes
  #               where MCP tools cannot.
  #   filesystem— strictly worse than Read/Write/Edit/Glob: no LSP diagnostics
  #               feedback, no Edit string-replace semantics, no permission
  #               integration.
  #   sequential-thinking — a no-op wrapper under Opus extended thinking.
  #   docker    — `Bash(docker *)` is already in permissions.allow.
  #   context7  — only ~3% of web lookups were library API docs; the rest were
  #               ghostty config, Anthropic docs, and TI datasheets. Routed via
  #               CLAUDE.md instead.
  _mcp_add chrome-devtools -- npx -y chrome-devtools-mcp@latest

  # Notion is deliberately not registered here. It arrives as the claude.ai
  # connector ("claude.ai Notion", OAuth) and is synced from the account, so a
  # `claude mcp add` entry would duplicate every tool. Reconnect it at
  # claude.ai/settings/connectors, not from this script.
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
  HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --file="$brewfile" --verbose --no-upgrade
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

setup_ssh_key() {
  local key="$HOME/.ssh/id_ed25519"

  if [[ -f "$key" ]]; then
    echo "SSH key already exists: $key"
    return 0
  fi

  if [[ "$INTERACTIVE_MODE" -ne 1 ]]; then
    echo "Non-interactive mode — skipping SSH key generation"
    return 0
  fi

  echo "No SSH key found at $key"

  local generate="n"
  read -rp "Generate a new ed25519 SSH key? [y/N] " generate

  if [[ "$generate" != "y" && "$generate" != "Y" ]]; then
    echo "Skipping SSH key generation"
    return 0
  fi

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "namitdeb739@gmail.com" -f "$key"
  echo "SSH key generated: $key"

  if ! command_exists gh; then
    echo "gh CLI not found — skipping GitHub upload. Add the key manually."
    return 0
  fi

  local upload="n"
  read -rp "Upload public key to GitHub via 'gh ssh-key add'? [y/N] " upload

  if [[ "$upload" == "y" || "$upload" == "Y" ]]; then
    local title
    title="$(hostname -s)-$(date +%Y%m%d)"
    gh ssh-key add "${key}.pub" --title "$title"
    echo "Public key uploaded to GitHub as: $title"
  fi

  return 0
}

import_iterm2_colors() {
  local colors_dir="$REPO_DIR/iterm2/colors"
  [[ ! -d "$colors_dir" ]] && return 0

  if ! compgen -G "$colors_dir/*.itermcolors" > /dev/null; then
    log_warn "No .itermcolors files found in $colors_dir"
    return 0
  fi

  # Write presets straight into iTerm2's preferences domain. The obvious
  # `open file.itermcolors` does not work unless iTerm2 is registered with
  # LaunchServices as the handler for that extension, which it frequently is
  # not — it fails with kLSApplicationNotFoundErr and imports nothing, while
  # still looking like it succeeded.
  if command_exists python3; then
    python3 - "$colors_dir" << 'PYEOF'
import plistlib
import subprocess
import sys
from pathlib import Path

DOMAIN = "com.googlecode.iterm2"
KEY = "Custom Color Presets"

colors_dir = Path(sys.argv[1])

existing = subprocess.run(
    ["defaults", "read", DOMAIN, KEY],
    capture_output=True, text=True,
).stdout

imported = 0
for f in sorted(colors_dir.glob("*.itermcolors")):
    name = " ".join(w.capitalize() for w in f.stem.split("-"))
    if f'"{name}"' in existing or f"{name} =" in existing:
        print(f"Already imported: {name}")
        continue
    try:
        preset = plistlib.load(f.open("rb"))
    except Exception as exc:
        print(f"Skipping {f.name}: {exc}", file=sys.stderr)
        continue
    result = subprocess.run(
        ["defaults", "write", DOMAIN, KEY, "-dict-add", name,
         plistlib.dumps(preset).decode()],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        print(f"Failed to import {name}: {result.stderr.strip()}", file=sys.stderr)
        continue
    print(f"Imported: {name}")
    imported += 1

if imported:
    print(f"iTerm2 color presets imported ({imported} files).")
    print("Quit iTerm2 first if it is running, or it will overwrite these on exit.")
PYEOF
  fi

  # Write a DynamicProfile with the correct font. iTerm2 watches this directory
  # and applies the change live — no restart needed, safe whether running or not.
  if command_exists python3; then
    python3 - << 'PYEOF'
import subprocess, plistlib, json, pathlib, datetime, sys

TARGET_FONT = 'JetBrainsMonoNFM-Regular 14'

dyn_dir = pathlib.Path.home() / 'Library/Application Support/iTerm2/DynamicProfiles'
dyn_file = dyn_dir / 'dotfiles.json'

if dyn_file.exists():
    try:
        existing = json.loads(dyn_file.read_text())
        profiles = existing.get('Profiles', [])
        if profiles and profiles[0].get('Normal Font') == TARGET_FONT:
            print('iTerm2 DynamicProfile already configured — skipping')
            sys.exit(0)
    except (json.JSONDecodeError, KeyError):
        pass

result = subprocess.run(['defaults', 'export', 'com.googlecode.iterm2', '-'], capture_output=True)
if result.returncode != 0:
    sys.exit(0)

data = plistlib.loads(result.stdout)
profile = next((p for p in data.get('New Bookmarks', []) if p.get('Name') == 'Default'), None)
if not profile:
    sys.exit(0)

profile['Normal Font'] = TARGET_FONT
profile['Non Ascii Font'] = TARGET_FONT
profile['Use Non-ASCII Font'] = True

def to_json(obj):
    if isinstance(obj, dict):
        return {k: to_json(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [to_json(v) for v in obj]
    elif isinstance(obj, bytes):
        return obj.hex()
    elif isinstance(obj, datetime.datetime):
        return obj.isoformat()
    return obj

dyn_dir.mkdir(parents=True, exist_ok=True)
dyn_file.write_text(json.dumps({'Profiles': [to_json(profile)]}, indent=2))
print(f'iTerm2 DynamicProfile written: font set to {TARGET_FONT}')
PYEOF
  fi

  echo "Next: Preferences → Profiles → Colors → set Light/Dark presets to Catppuccin Latte / Catppuccin Mocha"
}

# ===========================================================
# Main
# ===========================================================

main() {
  setup_styles
  parse_args "$@"
  detect_runtime_mode
  apply_section_defaults
  prompt_section_selection

  printf "%b=== Dotfiles Bootstrap ===%b\n" "$STYLE_BOLD" "$STYLE_RESET"
  print_runtime_context

  run_phase "Prerequisites" ensure_prerequisites || {
    print_summary
    return 1
  }

  run_or_skip_phase "SSH Key" "$RUN_SSH_KEY" setup_ssh_key || {
    print_summary
    return 1
  }

  run_or_skip_phase "Cleanup" "$RUN_CLEANUP" cleanup_legacy || {
    print_summary
    return 1
  }

  run_or_skip_phase "Brew Packages" "$RUN_BREW" install_brew_packages || {
    print_summary
    return 1
  }

  run_or_skip_phase "Stow Packages" "$RUN_STOW" stow_core_packages || {
    print_summary
    return 1
  }

  run_or_skip_phase "VS Code Linking" "$RUN_VSCODE" link_vscode || {
    print_summary
    return 1
  }

  run_or_skip_phase "Claude Config" "$RUN_CLAUDE" setup_claude || {
    print_summary
    return 1
  }

  run_or_skip_phase "iTerm2 Colors" "$RUN_ITERM2" import_iterm2_colors || {
    print_summary
    return 1
  }

  run_or_skip_phase "VS Code Extensions" "$RUN_EXTENSIONS" install_vscode_extensions || {
    print_summary
    return 1
  }

  run_or_skip_phase "Zsh Plugins" "$RUN_ZSH_PLUGINS" init_zsh_plugins || {
    print_summary
    return 1
  }

  run_or_skip_phase "macOS Defaults" "$RUN_MACOS" apply_macos_defaults || {
    print_summary
    return 1
  }

  run_or_skip_phase "Launch Agents" "$RUN_LAUNCHD" load_launch_agents || {
    print_summary
    return 1
  }

  run_or_skip_phase "Verification" "$RUN_VERIFICATION" run_verification || {
    print_summary
    return 1
  }

  print_summary
  printf "%b=== Bootstrap Complete ===%b\n" "$STYLE_BOLD" "$STYLE_RESET"
  return 0
}

main "$@"
