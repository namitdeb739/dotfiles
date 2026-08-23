#!/usr/bin/env bash
# The focused application. Event-driven — no polling.
sketchybar --add item front_app left \
           --set front_app \
                 icon.drawing=off \
                 label.font="JetBrainsMono Nerd Font:Bold:13.0" \
                 label.color="$MAUVE" \
                 label.padding_left=10 \
                 script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched
