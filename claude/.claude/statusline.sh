#!/usr/bin/env bash
# Catppuccin Mocha statusline — colourful blocks with diagonal slash dividers.
#   Line 1 (workspace):  dir [peach] → branch [yellow] → PR [state-coloured]
#   Line 2 (AI session): model [sapphire] → effort [mauve] → thinking [pink]
#                        → agent [flamingo] → ctx% [teal] → cost [lavender]
#   Line 3 (limits):     5h rate limit — teal/yellow/red, only when data present
# Requires a Nerd Font (same as Starship config).
set -euo pipefail

input="$(cat)"

dir="$(      echo "$input" | jq -r '.workspace.current_dir          // ""')"
model_id="$( echo "$input" | jq -r '.model.id // .model             // ""')"
ctx_pct="$(  echo "$input" | jq -r '.context_window.used_percentage // 0')"
cost="$(     echo "$input" | jq -r '.cost.total_cost_usd            // 0')"
effort="$(   echo "$input" | jq -r '.effort.level                   // ""')"
thinking="$( echo "$input" | jq -r '.thinking.enabled               // false')"
agent="$(    echo "$input" | jq -r '.agent.name                     // ""')"
pr_num="$(   echo "$input" | jq -r '.pr.number                      // ""')"
pr_state="$( echo "$input" | jq -r '.pr.review_state                // ""')"
rate_5h="$(  echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0')"

# ── Catppuccin Mocha palette ──────────────────────────────────────────────────
CRUST='\033[38;2;17;17;27m'                                        # #11111b
BG_PEACH='\033[48;2;250;179;135m';    FG_PEACH='\033[38;2;250;179;135m'
BG_YELLOW='\033[48;2;249;226;175m';   FG_YELLOW='\033[38;2;249;226;175m'
BG_GREEN='\033[48;2;166;227;161m';    FG_GREEN='\033[38;2;166;227;161m'
BG_TEAL='\033[48;2;148;226;213m';     FG_TEAL='\033[38;2;148;226;213m'
BG_SAPPHIRE='\033[48;2;116;199;236m'; FG_SAPPHIRE='\033[38;2;116;199;236m'
BG_LAVENDER='\033[48;2;180;190;254m'; FG_LAVENDER='\033[38;2;180;190;254m'
BG_MAUVE='\033[48;2;203;166;247m';    FG_MAUVE='\033[38;2;203;166;247m'
BG_PINK='\033[48;2;245;194;231m';     FG_PINK='\033[38;2;245;194;231m'
BG_FLAMINGO='\033[48;2;242;205;205m'; FG_FLAMINGO='\033[38;2;242;205;205m'
BG_RED='\033[48;2;243;139;168m';      FG_RED='\033[38;2;243;139;168m'
RESET='\033[0m'

# U+E0BC: Nerd Font diagonal slash — printed as fg=prev-bg, bg=next-bg
SLASH=$''

# ── Derived values ────────────────────────────────────────────────────────────

folder="${dir##*/}"; [[ -z "$folder" ]] && folder="."
case "$folder" in
  Developer) folder=$'\U000f02cb Dev'  ;;
  Documents) folder=$'\U000f0219 Docs' ;;
  Downloads) folder=$' DL'        ;;
  Music)     folder=$'\U000f075a Music';;
  Pictures)  folder=$' Pics'      ;;
esac

branch=""; dirty=""
if [[ -n "$dir" ]] && git -C "$dir" rev-parse --git-dir &>/dev/null 2>&1; then
  branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)" || branch=""
  [[ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]] && dirty="*"
fi

case "$model_id" in
  *sonnet*) short_model="Sonnet" ;;
  *opus*)   short_model="Opus"   ;;
  *haiku*)  short_model="Haiku"  ;;
  *)        short_model="${model_id:-'?'}" ;;
esac

ctx_int="${ctx_pct%.*}"; ctx_int="${ctx_int:-0}"
cost_fmt="$(printf '$%.3f' "$cost" 2>/dev/null)" || cost_fmt="\$0.000"
rate_5h_int="${rate_5h%.*}"; rate_5h_int="${rate_5h_int:-0}"

# ── LINE 1: Workspace ─────────────────────────────────────────────────────────

line1=""
line1+="${BG_PEACH}${CRUST} 󰲋 ${folder} ${RESET}"

if [[ -n "$branch" ]]; then
  line1+="${FG_PEACH}${BG_YELLOW}${SLASH}${RESET}"
  line1+="${BG_YELLOW}${CRUST}  ${branch}${dirty} ${RESET}"
  prev_fg1="${FG_YELLOW}"
else
  prev_fg1="${FG_PEACH}"
fi

if [[ -n "$pr_num" ]]; then
  case "$pr_state" in
    approved)          pr_icon="✓"; BG_PR="${BG_GREEN}";    FG_PR="${FG_GREEN}" ;;
    changes_requested) pr_icon="✗"; BG_PR="${BG_RED}";      FG_PR="${FG_RED}" ;;
    draft)             pr_icon="⊘"; BG_PR="${BG_SAPPHIRE}"; FG_PR="${FG_SAPPHIRE}" ;;
    *)                 pr_icon="…"; BG_PR="${BG_PEACH}";    FG_PR="${FG_PEACH}" ;;
  esac
  line1+="${prev_fg1}${BG_PR}${SLASH}${RESET}"
  line1+="${BG_PR}${CRUST} #${pr_num} ${pr_icon} ${RESET}"
  line1+="${FG_PR}${SLASH}${RESET}"
else
  line1+="${prev_fg1}${SLASH}${RESET}"
fi

# ── LINE 2: AI Session ────────────────────────────────────────────────────────

line2=""
line2+="${BG_SAPPHIRE}${CRUST}  ${short_model} ${RESET}"
prev_fg2="${FG_SAPPHIRE}"

if [[ -n "$effort" ]]; then
  line2+="${prev_fg2}${BG_MAUVE}${SLASH}${RESET}"
  line2+="${BG_MAUVE}${CRUST} ⚡ ${effort} ${RESET}"
  prev_fg2="${FG_MAUVE}"
fi

if [[ "$thinking" == "true" ]]; then
  line2+="${prev_fg2}${BG_PINK}${SLASH}${RESET}"
  line2+="${BG_PINK}${CRUST} 󰔩 thinking ${RESET}"
  prev_fg2="${FG_PINK}"
fi

if [[ -n "$agent" ]]; then
  line2+="${prev_fg2}${BG_FLAMINGO}${SLASH}${RESET}"
  line2+="${BG_FLAMINGO}${CRUST}  ${agent} ${RESET}"
  prev_fg2="${FG_FLAMINGO}"
fi

line2+="${prev_fg2}${BG_TEAL}${SLASH}${RESET}"
line2+="${BG_TEAL}${CRUST} ctx:${ctx_int}% ${RESET}"
line2+="${FG_TEAL}${BG_LAVENDER}${SLASH}${RESET}"
line2+="${BG_LAVENDER}${CRUST} ${cost_fmt} ${RESET}"
line2+="${FG_LAVENDER}${SLASH}${RESET}"

# ── LINE 3: Rate Limits ───────────────────────────────────────────────────────

line3=""
if [[ "$rate_5h_int" -gt 0 ]]; then
  if   [[ "$rate_5h_int" -ge 80 ]]; then BG_RATE="${BG_RED}";    FG_RATE="${FG_RED}"
  elif [[ "$rate_5h_int" -ge 50 ]]; then BG_RATE="${BG_YELLOW}"; FG_RATE="${FG_YELLOW}"
  else                                   BG_RATE="${BG_TEAL}";   FG_RATE="${FG_TEAL}"
  fi
  line3+="${BG_RATE}${CRUST} ⚡ 5h: ${rate_5h_int}% ${RESET}"
  line3+="${FG_RATE}${SLASH}${RESET}"
fi

# ── Output ────────────────────────────────────────────────────────────────────

printf "%b\n" "$line1"
printf "%b\n" "$line2"
if [[ -n "$line3" ]]; then printf "%b\n" "$line3"; fi
