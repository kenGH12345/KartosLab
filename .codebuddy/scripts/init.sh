#!/usr/bin/env bash
# AIVibeCodingProj — Init Script (bash equivalent of init.ps1)
#
# Usage:
#   ./.codebuddy/scripts/init.sh                          # interactive
#   ./.codebuddy/scripts/init.sh -n my-app -r ../my-app   # one-shot
#   ./.codebuddy/scripts/init.sh --non-interactive -n ci-test -r ""
#
# What it does:
#   1. Check svn is installed
#   2. Collect project name + repo path
#   3. Replace placeholders {{PROJECT_NAME}} / {{REPO_PATH}} across the repo
#   4. Create context/project/<name>/INDEX.md skeleton
#   5. Optionally svn checkout
#   6. Write .vibe/.initialized flag
#
# This script is idempotent. Re-run with --force to redo placeholder replacement.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# ---- args ----
PROJECT_NAME=""
REPO_PATH=""
NON_INTERACTIVE=false
FORCE=false
INIT_SVN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--project-name)   PROJECT_NAME="$2"; shift 2 ;;
        -r|--repo-path)      REPO_PATH="$2"; shift 2 ;;
        --non-interactive)   NON_INTERACTIVE=true; shift ;;
        --force)             FORCE=true; shift ;;
        --init-svn)          INIT_SVN=true; shift ;;
        -h|--help)
            grep '^#' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# ---- helpers ----
c_cyan='\033[36m'; c_green='\033[32m'; c_yellow='\033[33m'; c_red='\033[31m'; c_gray='\033[90m'; c_off='\033[0m'

step() { echo -e "${c_cyan}==> $*${c_off}"; }
ok()   { echo -e "  ${c_green}+${c_off} $*"; }
warn() { echo -e "  ${c_yellow}!${c_off} $*"; }
err()  { echo -e "  ${c_red}x${c_off} $*"; }
info() { echo -e "    ${c_gray}$*${c_off}"; }

ask_default() {
    local prompt="$1" default="$2"
    if $NON_INTERACTIVE; then echo "$default"; return; fi
    local val
    read -r -p "$prompt [$default]: " val
    echo "${val:-$default}"
}

is_valid_name() {
    [[ "$1" =~ ^[a-zA-Z][a-zA-Z0-9]*(-[a-zA-Z0-9]+)*$ ]]
}

# ---- banner ----
echo
echo -e "${c_cyan}  ╔══════════════════════════════════════════════════════╗${c_off}"
echo -e "${c_cyan}  ║       AIVibeCodingProj — Init Script v0.1            ║${c_off}"
echo -e "${c_cyan}  ║   Generic vibecoding harness for Cursor + Claude     ║${c_off}"
echo -e "${c_cyan}  ╚══════════════════════════════════════════════════════╝${c_off}"
echo

step "Project root: $PROJECT_ROOT"

# ---- 1. prerequisites ----
step "Checking prerequisites..."
command -v svn >/dev/null 2>&1 || { err "svn not found"; exit 1; }
ok "svn: $(svn --version --quiet 2>/dev/null || echo 'installed')"
command -v node >/dev/null 2>&1 && ok "node: installed" || warn "node: not installed (frontend projects may need it)"
command -v python3 >/dev/null 2>&1 && ok "python3: installed" || warn "python3: not installed (some hooks/MCP may need it)"

# ---- 2. already initialized? ----
INIT_FLAG="$PROJECT_ROOT/.vibe/.initialized"
if [[ -f "$INIT_FLAG" && "$FORCE" != "true" ]]; then
    warn "This repo appears already initialized (.vibe/.initialized exists)."
    info "Pass --force to redo. Otherwise use .codebuddy/scripts/new-requirement.sh or /pm-new for a new requirement."
    exit 0
fi

# ---- 3. collect metadata ----
step "Collecting project metadata..."

if [[ -z "$PROJECT_NAME" ]]; then
    default_name="$(basename "$PROJECT_ROOT" | sed 's/[^a-zA-Z0-9-]/-/g')"
    is_valid_name "$default_name" || default_name="my-project"
    PROJECT_NAME="$(ask_default "Project name (letters, numbers, hyphens)" "$default_name")"
fi

if ! is_valid_name "$PROJECT_NAME"; then
    err "Project name must start with a letter and contain only letters, numbers, hyphens: $PROJECT_NAME"
    exit 1
fi
ok "Project name: $PROJECT_NAME"

if [[ -z "${REPO_PATH+x}" || -z "$REPO_PATH" ]]; then
    REPO_PATH="$(ask_default "Repo path (absolute or relative; empty = unbound)" "")"
fi
ok "Repo path: ${REPO_PATH:-(unbound)}"

PRIMARY_TOOL="${PRIMARY_TOOL:-codebuddy,claude,cursor}"
CREATED_AT="$(date '+%Y-%m-%d %H:%M')"
PROJECT_DISPLAY_NAME="${PROJECT_DISPLAY_NAME:-$PROJECT_NAME}"
ok "Created at:   $CREATED_AT"
ok "Primary tool: $PRIMARY_TOOL"

# ---- 3.5. clean up template-carried requirements ----
# When cloning from the template repo, requirements/req-* from template history
# come along. A new project should start fresh with only _template/ and INDEX files.
# Also clean: .legacy files, template's own knowledge base, stale cache.
step "Cleaning template artifacts..."
cleaned=0
for d in "$PROJECT_ROOT"/requirements/req-*/; do
    [[ -d "$d" ]] || continue
    rm -rf "$d"
    cleaned=$((cleaned + 1))
done

# Remove template's own project knowledge base (new project gets a fresh one)
if [[ -d "$PROJECT_ROOT/context/project/AIVibeCodingProj" ]]; then
    rm -rf "$PROJECT_ROOT/context/project/AIVibeCodingProj"
    info "  removed context/project/AIVibeCodingProj/"
fi

# Remove template-only files that don't belong in new projects
for tf in "create-vibe-project" "CHANGELOG.md"; do
    if [[ -e "$PROJECT_ROOT/$tf" ]]; then
        rm -rf "$PROJECT_ROOT/$tf"
        info "  removed $tf"
    fi
done

# Remove stale .vibe/cache/ files from template
if [[ -d "$PROJECT_ROOT/.vibe/cache" ]]; then
    rm -rf "$PROJECT_ROOT/.vibe/cache"
    mkdir -p "$PROJECT_ROOT/.vibe/cache"
    info "  cleared .vibe/cache/"
fi

# Remove .legacy backup files left by sync-codebuddy.sh
find "$PROJECT_ROOT/.claude" "$PROJECT_ROOT/.cursor" -name "*.legacy" -type f -delete 2>/dev/null
legacy_count=$(find "$PROJECT_ROOT/.claude" "$PROJECT_ROOT/.cursor" -name "*.legacy" -type f 2>/dev/null | wc -l | tr -d ' ')
[[ "$legacy_count" == "0" ]] && info "  cleared .legacy files"

# Remove stale INDEX.yaml if present
rm -f "$PROJECT_ROOT/requirements/INDEX.yaml"

if [[ $cleaned -gt 0 ]]; then
    # Rebuild INDEX.md from meta.yaml (will be empty since all req-* deleted)
    bash "$PROJECT_ROOT/.codebuddy/scripts/rebuild-index.sh" --quiet
    ok "Removed $cleaned template requirements + cleaned artifacts, INDEX rebuilt"
else
    info "  No template requirements found, skip"
fi

# ---- 4. replace placeholders ----
step "Replacing placeholders..."

# Files to scan; exclude templates/git/general-purpose docs
# Use while+read instead of `mapfile` for bash 3.2 compatibility (macOS default)
#
# Skipped categories:
#   .codebuddy/skills/**           — skills are general-purpose docs; placeholders here are
#                          conceptual (e.g. context/project/{{PROJECT_NAME}}/),
#                          NOT slots for the current project
#   PHASE5-FINDINGS.md  — working notes describing the placeholder system itself
files=()
while IFS= read -r -d '' f; do
    files+=("$f")
done < <(find "$PROJECT_ROOT" \
    \( -name '*.md' -o -name '*.yaml' -o -name '*.yml' -o -name '*.json' -o -name '*.txt' -o -name '*.mdc' \) \
    -not -path '*/.svn/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/.vibe/cache/*' \
    -not -path '*/_template/*' \
    -not -path '*/_template_sop.md' \
    -not -path '*/SKILL_TEMPLATE.md' \
    -not -path '*/_example.yaml' \
    -not -path '*/skills/*' \
    -not -path '*/docs/PHASE5-FINDINGS.md' \
    -print0)

# Use Perl for the replacement. Two strategies:
#   - Top-level files (AGENTS.md, CLAUDE.md, CODEBUDDY.md, README.md): unconditional replace
#     (backtick-wrapped `{{XXX}}` are real slots here, not doc mentions)
#   - Internal files (.codebuddy/ etc.): use lookbehind/lookahead to skip `{{XXX}}` in backticks
#     (those are doc examples showing the placeholder syntax, not slots)
# Per-requirement placeholders ({{REQ_ID}} {{TITLE}} {{SOP}}) are handled by
# .codebuddy/scripts/new-requirement.sh on each `/pm-new`.
modified=0
for f in "${files[@]}"; do
    if grep -q -E '\{\{(PROJECT_NAME|PROJECT_DISPLAY_NAME|REPO_PATH|CREATED_AT|PRIMARY_TOOL)\}\}' "$f" 2>/dev/null; then
        # Determine if this is a top-level file (unconditional replace)
        relpath="${f#$PROJECT_ROOT/}"
        case "$relpath" in
            AGENTS.md|CLAUDE.md|CODEBUDDY.md|README.md)
                PROJECT_DISPLAY_NAME="$PROJECT_DISPLAY_NAME" \
                PROJECT_NAME="$PROJECT_NAME" \
                REPO_PATH="$REPO_PATH" \
                CREATED_AT="$CREATED_AT" \
                PRIMARY_TOOL="$PRIMARY_TOOL" \
                perl -i -pe '
                    s/`?\{\{PROJECT_DISPLAY_NAME\}\}`?/$ENV{PROJECT_DISPLAY_NAME}/g;
                    s/`?\{\{PROJECT_NAME\}\}`?/$ENV{PROJECT_NAME}/g;
                    s/`?\{\{REPO_PATH\}\}`?/$ENV{REPO_PATH}/g;
                    s/`?\{\{CREATED_AT\}\}`?/$ENV{CREATED_AT}/g;
                    s/`?\{\{PRIMARY_TOOL\}\}`?/$ENV{PRIMARY_TOOL}/g;
                ' "$f"
                ;;
            *)
                PROJECT_DISPLAY_NAME="$PROJECT_DISPLAY_NAME" \
                PROJECT_NAME="$PROJECT_NAME" \
                REPO_PATH="$REPO_PATH" \
                CREATED_AT="$CREATED_AT" \
                PRIMARY_TOOL="$PRIMARY_TOOL" \
                perl -i -pe '
                    s/(?<!`)\{\{PROJECT_DISPLAY_NAME\}\}(?!`)/$ENV{PROJECT_DISPLAY_NAME}/g;
                    s/(?<!`)\{\{PROJECT_NAME\}\}(?!`)/$ENV{PROJECT_NAME}/g;
                    s/(?<!`)\{\{REPO_PATH\}\}(?!`)/$ENV{REPO_PATH}/g;
                    s/(?<!`)\{\{CREATED_AT\}\}(?!`)/$ENV{CREATED_AT}/g;
                    s/(?<!`)\{\{PRIMARY_TOOL\}\}(?!`)/$ENV{PRIMARY_TOOL}/g;
                ' "$f"
                ;;
        esac
        modified=$((modified + 1))
        info "  modified: ${f#$PROJECT_ROOT/}"
    fi
done
ok "Modified $modified files"

# ---- 5. context/project/<name>/ ----
step "Setting up context/project/${PROJECT_NAME}/..."
PROJECT_CTX_DIR="$PROJECT_ROOT/context/project/${PROJECT_NAME}"
mkdir -p "$PROJECT_CTX_DIR"

PROJECT_INDEX="$PROJECT_CTX_DIR/INDEX.md"
if [[ ! -f "$PROJECT_INDEX" ]]; then
    cat > "$PROJECT_INDEX" <<EOF
# ${PROJECT_NAME} 项目知识库

> 本目录由 \`knowledge-maintainer\` agent 在需求收尾时自动维护。
> 单一源原则：同一事实只在一处定义，其他位置用引用。

## 目录结构（建议；按需创建）

\`\`\`
context/project/${PROJECT_NAME}/
├── INDEX.md
├── architecture/
├── services/
├── api/
├── data-model/
├── flows/
├── conventions/
├── experience/
├── config.md
├── dependencies.md
└── performance.md
\`\`\`

详细命名约定见 \`.codebuddy/skills/core/managing-knowledge/references/retrieval-pattern.md\`。

## 文档清单

| 文档 | 说明 | 最近更新 |
|---|---|---|
| _（暂无）_ | | |

---
*索引最后更新：项目初始化*
EOF
    ok "Created context/project/${PROJECT_NAME}/INDEX.md"
fi

# ---- 6. sync mirror assets (.cursor/ and .codebuddy/) ----
# .cursor/commands, .cursor/mcp.json, .codebuddy/* are all generated mirrors of
# .claude/* + .cursor/rules/* + .mcp.json. We run the sync scripts here so a
# fresh project has all three tools (Claude Code / Cursor / CodeBuddy) ready
# without an extra manual step.
step "Syncing mirror assets..."
for s in sync-commands.sh sync-mcp.sh sync-codebuddy.sh; do
    sp="$PROJECT_ROOT/.codebuddy/scripts/$s"
    if [[ -x "$sp" ]]; then
        info "  running $s"
        "$sp" --quiet || warn "  $s exited non-zero (continuing)"
    elif [[ -f "$sp" ]]; then
        info "  running $s (via bash)"
        bash "$sp" --quiet || warn "  $s exited non-zero (continuing)"
    else
        warn "  $s not found, skipping"
    fi
done
ok "Mirror assets synced (.cursor/ and .codebuddy/)"

# Clean up .legacy files generated by sync (new projects don't need backups of template files)
find "$PROJECT_ROOT/.claude" "$PROJECT_ROOT/.cursor" -name "*.legacy" -type f -delete 2>/dev/null
info "  cleaned .legacy backups from sync"

# ---- 7. svn checkout ----
if $INIT_SVN && [[ ! -d "$PROJECT_ROOT/.svn" ]]; then
    step "Setting up SVN working copy..."
    SVN_REPO_URL="${SVN_REPO_URL:-}"
    if [[ -z "$SVN_REPO_URL" ]]; then
        warn "No SVN repo URL provided. Skipping svn checkout."
        info "Run 'svn checkout <url> .' manually to set up the working copy."
    else
        svn checkout "$SVN_REPO_URL" "$PROJECT_ROOT"
        ok "SVN working copy checked out from $SVN_REPO_URL"
    fi
elif [[ -d "$PROJECT_ROOT/.svn" ]]; then
    info "Already an SVN working copy, skipping checkout"
fi

# ---- 8. write init flag ----
mkdir -p "$PROJECT_ROOT/.vibe"
cat > "$INIT_FLAG" <<EOF
project_name: ${PROJECT_NAME}
repo_path: ${REPO_PATH}
initialized_at: "$(date '+%Y-%m-%d %H:%M')"
template_version: 0.1.0
EOF

# ---- 9. next steps ----
echo
echo -e "${c_green}  ╔══════════════════════════════════════════════════════╗${c_off}"
echo -e "${c_green}  ║                 ✓ Initialization complete             ║${c_off}"
echo -e "${c_green}  ╚══════════════════════════════════════════════════════╝${c_off}"
echo
echo -e "${c_cyan}  Next steps:${c_off}"
echo
echo "    1. Open this project in Cursor / Claude Code"
echo "    2. Create your first requirement:"
echo -e "         ${c_yellow}/pm-new${c_off}"
echo "       or:"
echo -e "         ${c_yellow}./.codebuddy/scripts/new-requirement.sh${c_off}"
echo
echo "    3. Run a health check:"
echo -e "         ${c_yellow}/doctor${c_off}"
echo "       or:"
echo -e "         ${c_yellow}./.codebuddy/scripts/doctor.sh${c_off}"
echo
echo "    4. Read the quickstart:"
echo -e "         ${c_yellow}.codebuddy/docs/QUICKSTART.md${c_off}"
echo
