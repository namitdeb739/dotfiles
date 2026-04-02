# --- Git ---
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
alias ll='ls -lAh'
alias la='ls -A'

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
