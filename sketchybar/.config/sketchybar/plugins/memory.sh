#!/usr/bin/env bash
# memory_pressure reports free percentage; used is the complement. This counts
# cached/compressed pages as unavailable, so it tracks what macOS itself calls
# memory pressure rather than raw "wired + active".
FREE=$(memory_pressure | awk -F': ' '/System-wide memory free percentage/{gsub(/%/,"",$2); print $2; exit}')
[ -z "$FREE" ] && { sketchybar --set "$NAME" label="?"; exit 0; }
USED=$((100 - FREE))

if   [ "$USED" -gt 85 ]; then COLOR=0xfff38ba8
elif [ "$USED" -gt 70 ]; then COLOR=0xfff9e2af
else                          COLOR=0xffa6e3a1
fi

sketchybar --set "$NAME" label="${USED}%" icon.color="$COLOR"
