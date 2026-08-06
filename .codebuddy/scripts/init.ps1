<#
.SYNOPSIS
    AIVibeCodingProj 模板初始化脚本。

.DESCRIPTION
    在用户首次 clone 模板后运行。完成：
      1. 检查前置依赖（svn；可选 node/python）
      2. 收集项目元数据（name / repo path / 偏好）
      3. 替换全仓占位符 {{PROJECT_NAME}} / {{REPO_PATH}} 等
      4. 重命名 context/project/{{PROJECT_NAME}}/ 为真实项目名
      5. 生成 context/project/<name>/INDEX.md 骨架
      6. 可选：建 skills junction（让多项目共享 skills）
      7. 可选：初始化 SVN 工作副本
      8. 打印下一步建议

    本脚本可重复运行（幂等）：第二次运行时检测到已初始化会询问是否重做。

.PARAMETER ProjectName
    项目名（用作 context/project/<name>/ 的目录名与各处替换值）。
    如未提供，会交互式询问。

.PARAMETER RepoPath
    主代码仓库的路径（可绝对，可相对于本仓库根的相对路径）。
    如未提供，会交互式询问；空字符串表示"暂不绑定代码仓"。

.PARAMETER NonInteractive
    非交互模式（CI 用）。所有未提供的参数会用默认值或失败。

.PARAMETER Force
    跳过"已初始化"检查，强制重新替换占位符。

.PARAMETER InitSvn
    初始化 SVN 工作副本（如尚未 svn checkout）。

.PARAMETER SkillsJunction
    建立 .codebuddy/skills/ junction：让本项目复用共享的 skills 仓库。
    需要额外提供 -SkillsSource 指向源仓库的 .codebuddy/skills/ 目录。

.PARAMETER SkillsSource
    与 -SkillsJunction 配合：共享的 .codebuddy/skills/ 源目录绝对路径。

.EXAMPLE
    .\scripts\init.ps1
    交互式初始化。

.EXAMPLE
    .\scripts\init.ps1 -ProjectName "my-app" -RepoPath "../my-app-code" -InitSvn
    一次性给出所有参数。

.EXAMPLE
    .\scripts\init.ps1 -NonInteractive -ProjectName "ci-test" -RepoPath ""
    CI 自动化场景。
#>

[CmdletBinding()]
param(
    [string]$ProjectName,
    [string]$RepoPath,
    [switch]$NonInteractive,
    [switch]$Force,
    [switch]$InitSvn,
    [switch]$SkillsJunction,
    [string]$SkillsSource
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# ============ 工具函数 ============

function Write-Step($msg)    { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-OK($msg)      { Write-Host "  + $msg" -ForegroundColor Green }
function Write-Warn2($msg)   { Write-Host "  ! $msg" -ForegroundColor Yellow }
function Write-Err($msg)     { Write-Host "  x $msg" -ForegroundColor Red }
function Write-Info($msg)    { Write-Host "    $msg" -ForegroundColor Gray }

function Read-WithDefault {
    param([string]$Prompt, [string]$Default)
    if ($NonInteractive) { return $Default }
    $val = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($val)) { return $Default }
    return $val
}

function Confirm-YesNo {
    param([string]$Prompt, [bool]$DefaultYes = $true)
    if ($NonInteractive) { return $DefaultYes }
    $hint = if ($DefaultYes) { "(Y/n)" } else { "(y/N)" }
    $val = Read-Host "$Prompt $hint"
    if ([string]::IsNullOrWhiteSpace($val)) { return $DefaultYes }
    return ($val.Trim().ToLower() -in @("y", "yes"))
}

function Test-KebabCase {
    param([string]$Name)
    return $Name -match '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'
}

function Replace-InFiles {
    param(
        [string[]]$Patterns,
        [hashtable]$Replacements,
        [string[]]$ExcludeDirs = @('.svn', 'node_modules', '.vibe\cache')
    )
    $count = 0
    foreach ($pattern in $Patterns) {
        Get-ChildItem -Path $ProjectRoot -Filter $pattern -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            $relPath = $_.FullName.Substring($ProjectRoot.Length + 1)
            # 排除目录
            $skip = $false
            foreach ($ex in $ExcludeDirs) {
                if ($relPath -like "$ex*") { $skip = $true; break }
            }
            # 排除模板文件（这些保留占位符）
            if ($relPath -match '(^|\\)_template(\\|$)' -or
                $relPath -like 'skills\_meta\SKILL_TEMPLATE.md' -or
                $relPath -like 'sop\_template_sop.md') {
                $skip = $true
            }
            if ($skip) { return }

            $content = Get-Content $_.FullName -Raw -Encoding UTF8
            $original = $content
            foreach ($key in $Replacements.Keys) {
                $content = $content.Replace($key, $Replacements[$key])
            }
            if ($content -ne $original) {
                Set-Content -Path $_.FullName -Value $content -Encoding UTF8 -NoNewline
                $count++
                Write-Info "  modified: $relPath"
            }
        }
    }
    return $count
}

# ============ 主流程 ============

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║       AIVibeCodingProj — Init Script v0.1            ║" -ForegroundColor Cyan
Write-Host "  ║   Generic vibecoding harness for Cursor + Claude     ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Step "项目根目录: $ProjectRoot"

# ---- 1. 前置检查 ----

Write-Step "检查前置依赖..."

if (-not (Get-Command svn -ErrorAction SilentlyContinue)) {
    Write-Err "未找到 svn。请先安装 svn 后再运行。"
    exit 1
}
$svnVer = (svn --version --quiet) 2>$null
Write-OK "svn: $svnVer"

# 可选依赖检测（不阻塞）
$optional = @{
    'node' = '前端项目可能需要'
    'python' = '部分 hooks/MCP 服务器可能需要'
}
foreach ($cmd in $optional.Keys) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        Write-OK "${cmd}: 已安装"
    } else {
        Write-Warn2 ("{0}: 未安装（{1}）" -f $cmd, $optional[$cmd])
    }
}

# ---- 2. 已初始化检测 ----

$initFlagFile = Join-Path $ProjectRoot ".vibe\.initialized"
if ((Test-Path $initFlagFile) -and (-not $Force)) {
    Write-Warn2 "检测到本仓库已经初始化过（.vibe/.initialized 存在）。"
    Write-Info "如要重新初始化，请加 -Force 参数。"
    Write-Info "如只是想新建一个需求，请用 .codebuddy/scripts/new-requirement.ps1 或 /pm-new 命令。"
    exit 0
}

# ---- 3. 收集元数据 ----

Write-Step "收集项目元数据..."

if (-not $ProjectName) {
    $defaultName = (Split-Path -Leaf $ProjectRoot).ToLower() -replace '[^a-z0-9-]', '-'
    if (-not (Test-KebabCase $defaultName)) { $defaultName = "my-project" }
    $ProjectName = Read-WithDefault "项目名（kebab-case，会用作目录名）" $defaultName
}

if (-not (Test-KebabCase $ProjectName)) {
    Write-Err "项目名必须是 kebab-case：小写字母 + 数字 + 短横线，必须以字母开头。"
    Write-Info "你输入的是：$ProjectName"
    exit 1
}
Write-OK "项目名: $ProjectName"

if ($null -eq $RepoPath) {
    $RepoPath = Read-WithDefault "代码仓库路径（绝对或相对，可空表示暂不绑定）" ""
}
$repoPathDisplay = if ([string]::IsNullOrWhiteSpace($RepoPath)) { "(未绑定)" } else { $RepoPath }
Write-OK "代码仓库: $repoPathDisplay"

# ---- 4. 替换占位符 ----

Write-Step "替换占位符..."

$createdAt = Get-Date -Format 'yyyy-MM-dd HH:mm'
$primaryTool = if ($env:PRIMARY_TOOL) { $env:PRIMARY_TOOL } else { 'cursor,claude' }
$projectDisplayName = if ($env:PROJECT_DISPLAY_NAME) { $env:PROJECT_DISPLAY_NAME } else { $ProjectName }
Write-OK "Created at:   $createdAt"
Write-OK "Primary tool: $primaryTool"

# 项目级占位符。Per-requirement 占位符（{{REQ_ID}} {{TITLE}} {{SOP}}）由
# .codebuddy/scripts/new-requirement.ps1 在每次 /pm-new 时替换。
$replacements = @{
    '{{PROJECT_DISPLAY_NAME}}' = $projectDisplayName
    '{{PROJECT_NAME}}' = $ProjectName
    '{{REPO_PATH}}' = $RepoPath
    '{{CREATED_AT}}' = $createdAt
    '{{PRIMARY_TOOL}}' = $primaryTool
}

$modified = Replace-InFiles `
    -Patterns @('*.md', '*.mdc', '*.yaml', '*.yml', '*.json', '*.txt') `
    -Replacements $replacements

Write-OK "已修改 $modified 个文件"

# ---- 5. 重命名 / 创建 context/project/<name>/ ----

Write-Step "处理 context/project/<name>/..."

$projectContextDir = Join-Path $ProjectRoot "context\project\$ProjectName"
$placeholderDir = Join-Path $ProjectRoot "context\project\{{PROJECT_NAME}}"

if (Test-Path $placeholderDir) {
    # 模板里没有这个占位目录（当前是 .gitkeep），但保留逻辑以备将来
    Move-Item -Path $placeholderDir -Destination $projectContextDir -Force
    Write-OK "已重命名 context/project/{{PROJECT_NAME}}/ → context/project/$ProjectName/"
} elseif (-not (Test-Path $projectContextDir)) {
    New-Item -ItemType Directory -Path $projectContextDir -Force | Out-Null
    Write-OK "已创建 context/project/$ProjectName/"
} else {
    Write-Info "context/project/$ProjectName/ 已存在，跳过"
}

# 创建 INDEX.md 骨架
$projectIndexPath = Join-Path $projectContextDir "INDEX.md"
if (-not (Test-Path $projectIndexPath)) {
    $indexContent = @"
# $ProjectName 项目知识库

> 本目录由 ``knowledge-maintainer`` agent 在需求收尾时自动维护。
> 单一源原则：同一事实只在一处定义，其他位置用引用。

## 目录结构（建议；按需创建）

``````
context/project/$ProjectName/
├── INDEX.md                  # 本文件
├── README.md                 # 项目介绍（可选）
├── architecture/             # 架构层
├── services/                 # 各服务/子系统
├── api/                      # 接口契约
├── data-model/               # 数据模型
├── flows/                    # 端到端流程
├── conventions/              # 通用约定
├── experience/               # 已验证的踩坑
├── config.md                 # 配置项
├── dependencies.md           # 依赖
└── performance.md            # 性能基线
``````

详细命名约定见 ``.codebuddy/skills/core/managing-knowledge/references/retrieval-pattern.md``。

## 文档清单

> 当前为空。每完成一个需求，``knowledge-maintainer`` 会把项目级发现回写到此处并更新本表。

| 文档 | 说明 | 最近更新 |
|---|---|---|
| _（暂无）_ | | |

## 跨引用

- 需求知识库: ``../../../requirements/INDEX.md``
- 团队约定: ``../../team/INDEX.md``
- 通用知识: ``../../shared/INDEX.md``

---
*索引最后更新：项目初始化*
"@
    Set-Content -Path $projectIndexPath -Value $indexContent -Encoding UTF8
    Write-OK "已创建 context/project/$ProjectName/INDEX.md"
}

# ---- 6. 可选：skills junction ----

if ($SkillsJunction) {
    Write-Step "建立 .codebuddy/skills/ junction..."
    if (-not $SkillsSource) {
        Write-Err "-SkillsJunction 需要配合 -SkillsSource <path> 使用"
        exit 1
    }
    if (-not (Test-Path $SkillsSource)) {
        Write-Err "SkillsSource 不存在: $SkillsSource"
        exit 1
    }

    $skillsDir = Join-Path $ProjectRoot "skills"
    $backup = "$skillsDir.local-backup"

    if (Test-Path $skillsDir) {
        if (Confirm-YesNo ".codebuddy/skills/ 已存在，移到 skills.local-backup/ 后建 junction？" $false) {
            Move-Item -Path $skillsDir -Destination $backup -Force
            Write-Warn2 "已备份原 .codebuddy/skills/ → skills.local-backup/"
        } else {
            Write-Warn2 "跳过 junction（保留本地 .codebuddy/skills/）"
            $SkillsJunction = $false
        }
    }
    if ($SkillsJunction) {
        cmd /c "mklink /J `"$skillsDir`" `"$SkillsSource`"" | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-OK "junction 建立: $skillsDir → $SkillsSource"
        } else {
            Write-Err "junction 创建失败"
            exit 1
        }
    }
}

# ---- 7. 同步镜像资产（.cursor/ 与 .codebuddy/） ----
# .cursor/commands、.cursor/mcp.json、.codebuddy/* 都是从 .claude/* + .cursor/rules/*
# + .mcp.json 镜像而来。在这里跑 sync 让新项目开箱即拥有 Claude Code / Cursor /
# CodeBuddy 三端可用，不再要求用户多走一步手动同步。

Write-Step "同步镜像资产..."
foreach ($s in @('sync-commands.ps1','sync-mcp.ps1','sync-codebuddy.ps1')) {
    $sp = Join-Path $ProjectRoot "scripts\$s"
    if (Test-Path $sp) {
        Write-Info "  running $s"
        try {
            & powershell -NoProfile -ExecutionPolicy Bypass -File $sp -Quiet
        } catch {
            Write-Warn2 "  $s failed: $_ (continuing)"
        }
    } else {
        Write-Warn2 "  $s not found, skipping"
    }
}
Write-OK "镜像资产已同步（.cursor/ 与 .codebuddy/）"

# ---- 8. 可选：svn checkout ----

$svnDir = Join-Path $ProjectRoot ".svn"
if ($InitSvn -and -not (Test-Path $svnDir)) {
    Write-Step "设置 SVN 工作副本..."
    $svnRepoUrl = if ($env:SVN_REPO_URL) { $env:SVN_REPO_URL } else { "" }
    if ([string]::IsNullOrWhiteSpace($svnRepoUrl)) {
        Write-Warn2 "未提供 SVN 仓库 URL。跳过 svn checkout。"
        Write-Info "请手动运行 'svn checkout <url> .' 来设置工作副本。"
    } else {
        svn checkout $svnRepoUrl $ProjectRoot
        Write-OK "SVN 工作副本已从 $svnRepoUrl 检出"
    }
} elseif (Test-Path $svnDir) {
    Write-Info "已是 SVN 工作副本，跳过 checkout"
}

# ---- 9. 写入初始化标记 ----

$vibeDir = Join-Path $ProjectRoot ".vibe"
if (-not (Test-Path $vibeDir)) {
    New-Item -ItemType Directory -Path $vibeDir -Force | Out-Null
}
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$flagContent = @"
project_name: $ProjectName
repo_path: $RepoPath
initialized_at: "$timestamp"
template_version: 0.1.0
"@
Set-Content -Path $initFlagFile -Value $flagContent -Encoding UTF8

# ---- 10. 打印下一步 ----

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                 ✓ 初始化完成                          ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  下一步建议：" -ForegroundColor Cyan
Write-Host ""
Write-Host "    1. 在 Cursor / Claude Code 中打开本项目" -ForegroundColor White
Write-Host "    2. 创建第一个需求："
Write-Host "         /pm-new" -ForegroundColor Yellow
Write-Host "       或："
Write-Host "         .\scripts\new-requirement.ps1 -ReqId my-first-feature" -ForegroundColor Yellow
Write-Host ""
Write-Host "    3. 检查体系健康："
Write-Host "         /doctor" -ForegroundColor Yellow
Write-Host "       或："
Write-Host "         .\scripts\doctor.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "    4. 阅读快速上手："
Write-Host "         docs\QUICKSTART.md" -ForegroundColor Yellow
Write-Host ""
Write-Host "  关键文件：" -ForegroundColor Cyan
Write-Host "    AGENTS.md / CLAUDE.md         — Agent 主入口（已替换占位符）"
Write-Host "    .cursor/rules/ + .claude/agents/  — 规则与 agent 定义"
Write-Host "    .codebuddy/skills/                       — 11 个 core skills"
Write-Host "    .codebuddy/sop/                          — agile-vibe + deep-vibe"
Write-Host ""
