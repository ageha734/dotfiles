#!/usr/bin/env bash
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$DIR/lib-hook-common.sh"

CMD="$(hook_read_command)"
[ -z "$CMD" ] && exit 0

if printf '%s' "$CMD" | grep -qE 'AKIA[0-9A-Z]{16}'; then
  hook_deny "AWS access key (AKIA...) found in plaintext. Use environment variables or a credential store instead."
fi
if printf '%s' "$CMD" | grep -qE 'gh[pousr]_[0-9A-Za-z]{36,}'; then
  hook_deny "GitHub token (ghp_/gho_...) found in plaintext in the command."
fi
if printf '%s' "$CMD" | grep -qE 'xox[baprs]-[0-9A-Za-z-]{10,}'; then
  hook_deny "Slack token (xox...) found in plaintext in the command."
fi
if printf '%s' "$CMD" | grep -qE -- '-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----'; then
  hook_deny "Private key (PRIVATE KEY) detected in the command."
fi
if printf '%s' "$CMD" | grep -qE 'tg_(anon|org)_[0-9A-Za-z]{8,}'; then
  hook_deny "Guard token (tg_...) found in plaintext. Use a config file or environment variable instead."
fi

if printf '%s' "$CMD" | grep -qE '(curl|wget)\b.*\|\s*(sudo[[:space:]]+)?(bash|sh|zsh)\b'; then
  hook_deny "Piping remote scripts into a shell (curl|bash etc.) is blocked. Save the script and review it before executing."
fi

if printf '%s' "$CMD" | grep -qE '(aws[[:space:]]+(sts[[:space:]]+(get-session-token|assume-role)|secretsmanager[[:space:]]+(get-secret-value|batch-get-secret-value)|ssm[[:space:]]+get-parameter|kms[[:space:]]+decrypt)|gcloud[[:space:]]+(auth[[:space:]]+(print-access-token|print-identity-token|application-default[[:space:]]+print-access-token)|secrets[[:space:]]+versions[[:space:]]+access)|gh[[:space:]]+auth[[:space:]]+token|kubectl[[:space:]]+(get|describe)[[:space:]]+secret|vault[[:space:]]+(read|kv[[:space:]]+get)|op[[:space:]]+(read|item[[:space:]]+get)|security[[:space:]]+find-(generic|internet)-password)'; then
  hook_deny "Credential/token retrieval commands are blocked. Run manually if needed."
fi

if printf '%s' "$CMD" | grep -qE '(cat|head|tail|less|more|xxd|od|strings|grep|awk|sed)\b[^|]*\.(env|pem|key|p12|pfx|tfvars)\b'; then
  hook_warn "Attempting to read a secret-like file (.env/.pem/.key etc.). Do not send its contents to external services."
fi

exit 0
