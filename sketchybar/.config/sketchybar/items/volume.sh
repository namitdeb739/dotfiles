#!/usr/bin/env bash
# Event-driven: macOS emits volume_change and passes the level in $INFO, so
# there is nothing to poll.
sketchybar --add item volume right \
           --set volume icon.color="$LAVENDER" \
                 script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change
