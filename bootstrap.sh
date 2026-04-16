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
RUN_STARSHIP=1
RUN_EXTENSIONS=1
RUN_ZSH_PLUGINS=1
RUN_VERIFICATION=1
RUN_SSH_KEY=1
RUN_CLAUDE=1

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
  RUN_STARSHIP=1
  RUN_EXTENSIONS=1
  RUN_ZSH_PLUGINS=1
  RUN_VERIFICATION=1
  RUN_SSH_KEY=1
  RUN_CLAUDE=1
}

disable_all_sections() {
  RUN_CLEANUP=0
  RUN_BREW=0
  RUN_STOW=0
  RUN_VSCODE=0
  RUN_STARSHIP=0
  RUN_EXTENSIONS=0
  RUN_ZSH_PLUGINS=0
  RUN_VERIFICATION=0
  RUN_SSH_KEY=0
  RUN_CLAUDE=0
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
    starship)
      RUN_STARSHIP=1
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
  local sections=("cleanup" "brew" "stow" "vscode" "starship" "extensions" "zsh-plugins" "verification" "ssh-key" "claude")

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
    echo "  5) starship"
    echo "  6) extensions"
    echo "  7) zsh-plugins"
    echo "  8) verification"
    echo "  9) ssh-key"
    echo " 10) claude"

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
        5|starship) enable_section "starship" ;;
        6|extensions) enable_section "extensions" ;;
        7|zsh-plugins) enable_section "zsh-plugins" ;;
        8|verification) enable_section "verification" ;;
        9|ssh-key) enable_section "ssh-key" ;;
        10|claude) enable_section "claude" ;;
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
    RUN_STARSHIP + RUN_EXTENSIONS + RUN_ZSH_PLUGINS + RUN_VERIFICATION + RUN_SSH_KEY + RUN_CLAUDE
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

  return 0
}

stow_core_packages() {
  stow_package "git"
  stow_package "github"
  stow_package "zsh"
  stow_package "atuin"
  stow_package "starship"
  stow_package "nvim"
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

setup_claude() {
  stow_package "claude"
  local statusline="$HOME/.claude/statusline.sh"
  local hook="$HOME/.claude/hooks/security-guidance.py"
  [[ -f "$statusline" ]] && chmod +x "$statusline" \
    && echo "Made statusline.sh executable"
  [[ -f "$hook" ]] && chmod +x "$hook" \
    && echo "Made security-guidance.py executable"

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

  local github_token
  github_token="$(gh auth token 2>/dev/null || echo "")"

  if [[ -n "$github_token" ]]; then
    _mcp_add github -e "GITHUB_TOKEN=${github_token}" -- \
      npx -y @modelcontextprotocol/server-github
  else
    _mcp_add github -- npx -y @modelcontextprotocol/server-github
    log_warn "GITHUB_TOKEN not set — add token later: claude mcp add -s user -e GITHUB_TOKEN=\$(gh auth token) github -- npx -y @modelcontextprotocol/server-github"
  fi

  _mcp_add context7 -- npx -y @upstash/context7-mcp
  _mcp_add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
  _mcp_add filesystem -- npx -y @modelcontextprotocol/server-filesystem "${HOME}"
  _mcp_add docker -- npx -y @modelcontextprotocol/server-docker
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
  local dotfiles_config="$REPO_DIR/starship/.config/starship.toml"

  # Initial symlinking is handled by stow (starship package in stow_core_packages).
  # This phase only handles interactive preset selection on machines that want a
  # different theme — non-interactive runs keep whatever stow put in place.
  if [[ "$INTERACTIVE_MODE" -ne 1 || "${BOOTSTRAP_NONINTERACTIVE}" == "1" || ! -t 0 ]]; then
    echo "Non-interactive — keeping existing Starship config."
    return 0
  fi

  echo "--- Starship ---"
  if [[ -e "$config" ]]; then
    echo "Found existing config at: $config"
    if [[ -L "$config" ]]; then
      echo "Current symlink target: $(readlink "$config")"
    fi
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

  run_or_skip_phase "Starship" "$RUN_STARSHIP" configure_starship || {
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

  run_or_skip_phase "Verification" "$RUN_VERIFICATION" run_verification || {
    print_summary
    return 1
  }

  print_summary
  printf "%b=== Bootstrap Complete ===%b\n" "$STYLE_BOLD" "$STYLE_RESET"
  return 0
}

main "$@"
