#!/usr/bin/env bash
set -uo pipefail

QDRANT_URL="${QDRANT_MEMORY_URL:-http://localhost:6333}"
COLLECTION="${QDRANT_MEMORY_COLLECTION:-cc_memory}"
LIMIT="${QDRANT_MEMORY_RECALL_LIMIT:-8}"

cat >/dev/null 2>&1 || true

resp=$(curl -s --max-time 6 -X POST \
  "${QDRANT_URL}/collections/${COLLECTION}/points/scroll" \
  -H 'Content-Type: application/json' \
  -d "{\"limit\":${LIMIT},\"with_payload\":true,\"with_vector\":false}" 2>/dev/null) || exit 0
[ -z "$resp" ] && exit 0

if printf '%s' "$resp" | grep -q '"error"'; then
  exit 0
fi

memo=$(printf '%s' "$resp" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    pts = (d.get("result") or {}).get("points") or []
    lines = []
    for p in pts:
        pl = p.get("payload") or {}
        doc = pl.get("document") or pl.get("information") or ""
        if not doc:
            doc = " ".join(str(v) for v in pl.values() if isinstance(v, str))[:300]
        doc = doc.strip().replace("\n", " ")
        if doc:
            lines.append("- " + doc[:300])
    print("\n".join(lines[:8]))
except Exception:
    pass
' 2>/dev/null) || exit 0

[ -z "$memo" ] && exit 0

python3 -c '
import json, sys
memo = sys.argv[1]
ctx = "## 過去の学習メモ(Qdrant メモリより自動想起)\n" + memo + "\n\n(さらに関連記憶が必要なら qdrant-find ツールで意味検索できます)"
print(json.dumps({"additionalContext": ctx}))
' "$memo" 2>/dev/null || exit 0

exit 0
