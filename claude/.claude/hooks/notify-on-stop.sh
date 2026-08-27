#!/bin/sh
# Post a macOS notification when Claude Code finishes a response.
# Claude Code's built-in notification channels are all terminal escape
# sequences (iTerm2, kitty, Ghostty); the VS Code terminal implements none
# of them, so notifications there have to come from osascript.
dir=$(jq -r '.cwd // empty')
[ -n "$dir" ] && dir=$(basename "$dir") || dir="claude"

osascript - "$dir" <<'OSA' >/dev/null 2>&1
on run argv
  display notification "Response complete" with title "Claude Code" subtitle (item 1 of argv) sound name "Ping"
end run
OSA
exit 0
