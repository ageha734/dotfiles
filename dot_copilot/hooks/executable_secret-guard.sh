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

if printf '%s' "$CMD" | grep -qE 'AKIA[0-9A-Z]{16}'; then
  hook_deny "AWSアクセスキー(AKIA...)がコマンドに平文で含まれています。環境変数や認証情報ストアを使ってください。"
fi
if printf '%s' "$CMD" | grep -qE 'gh[pousr]_[0-9A-Za-z]{36,}'; then
  hook_deny "GitHubトークン(ghp_/gho_...)がコマンドに平文で含まれています。"
fi
if printf '%s' "$CMD" | grep -qE 'xox[baprs]-[0-9A-Za-z-]{10,}'; then
  hook_deny "Slackトークン(xox...)がコマンドに平文で含まれています。"
fi
if printf '%s' "$CMD" | grep -qE -- '-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----'; then
  hook_deny "秘密鍵(PRIVATE KEY)がコマンドに含まれています。"
fi
if printf '%s' "$CMD" | grep -qE 'tg_(anon|org)_[0-9A-Za-z]{8,}'; then
  hook_deny "Guardトークン(tg_...)がコマンドに平文で含まれています。設定ファイル/環境変数で管理してください。"
fi

if printf '%s' "$CMD" | grep -qE '(curl|wget)\b.*\|\s*(sudo[[:space:]]+)?(bash|sh|zsh)\b'; then
  hook_deny "リモートスクリプトのパイプ実行(curl|bash 等)はブロックされます。スクリプトを保存しレビューしてから実行してください。"
fi

if printf '%s' "$CMD" | grep -qE '(aws[[:space:]]+(sts[[:space:]]+(get-session-token|assume-role)|secretsmanager[[:space:]]+(get-secret-value|batch-get-secret-value)|ssm[[:space:]]+get-parameter|kms[[:space:]]+decrypt)|gcloud[[:space:]]+(auth[[:space:]]+(print-access-token|print-identity-token|application-default[[:space:]]+print-access-token)|secrets[[:space:]]+versions[[:space:]]+access)|gh[[:space:]]+auth[[:space:]]+token|kubectl[[:space:]]+(get|describe)[[:space:]]+secret|vault[[:space:]]+(read|kv[[:space:]]+get)|op[[:space:]]+(read|item[[:space:]]+get)|security[[:space:]]+find-(generic|internet)-password)'; then
  hook_deny "認証情報・トークン取得コマンドはブロックされます。必要なら手動で実行してください。"
fi

if printf '%s' "$CMD" | grep -qE '(cat|head|tail|less|more|xxd|od|strings|grep|awk|sed)\b[^|]*\.(env|pem|key|p12|pfx|tfvars)\b'; then
  hook_warn "シークレットらしきファイル(.env/.pem/.key 等)を読み出そうとしています。内容を外部へ送信しないよう注意してください。"
fi

exit 0
