#!/usr/bin/env bash
# Network name. `airport -I` was removed in recent macOS; this reads the SSID
# from ipconfig instead, which still works.
sketchybar --add item wifi right \
           --set wifi icon="󰖩" icon.color="$SKY" \
                 update_freq=30 \
                 script="$PLUGIN_DIR/wifi.sh"
