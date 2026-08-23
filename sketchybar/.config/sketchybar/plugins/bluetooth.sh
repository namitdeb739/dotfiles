#!/usr/bin/env bash
# Mirrors the native Bluetooth menu bar item: on / off, and whether anything is
# actually connected.
#
# The obvious parse is wrong: `/Connected:/` also matches the "Not Connected:"
# section heading, which reports every *paired* device as connected. Both
# section headings are anchored below to avoid that.
#
# `system_profiler SPBluetoothDataType` returns in ~0.2s, which is fine at a
# 60s poll. There is no cheaper source that does not need sudo.
INFO_OUT=$(system_profiler SPBluetoothDataType 2>/dev/null)

STATE=$(printf '%s\n' "$INFO_OUT" | awk -F': ' '/^ +State: /{print $2; exit}')

if [ "$STATE" != "On" ]; then
  sketchybar --set "$NAME" icon="󰂲" icon.color=0xff6c7086 label.drawing=off
  exit 0
fi

# Devices listed under a line that is exactly "Connected:", not "Not Connected:".
COUNT=$(printf '%s\n' "$INFO_OUT" | awk '
  /^ +Not Connected:/ { inblock = 0; next }
  /^ +Connected:/     { inblock = 1; indent = match($0, /[^ ]/); next }
  inblock && /^ +[^ ].*:$/ {
    here = match($0, /[^ ]/)
    if (here <= indent) { inblock = 0; next }
    if (here == indent + 4) n++
  }
  END { print n + 0 }
')

if [ "$COUNT" -gt 0 ]; then
  sketchybar --set "$NAME" icon="󰂱" icon.color=0xff89b4fa \
                           label="$COUNT" label.drawing=on
else
  sketchybar --set "$NAME" icon="󰂯" icon.color=0xffa6adc8 label.drawing=off
fi
