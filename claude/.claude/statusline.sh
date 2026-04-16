#!/usr/bin/env bash
# Claude Code status line — reads JSON from stdin, outputs a one-line status string.
# Format: <folder> | <branch> | <model> | ctx: <pct>%

set -euo pipefail

input="$(cat)"

# Extract fields from JSON (gracefully fall back on parse failure)
dir="$(echo "$input" | jq -r '.session.cwd // ""' 2>/dev/null)" || dir=""
model="$(echo "$input" | jq -r '.model // ""' 2>/dev/null)" || model=""
ctx_pct="$(echo "$input" | jq -r '.context_window.used_percentage // 0' 2>/dev/null)" || ctx_pct=0

# Derive display values
folder="${dir##*/}"
[[ -z "$folder" ]] && folder="."

branch=""
if [[ -n "$dir" && -d "$dir/.git" ]] || git -C "$dir" rev-parse --git-dir &>/dev/null 2>&1; then
  branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)" || branch=""
fi

# Shorten model name: "claude-sonnet-4-6" → "Sonnet"
short_model="$model"
if [[ "$model" == *sonnet* ]]; then
  short_model="Sonnet"
elif [[ "$model" == *opus* ]]; then
  short_model="Opus"
elif [[ "$model" == *haiku* ]]; then
  short_model="Haiku"
fi

# Context color (ANSI only when stdout is a terminal; status line renderers vary)
ctx_int="${ctx_pct%.*}"
ctx_int="${ctx_int:-0}"
if [[ "$ctx_int" -ge 60 ]]; then
  ctx_color="\033[31m"  # red
elif [[ "$ctx_int" -ge 40 ]]; then
  ctx_color="\033[33m"  # yellow
else
  ctx_color="\033[32m"  # green
fi
reset="\033[0m"

# Build output
parts=("$folder")
[[ -n "$branch" ]] && parts+=("$branch")
[[ -n "$short_model" ]] && parts+=("$short_model")

line="$(IFS=" | "; echo "${parts[*]}")"

printf "%s | %bctx: %s%%%b\n" "$line" "$ctx_color" "$ctx_int" "$reset"
