# sketchybar

A scriptable replacement for the macOS menu bar. Every item is a shell script
run on a timer or an event.

## No window-manager dependency

The configs this was modelled on (kienanana's, F1lmzy's) drive their workspace
indicators from **yabai**, which needs SIP partially disabled to inject a
scripting addition into `Dock.app`. This machine runs Loop with SIP intact, and
`macos.sh` states plainly that nothing in this repo touches security posture.

So there is no spaces item here at all. Every item reads from ordinary
userland commands, and the bar works regardless of which window manager is
running — Loop today, AeroSpace later, or none.

## Items

| Item | Source | Refresh |
|---|---|---|
| `front_app` | `front_app_switched` event | event-driven |
| `cpu` | `ps -A -o %cpu` ÷ core count | 5s |
| `memory` | `memory_pressure` | 15s |
| `wifi` | `ipconfig getsummary` | 30s |
| `volume` | `volume_change` event | event-driven |
| `battery` | `pmset -g batt` | 120s + on plug/unplug |
| `clock` | `date` | 10s |

Two deliberate choices:

- **CPU does not use `top -l 1`.** That samples for a full second, so a bar
  refreshing every 5s would spend a fifth of its life inside `top`. Reading the
  accounting `ps` already keeps returns instantly.
- **Wi-Fi does not use `airport -I`.** That was removed in recent macOS
  versions; `ipconfig getsummary` still exposes the SSID.

## The native menu bar

`macos.sh` sets `_HIHideMenuBar`, otherwise the native bar sits behind this one
and you get two. It auto-hides rather than disappearing, so the Apple menu and
per-app menus still slide down when the pointer reaches the top edge.

Apply it without running all of `macos.sh`:

```sh
defaults write NSGlobalDomain _HIHideMenuBar -bool true && killall SystemUIServer
```

Revert:

```sh
defaults delete NSGlobalDomain _HIHideMenuBar && killall SystemUIServer
```

## Editing

```sh
sketchybar --reload            # re-read config, no restart
brew services restart sketchybar
```

Colours are Catppuccin Mocha in `colors.sh`, matching ghostty, nvim, tmux,
btop and borders. SketchyBar cannot follow the macOS appearance setting, so
like those it is pinned to Mocha. Note the format is `0xAARRGGBB` — alpha
first.
