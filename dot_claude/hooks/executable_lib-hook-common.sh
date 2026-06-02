#!/usr/bin/env bash
set -uo pipefail

hook_read_command() {
    local input
    input="$(cat)"
    printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null
}

hook_deny() {
    jq -cn --arg r "$1" \
        '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
    exit 0
}

hook_warn() {
    jq -cn --arg m "$1" '{systemMessage:$m}'
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
    age=$(((now - epoch) / 86400))
    [ "$age" -lt "$RELEASE_THRESHOLD_DAYS" ] && return 0
    return 1
}
