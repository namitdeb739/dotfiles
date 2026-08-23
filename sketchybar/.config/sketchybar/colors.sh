#!/usr/bin/env bash
# Catppuccin Mocha, matching ghostty, nvim, tmux, btop and borders.
#
# SketchyBar cannot follow the macOS appearance setting, so this is pinned to
# Mocha — the same trade-off tmux, lazygit and btop already make.
#
# Format is 0xAARRGGBB (alpha first), not the 0xRRGGBB you might expect.

export BASE=0xff1e1e2e
export MANTLE=0xff181825
export SURFACE0=0xff313244
export SURFACE1=0xff45475a
export TEXT=0xffcdd6f4
export SUBTEXT=0xffa6adc8
export OVERLAY=0xff6c7086

export ROSEWATER=0xfff5e0dc
export MAUVE=0xffcba6f7
export RED=0xfff38ba8
export PEACH=0xfffab387
export YELLOW=0xfff9e2af
export GREEN=0xffa6e3a1
export TEAL=0xff94e2d5
export SKY=0xff89dceb
export BLUE=0xff89b4fa
export LAVENDER=0xffb4befe

# Bar itself: mantle at ~94% so the desktop shows through very slightly.
export BAR_COLOR=0xf0181825
export ITEM_BG=0xff313244
export TRANSPARENT=0x00000000
