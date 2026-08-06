#!/usr/bin/env bash
# AIVibeCodingProj — Maintain three-way symlinks (.codebuddy → .cursor / .claude)
#
# Usage:
#   ./.codebuddy/scripts/sync-codebuddy.sh             # rebuild all symlinks
#   ./.codebuddy/scripts/sync-codebuddy.sh --dry-run   # show what would change
#   ./.codebuddy/scripts/sync-codebuddy.sh --quiet     # only print summary
#
# Architecture (since v0.2):
#   .codebuddy/ is the SINGLE SOURCE OF TRUTH for shared assets.
#   .cursor/ and .claude/ contain SYMLINKS into .codebuddy/.
#
#     .cursor/rules/*.mdc      -> ../../.codebuddy/rules/*.mdc
#     .cursor/commands/*.md    -> ../../.codebuddy/commands/*.md
#     .claude/agents/*.md      -> ../../.codebuddy/agents/*.md
#     .claude/commands/*.md    -> ../../.codebuddy/commands/*.md
#
#   Editing any of these paths edits the same underlying file. All three IDEs
#   (Claude Code, Cursor, CodeBuddy) see consistent content automatically.
#
#   .mcp.json (project root) is read directly by all three tools — no link.
#   .claude/settings.json and .codebuddy/settings.json stay as separate copies
#   (kept in sync by this script) — they may diverge in future for hooks.
#   CLAUDE.md / CODEBUDDY.md / AGENTS.md remain hand-maintained.
#
# When to run:
#   - After checking out the repo on a system where SVN did not restore symlinks
#     (e.g. Windows without Developer Mode / core.symlinks=false)
#   - After adding a new file under .codebuddy/{rules,agents,commands}/
#   - After deleting a file under .codebuddy/ (cleans up dangling symlinks)
#
# Idempotent: safe to re-run.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

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

step() { $QUIET || echo -e "${c_cyan}==> $*${c_off}" >&2; }
ok()   { $QUIET || echo -e "  ${c_green}+${c_off} $*" >&2; }
warn() { echo -e "  ${c_yellow}!${c_off} $*" >&2; }
err()  { echo -e "  ${c_red}x${c_off} $*" >&2; }
info() { $QUIET || echo -e "    ${c_gray}$*${c_off}" >&2; }

# Build/rebuild a single set of symlinks.
# All link_dir values are at depth 2 from project root (.cursor/rules,
# .claude/agents etc), so the relative target is always ../../.codebuddy/<sub>/<file>.
# $1=src_subdir (e.g. rules)  $2=link_dir_rel (e.g. .cursor/rules)  $3=glob  $4=label
link_set() {
    local src_subdir="$1" link_dir_rel="$2" glob="$3" label="$4"
    local src="$PROJECT_ROOT/.codebuddy/$src_subdir"
    local link_dir="$PROJECT_ROOT/$link_dir_rel"

    if [[ ! -d "$src" ]]; then
        warn "skip $label: source missing ($src)"
        echo "0"
        return 0
    fi

    if ! $DRY_RUN; then mkdir -p "$link_dir"; fi

    local src_files=()
    while IFS= read -r -d '' f; do
        src_files+=("$f")
    done < <(find "$src" -maxdepth 1 -name "$glob" -type f -print0)

    info "$label: ${#src_files[@]} source file(s)"

    if $DRY_RUN; then
        for f in "${src_files[@]}"; do
            local name=$(basename "$f")
            info "[dry-run] $link_dir_rel/$name -> ../../.codebuddy/$src_subdir/$name"
        done
        echo "${#src_files[@]}"
        return 0
    fi

    # Clean dangling symlinks first
    if [[ -d "$link_dir" ]]; then
        while IFS= read -r -d '' link; do
            if [[ ! -e "$link" ]]; then
                rm "$link"
                info "removed dangling: $(basename "$link")"
            fi
        done < <(find "$link_dir" -maxdepth 1 -type l -print0)
    fi

    # Create / refresh symlinks
    local count=0
    for f in "${src_files[@]}"; do
        local name=$(basename "$f")
        local target_path="$link_dir/$name"
        local link_target="../../.codebuddy/$src_subdir/$name"

        if [[ -L "$target_path" ]]; then
            local current=$(readlink "$target_path")
            if [[ "$current" == "$link_target" ]]; then
                count=$((count+1))
                continue
            fi
            rm "$target_path"
        elif [[ -e "$target_path" ]]; then
            warn "$name is a regular file, replacing with symlink (backup at $name.legacy)"
            mv "$target_path" "$target_path.legacy"
        fi

        ln -s "$link_target" "$target_path"
        info "$name -> $link_target"
        count=$((count+1))
    done

    echo "$count"
}

mirror_file() {
    local src="$1" dst="$2" label="$3"
    if [[ ! -f "$src" ]]; then
        warn "skip $label: source missing ($src)"
        return 1
    fi
    info "$label: $src"
    if $DRY_RUN; then
        info "[dry-run] would copy to $dst"
        return 0
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    return 0
}

step "Maintain three-way symlinks (.codebuddy → .cursor / .claude)"

n_rules=$(link_set "rules"    ".cursor/rules"    "*.mdc" "rules (.cursor/rules)")
n_cur_cmds=$(link_set "commands" ".cursor/commands" "*.md"  "commands (.cursor/commands)")
n_agents=$(link_set "agents"   ".claude/agents"   "*.md"  "agents (.claude/agents)")
n_cl_cmds=$(link_set "commands" ".claude/commands" "*.md"  "commands (.claude/commands)")

mirror_file "$PROJECT_ROOT/.claude/settings.json" "$PROJECT_ROOT/.codebuddy/settings.json" "settings (cp)" || true

ok "Linked: $n_rules rules / $n_cur_cmds cursor-cmds / $n_agents agents / $n_cl_cmds claude-cmds  (+1 settings cp)"

if ! $DRY_RUN; then
    step "Verifying"
    fail=0

    for pair in \
        "rules:.cursor/rules:*.mdc:rules" \
        "commands:.cursor/commands:*.md:cursor-cmds" \
        "agents:.claude/agents:*.md:agents" \
        "commands:.claude/commands:*.md:claude-cmds"
    do
        IFS=':' read -r srcsub dstrel glob label <<< "$pair"
        src="$PROJECT_ROOT/.codebuddy/$srcsub"
        dst="$PROJECT_ROOT/$dstrel"
        if [[ ! -d "$src" ]]; then continue; fi
        src_n=$(find "$src" -maxdepth 1 -name "$glob" -type f | wc -l | tr -d ' ')
        dst_n=$(find "$dst" -maxdepth 1 -name "$glob" -type l | wc -l | tr -d ' ')
        if [[ "$src_n" == "$dst_n" ]]; then
            ok "$label: $src_n source = $dst_n symlinks"
        else
            err "$label count mismatch: $src_n source vs $dst_n symlinks"
            fail=$((fail+1))
        fi
    done

    if [[ -f "$PROJECT_ROOT/.claude/settings.json" ]]; then
        if cmp -s "$PROJECT_ROOT/.claude/settings.json" "$PROJECT_ROOT/.codebuddy/settings.json"; then
            ok "settings: byte-identical"
        else
            err "settings: copy succeeded but contents differ"
            fail=$((fail+1))
        fi
    fi

    [[ $fail -eq 0 ]] || exit 2
fi
