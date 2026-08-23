#!/usr/bin/env bash
BATT=$(pmset -g batt)
PCT=$(echo "$BATT" | grep -Eo '[0-9]+%' | tr -d '%')
CHARGING=$(echo "$BATT" | grep -c 'AC Power')
[ -z "$PCT" ] && exit 0

if [ "$CHARGING" -ne 0 ]; then
  ICON="󰂄"; COLOR=0xffa6e3a1
else
  if   [ "$PCT" -gt 80 ]; then ICON="󰁹"; COLOR=0xffa6e3a1
  elif [ "$PCT" -gt 50 ]; then ICON="󰂁"; COLOR=0xffa6e3a1
  elif [ "$PCT" -gt 30 ]; then ICON="󰂀"; COLOR=0xfff9e2af
  elif [ "$PCT" -gt 15 ]; then ICON="󰁽"; COLOR=0xfffab387
  else                         ICON="󰁻"; COLOR=0xfff38ba8
  fi
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PCT}%"
