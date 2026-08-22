# dotfiles-update — show the last scheduled maintenance result once.
#
# The weekly launchd job writes a summary to this file; the first new shell
# after a run prints it and deletes it, so you see the result exactly once.

() {
  local summary="$HOME/.local/state/dotfiles-update/last-summary"
  [[ -r "$summary" ]] || return 0

  print -P "%F{blue}󰚰%f $(head -1 "$summary")"
  tail -n +2 "$summary" | while IFS= read -r line; do
    print -P "  %F{242}${line}%f"
  done
  print

  rm -f "$summary"
}

# Manual maintenance run (the same script launchd schedules weekly).
alias dfu='dotfiles-update'
alias dfu-log='less +G ~/.local/state/dotfiles-update/update.log'
