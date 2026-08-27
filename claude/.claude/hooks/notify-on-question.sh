#!/bin/sh
# Notify when Claude Code asks a question and waits on an answer.
# AskUserQuestion never fires the Notification hook (anthropics/claude-code
# #59908), so this rides on PreToolUse instead.
dir=$(jq -r '.cwd // empty')
[ -n "$dir" ] && dir=$(basename "$dir") || dir="claude"

exec "$HOME/.claude/hooks/notify.sh" "Waiting on your answer" "$dir"
