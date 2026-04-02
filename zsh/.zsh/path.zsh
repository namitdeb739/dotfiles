# PATH management — deduplicated, ordered by priority
typeset -U path  # unique entries only

path=(
  "$HOME/.local/bin"       # pipx, uv-installed tools
  "$HOME/bin"              # personal scripts
  $path
)

# --- Environment ---
export EDITOR='code --wait'
export VISUAL='code --wait'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
