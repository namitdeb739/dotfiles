#!/usr/bin/env bash
# Matches the native clock exactly, as configured in com.apple.menuextra.clock:
#   ShowDayOfWeek = 1, ShowDate = 1, ShowAMPM = 1, ShowSeconds = 1
# so: "Sun 23 Aug 11:52:07 PM".
#
# %l is the hour 1-12, space-padded, so `tr -s` squeezes the double space that
# leaves before single-digit hours.
sketchybar --set "$NAME" label="$(date '+%a %d %b %l:%M:%S %p' | tr -s ' ')"
