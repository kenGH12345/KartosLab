#!/usr/bin/env bash
# AIVibeCodingProj — Rebuild requirements/INDEX.md from meta.yaml files
#
# Usage:
#   ./.codebuddy/scripts/rebuild-index.sh            # rebuild INDEX.md
#   ./.codebuddy/scripts/rebuild-index.sh --quiet    # no output except errors
#
# This script is the SINGLE SOURCE mechanism for INDEX.md.
# It reads all requirements/req-*/meta.yaml and generates a fresh INDEX.md.
# Call it after any phase/status change instead of manually editing INDEX.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
REQ_DIR="$PROJECT_ROOT/requirements"
INDEX_MD="$REQ_DIR/INDEX.md"

QUIET=false
[[ "${1:-}" == "--quiet" ]] && QUIET=true

log() { $QUIET || echo "$1"; }

# ---- Collect data from meta.yaml files ----
declare -a rows=()

for meta in "$REQ_DIR"/req-*/meta.yaml; do
    [[ -f "$meta" ]] || continue

    # Parse yaml fields (simple grep-based, no external deps)
    req_id=$(grep -m1 '^req_id:' "$meta" | sed 's/^req_id:[[:space:]]*//' | tr -d '"')
    title=$(grep -m1 '^title:' "$meta" | sed 's/^title:[[:space:]]*//' | tr -d '"')
    sop=$(grep -m1 '^sop:' "$meta" | sed 's/^sop:[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | tr -d '"')
    phase=$(grep -m1 '^phase:' "$meta" | sed 's/^phase:[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | tr -d '"')
    status=$(grep -m1 '^status:' "$meta" | sed 's/^status:[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | tr -d '"')

    rows+=("| $req_id | $title | $status | $sop | $phase |")
done

# ---- Generate INDEX.md ----
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

cat > "$INDEX_MD" << 'HEADER'
# 需求索引

> 所有需求的总览。每个需求一个独立目录，命名 `req-<short-id>`。
> 本文件由 `.codebuddy/scripts/rebuild-index.sh` 自动生成，**不要手动编辑**。

## 需求清单

| 需求 ID | 标题 | 状态 | SOP | 阶段 |
|---|---|---|---|---|
HEADER

set +u  # arrays may be empty
if [[ ${#rows[@]} -gt 0 ]]; then
    for row in "${rows[@]}"; do
        echo "$row" >> "$INDEX_MD"
    done
fi
set -u

cat >> "$INDEX_MD" << EOF

---
*索引自动生成于：$TIMESTAMP*
EOF

set +u; count=${#rows[@]}; set -u
log "✓ INDEX.md rebuilt ($count requirements)"
