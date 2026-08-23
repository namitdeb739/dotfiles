#!/usr/bin/env bash
# Rightmost, and the only item given the accent background, so the eye has a
# fixed anchor at the end of the bar.
sketchybar --add item clock right \
           --set clock icon="󰃰" icon.color="$BASE" \
                 label.color="$BASE" \
                 background.color="$BLUE" \
                 update_freq=10 \
                 script="$PLUGIN_DIR/clock.sh"
