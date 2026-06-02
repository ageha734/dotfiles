#!/usr/bin/env bash

set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$DIR/lib-hook-common.sh"

CMD="$(hook_read_command)"
[ -z "$CMD" ] && exit 0

printf '%s' "$CMD" | grep -qE '\b(npm[[:space:]]+(i|install|add)|pnpm[[:space:]]+(add|install)|yarn[[:space:]]+add|pip3?[[:space:]]+install|python3?[[:space:]]+-m[[:space:]]+pip[[:space:]]+install|gem[[:space:]]+install|go[[:space:]]+(get|install))\b' || exit 0

EXACT_NPM='^[0-9]+\.[0-9]+\.[0-9]+([-+][0-9A-Za-z.-]+)?$'
EXACT_GEM='^[0-9]+(\.[0-9]+)*([.-][0-9A-Za-z]+)*$'
GO_SEMVER='^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'
GO_PSEUDO='^v[0-9]+\.[0-9]+\.[0-9]+-(0\.)?[0-9]{14}-[0-9a-f]{12}$'
GO_HASH='^[0-9a-f]{7,40}$'

WARN_MSGS=""

add_warn() { WARN_MSGS="${WARN_MSGS}${WARN_MSGS:+ / }$1"; }

# ---- npm ----
if printf '%s' "$CMD" | grep -qE '\b(npm|pnpm|yarn)\b'; then
  pkgs=$(printf '%s' "$CMD" | grep -oE '(install|add|i)[[:space:]]+([^|;&]+)' | sed -E 's/^(install|add|i)[[:space:]]+//')
  for tok in $pkgs; do
    case "$tok" in -*) continue ;; esac
    name="$tok"; spec=""
    base="${tok#@}"
    if [[ "$base" == *"@"* ]]; then
      spec="${base##*@}"
      name="${tok%@*}"
    fi
    if [ -z "$spec" ]; then
      hook_deny "npm: '$name' has no pinned version. Use '$name@X.Y.Z' with an exact version."
    fi
    if ! [[ "$spec" =~ $EXACT_NPM ]]; then
      hook_deny "npm: '$name@$spec' is not an exact version (ranges/latest/dist-tags not allowed). Specify X.Y.Z."
    fi
    enc="${name/\//%2f}"
    ts=$(curl -fsSL --max-time 8 "https://registry.npmjs.org/${enc}" 2>/dev/null \
      | python3 -c "import sys,json;print(json.load(sys.stdin).get('time',{}).get('$spec',''))" 2>/dev/null)
    if [ -n "$ts" ]; then
      release_is_too_fresh "$ts" && add_warn "npm '$name@$spec' was released less than ${RELEASE_THRESHOLD_DAYS} days ago (beware of supply-chain attacks)."
    fi
  done
fi

# ---- pip ----
if printf '%s' "$CMD" | grep -qE '\bpip3?[[:space:]]+install|python3?[[:space:]]+-m[[:space:]]+pip[[:space:]]+install'; then
  reqs=$(printf '%s' "$CMD" | sed -E 's/.*pip[[:space:]]+install//' )
  for tok in $reqs; do
    case "$tok" in -*) continue ;; esac
    if [ -z "$tok" ]; then continue; fi
    if [[ "$tok" == *"*"* ]] || [[ "$tok" =~ (\>|\<|~=|!=|,) ]]; then
      hook_deny "pip: '$tok' uses a range/wildcard. Pin to an exact version with 'pkg==X.Y.Z'."
    fi
    if ! [[ "$tok" =~ ^[A-Za-z0-9._-]+(\[[^]]+\])?==[^*,]+$ ]]; then
      hook_deny "pip: '$tok' is not pinned (==X.Y.Z required)."
    fi
    pkg="${tok%%[==\[]*}"; ver="${tok##*==}"
    ts=$(curl -fsSL --max-time 8 "https://pypi.org/pypi/${pkg}/${ver}/json" 2>/dev/null \
      | python3 -c "import sys,json;u=json.load(sys.stdin).get('urls',[]);print(min((x['upload_time_iso_8601'] for x in u), default=''))" 2>/dev/null)
    if [ -n "$ts" ]; then
      release_is_too_fresh "$ts" && add_warn "pip '$pkg==$ver' was released less than ${RELEASE_THRESHOLD_DAYS} days ago."
    fi
  done
fi

# ---- gem ----
if printf '%s' "$CMD" | grep -qE '\bgem[[:space:]]+install'; then
  gemver=$(printf '%s' "$CMD" | grep -oE -- '(-v|--version)[[:space:]]+[^[:space:]]+' | awk '{print $2}')
  if [ -z "$gemver" ]; then
    gemver=$(printf '%s' "$CMD" | grep -oE 'install[[:space:]]+[^[:space:]]+:[^[:space:]]+' | sed -E 's/.*://')
  fi
  if [ -z "$gemver" ]; then
    hook_deny "gem: No version specified. Pin with 'gem install foo -v 1.2.3'."
  fi
  if [[ "$gemver" =~ (\>|\<|~|=|,|\*) ]] || ! [[ "$gemver" =~ $EXACT_GEM ]]; then
    hook_deny "gem: '$gemver' is not an exact version (ranges/operators not allowed)."
  fi
fi

# ---- go ----
if printf '%s' "$CMD" | grep -qE '\bgo[[:space:]]+(get|install)\b'; then
  mods=$(printf '%s' "$CMD" | sed -E 's/.*go[[:space:]]+(get|install)//')
  for tok in $mods; do
    case "$tok" in -*) continue ;; esac
    [ -z "$tok" ] && continue
    if [[ "$tok" != *"@"* ]]; then
      hook_deny "go: '$tok' has no version/commit hash (equivalent to @latest). Pin with '@vX.Y.Z' or '@<commit-hash>'."
    fi
    gover="${tok##*@}"
    if [[ "$gover" =~ $GO_HASH ]] || [[ "$gover" =~ $GO_SEMVER ]] || [[ "$gover" =~ $GO_PSEUDO ]]; then
      :
    else
      hook_deny "go: '$tok' is not pinned (@latest/@master/major-only not allowed)."
    fi
  done
  if [ -n "${GOPROXY:-}" ]; then
    if [[ "$GOPROXY" != *golang.flatt.tech* ]]; then
      add_warn "GOPROXY does not point to golang.flatt.tech."
    elif [[ "$GOPROXY" =~ (\||,)[[:space:]]*direct ]]; then
      add_warn "GOPROXY includes ',direct' which can bypass golang.flatt.tech. Remove the direct fallback."
    fi
  fi
fi

[ -n "$WARN_MSGS" ] && hook_warn "$WARN_MSGS"
exit 0
