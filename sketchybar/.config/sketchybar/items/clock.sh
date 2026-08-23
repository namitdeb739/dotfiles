#!/usr/bin/env bash
# Rightmost, and the only item given the accent background, so the eye has a
# fixed anchor at the end of the bar.
#
# Ticks every second because the native clock is configured with ShowSeconds=1
# and the point of this bar is parity with it. The script is a single `date`.
sketchybar --add item clock right \
           --set clock icon="󰃰" icon.color="$BASE" \
                 label.color="$BASE" \
                 background.color="$BLUE" \
                 update_freq=1 \
                 script="$PLUGIN_DIR/clock.sh"
