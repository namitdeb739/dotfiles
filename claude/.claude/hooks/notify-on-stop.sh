#!/bin/sh
# Notify when Claude Code finishes a response. Claude Code's built-in
# notification channels are all terminal escape sequences (iTerm2, kitty,
# Ghostty); the VS Code terminal implements none of them, so notifications
# there have to be posted by us.
dir=$(jq -r '.cwd // empty')
[ -n "$dir" ] && dir=$(basename "$dir") || dir="claude"

exec "$HOME/.claude/hooks/notify.sh" "Response complete" "$dir"
