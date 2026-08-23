#!/usr/bin/env bash
sketchybar --add item memory right \
           --set memory icon="󰍛" icon.color="$GREEN" \
                 update_freq=15 \
                 script="$PLUGIN_DIR/memory.sh"
