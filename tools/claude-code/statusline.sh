#!/bin/bash
# Claude Code status line: model, directory, git branch, context %, cost,
# and the account's rolling 5-hour / 7-day plan usage (Pro/Max only).
# Requires jq. Wired up via the "statusLine" key in settings.json.

input=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  echo "[statusline] jq not found, install jq to use this script"
  exit 0
fi

GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
RESET=$'\033[0m'

color_for_pct() {
  local pct_int=${1%.*}
  if [ "$pct_int" -ge 90 ]; then echo "$RED"
  elif [ "$pct_int" -ge 70 ]; then echo "$YELLOW"
  else echo "$GREEN"
  fi
}

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
DIRNAME="${DIR##*/}"
CTX=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

BRANCH=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
  [ -n "$CURRENT_BRANCH" ] && BRANCH=" | branch:$CURRENT_BRANCH"
fi

FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

LIMITS=""
if [ -n "$FIVE_H" ]; then
  C=$(color_for_pct "$FIVE_H")
  LIMITS="${C}5h:$(printf '%.0f' "$FIVE_H")%${RESET}"
fi
if [ -n "$WEEK" ]; then
  C=$(color_for_pct "$WEEK")
  [ -n "$LIMITS" ] && LIMITS="$LIMITS "
  LIMITS="${LIMITS}${C}7d:$(printf '%.0f' "$WEEK")%${RESET}"
fi

CTX_COLOR=$(color_for_pct "$CTX")
LINE="[$MODEL] ${DIRNAME}${BRANCH} | ctx:${CTX_COLOR}${CTX}%${RESET}"
[ -n "$LIMITS" ] && LINE="$LINE | $LIMITS"
[ -n "$COST" ] && LINE="$LINE | \$$(printf '%.2f' "$COST")"

echo -e "$LINE"
