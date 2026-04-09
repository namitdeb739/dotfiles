# --- Git ---
gacp() {
	git add .
	git commit -m "$1"
	git push
}
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gsw='git switch'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate -20'
alias gloga='git log --oneline --graph --decorate --all -30'

# --- Navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ls='eza'
alias ll='eza -lAh --git'
alias la='eza -A'
alias cat='bat --pager=never'

# --- Python / uv ---
alias uvr='uv run'
alias uvs='uv sync'
alias uvt='uv run pytest'

# --- Docker ---
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcp='docker compose ps'
alias dcl='docker compose logs -f'

# --- Misc ---
alias c='clear'
alias path='echo $PATH | tr ":" "\n"'
alias reload='source ~/.zshrc'

# --- Project Templates ---
# Project Templates
# pynew <repo-name> — Scaffold a new repo from python-template (Copier, trusted, skip prompts)
alias pynew='uvx copier copy --trust gh:namitdeb739/python-template $1'

# --- Dotfiles Bootstrap ---
# Run dotfiles bootstrap.sh from anywhere, then return to original directory
alias dotbootstrap='(CURDIR="$PWD"; cd ~/Developer/dotfiles && ./bootstrap.sh; cd "$CURDIR")'
