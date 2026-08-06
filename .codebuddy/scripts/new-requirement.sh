#!/usr/bin/env bash
# Create a new requirement skeleton (bash equivalent of new-requirement.ps1)
# Implements the `create` operation of .codebuddy/skills/core/managing-requirement/
#
# Usage:
#   ./.codebuddy/scripts/new-requirement.sh                            # interactive
#   ./.codebuddy/scripts/new-requirement.sh -i user-edit -t "用户编辑" -s agile-vibe
#   ./.codebuddy/scripts/new-requirement.sh --non-interactive -i ci-test -t "CI test"
#   ./.codebuddy/scripts/new-requirement.sh -i foo -t "test" -k trunk

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

REQ_ID=""
TITLE=""
SOP="agile-vibe"
REPO_KEY=""
REPO_PATH=""
VARIANT=""
NON_INTERACTIVE=false

# ---- repo_key → repo_path + variant mapping ----
declare -A REPO_PATH_MAP=(
    ["trunk"]="/data/home/chennychen/trunk/dev/src"
    ["Wepop_release"]="/data/home/chennychen/Wepop_release/dev/src"
    ["Wepop_release_YJ"]="/data/home/chennychen/Wepop_release_YJ/dev/src"
    ["KartRider_Trunk"]="/data/home/chennychen/KartRider_Trunk/dev/src"
    ["KartRider_International_Release"]="/data/home/chennychen/KartRider_International_Release/dev/src"
    ["KartRider_International_Release_YJ"]="/data/home/chennychen/KartRider_International_Release_YJ/dev/src"
)

resolve_variant() {
    local key="$1"
    if [[ "$key" == KartRider* ]]; then
        echo "KartRider"
    else
        echo "Wepop"
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--req-id)        REQ_ID="$2"; shift 2 ;;
        -t|--title)         TITLE="$2"; shift 2 ;;
        -s|--sop)           SOP="$2"; shift 2 ;;
        -k|--repo-key)      REPO_KEY="$2"; shift 2 ;;
        -r|--repo-path)     REPO_PATH="$2"; shift 2 ;;  # deprecated, use -k instead
        --non-interactive)  NON_INTERACTIVE=true; shift ;;
        -h|--help)
            grep '^#' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# ---- helpers ----
c_cyan='\033[36m'; c_green='\033[32m'; c_red='\033[31m'; c_gray='\033[90m'; c_off='\033[0m'
step() { echo -e "${c_cyan}==> $*${c_off}"; }
ok()   { echo -e "  ${c_green}+${c_off} $*"; }
err()  { echo -e "  ${c_red}x${c_off} $*"; }
info() { echo -e "    ${c_gray}$*${c_off}"; }

ask_default() {
    local prompt="$1" default="$2"
    if $NON_INTERACTIVE; then echo "$default"; return; fi
    local val
    read -r -p "$prompt [$default]: " val
    echo "${val:-$default}"
}

is_kebab() { [[ "$1" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]; }

# ---- collect input ----
step "Creating new requirement"

if [[ -z "$REQ_ID" ]]; then
    if $NON_INTERACTIVE; then err "--req-id required in non-interactive mode"; exit 1; fi
    REQ_ID="$(ask_default 'Req ID (kebab-case, no req- prefix)' '')"
fi

REQ_ID="${REQ_ID#req-}"
if ! is_kebab "$REQ_ID"; then err "Req ID must be kebab-case: $REQ_ID"; exit 1; fi

FULL_REQ_ID="req-${REQ_ID}"
REQ_DIR="$PROJECT_ROOT/requirements/$FULL_REQ_ID"

if [[ -d "$REQ_DIR" ]]; then
    err "Requirement already exists: $FULL_REQ_ID"
    info "To continue: /pm-continue $FULL_REQ_ID"
    exit 1
fi

[[ -z "$TITLE" ]] && TITLE="$(ask_default 'Title' "$REQ_ID")"

# Resolve repo_key → repo_path + variant
if [[ -n "$REPO_KEY" ]]; then
    if [[ -z "${REPO_PATH_MAP[$REPO_KEY]+x}" ]]; then
        err "Unknown repo_key: $REPO_KEY (allowed: ${!REPO_PATH_MAP[@]})"
        exit 1
    fi
    REPO_PATH="${REPO_PATH_MAP[$REPO_KEY]}"
    VARIANT="$(resolve_variant "$REPO_KEY")"
elif [[ -n "$REPO_PATH" ]]; then
    # Legacy: try to reverse-lookup repo_key from repo_path
    for key in "${!REPO_PATH_MAP[@]}"; do
        if [[ "${REPO_PATH_MAP[$key]}" == "$REPO_PATH" ]]; then
            REPO_KEY="$key"
            break
        fi
    done
    VARIANT="$(resolve_variant "${REPO_KEY:-unknown}")"
else
    REPO_PATH=""
    REPO_KEY=""
    VARIANT=""
fi

case "$SOP" in
    agile-vibe|deep-vibe|game-design) ;;
    *) err "Unknown SOP: $SOP (allowed: agile-vibe / deep-vibe / game-design)"; exit 1 ;;
esac

TIMESTAMP="$(date '+%Y-%m-%d %H:%M')"

ok "ReqId:    $FULL_REQ_ID"
ok "Title:    $TITLE"
ok "SOP:      $SOP"
ok "Variant:  ${VARIANT:-(empty)}"
ok "RepoKey:  ${REPO_KEY:-(empty)}"
ok "RepoPath: ${REPO_PATH:-(empty)}"
ok "Created:  $TIMESTAMP"

# ---- copy template ----
step "Copying template..."
TEMPLATE_DIR="$PROJECT_ROOT/requirements/_template"
[[ -d "$TEMPLATE_DIR" ]] || { err "Template dir missing: $TEMPLATE_DIR"; exit 1; }

cp -r "$TEMPLATE_DIR" "$REQ_DIR"
rm -f "$REQ_DIR/README.md"
ok "Copied to requirements/$FULL_REQ_ID/"

# ---- SOP-specific cleanup ----
# game-design SOP doesn't use plan.md, design/, or tasks/ (no coding phase)
if [[ "$SOP" == "game-design" ]]; then
    rm -f "$REQ_DIR/plan.md"
    rm -rf "$REQ_DIR/design"
    rm -rf "$REQ_DIR/tasks"
    info "  game-design SOP: removed plan.md, design/, tasks/ (not used)"
fi

# ---- replace placeholders ----
step "Replacing placeholders..."
# Use while+read instead of `mapfile` for bash 3.2 compatibility (macOS default)
files=()
while IFS= read -r -d '' f; do
    files+=("$f")
done < <(find "$REQ_DIR" -type f \( -name '*.md' -o -name '*.yaml' -o -name '*.yml' -o -name '*.txt' -o -name '*.json' \) -print0)

for f in "${files[@]}"; do
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' \
            -e "s|{{REQ_ID}}|${FULL_REQ_ID}|g" \
            -e "s|{{TITLE}}|${TITLE}|g" \
            -e "s|{{SOP}}|${SOP}|g" \
            -e "s|{{CREATED_AT}}|${TIMESTAMP}|g" \
            -e "s|{{VARIANT}}|${VARIANT}|g" \
            -e "s|{{REPO_KEY}}|${REPO_KEY}|g" \
            -e "s|{{REPO_PATH}}|${REPO_PATH}|g" \
            "$f"
    else
        sed -i \
            -e "s|{{REQ_ID}}|${FULL_REQ_ID}|g" \
            -e "s|{{TITLE}}|${TITLE}|g" \
            -e "s|{{SOP}}|${SOP}|g" \
            -e "s|{{CREATED_AT}}|${TIMESTAMP}|g" \
            -e "s|{{VARIANT}}|${VARIANT}|g" \
            -e "s|{{REPO_KEY}}|${REPO_KEY}|g" \
            -e "s|{{REPO_PATH}}|${REPO_PATH}|g" \
            "$f"
    fi
done
ok "Placeholders replaced"

# ---- rebuild INDEX.md (auto-generated from meta.yaml) ----
REBUILD_SCRIPT="$PROJECT_ROOT/.codebuddy/scripts/rebuild-index.sh"
if [[ -x "$REBUILD_SCRIPT" ]]; then
    bash "$REBUILD_SCRIPT" --quiet
    ok "INDEX.md rebuilt"
elif [[ -f "$REBUILD_SCRIPT" ]]; then
    bash "$REBUILD_SCRIPT" --quiet
    ok "INDEX.md rebuilt"
else
    info "rebuild-index.sh not found, INDEX.md not updated"
fi

# ---- done ----
echo
echo -e "${c_green}  ╔══════════════════════════════════════════════════════╗${c_off}"
echo -e "${c_green}  ║              ✓ Requirement skeleton created           ║${c_off}"
echo -e "${c_green}  ╚══════════════════════════════════════════════════════╝${c_off}"
echo
echo -e "  Req ID:  ${c_cyan}$FULL_REQ_ID${c_off}"
echo "  Dir:     requirements/$FULL_REQ_ID/"
echo "  Phase:   1.init (draft)"
echo "  SOP:     $SOP"
echo "  Variant: ${VARIANT:-(empty)}"
echo
echo -e "${c_cyan}  Next:${c_off}"
echo "    In Cursor / Claude Code, run:"
echo -e "      ${c_yellow:-\033[33m}/pm-continue $FULL_REQ_ID${c_off}"
echo
