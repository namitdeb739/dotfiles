#!/usr/bin/env bash
# `airport -I` was removed in recent macOS. ipconfig still exposes the SSID.
# Falls back through the common interface names rather than assuming en0.
SSID=""
for iface in en0 en1; do
  SSID=$(ipconfig getsummary "$iface" 2>/dev/null \
         | awk -F' SSID : ' '/ SSID : /{print $2; exit}')
  [ -n "$SSID" ] && break
done

if [ -z "$SSID" ]; then
  sketchybar --set "$NAME" icon="󰖪" icon.color=0xff6c7086 label="offline"
else
  sketchybar --set "$NAME" icon="󰖩" icon.color=0xff89dceb label="$SSID"
fi
