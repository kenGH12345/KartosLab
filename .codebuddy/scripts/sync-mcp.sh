#!/usr/bin/env bash
# AIVibeCodingProj — Sync MCP config (.mcp.json → .cursor/mcp.json)
#
# Usage:
#   ./.codebuddy/scripts/sync-mcp.sh             # sync
#   ./.codebuddy/scripts/sync-mcp.sh --dry-run   # show what would change
#
# What it does:
#   Copy .mcp.json (project-root MCP config; read directly by both Claude Code
#   and CodeBuddy) to .cursor/mcp.json (Cursor's project-level MCP config).
#   All three tools use the same `mcpServers` schema, so a straight copy works.
#   .codebuddy/ does NOT need a sync target — CodeBuddy reads the same root
#   .mcp.json that Claude Code reads.
#
# Idempotent: safe to re-run.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$PROJECT_ROOT/.mcp.json"
DST="$PROJECT_ROOT/.cursor/mcp.json"

DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help)
            grep '^#' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

c_cyan='\033[36m'; c_green='\033[32m'; c_red='\033[31m'; c_gray='\033[90m'; c_off='\033[0m'

step() { echo -e "${c_cyan}==> $*${c_off}"; }
ok()   { echo -e "  ${c_green}+${c_off} $*"; }
err()  { echo -e "  ${c_red}x${c_off} $*"; }
info() { echo -e "    ${c_gray}$*${c_off}"; }

[[ -f "$SRC" ]] || { err "Source missing: $SRC"; exit 1; }

step "Sync .mcp.json → .cursor/mcp.json"
info "src: $SRC"
info "dst: $DST"

if $DRY_RUN; then
    if [[ -f "$DST" ]] && cmp -s "$SRC" "$DST"; then
        ok "[dry-run] already in sync"
    else
        info "[dry-run] would copy"
    fi
    exit 0
fi

mkdir -p "$(dirname "$DST")"
cp "$SRC" "$DST"

if cmp -s "$SRC" "$DST"; then
    ok "Synced ($(wc -c < "$DST" | tr -d ' ') bytes)"
else
    err "Copy succeeded but contents differ — investigate"
    exit 2
fi
