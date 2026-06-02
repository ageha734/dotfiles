#!/usr/bin/env bash

set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$DIR/lib-hook-common.sh"

INPUT="$(hook_read_input)"
TOOL="$(hook_read_tool_name "$INPUT")"
[ "${TOOL}" != "bash" ] && exit 0

CMD="$(hook_read_command "$INPUT")"
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
      hook_deny "npm: '$name' のバージョンが固定されていません。'$name@X.Y.Z' の完全固定で指定してください。"
    fi
    if ! [[ "$spec" =~ $EXACT_NPM ]]; then
      hook_deny "npm: '$name@$spec' は固定バージョンではありません(範囲/latest/dist-tag不可)。X.Y.Z で指定してください。"
    fi
    enc="${name/\//%2f}"
    ts=$(curl -fsSL --max-time 8 "https://registry.npmjs.org/${enc}" 2>/dev/null \
      | python3 -c "import sys,json;print(json.load(sys.stdin).get('time',{}).get('$spec',''))" 2>/dev/null)
    if [ -n "$ts" ]; then
      release_is_too_fresh "$ts" && add_warn "npm '$name@$spec' はリリースから${RELEASE_THRESHOLD_DAYS}日未満です(供給網攻撃の初動に注意)。"
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
      hook_deny "pip: '$tok' は範囲/ワイルドカード指定です。'pkg==X.Y.Z' の完全固定にしてください。"
    fi
    if ! [[ "$tok" =~ ^[A-Za-z0-9._-]+(\[[^]]+\])?==[^*,]+$ ]]; then
      hook_deny "pip: '$tok' はバージョン固定(==X.Y.Z)されていません。"
    fi
    pkg="${tok%%[==\[]*}"; ver="${tok##*==}"
    ts=$(curl -fsSL --max-time 8 "https://pypi.org/pypi/${pkg}/${ver}/json" 2>/dev/null \
      | python3 -c "import sys,json;u=json.load(sys.stdin).get('urls',[]);print(min((x['upload_time_iso_8601'] for x in u), default=''))" 2>/dev/null)
    if [ -n "$ts" ]; then
      release_is_too_fresh "$ts" && add_warn "pip '$pkg==$ver' はリリースから${RELEASE_THRESHOLD_DAYS}日未満です。"
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
    hook_deny "gem: バージョンが指定されていません。'gem install foo -v 1.2.3' のように固定してください。"
  fi
  if [[ "$gemver" =~ (\>|\<|~|=|,|\*) ]] || ! [[ "$gemver" =~ $EXACT_GEM ]]; then
    hook_deny "gem: '$gemver' は固定バージョンではありません(範囲/演算子不可)。"
  fi
fi

# ---- go ----
if printf '%s' "$CMD" | grep -qE '\bgo[[:space:]]+(get|install)\b'; then
  mods=$(printf '%s' "$CMD" | sed -E 's/.*go[[:space:]]+(get|install)//')
  for tok in $mods; do
    case "$tok" in -*) continue ;; esac
    [ -z "$tok" ] && continue
    if [[ "$tok" != *"@"* ]]; then
      hook_deny "go: '$tok' にバージョン/コミットハッシュ指定がありません(@latest相当)。'@vX.Y.Z' か '@<commit-hash>' で固定してください。"
    fi
    gover="${tok##*@}"
    if [[ "$gover" =~ $GO_HASH ]] || [[ "$gover" =~ $GO_SEMVER ]] || [[ "$gover" =~ $GO_PSEUDO ]]; then
      :
    else
      hook_deny "go: '$tok' は固定指定ではありません(@latest/@master/@vメジャーのみ 不可)。"
    fi
  done
  if [ -n "${GOPROXY:-}" ]; then
    if [[ "$GOPROXY" != *golang.flatt.tech* ]]; then
      add_warn "GOPROXY が golang.flatt.tech を指していません。"
    elif [[ "$GOPROXY" =~ (\||,)[[:space:]]*direct ]]; then
      add_warn "GOPROXY に ',direct' が付いており golang.flatt.tech を迂回できます。direct を外してください。"
    fi
  fi
fi

[ -n "$WARN_MSGS" ] && hook_warn "$WARN_MSGS"
exit 0
