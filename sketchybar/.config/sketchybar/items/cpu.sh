#!/usr/bin/env bash
# Load averaged across all cores. 5s is frequent enough to be useful and cheap
# enough not to show up in its own reading.
sketchybar --add item cpu right \
           --set cpu icon="󰻠" icon.color="$PEACH" \
                 update_freq=5 \
                 script="$PLUGIN_DIR/cpu.sh"
