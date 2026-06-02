#!/usr/bin/env bash
set -uo pipefail

hook_read_input() {
  cat
}

hook_read_tool_name() {
  local input="$1"
  printf '%s' "$input" | jq -r '.toolName // .tool_name // empty' 2>/dev/null
}

hook_read_command() {
  local input="$1"
  printf '%s' "$input" | jq -r '
    .toolArgs.command //
    .tool_input.command //
    (
      if (.toolArgs | type) == "string" then .toolArgs else empty end
    ) //
    (
      if (.tool_input | type) == "string" then .tool_input else empty end
    ) //
    empty
  ' 2>/dev/null
}

hook_deny() {
  jq -cn --arg r "$1" \
    '{permissionDecision:"deny",permissionDecisionReason:$r}'
  exit 0
}

hook_warn() {
  jq -cn --arg m "$1" '{additionalContext:$m}'
  exit 0
}

iso_to_epoch() {
  local clean
  clean=$(printf '%s' "$1" | sed -E 's/\.[0-9]+//; s/Z$//')
  date -j -u -f "%Y-%m-%dT%H:%M:%S" "$clean" +%s 2>/dev/null
}

RELEASE_THRESHOLD_DAYS="${RELEASE_THRESHOLD_DAYS:-14}"
release_is_too_fresh() {
  local ts epoch now age
  ts="$1"
  epoch=$(iso_to_epoch "$ts") || return 2
  [ -z "$epoch" ] && return 2
  now=$(date -u +%s)
  age=$(( (now - epoch) / 86400 ))
  [ "$age" -lt "$RELEASE_THRESHOLD_DAYS" ] && return 0
  return 1
}
