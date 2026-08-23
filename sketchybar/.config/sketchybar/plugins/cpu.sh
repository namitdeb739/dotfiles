#!/usr/bin/env bash
# Sum of per-process CPU divided by core count.
#
# Deliberately not `top -l 1`: that samples for a full second, so a bar
# refreshing every 5s would spend 20% of its life inside top. This reads the
# accounting ps already has and returns instantly.
CORES=$(sysctl -n hw.ncpu)
USED=$(ps -A -o %cpu= | awk -v n="$CORES" '{s+=$1} END {printf "%.0f", s/n}')

if   [ "$USED" -gt 80 ]; then COLOR=0xfff38ba8   # red
elif [ "$USED" -gt 50 ]; then COLOR=0xfff9e2af   # yellow
else                          COLOR=0xfffab387   # peach
fi

sketchybar --set "$NAME" label="${USED}%" icon.color="$COLOR"
