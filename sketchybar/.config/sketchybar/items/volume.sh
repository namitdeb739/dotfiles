#!/usr/bin/env bash
# Event-driven for instant response, plus a slow poll so the item is correct
# immediately after a start or --reload, when no event has fired yet.
sketchybar --add item volume right \
           --set volume icon.color="$LAVENDER" \
                 update_freq=30 \
                 script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change
