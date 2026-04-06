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
# Source ~/.secrets for API keys and tokens that can't be committed.
# Create this file on each machine; it is gitignored globally.
# Example contents:
#   export OPENAI_API_KEY="sk-..."
#   export GITHUB_TOKEN="ghp_..."
# shellcheck source=/dev/null
[[ -f ~/.secrets ]] && source ~/.secrets
