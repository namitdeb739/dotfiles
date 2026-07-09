# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Extract any archive
extract() {
  if [[ ! -f "$1" ]]; then
    echo "File not found: $1"
    return 1
  fi
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.7z)      7z x "$1" ;;
    *)         echo "Unknown archive format: $1" ;;
  esac
}

# Quick project setup: clone + cd
ghclone() {
  git clone "https://github.com/$1.git" && cd "$(basename "$1")"
}

# Find and kill process by port
killport() {
  lsof -ti:"$1" | xargs kill -9 2>/dev/null && echo "Killed process on port $1" || echo "No process on port $1"
}

# Open VS Code defaulting to ~/Developer when called with no arguments
code() {
  if [[ $# -eq 0 ]]; then
    command code ~/Developer
  else
    command code "$@"
  fi
}

# Scaffold a new Python project from the template, identity pre-filled from git/gh
newpy() {
  if [[ -z "$1" ]]; then
    echo "usage: newpy <dest>"
    return 1
  fi
  # Resolve identity first so gh/git output can't clobber Copier's first prompt.
  local name email user
  name="$(git config user.name)"
  email="$(git config user.email)"
  user="$(gh api user --jq .login)"
  printf '\nScaffolding %s — first prompt is the project name (kebab-case).\n\n' "$1"
  uvx copier copy --trust gh:namitdeb739/python-template "$1" \
    --data author_name="$name" \
    --data author_email="$email" \
    --data github_user="$user"
}
