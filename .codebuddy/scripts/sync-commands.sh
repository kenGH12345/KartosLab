#!/usr/bin/env bash
# AIVibeCodingProj — Sync Commands (.claude → .cursor)
#
# Usage:
#   ./.codebuddy/scripts/sync-commands.sh            # sync all
#   ./.codebuddy/scripts/sync-commands.sh --dry-run  # show what would change
#   ./.codebuddy/scripts/sync-commands.sh --quiet    # only print summary
#
# What it does:
#   For each .claude/commands/*.md, write a copy to .cursor/commands/<same>.md
#   with the YAML frontmatter (between leading `---` lines) stripped.
#   Cursor commands don't use frontmatter; they expect plain markdown content.
#
# Idempotent: safe to re-run. Re-creates .cursor/commands/ from scratch each run
# to avoid stale files when commands are renamed/removed in .claude/.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC_DIR="$PROJECT_ROOT/.claude/commands"
DST_DIR="$PROJECT_ROOT/.cursor/commands"

DRY_RUN=false
QUIET=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --quiet)   QUIET=true; shift ;;
        -h|--help)
            grep '^#' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

c_cyan='\033[36m'; c_green='\033[32m'; c_yellow='\033[33m'; c_red='\033[31m'; c_gray='\033[90m'; c_off='\033[0m'

step() { $QUIET || echo -e "${c_cyan}==> $*${c_off}"; }
ok()   { $QUIET || echo -e "  ${c_green}+${c_off} $*"; }
warn() { echo -e "  ${c_yellow}!${c_off} $*"; }
err()  { echo -e "  ${c_red}x${c_off} $*"; }
info() { $QUIET || echo -e "    ${c_gray}$*${c_off}"; }

[[ -d "$SRC_DIR" ]] || { err "Source missing: $SRC_DIR"; exit 1; }

step "Sync .claude/commands/ → .cursor/commands/"
info "src: $SRC_DIR"
info "dst: $DST_DIR"

# Strip YAML frontmatter (between leading --- lines) AND normalize CRLF -> LF
# Algorithm:
#   1. Strip CR (so awk regex works regardless of source line endings)
#   2. line 1 == "---" → start frontmatter; skip until next "---"
#   3. else → emit all lines as-is
strip_frontmatter() {
    local f="$1"
    tr -d '\r' < "$f" | awk '
        BEGIN { in_fm=0; fm_done=0 }
        NR==1 && /^---$/ { in_fm=1; next }
        in_fm && /^---$/ { in_fm=0; fm_done=1; next }
        in_fm { next }
        # Skip a single blank line right after frontmatter close (cosmetic)
        fm_done && NF==0 { fm_done=0; next }
        { fm_done=0; print }
    '
}

if $DRY_RUN; then
    step "[dry-run] would recreate $DST_DIR"
else
    rm -rf "$DST_DIR"
    mkdir -p "$DST_DIR"
fi

count=0
src_files=()
while IFS= read -r -d '' f; do
    src_files+=("$f")
done < <(find "$SRC_DIR" -maxdepth 1 -name '*.md' -type f -print0)

for src in "${src_files[@]}"; do
    name="$(basename "$src")"
    dst="$DST_DIR/$name"
    if $DRY_RUN; then
        info "[dry-run] $name"
    else
        strip_frontmatter "$src" > "$dst"
        info "$name"
    fi
    count=$((count + 1))
done

ok "Synced $count command(s)"

if ! $DRY_RUN; then
    step "Verifying"
    dst_count=$(find "$DST_DIR" -maxdepth 1 -name '*.md' -type f | wc -l | tr -d ' ')
    if [[ "$dst_count" == "$count" ]]; then
        ok "Counts match: $count source = $dst_count synced"
    else
        err "Count mismatch: $count source vs $dst_count synced"
        exit 2
    fi
fi
