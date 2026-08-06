<#
.SYNOPSIS
    创建一个新需求骨架（被 /pm-new 命令调用，也可手工运行）。

.DESCRIPTION
    实现 .codebuddy/skills/core/managing-requirement/SKILL.md 的 `create` operation：
      1. 校验 req-id 不重复
      2. 复制 requirements/_template/ 到 requirements/req-<id>/
      3. 替换占位符 ({{REQ_ID}} / {{TITLE}} / {{SOP}} / {{CREATED_AT}} / {{VARIANT}} / {{REPO_KEY}} / {{REPO_PATH}})
      4. 重建 requirements/INDEX.md（调用 rebuild-index.sh）
      5. 不自动委派下游 agent（这是 /pm-new 命令的责任）

    本脚本严格遵守"先写状态后做事"——所有写操作完成后才打印"成功"。

.PARAMETER ReqId
    需求短标识，kebab-case，如 user-profile-edit。
    脚本会自动加 req- 前缀。

.PARAMETER Title
    需求标题（中英文均可），可空。

.PARAMETER Sop
    使用的 SOP，默认 agile-vibe。

.PARAMETER RepoKey
    代码目录选项标识，如 trunk / Wepop_release / KartRider_Trunk 等。
    优先于 RepoPath 使用。脚本自动解析为 RepoPath + Variant。

.PARAMETER RepoPath
    本需求关联的代码仓库路径，可空。
    已废弃，建议使用 -RepoKey 代替。

.PARAMETER NonInteractive
    非交互模式。所有未提供的必需参数会失败。

.EXAMPLE
    .\scripts\new-requirement.ps1
    交互式创建。

.EXAMPLE
    .\scripts\new-requirement.ps1 -ReqId user-edit -Title "用户资料编辑" -Sop agile-vibe -RepoKey trunk
#>

[CmdletBinding()]
param(
    [string]$ReqId,
    [string]$Title,
    [ValidateSet("agile-vibe", "deep-vibe", "game-design")]
    [string]$Sop = "agile-vibe",
    [string]$RepoKey,
    [string]$RepoPath,
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# ============ repo_key → repo_path + variant mapping ============

$RepoPathMap = @{
    "trunk"                            = "/data/home/chennychen/trunk/dev/src"
    "Wepop_release"                    = "/data/home/chennychen/Wepop_release/dev/src"
    "Wepop_release_YJ"                = "/data/home/chennychen/Wepop_release_YJ/dev/src"
    "KartRider_Trunk"                  = "/data/home/chennychen/KartRider_Trunk/dev/src"
    "KartRider_International_Release"  = "/data/home/chennychen/KartRider_International_Release/dev/src"
    "KartRider_International_Release_YJ" = "/data/home/chennychen/KartRider_International_Release_YJ/dev/src"
}

function Resolve-Variant {
    param([string]$Key)
    if ($Key -like "KartRider*") {
        return "KartRider"
    } else {
        return "Wepop"
    }
}

# ============ 工具函数 ============

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "  + $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host "  x $msg" -ForegroundColor Red }
function Write-Info($msg) { Write-Host "    $msg" -ForegroundColor Gray }

function Read-WithDefault {
    param([string]$Prompt, [string]$Default)
    if ($NonInteractive) { return $Default }
    $val = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($val)) { return $Default }
    return $val
}

function Test-KebabCase {
    param([string]$Name)
    return $Name -match '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'
}

function Get-RealTimestamp {
    return (Get-Date -Format "yyyy-MM-dd HH:mm")
}

function Replace-Placeholders {
    param(
        [string]$DirPath,
        [hashtable]$Replacements
    )
    Get-ChildItem -Path $DirPath -Recurse -File -Include "*.md","*.yaml","*.yml","*.txt","*.json" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw -Encoding UTF8
        $changed = $false
        foreach ($key in $Replacements.Keys) {
            if ($content.Contains($key)) {
                $content = $content.Replace($key, $Replacements[$key])
                $changed = $true
            }
        }
        if ($changed) {
            Set-Content -Path $_.FullName -Value $content -Encoding UTF8 -NoNewline
        }
    }
}

# ============ 主流程 ============

Write-Step "新建需求"

# ---- 1. 收集与校验输入 ----

if (-not $ReqId) {
    if ($NonInteractive) {
        Write-Err "缺少 -ReqId 参数（NonInteractive 模式下必填）"
        exit 1
    }
    $ReqId = Read-Host "需求 ID（kebab-case，无需 req- 前缀）"
}

# 自动剥离 req- 前缀（如有），后面再统一加
$ReqId = $ReqId -replace '^req-', ''

if (-not (Test-KebabCase $ReqId)) {
    Write-Err "需求 ID 必须是 kebab-case：$ReqId"
    exit 1
}

$fullReqId = "req-$ReqId"
$reqDir = Join-Path $ProjectRoot "requirements\$fullReqId"

if (Test-Path $reqDir) {
    Write-Err "需求已存在: $fullReqId"
    Write-Info "如要续接，请用 /pm-continue $fullReqId"
    Write-Info "如要重命名旧需求，请手工 mv 后再创建"
    exit 1
}

if (-not $Title) {
    $Title = Read-WithDefault "需求标题" $ReqId
}

# ---- Resolve repo_key → repo_path + variant ----
$Variant = ""

if ($RepoKey) {
    if (-not $RepoPathMap.ContainsKey($RepoKey)) {
        $allowed = $RepoPathMap.Keys -join ", "
        Write-Err "未知的 RepoKey: $RepoKey（允许: $allowed）"
        exit 1
    }
    $RepoPath = $RepoPathMap[$RepoKey]
    $Variant = Resolve-Variant -Key $RepoKey
} elseif ($RepoPath) {
    # Legacy: try to reverse-lookup repo_key from repo_path
    foreach ($key in $RepoPathMap.Keys) {
        if ($RepoPathMap[$key] -eq $RepoPath) {
            $RepoKey = $key
            break
        }
    }
    $Variant = Resolve-Variant -Key $(if ($RepoKey) { $RepoKey } else { "unknown" })
} else {
    $RepoPath = ""
    $RepoKey = ""
    $Variant = ""
}

$timestamp = Get-RealTimestamp

Write-OK ("ReqId: {0}" -f $fullReqId)
Write-OK ("Title: {0}" -f $Title)
Write-OK ("SOP: {0}" -f $Sop)
Write-OK ("Variant: {0}" -f $(if ([string]::IsNullOrWhiteSpace($Variant)) { "(空)" } else { $Variant }))
Write-OK ("RepoKey: {0}" -f $(if ([string]::IsNullOrWhiteSpace($RepoKey)) { "(空)" } else { $RepoKey }))
Write-OK ("RepoPath: {0}" -f $(if ([string]::IsNullOrWhiteSpace($RepoPath)) { "(空)" } else { $RepoPath }))
Write-OK ("CreatedAt: {0}" -f $timestamp)

# ---- 2. 复制模板 ----

Write-Step "复制模板..."

$templateDir = Join-Path $ProjectRoot "requirements\_template"
if (-not (Test-Path $templateDir)) {
    Write-Err "模板目录不存在: $templateDir"
    Write-Info "请检查 requirements/_template/ 是否完整。"
    exit 1
}

# 复制时排除 README.md（那是模板自身的说明）
Copy-Item -Path $templateDir -Destination $reqDir -Recurse -Force
$templateReadme = Join-Path $reqDir "README.md"
if (Test-Path $templateReadme) {
    Remove-Item $templateReadme -Force
}

# SOP-specific cleanup: game-design doesn't use plan.md, design/, tasks/
if ($Sop -eq "game-design") {
    $planFile = Join-Path $reqDir "plan.md"
    $designDir = Join-Path $reqDir "design"
    $tasksDir = Join-Path $reqDir "tasks"
    if (Test-Path $planFile) { Remove-Item $planFile -Force }
    if (Test-Path $designDir) { Remove-Item $designDir -Recurse -Force }
    if (Test-Path $tasksDir) { Remove-Item $tasksDir -Recurse -Force }
    Write-Info "  game-design SOP: removed plan.md, design/, tasks/ (not used)"
}

Write-OK "已复制到 $($reqDir.Substring($ProjectRoot.Length+1))"

# ---- 3. 替换占位符 ----

Write-Step "替换占位符..."

$replacements = @{
    '{{REQ_ID}}' = $fullReqId
    '{{TITLE}}' = $Title
    '{{SOP}}' = $Sop
    '{{CREATED_AT}}' = $timestamp
    '{{VARIANT}}' = $Variant
    '{{REPO_KEY}}' = $RepoKey
    '{{REPO_PATH}}' = $RepoPath
}

Replace-Placeholders -DirPath $reqDir -Replacements $replacements
Write-OK "占位符已替换"

# ---- 4. 重建 INDEX.md（自动从 meta.yaml 生成） ----

Write-Step "重建 INDEX.md..."

$rebuildScript = Join-Path $ProjectRoot ".codebuddy\scripts\rebuild-index.sh"
if (Test-Path $rebuildScript) {
    # On Windows, try bash (WSL/Git Bash)
    try {
        & bash $rebuildScript --quiet 2>$null
        Write-OK "INDEX.md rebuilt"
    } catch {
        Write-Info "rebuild-index.sh 执行失败，尝试 PowerShell 内联重建..."
        # Fallback: inline rebuild
        $rows = @()
        Get-ChildItem (Join-Path $ProjectRoot "requirements\req-*\meta.yaml") -ErrorAction SilentlyContinue | ForEach-Object {
            $content = Get-Content $_.FullName -Raw -Encoding UTF8
            $rid = if ($content -match '(?m)^req_id:\s*(.+)$') { $Matches[1].Trim().Trim('"') } else { "" }
            $rtitle = if ($content -match '(?m)^title:\s*(.+)$') { $Matches[1].Trim().Trim('"') } else { "" }
            $rsop = if ($content -match '(?m)^sop:\s*(\S+)') { $Matches[1].Trim().Trim('"') } else { "" }
            $rphase = if ($content -match '(?m)^phase:\s*(\S+)') { $Matches[1].Trim().Trim('"') } else { "" }
            $rstatus = if ($content -match '(?m)^status:\s*(\S+)') { $Matches[1].Trim().Trim('"') } else { "" }
            if ($rid) { $rows += "| $rid | $rtitle | $rstatus | $rsop | $rphase |" }
        }
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm"
        $indexContent = @"
# 需求索引

> 所有需求的总览。每个需求一个独立目录，命名 ``req-<short-id>``。
> 本文件由 ``.codebuddy/scripts/rebuild-index.sh`` 自动生成，**不要手动编辑**。

## 需求清单

| 需求 ID | 标题 | 状态 | SOP | 阶段 |
|---|---|---|---|---|
$($rows -join "`n")

---
*索引自动生成于：$ts*
"@
        Set-Content -Path (Join-Path $ProjectRoot "requirements\INDEX.md") -Value $indexContent -Encoding UTF8 -NoNewline
        Write-OK "INDEX.md rebuilt (PowerShell fallback)"
    }
} else {
    Write-Info "rebuild-index.sh 不存在，INDEX.md 未更新"
}

# ---- 5. 完成 ----

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║              ✓ 需求骨架创建完成                       ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  需求 ID: $fullReqId" -ForegroundColor Cyan
Write-Host "  目录:    requirements\$fullReqId\" -ForegroundColor Cyan
Write-Host "  阶段:    1.init (draft)"
Write-Host "  SOP:     $Sop"
Write-Host "  Variant: $(if ([string]::IsNullOrWhiteSpace($Variant)) { '(空)' } else { $Variant })"
Write-Host ""
Write-Host "  下一步：" -ForegroundColor Cyan
Write-Host ""
Write-Host "    在 Cursor / Claude Code 中执行："
Write-Host "      /pm-continue $fullReqId" -ForegroundColor Yellow
Write-Host ""
