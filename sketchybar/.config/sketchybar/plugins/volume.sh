#!/usr/bin/env bash
# The volume_change event supplies the level in $INFO, but it only fires when
# the volume actually changes — so on a fresh start or a --reload the item
# would sit at 0% until the user happened to press a volume key. When there is
# no event, read the current level instead.
if [ "$SENDER" = "volume_change" ] && [ -n "$INFO" ]; then
  VOL="$INFO"
  MUTED=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)
else
  VOL=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
  MUTED=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)
fi
VOL="${VOL:-0}"

if [ "$MUTED" = "true" ]; then
  ICON="󰝟"
else
  case "$VOL" in
    [6-9][0-9]|100)   ICON="󰕾" ;;
    [3-5][0-9])       ICON="󰖀" ;;
    [1-9]|[1-2][0-9]) ICON="󰕿" ;;
    *)                ICON="󰝟" ;;
  esac
fi

sketchybar --set "$NAME" icon="$ICON" label="${VOL}%"
