#!/usr/bin/env bash
# Health check (bash equivalent of doctor.ps1)
# Implements the four checks from .codebuddy/skills/core/doctor/SKILL.md
#
# Usage:
#   ./.codebuddy/scripts/doctor.sh                    # full check, human-readable
#   ./.codebuddy/scripts/doctor.sh --scope assets     # only check assets
#   ./.codebuddy/scripts/doctor.sh --json             # JSON output (for /doctor or CI)
#   ./.codebuddy/scripts/doctor.sh --quiet            # only print problems
#
# Exit codes: 0 healthy, 1 subhealthy, 2 unhealthy, 3 unknown

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

SCOPE="all"
TARGET_REQ=""
JSON=false
QUIET=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --scope)         SCOPE="$2"; shift 2 ;;
        --req-id)        TARGET_REQ="$2"; shift 2 ;;
        --json)          JSON=true; QUIET=true; shift ;;
        --quiet)         QUIET=true; shift ;;
        -h|--help)
            grep '^#' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# ---- helpers ----
c_cyan='\033[36m'; c_green='\033[32m'; c_yellow='\033[33m'; c_red='\033[31m'; c_gray='\033[90m'; c_off='\033[0m'

section() { $QUIET || { echo; echo -e "${c_cyan}==> $*${c_off}"; }; }
ok()      { $QUIET || echo -e "  ${c_green}+${c_off} $*"; }
warn()    { $QUIET || echo -e "  ${c_yellow}!${c_off} $*"; }
err()     { $QUIET || echo -e "  ${c_red}x${c_off} $*"; }
info()    { $QUIET || echo -e "    ${c_gray}$*${c_off}"; }

# Counters
ASSET_MISSING=0
STATE_INCONSISTENT=0
STATE_WARNINGS=0
LINKS_BROKEN=0
LINKS_CHECKED=0
PLACEHOLDERS=0

# Lists (for JSON)
asset_missing_list=()
state_inconsistencies=()
state_warnings_list=()
broken_links=()
placeholder_list=()

# ---- 1. assets ----
if [[ "$SCOPE" == "all" || "$SCOPE" == "assets" ]]; then
    section "1. Assets"

    check_dir_min() {
        local name="$1" path="$2" pattern="$3" min="$4"
        local count
        count=$(find "$PROJECT_ROOT/$path" -maxdepth 1 -name "$pattern" 2>/dev/null | wc -l | tr -d ' ')
        if [[ $count -ge $min ]]; then
            ok "$name: $count (>= $min)"
        else
            err "INSUFFICIENT: $name: $count (expected >= $min)"
            ASSET_MISSING=$((ASSET_MISSING+1))
            asset_missing_list+=("$name (count $count < $min)")
        fi
    }

    check_file() {
        local path="$1"
        if [[ -f "$PROJECT_ROOT/$path" ]]; then
            ok "$path"
        else
            err "MISSING: $path"
            ASSET_MISSING=$((ASSET_MISSING+1))
            asset_missing_list+=("$path")
        fi
    }

    check_dir_min ".cursor/rules/*.mdc" ".cursor/rules" "*.mdc" 8
    check_dir_min ".claude/agents/*.md" ".claude/agents" "*.md" 14
    check_dir_min ".claude/commands/*.md" ".claude/commands" "*.md" 17
    check_dir_min ".cursor/commands/*.md" ".cursor/commands" "*.md" 17
    check_dir_min ".codebuddy/rules/*.mdc" ".codebuddy/rules" "*.mdc" 8
    check_dir_min ".codebuddy/agents/*.md" ".codebuddy/agents" "*.md" 14
    check_dir_min ".codebuddy/commands/*.md" ".codebuddy/commands" "*.md" 17

    for f in \
        .codebuddy/skills/_meta/SKILL_TEMPLATE.md \
        .codebuddy/skills/_meta/skill-authoring-guide.md \
        .codebuddy/skills/_meta/self-evolution-protocol.md \
        .codebuddy/skills/INDEX.md \
        .codebuddy/sop/INDEX.md \
        .codebuddy/sop/agile-vibe.md \
        .codebuddy/sop/deep-vibe.md \
        .codebuddy/sop/_template_sop.md \
        requirements/INDEX.md \
        requirements/_template/meta.yaml \
        AGENTS.md \
        CLAUDE.md \
        CODEBUDDY.md \
        .mcp.json \
        .cursor/mcp.json \
        .codebuddy/settings.json \
    ; do
        check_file "$f"
    done

    # symmetry: .claude / .cursor / .codebuddy commands counts must match
    cn=$(find "$PROJECT_ROOT/.claude/commands" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    cu=$(find "$PROJECT_ROOT/.cursor/commands" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    cb=$(find "$PROJECT_ROOT/.codebuddy/commands" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [[ $cn -ne $cu || $cn -ne $cb ]]; then
        err "command counts mismatch: .claude=$cn .cursor=$cu .codebuddy=$cb"
        ASSET_MISSING=$((ASSET_MISSING+1))
        asset_missing_list+=("commands_symmetry (.claude=$cn vs .cursor=$cu vs .codebuddy=$cb)")
    else
        ok "commands symmetry: .claude=$cn .cursor=$cu .codebuddy=$cb"
    fi
fi

# ---- 2. state ----
if [[ "$SCOPE" == "all" || "$SCOPE" == "state" ]]; then
    section "2. State consistency (per requirement)"

    if [[ -n "$TARGET_REQ" ]]; then
        req_dirs=("$PROJECT_ROOT/requirements/$TARGET_REQ")
    else
        req_dirs=("$PROJECT_ROOT"/requirements/req-*/)
    fi

    found_any=false
    for d in "${req_dirs[@]}"; do
        [[ -d "$d" ]] || continue
        found_any=true
        rid=$(basename "$d")
        issues=()

        meta_file="$d/meta.yaml"
        process_file="$d/process.txt"
        [[ -f "$meta_file" ]] || issues+=("meta.yaml missing")
        [[ -f "$process_file" ]] || issues+=("process.txt missing")

        if [[ ${#issues[@]} -eq 0 ]]; then
            meta_phase=$(grep -E '^phase:' "$meta_file" | head -1 | awk '{print $2}')
            meta_status=$(grep -E '^status:' "$meta_file" | head -1 | awk '{print $2}')
            meta_sop=$(grep -E '^sop:' "$meta_file" | head -1 | awk '{print $2}')

            # check artifact existence based on sop+phase
            if [[ "$meta_sop" == "deep-vibe" ]]; then
                case "$meta_phase" in
                    2.*|3.*|4.*|5.*) [[ -f "$d/spec/需求文档.md" ]] || issues+=("phase>=2 missing spec/需求文档.md") ;;
                esac
                case "$meta_phase" in
                    3.*|4.*|5.*) [[ -f "$d/design/技术方案.md" ]] || issues+=("phase>=3 missing design/技术方案.md") ;;
                esac
            elif [[ "$meta_sop" == "agile-vibe" ]]; then
                case "$meta_phase" in
                    2.*|3.*|4.*)
                        if [[ ! -f "$d/spec/需求简述.md" && ! -f "$d/spec/需求文档.md" ]]; then
                            issues+=("phase>=2 missing spec/需求简述.md")
                        fi ;;
                esac
            fi

            if [[ "$meta_status" == "done" ]]; then
                [[ -f "$d/spec/最终需求.md" ]] || issues+=("status=done missing spec/最终需求.md")
            fi
        fi

        if [[ ${#issues[@]} -eq 0 ]]; then
            ok "$rid: consistent"
        else
            warn "$rid:"
            for is in "${issues[@]}"; do info "  - $is"; done
            STATE_INCONSISTENT=$((STATE_INCONSISTENT+1))
            state_inconsistencies+=("$rid: ${issues[*]}")
        fi
    done
    $found_any || info "(no requirements yet)"
fi

# ---- 3. links ----
if [[ "$SCOPE" == "all" || "$SCOPE" == "links" ]]; then
    section "3. Link validity"

    while IFS= read -r -d '' file; do
        relsource="${file#$PROJECT_ROOT/}"
        in_fence=false
        lineno=0
        while IFS= read -r line; do
            lineno=$((lineno+1))
            # toggle fence state
            if [[ "$line" =~ ^[[:space:]]*'```' ]]; then
                if $in_fence; then in_fence=false; else in_fence=true; fi
                continue
            fi
            $in_fence && continue

            # Strip inline code spans (`...`) — links inside are examples
            stripped=$(echo "$line" | sed -E 's/`[^`]*`//g')
            # Extract markdown links: [text](target)
            while read -r match; do
                [[ -z "$match" ]] && continue
                # match looks like "text|target" via our awk-based extraction below
                target="${match#*|}"
                # Skip remote/anchor/empty
                [[ "$target" =~ ^(https?:|mailto:|#|tel:|ftp:) ]] && continue
                # Strip anchor
                clean="${target%%#*}"
                [[ -z "$clean" ]] && continue
                # Skip placeholder-style targets containing < > * ? " |
                [[ "$clean" =~ [\<\>\*\?\"\|] ]] && continue
                # Skip pure-Chinese targets (likely placeholder text)
                if ! [[ "$clean" =~ [a-zA-Z0-9./_-] ]]; then continue; fi

                LINKS_CHECKED=$((LINKS_CHECKED+1))
                src_dir="$(dirname "$file")"
                if [[ "$clean" = /* ]]; then
                    abs_target="$clean"
                else
                    abs_target="$src_dir/$clean"
                fi
                if [[ ! -e "$abs_target" ]]; then
                    warn "$relsource:$lineno -> $target"
                    LINKS_BROKEN=$((LINKS_BROKEN+1))
                    broken_links+=("$relsource:$lineno -> $target")
                fi
            done < <(echo "$stripped" | grep -oE '\[[^]]+\]\([^)]+\)' | sed -E 's/\[([^]]+)\]\(([^)]+)\)/\1|\2/')
        done < "$file"
    done < <(find "$PROJECT_ROOT" -name '*.md' -type f \
        -not -path '*/.svn/*' \
        -not -path '*/node_modules/*' \
        -not -path '*/.vibe/cache/*' \
        -not -path '*/_archived/*' \
        -print0)

    if [[ $LINKS_BROKEN -eq 0 ]]; then
        ok "$LINKS_CHECKED local links all valid"
    else
        err "$LINKS_BROKEN broken / $LINKS_CHECKED local links"
    fi
fi

# ---- 4. placeholders ----
if [[ "$SCOPE" == "all" || "$SCOPE" == "placeholders" ]]; then
    section "4. Placeholder remnants"

    while IFS= read -r -d '' file; do
        relsource="${file#$PROJECT_ROOT/}"
        # Skip template files & sync-target mirrors (placeholder source is in
        # .claude/ or .mcp.json; checking sync products would double-count).
        # Also skip .codebuddy/skills/** and PHASE5-FINDINGS.md — they document the
        # placeholder system as content, not as slots awaiting fill.
        case "$relsource" in
            */_template/*) continue ;;
            *_template_sop.md) continue ;;
            */SKILL_TEMPLATE.md) continue ;;
            *_example.yaml) continue ;;
            .codebuddy/scripts/init.*) continue ;;
            .codebuddy/scripts/new-requirement.*) continue ;;
            .codebuddy/scripts/doctor.*) continue ;;
            .codebuddy/scripts/sync-*) continue ;;
            .cursor/*) continue ;;
            .codebuddy/*) continue ;;
            .codebuddy/skills/*) continue ;;
            .codebuddy/docs/PHASE5-FINDINGS.md) continue ;;
        esac
        # Use Perl to detect placeholders not adjacent to a backtick on either
        # side (consistent with .codebuddy/scripts/init.sh's replacement logic). Returns
        # one match line per (lineno, placeholder) pair.
        while IFS=$'\t' read -r lineno ph; do
            warn "$relsource:$lineno - $ph"
            PLACEHOLDERS=$((PLACEHOLDERS+1))
            placeholder_list+=("$relsource:$lineno $ph")
        done < <(perl -ne '
            my @phs = ("{{PROJECT_NAME}}", "{{REPO_PATH}}", "{{REQ_ID}}",
                       "{{TITLE}}", "{{CREATED_AT}}", "{{SOP}}");
            for my $ph (@phs) {
                my $q = quotemeta $ph;
                if ($_ =~ /(?<!`)$q(?!`)/) {
                    print "$.\t$ph\n";
                }
            }
        ' "$file")
    done < <(find "$PROJECT_ROOT" -type f \( -name '*.md' -o -name '*.yaml' -o -name '*.yml' -o -name '*.json' -o -name '*.txt' -o -name '*.mdc' \) \
        -not -path '*/.svn/*' \
        -not -path '*/node_modules/*' \
        -not -path '*/.vibe/cache/*' \
        -print0)

    if [[ $PLACEHOLDERS -eq 0 ]]; then
        ok "no placeholders remaining"
    else
        warn "$PLACEHOLDERS placeholder remnants"
    fi
fi

# ---- 5. state product integrity ----
if [[ "$SCOPE" == "all" || "$SCOPE" == "integrity" ]]; then
    section "5. State product integrity"

    # 5.1 INDEX duplicate req-id detection
    # Scans requirements/INDEX.md table rows;
    # any req-id appearing >1 time is treated as inconsistency.
    index_md="$PROJECT_ROOT/requirements/INDEX.md"
    dup_found=0

    if [[ -f "$index_md" ]]; then
        # Extract req-ids from table rows: "| req-xxx | ..." (first column)
        md_ids=$(grep -E '^\|[[:space:]]*`?req-' "$index_md" \
                 | awk -F'|' '{print $2}' \
                 | sed -E 's/^[[:space:]]*`?//; s/`?[[:space:]]*$//')
        dup_md=$(echo "$md_ids" | sort | uniq -d)
        if [[ -n "$dup_md" ]]; then
            while IFS= read -r dup; do
                err "INDEX.md duplicate req-id: $dup"
                STATE_INCONSISTENT=$((STATE_INCONSISTENT+1))
                state_inconsistencies+=("INDEX.md duplicate req-id: $dup")
                dup_found=$((dup_found+1))
            done <<< "$dup_md"
        fi
    fi

    [[ $dup_found -eq 0 ]] && ok "5.1 INDEX no duplicate req-ids"

    # 5.2 process.txt timestamp monotonic check
    # Each non-empty line should start with [YYYY-MM-DD HH:MM]; later lines
    # must have ts >= previous line's ts. Out-of-order is warn (not inconsistent),
    # because process.txt is append-only history—old typos can't be rewritten.
    ts_warns=0
    for d in "$PROJECT_ROOT"/requirements/req-*/; do
        [[ -d "$d" ]] || continue
        pf="$d/process.txt"
        [[ -f "$pf" ]] || continue
        rid=$(basename "$d")
        prev_ts=""
        prev_lineno=0
        lineno=0
        while IFS= read -r line; do
            lineno=$((lineno+1))
            # Match leading [YYYY-MM-DD HH:MM]
            if [[ "$line" =~ ^\[([0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]][0-9]{2}:[0-9]{2})\] ]]; then
                cur_ts="${BASH_REMATCH[1]}"
                if [[ -n "$prev_ts" ]]; then
                    # Lexicographic compare works for ISO-like timestamps
                    if [[ "$cur_ts" < "$prev_ts" ]]; then
                        warn "$rid/process.txt:$lineno timestamp $cur_ts < prev (line $prev_lineno: $prev_ts)"
                        STATE_WARNINGS=$((STATE_WARNINGS+1))
                        state_warnings_list+=("$rid/process.txt:$lineno timestamp $cur_ts < line $prev_lineno: $prev_ts")
                        ts_warns=$((ts_warns+1))
                    fi
                fi
                prev_ts="$cur_ts"
                prev_lineno=$lineno
            fi
        done < "$pf"
    done
    [[ $ts_warns -eq 0 ]] && ok "5.2 process.txt timestamps monotonic"

    # 5.3 verdict enum whitelist (per 45-state-sync-protocol.mdc)
    # Allowed: approve_go / tweak / redo / back_to_phase_<N> / delegate_<agent-name> / abort
    # Format: lines containing "verdict=<enum>" anywhere; suffix " / 备注: ..." allowed.
    verdict_warns=0
    for d in "$PROJECT_ROOT"/requirements/req-*/; do
        [[ -d "$d" ]] || continue
        pf="$d/process.txt"
        [[ -f "$pf" ]] || continue
        rid=$(basename "$d")
        lineno=0
        while IFS= read -r line; do
            lineno=$((lineno+1))
            # Find "verdict=<token>" — token is non-space until end-of-token char
            if [[ "$line" =~ verdict=([A-Za-z0-9_-]+) ]]; then
                v="${BASH_REMATCH[1]}"
                case "$v" in
                    approve_go|tweak|redo|abort) ;;
                    back_to_phase_*) ;;
                    delegate_*) ;;
                    *)
                        warn "$rid/process.txt:$lineno invalid verdict: $v (allowed: approve_go|tweak|redo|back_to_phase_<N>|delegate_<agent>|abort)"
                        STATE_WARNINGS=$((STATE_WARNINGS+1))
                        state_warnings_list+=("$rid/process.txt:$lineno invalid verdict: $v")
                        verdict_warns=$((verdict_warns+1))
                        ;;
                esac
            fi
        done < "$pf"
    done
    [[ $verdict_warns -eq 0 ]] && ok "5.3 verdict enums all valid"
fi

# ---- health ----
if [[ $ASSET_MISSING -eq 0 && $STATE_INCONSISTENT -eq 0 && $LINKS_BROKEN -eq 0 && $PLACEHOLDERS -eq 0 && $STATE_WARNINGS -eq 0 ]]; then
    HEALTH="healthy"; CODE=0
elif [[ $LINKS_BROKEN -gt 0 || $STATE_INCONSISTENT -gt 0 || $ASSET_MISSING -gt 0 ]]; then
    HEALTH="unhealthy"; CODE=2
else
    HEALTH="subhealthy"; CODE=1
fi

# ---- output ----
if $JSON; then
    # crude JSON; for full schema use the .ps1 version
    printf '{\n'
    printf '  "timestamp": "%s",\n' "$(date '+%Y-%m-%d %H:%M')"
    printf '  "scope": "%s",\n' "$SCOPE"
    printf '  "assets_missing": %d,\n' "$ASSET_MISSING"
    printf '  "state_inconsistent": %d,\n' "$STATE_INCONSISTENT"
    printf '  "state_warnings": %d,\n' "$STATE_WARNINGS"
    printf '  "links_checked": %d,\n' "$LINKS_CHECKED"
    printf '  "links_broken": %d,\n' "$LINKS_BROKEN"
    printf '  "placeholders": %d,\n' "$PLACEHOLDERS"
    printf '  "health": "%s"\n' "$HEALTH"
    printf '}\n'
    exit "$CODE"
fi

echo
echo -e "${c_cyan}  ╔══════════════════════════════════════════════════════╗${c_off}"
echo -e "${c_cyan}  ║                  Health Report                         ║${c_off}"
echo -e "${c_cyan}  ╚══════════════════════════════════════════════════════╝${c_off}"
echo
printf "  Time:        %s\n" "$(date '+%Y-%m-%d %H:%M')"
printf "  Root:        %s\n" "$PROJECT_ROOT"
printf "  Scope:       %s\n\n" "$SCOPE"
printf "  Stats:\n"
printf "    Assets missing:      %d\n" "$ASSET_MISSING"
printf "    State inconsistent:  %d\n" "$STATE_INCONSISTENT"
printf "    State warnings:      %d\n" "$STATE_WARNINGS"
printf "    Broken links:        %d / %d\n" "$LINKS_BROKEN" "$LINKS_CHECKED"
printf "    Placeholders:        %d\n\n" "$PLACEHOLDERS"

case "$HEALTH" in
    healthy)    echo -e "  Health: ${c_green}$HEALTH${c_off}" ;;
    subhealthy) echo -e "  Health: ${c_yellow}$HEALTH${c_off}" ;;
    unhealthy)  echo -e "  Health: ${c_red}$HEALTH${c_off}" ;;
esac
echo

exit "$CODE"
