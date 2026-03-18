#!/bin/bash
# Claude Code statusline script (Linux version)
# Line 1: Model | Context% | +added/-removed | git branch
# Line 2: 5h rate limit progress bar
# Line 3: 7d rate limit progress bar

input=$(cat)

# ---------- ANSI Colors ----------
GREEN=$'\e[38;2;151;201;195m'
YELLOW=$'\e[38;2;229;192;123m'
RED=$'\e[38;2;224;108;117m'
GRAY=$'\e[38;2;74;88;92m'
RESET=$'\e[0m'
DIM=$'\e[2m'

# ---------- Color by percentage ----------
color_for_pct() {
  local pct="$1"
  if [ -z "$pct" ] || [ "$pct" = "null" ]; then
    printf '%s' "$GRAY"
    return
  fi
  local ipct
  ipct=$(printf "%.0f" "$pct" 2>/dev/null || echo "0")
  if [ "$ipct" -ge 80 ]; then
    printf '%s' "$RED"
  elif [ "$ipct" -ge 50 ]; then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# ---------- Progress bar (10 segments) ----------
progress_bar() {
  local pct="$1"
  local filled
  filled=$(awk "BEGIN{printf \"%d\", int($pct / 5 + 0.5)}" 2>/dev/null || echo 0)
  [ "$filled" -gt 20 ] 2>/dev/null && filled=20
  [ "$filled" -lt 0 ] 2>/dev/null && filled=0
  local bar="["
  for i in $(seq 1 20); do
    if [ "$i" -le "$filled" ]; then
      bar="${bar}="
    else
      bar="${bar}-"
    fi
  done
  bar="${bar}]"
  printf '%s' "$bar"
}

# ---------- Parse stdin (single jq call) ----------
eval "$(echo "$input" | jq -r '
  "model_name=" + (.model.display_name // "Unknown" | @sh),
  "used_pct=" + (.context_window.used_percentage // 0 | tostring),
  "cwd=" + (.cwd // "" | @sh),
  "lines_added=" + (.cost.total_lines_added // 0 | tostring),
  "lines_removed=" + (.cost.total_lines_removed // 0 | tostring),
  "cc_version=" + (.version // "0.0.0" | @sh)
' 2>/dev/null)"

# ---------- Git branch ----------
git_branch=""
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null || true)
fi

# ---------- Line stats from stdin ----------
git_stats=""
if [ "$lines_added" -gt 0 ] 2>/dev/null || [ "$lines_removed" -gt 0 ] 2>/dev/null; then
  git_stats="+${lines_added}/-${lines_removed}"
fi

# ---------- Rate limit via Haiku probe (cached 360s) ----------
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_TTL=360
FIVE_HOUR_UTIL=""
FIVE_HOUR_RESET=""
SEVEN_DAY_UTIL=""
SEVEN_DAY_RESET=""

fetch_usage() {
  # Linux: read credentials from ~/.claude/.credentials.json
  local creds_file="$HOME/.claude/.credentials.json"
  [ ! -f "$creds_file" ] && return 1

  local token
  token=$(cat "$creds_file" 2>/dev/null || true)
  [ -z "$token" ] && return 1

  local access_token
  if echo "$token" | jq -e . >/dev/null 2>&1; then
    access_token=$(echo "$token" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
  else
    access_token="$token"
  fi
  [ -z "$access_token" ] && return 1

  # Tiny Haiku call (max_tokens=1) to get rate limit response headers
  local full_response
  full_response=$(curl -sD- --max-time 8 -o /dev/null \
    -H "Authorization: Bearer ${access_token}" \
    -H "Content-Type: application/json" \
    -H "User-Agent: claude-code/${cc_version:-0.0.0}" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "anthropic-version: 2023-06-01" \
    -d '{"model":"claude-haiku-4-5-20251001","max_tokens":1,"messages":[{"role":"user","content":"h"}]}' \
    "https://api.anthropic.com/v1/messages" 2>/dev/null || true)
  local headers="$full_response"
  [ -z "$headers" ] && return 1

  # Parse rate limit headers
  local h5_util h5_reset h7_util h7_reset
  h5_util=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-5h-utilization' | tr -d '\r' | awk '{print $2}')
  h5_reset=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-5h-reset' | tr -d '\r' | awk '{print $2}')
  h7_util=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-7d-utilization' | tr -d '\r' | awk '{print $2}')
  h7_reset=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-7d-reset' | tr -d '\r' | awk '{print $2}')

  [ -z "$h5_util" ] && return 1

  # Save to cache as JSON
  jq -n \
    --arg h5u "$h5_util" --arg h5r "$h5_reset" \
    --arg h7u "$h7_util" --arg h7r "$h7_reset" \
    '{five_hour_util: $h5u, five_hour_reset: $h5r, seven_day_util: $h7u, seven_day_reset: $h7r}' \
    > "$CACHE_FILE"
  return 0
}

load_usage() {
  local data="$1"
  eval "$(echo "$data" | jq -r '
    "FIVE_HOUR_UTIL=" + (.five_hour_util // empty),
    "FIVE_HOUR_RESET=" + (.five_hour_reset // empty),
    "SEVEN_DAY_UTIL=" + (.seven_day_util // empty),
    "SEVEN_DAY_RESET=" + (.seven_day_reset // empty)
  ' 2>/dev/null)"
}

# Check cache validity (Linux: stat -c '%Y')
USE_CACHE=false
if [ -f "$CACHE_FILE" ]; then
  cache_age=$(( $(date +%s) - $(stat -c '%Y' "$CACHE_FILE" 2>/dev/null || echo 0) ))
  if [ "$cache_age" -lt "$CACHE_TTL" ]; then
    USE_CACHE=true
  fi
fi

if $USE_CACHE; then
  load_usage "$(cat "$CACHE_FILE")"
else
  if fetch_usage; then
    load_usage "$(cat "$CACHE_FILE")"
  elif [ -f "$CACHE_FILE" ]; then
    load_usage "$(cat "$CACHE_FILE")"
  fi
fi

# Convert utilization (0.0-1.0) to percentage
to_pct() {
  local val="$1"
  if [ -z "$val" ] || [ "$val" = "null" ] || [ "$val" = "0" ]; then
    echo ""
    return
  fi
  awk "BEGIN{printf \"%.0f\", $val * 100}" 2>/dev/null || echo ""
}

FIVE_HOUR_PCT=$(to_pct "$FIVE_HOUR_UTIL")
SEVEN_DAY_PCT=$(to_pct "$SEVEN_DAY_UTIL")

# ---------- Format reset time (ISO 8601 or epoch) ----------
# style: "time" → "3:00 PM"  |  "date_time" → "3/7 3:00 PM"
format_reset_time() {
  local ts="$1"
  local style="$2"
  [ -z "$ts" ] || [ "$ts" = "0" ] && echo "" && return

  local fmt
  case "$style" in
    date_time) fmt="+%m/%d %I%p" ;;
    *)         fmt="+%I%p" ;;
  esac

  local result=""
  # Try ISO 8601 (GNU date supports this natively)
  result=$(LC_ALL=C TZ="Asia/Tokyo" date -d "$ts" "$fmt" 2>/dev/null || true)
  # Fallback: treat as epoch seconds
  if [ -z "$result" ]; then
    result=$(LC_ALL=C TZ="Asia/Tokyo" date -d "@${ts}" "$fmt" 2>/dev/null || echo "")
  fi
  # Strip leading zeros: "03:00" → "3:00", "03/07" → "3/7"
  echo "$result" | sed 's|^0||;s|/0|/|;s| 0| |'
}

five_reset_display=""
if [ -n "$FIVE_HOUR_RESET" ] && [ "$FIVE_HOUR_RESET" != "0" ]; then
  five_reset_display="Resets $(format_reset_time "$FIVE_HOUR_RESET" "time") (JST)"
fi

seven_reset_display=""
if [ -n "$SEVEN_DAY_RESET" ] && [ "$SEVEN_DAY_RESET" != "0" ]; then
  seven_reset_display="Resets $(format_reset_time "$SEVEN_DAY_RESET" "date_time") (JST)"
fi

# ---------- Format context used% ----------
ctx_pct_int=0
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ] && [ "$used_pct" != "0" ]; then
  ctx_pct_int=$(printf "%.0f" "$used_pct" 2>/dev/null || echo 0)
fi

# ---------- Line 1 ----------
SEP="${GRAY} │ ${RESET}"
ctx_color=$(color_for_pct "$ctx_pct_int")

line1="${model_name}${SEP}${ctx_color}ctx ${ctx_pct_int}%${RESET}"

if [ -n "$git_stats" ]; then
  line1+="${SEP}${GREEN}${git_stats}${RESET}"
fi

if [ -n "$git_branch" ]; then
  line1+="${SEP}${git_branch}"
fi

# ---------- Line 2 (5h) ----------
line2=""
if [ -n "$FIVE_HOUR_PCT" ]; then
  c5=$(color_for_pct "$FIVE_HOUR_PCT")
  bar5=$(progress_bar "$FIVE_HOUR_PCT")
  line2="${c5}5h  ${bar5}  ${FIVE_HOUR_PCT}%${RESET}"
  [ -n "$five_reset_display" ] && line2+="  ${DIM}${five_reset_display}${RESET}"
else
  line2="${GRAY}5h  [--------------------]  --%${RESET}"
fi

# ---------- Line 3 (7d) ----------
line3=""
if [ -n "$SEVEN_DAY_PCT" ]; then
  c7=$(color_for_pct "$SEVEN_DAY_PCT")
  bar7=$(progress_bar "$SEVEN_DAY_PCT")
  line3="${c7}7d  ${bar7}  ${SEVEN_DAY_PCT}%${RESET}"
  [ -n "$seven_reset_display" ] && line3+="  ${DIM}${seven_reset_display}${RESET}"
else
  line3="${GRAY}7d  [--------------------]  --%${RESET}"
fi

# ---------- Output ----------
printf '%s\n' "$line1"
printf '%s\n' "$line2"
printf '%s' "$line3"
