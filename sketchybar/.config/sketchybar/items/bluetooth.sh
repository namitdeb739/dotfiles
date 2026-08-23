#!/usr/bin/env bash
# Mirrors the native Bluetooth menu bar item, which is visible on this machine
# ("NSStatusItem VisibleCC Bluetooth" = 1 in com.apple.controlcenter).
sketchybar --add item bluetooth right \
           --set bluetooth icon="󰂯" icon.color="$SKY" \
                 label.drawing=off \
                 update_freq=60 \
                 script="$PLUGIN_DIR/bluetooth.sh" \
           --subscribe bluetooth system_woke
