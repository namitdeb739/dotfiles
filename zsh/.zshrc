# ============================================================
# Dotfiles-managed .zshrc — antidote + Starship
# ============================================================

# --- VS Code shell integration (must be early) ---
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  if command -v code &>/dev/null; then
    [[ -r "$(code --locate-shell-integration-path zsh 2>/dev/null)" ]] && \
      source "$(code --locate-shell-integration-path zsh)"
  fi
fi

# --- History ---
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# --- Shell options ---
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS

# --- Completions ---
autoload -Uz compinit
# Only regenerate .zcompdump once per day
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# --- Key bindings ---
bindkey -e
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# --- Antidote plugin manager ---
# Install: brew install antidote
# Sources the pre-compiled static file (~/.zsh_plugins.zsh) for fast startup when
# available; falls back to dynamic load. Re-run bootstrap to regenerate static file.
_antidote_init="$(brew --prefix 2>/dev/null)/opt/antidote/share/antidote/antidote.zsh"
if [[ -f "$_antidote_init" ]]; then
  source "$_antidote_init"
  if [[ -f ~/.zsh_plugins.zsh ]]; then
    source ~/.zsh_plugins.zsh
  else
    antidote load ~/.zsh_plugins.txt
  fi
fi
unset _antidote_init

# --- Source modular configs ---
for config_file in ~/.zsh/*.zsh(N); do
  source "$config_file"
done

# --- Tool initialization ---

# Homebrew (Apple Silicon)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# fzf key bindings and completions
if command -v fzf &>/dev/null; then
  source <(fzf --zsh 2>/dev/null) || true
fi

# zoxide (smart cd)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# atuin (shell history)
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh)"
fi

# fnm (fast Node manager)
if command -v fnm &>/dev/null; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# uv completions
if command -v uv &>/dev/null; then
  eval "$(uv generate-shell-completion zsh 2>/dev/null)" || true
fi

# direnv
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# --- Secrets ---
# Secrets live in the macOS login Keychain, loaded by ~/.zsh/secrets.zsh above.
# Manage them with the `secret` command:
#   secret set NOTION_TOKEN      # prompts without echoing
#   secret list                  # names only
#
# A plaintext ~/.secrets is deliberately NOT sourced: silently reading
# credentials from an unencrypted file is the thing this setup exists to stop,
# and a working fallback means it never gets migrated. Warn loudly instead.
if [[ -f ~/.secrets ]]; then
  print -u2 -P "%F{yellow}warning:%f ~/.secrets exists but is no longer sourced."
  print -u2 -P "  Migrate it:  %F{cyan}secret import ~/.secrets && secret list && rm -P ~/.secrets%f"
fi

# notion-automations (na) CLI config
export NOTION_CLASSES_DB_ID="33d9080d-a147-80e6-a934-c7f5cf7501f8"
# NOTION_TOKEN lives in ~/.secrets (sourced above) — never inline it here.

# Added by cua-driver-rs installer — see https://github.com/trycua/cua
export PATH="/Users/namit/.local/bin:$PATH"

# research-assistant CLI config (CP4101 dissertation vault)
# The tool ships with no path of its own, so without these it refuses to run
# outside `just` in earth-computers, which exports the same two values.
export VAULT_PAPERS_DIR="$HOME/Obsidian/School/Y4S1/CP4101 B.Comp. Dissertation/papers"
export RESEARCH_ASSISTANT_USER_AGENT="earth-computers/0.1 (mailto:namitdeb739@gmail.com)"
