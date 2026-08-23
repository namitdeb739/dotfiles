#!/usr/bin/env bash
# $INFO is the new frontmost app name, supplied by the front_app_switched event.
[ "$SENDER" = "front_app_switched" ] && sketchybar --set "$NAME" label="$INFO"
