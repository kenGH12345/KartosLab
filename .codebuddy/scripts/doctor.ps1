<#
.SYNOPSIS
    工程健康检查（实现 .codebuddy/skills/core/doctor/SKILL.md 的检查逻辑）。

.DESCRIPTION
    四类检查：
      1. 资产完整性：rules/agents/commands/skills/sop 数量是否齐全
      2. 状态一致性：每个需求的 meta.yaml 与 process.txt / INDEX 是否对得上
      3. 链接有效性：所有 .md 中的本地相对链接目标是否存在
      4. 占位符遗留：{{PROJECT_NAME}} {{REPO_PATH}} 等是否仍未替换

    本脚本**只诊断不修复**——按报告自行决定修复方式。

.PARAMETER Scope
    检查范围：all（默认）/ assets / state / links / placeholders。

.PARAMETER TargetReqId
    仅检查某个需求的状态一致性（默认全部）。

.PARAMETER Json
    以 JSON 格式输出（便于 CI 集成或 /doctor 命令解析）。

.PARAMETER Quiet
    安静模式，仅输出问题。

.EXAMPLE
    .\scripts\doctor.ps1
    全量检查并输出 markdown 报告。

.EXAMPLE
    .\scripts\doctor.ps1 -Scope links
    只检查链接断裂。

.EXAMPLE
    .\scripts\doctor.ps1 -Json | ConvertFrom-Json
    脚本化处理。
#>

[CmdletBinding()]
param(
    [ValidateSet("all", "assets", "state", "links", "placeholders", "integrity")]
    [string]$Scope = "all",
    [string]$TargetReqId,
    [switch]$Json,
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# Json 隐式开启 Quiet（除最终 JSON 输出外其他都静默）
if ($Json) { $Quiet = $true }

# ============ 工具函数 ============

function Write-Section($msg) { if (-not $Quiet) { Write-Host ""; Write-Host "==> $msg" -ForegroundColor Cyan } }
function Write-OK($msg)      { if (-not $Quiet) { Write-Host "  + $msg" -ForegroundColor Green } }
function Write-Warn2($msg)   { if (-not $Quiet) { Write-Host "  ! $msg" -ForegroundColor Yellow } }
function Write-Err($msg)     { if (-not $Quiet) { Write-Host "  x $msg" -ForegroundColor Red } }
function Write-Info($msg)    { if (-not $Quiet) { Write-Host "    $msg" -ForegroundColor Gray } }

# 全局结果收集
$report = [ordered]@{
    timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm")
    project_root = $ProjectRoot
    scope = $Scope
    assets = @{ status = "skipped"; passed = @(); missing = @() }
    state = @{ status = "skipped"; passed = @(); inconsistencies = @() }
    links = @{ status = "skipped"; checked = 0; broken = @() }
    placeholders = @{ status = "skipped"; remaining = @() }
    integrity = @{ status = "skipped"; warnings = @(); duplicates = @() }
    health = "unknown"
}

# ============ 1. 资产完整性 ============

if ($Scope -in @("all", "assets")) {
    Write-Section "1. 资产完整性"
    $report.assets.status = "checked"

    $expectations = @(
        @{ Name = ".cursor/rules/*.mdc"; Path = ".cursor\rules"; Filter = "*.mdc"; Min = 8 }
        @{ Name = ".claude/agents/*.md"; Path = ".claude\agents"; Filter = "*.md"; Min = 14 }
        @{ Name = ".claude/commands/*.md"; Path = ".claude\commands"; Filter = "*.md"; Min = 17 }
        @{ Name = ".cursor/commands/*.md"; Path = ".cursor\commands"; Filter = "*.md"; Min = 17 }
        @{ Name = ".codebuddy/rules/*.mdc"; Path = ".codebuddy\rules"; Filter = "*.mdc"; Min = 8 }
        @{ Name = ".codebuddy/agents/*.md"; Path = ".codebuddy\agents"; Filter = "*.md"; Min = 14 }
        @{ Name = ".codebuddy/commands/*.md"; Path = ".codebuddy\commands"; Filter = "*.md"; Min = 17 }
        @{ Name = ".codebuddy/skills/_meta/SKILL_TEMPLATE.md"; Path = "skills\_meta\SKILL_TEMPLATE.md"; IsFile = $true }
        @{ Name = ".codebuddy/skills/_meta/skill-authoring-guide.md"; Path = "skills\_meta\skill-authoring-guide.md"; IsFile = $true }
        @{ Name = ".codebuddy/skills/_meta/self-evolution-protocol.md"; Path = "skills\_meta\self-evolution-protocol.md"; IsFile = $true }
        @{ Name = ".codebuddy/skills/INDEX.md"; Path = "skills\INDEX.md"; IsFile = $true }
        @{ Name = ".codebuddy/sop/INDEX.md"; Path = "sop\INDEX.md"; IsFile = $true }
        @{ Name = ".codebuddy/sop/agile-vibe.md"; Path = "sop\agile-vibe.md"; IsFile = $true }
        @{ Name = ".codebuddy/sop/deep-vibe.md"; Path = "sop\deep-vibe.md"; IsFile = $true }
        @{ Name = ".codebuddy/sop/_template_sop.md"; Path = "sop\_template_sop.md"; IsFile = $true }
        @{ Name = "requirements/INDEX.md"; Path = "requirements\INDEX.md"; IsFile = $true }
        @{ Name = "requirements/INDEX.yaml"; Path = "requirements\INDEX.yaml"; IsFile = $true }
        @{ Name = "requirements/_template/meta.yaml"; Path = "requirements\_template\meta.yaml"; IsFile = $true }
        @{ Name = "AGENTS.md"; Path = "AGENTS.md"; IsFile = $true }
        @{ Name = "CLAUDE.md"; Path = "CLAUDE.md"; IsFile = $true }
        @{ Name = "CODEBUDDY.md"; Path = "CODEBUDDY.md"; IsFile = $true }
        @{ Name = ".mcp.json"; Path = ".mcp.json"; IsFile = $true }
        @{ Name = ".cursor/mcp.json"; Path = ".cursor\mcp.json"; IsFile = $true }
        @{ Name = ".codebuddy/settings.json"; Path = ".codebuddy\settings.json"; IsFile = $true }
    )

    foreach ($exp in $expectations) {
        $fullPath = Join-Path $ProjectRoot $exp.Path
        if ($exp.IsFile) {
            if (Test-Path $fullPath) {
                Write-OK ("{0}" -f $exp.Name)
                $report.assets.passed += $exp.Name
            } else {
                Write-Err ("MISSING: {0}" -f $exp.Name)
                $report.assets.missing += @{ name = $exp.Name; reason = "not found" }
            }
        } else {
            $count = @(Get-ChildItem -Path $fullPath -Filter $exp.Filter -ErrorAction SilentlyContinue).Count
            if ($count -ge $exp.Min) {
                Write-OK ("{0}: {1} (>= {2})" -f $exp.Name, $count, $exp.Min)
                $report.assets.passed += $exp.Name
            } else {
                Write-Err ("INSUFFICIENT: {0}: {1} (expected >= {2})" -f $exp.Name, $count, $exp.Min)
                $report.assets.missing += @{ name = $exp.Name; reason = ("count {0} < min {1}" -f $count, $exp.Min) }
            }
        }
    }

    # commands 三端对称（.claude / .cursor / .codebuddy）
    $claudeCmds = @(Get-ChildItem (Join-Path $ProjectRoot ".claude\commands") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    $cursorCmds = @(Get-ChildItem (Join-Path $ProjectRoot ".cursor\commands") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    $codebuddyCmds = @(Get-ChildItem (Join-Path $ProjectRoot ".codebuddy\commands") -Filter "*.md" -ErrorAction SilentlyContinue).Count
    if ($claudeCmds -ne $cursorCmds -or $claudeCmds -ne $codebuddyCmds) {
        Write-Err "commands 三端不对称: .claude=$claudeCmds .cursor=$cursorCmds .codebuddy=$codebuddyCmds"
        $report.assets.missing += @{ name = "commands_symmetry"; reason = ".claude=$claudeCmds vs .cursor=$cursorCmds vs .codebuddy=$codebuddyCmds" }
    } else {
        Write-OK "commands 三端对称: .claude=$claudeCmds .cursor=$cursorCmds .codebuddy=$codebuddyCmds"
    }
}

# ============ 2. 状态一致性 ============

if ($Scope -in @("all", "state")) {
    Write-Section "2. 状态一致性（每个需求）"
    $report.state.status = "checked"

    $reqDirs = if ($TargetReqId) {
        @(Get-Item (Join-Path $ProjectRoot "requirements\$TargetReqId") -ErrorAction SilentlyContinue)
    } else {
        @(Get-ChildItem (Join-Path $ProjectRoot "requirements") -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like "req-*" })
    }

    if ($reqDirs.Count -eq 0) {
        Write-Info "(no requirements yet)"
    }

    foreach ($dir in $reqDirs) {
        $reqId = $dir.Name
        $issues = @()

        $metaPath = Join-Path $dir.FullName "meta.yaml"
        $processPath = Join-Path $dir.FullName "process.txt"

        if (-not (Test-Path $metaPath)) { $issues += "meta.yaml 缺失" }
        if (-not (Test-Path $processPath)) { $issues += "process.txt 缺失" }

        if ($issues.Count -eq 0) {
            $metaContent = Get-Content $metaPath -Raw -Encoding UTF8
            $metaPhase = if ($metaContent -match '(?m)^phase:\s*(\S+)') { $Matches[1] } else { $null }
            $metaStatus = if ($metaContent -match '(?m)^status:\s*(\S+)') { $Matches[1] } else { $null }
            $metaSop = if ($metaContent -match '(?m)^sop:\s*(\S+)') { $Matches[1] } else { $null }

            # 校验 process.txt 的最近 phase 事件
            $processLines = Get-Content $processPath -Encoding UTF8
            $lastPhaseLine = $processLines | Where-Object { $_ -match '\] (phase|phase_force|init):' } | Select-Object -Last 1
            if ($lastPhaseLine -and $metaPhase) {
                # phase 事件可能形如：[time] phase: 2.requirement → 3.iteration
                if ($lastPhaseLine -match '→\s*([\w\.\-]+)') {
                    $processPhase = $Matches[1]
                    if ($processPhase -ne $metaPhase) {
                        $issues += "meta.phase=$metaPhase 与 process.txt 末次 phase 事件目标=$processPhase 不一致"
                    }
                } elseif ($lastPhaseLine -match '\] init:') {
                    if ($metaPhase -ne "1.init") {
                        $issues += "process.txt 显示仍在 init，但 meta.phase=$metaPhase"
                    }
                }
            }

            # 校验产物存在（按 SOP+phase）
            if ($metaSop -eq "deep-vibe") {
                if ($metaPhase -match '^(2|3|4|5)\.') {
                    if (-not (Test-Path (Join-Path $dir.FullName "spec\需求文档.md"))) {
                        $issues += "phase >= 2 但缺 spec/需求文档.md"
                    }
                }
                if ($metaPhase -match '^(3|4|5)\.') {
                    if (-not (Test-Path (Join-Path $dir.FullName "design\技术方案.md"))) {
                        $issues += "phase >= 3 但缺 design/技术方案.md"
                    }
                }
                if ($metaStatus -eq "done") {
                    if (-not (Test-Path (Join-Path $dir.FullName "spec\最终需求.md"))) {
                        $issues += "status=done 但缺 spec/最终需求.md"
                    }
                }
            } elseif ($metaSop -eq "agile-vibe") {
                if ($metaPhase -match '^(2|3|4)\.') {
                    $hasSpec = (Test-Path (Join-Path $dir.FullName "spec\需求简述.md")) -or
                               (Test-Path (Join-Path $dir.FullName "spec\需求文档.md"))
                    if (-not $hasSpec) {
                        $issues += "phase >= 2 但缺 spec/需求简述.md（或 需求文档.md）"
                    }
                }
                if ($metaStatus -eq "done") {
                    if (-not (Test-Path (Join-Path $dir.FullName "spec\最终需求.md"))) {
                        $issues += "status=done 但缺 spec/最终需求.md"
                    }
                }
            }
        }

        if ($issues.Count -eq 0) {
            Write-OK ("{0}: 一致" -f $reqId)
            $report.state.passed += $reqId
        } else {
            Write-Warn2 ("{0}:" -f $reqId)
            foreach ($issue in $issues) { Write-Info "    - $issue" }
            $report.state.inconsistencies += @{ req_id = $reqId; issues = $issues }
        }
    }
}

# ============ 3. 链接有效性 ============

if ($Scope -in @("all", "links")) {
    Write-Section "3. 链接有效性"
    $report.links.status = "checked"

    $excludeDirs = @('\.svn\', '\node_modules\', '\.vibe\cache\', '\_archived\')
    $linkPattern = '\[([^\]]+)\]\(([^)]+)\)'

    $mdFiles = Get-ChildItem -Path $ProjectRoot -Filter "*.md" -Recurse -File | Where-Object {
        $rel = $_.FullName.Substring($ProjectRoot.Length)
        $skip = $false
        foreach ($ex in $excludeDirs) { if ($rel -like "*$ex*") { $skip = $true; break } }
        -not $skip
    }

    $totalLinks = 0
    foreach ($file in $mdFiles) {
        $relSource = $file.FullName.Substring($ProjectRoot.Length+1)
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $lineNum = 0
        $inFence = $false  # 跳过 ```...``` 代码块内的链接（往往是示例）
        foreach ($line in ($content -split "`n")) {
            $lineNum++
            # toggle fence 状态（行首三个反引号）
            if ($line -match '^\s*```') { $inFence = -not $inFence; continue }
            if ($inFence) { continue }

            # 剥掉行内 code span（`...`）——里面的 [x](y) 是示例，不是真链接
            $stripped = [regex]::Replace($line, '`[^`]*`', '')
            $matches = [regex]::Matches($stripped, $linkPattern)
            foreach ($m in $matches) {
                $target = $m.Groups[2].Value.Trim()
                $linkText = $m.Groups[1].Value.Trim()
                # 跳过远程链接 / 锚点链接 / mailto
                if ($target -match '^(https?:|mailto:|#|tel:|ftp:)') { continue }
                # 剥离 anchor 部分
                $cleanTarget = ($target -split '#')[0]
                if ([string]::IsNullOrWhiteSpace($cleanTarget)) { continue }
                # 跳过含非法路径字符的"占位文本"链接（如 [foo](<path>) [文字](路径)）
                $invalidChars = [System.IO.Path]::GetInvalidPathChars() + [char[]]('<', '>', '*', '?', '"', '|')
                $hasInvalid = $false
                foreach ($c in $invalidChars) { if ($cleanTarget.Contains($c)) { $hasInvalid = $true; break } }
                if ($hasInvalid) { continue }
                # 跳过含中文的"占位/示例"路径（真实路径应该是 ASCII，需求文档除外）
                # 注意：requirements/<id>/spec/需求文档.md 这类是合法中文路径，故只在 cleanTarget 完全非 ASCII 时跳过
                if ($cleanTarget -notmatch '[a-zA-Z0-9./_\-]' -and $cleanTarget -match '[\u4e00-\u9fff]') {
                    continue
                }
                $totalLinks++

                # 解析为绝对路径（基于源文件目录）
                $sourceDir = Split-Path -Parent $file.FullName
                $absTarget = $null
                try {
                    $absTarget = if ([System.IO.Path]::IsPathRooted($cleanTarget)) {
                        $cleanTarget
                    } else {
                        Join-Path $sourceDir $cleanTarget
                    }
                } catch {
                    continue
                }
                if (-not (Test-Path $absTarget)) {
                    Write-Warn2 ("{0}:{1} -> {2}" -f $relSource, $lineNum, $target)
                    $report.links.broken += @{
                        source = $relSource
                        line = $lineNum
                        target = $target
                    }
                }
            }
        }
    }
    $report.links.checked = $totalLinks
    if ($report.links.broken.Count -eq 0) {
        Write-OK "$totalLinks 个本地链接全部有效"
    } else {
        Write-Err "$($report.links.broken.Count) 个断链 / $totalLinks 个本地链接"
    }
}

# ============ 4. 占位符遗留 ============

if ($Scope -in @("all", "placeholders")) {
    Write-Section "4. 占位符遗留"
    $report.placeholders.status = "checked"

    $placeholders = @('{{PROJECT_NAME}}', '{{REPO_PATH}}', '{{REQ_ID}}', '{{TITLE}}', '{{CREATED_AT}}', '{{SOP}}')
    $excludePathFragments = @(
        '\_template\',
        '\_template_sop.md',
        '\SKILL_TEMPLATE.md',
        '\_example.yaml',
        '\.svn\',
        '\node_modules\',
        '\.vibe\cache\',
        '\scripts\init.ps1',
        '\scripts\new-requirement.ps1',
        '\scripts\doctor.ps1',
        '\scripts\sync-',
        '\.cursor\',
        '\.codebuddy\',
        '\skills\',
        '\docs\PHASE5-FINDINGS.md'
    )

    $files = Get-ChildItem -Path $ProjectRoot -Recurse -File -Include "*.md","*.yaml","*.yml","*.json","*.txt","*.mdc" | Where-Object {
        $rel = $_.FullName.Substring($ProjectRoot.Length)
        $skip = $false
        foreach ($ex in $excludePathFragments) { if ($rel -like "*$ex*") { $skip = $true; break } }
        -not $skip
    }

    foreach ($file in $files) {
        $relSource = $file.FullName.Substring($ProjectRoot.Length+1)
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $lineNum = 0
        foreach ($line in ($content -split "`n")) {
            $lineNum++
            foreach ($ph in $placeholders) {
                # 去掉反引号包裹的 `{{XXX}}` 后再检查——那些是文档里
                # 字面提到占位符的说明，不是待替换的真实槽。
                $unwrapped = $line.Replace("``${ph}``", "")
                if ($unwrapped.Contains($ph)) {
                    Write-Warn2 ("{0}:{1} - {2}" -f $relSource, $lineNum, $ph)
                    $report.placeholders.remaining += @{
                        source = $relSource
                        line = $lineNum
                        placeholder = $ph
                    }
                }
            }
        }
    }
    if ($report.placeholders.remaining.Count -eq 0) {
        Write-OK "未发现占位符遗留"
    } else {
        Write-Warn2 "$($report.placeholders.remaining.Count) 处占位符遗留"
    }
}

# ============ 5. 状态产物自洽性 ============

if ($Scope -in @("all", "integrity")) {
    Write-Section "5. 状态产物自洽性"
    $report.integrity.status = "checked"

    # 5.1 INDEX 重复 req-id 检测（入 inconsistencies）
    $indexMd = Join-Path $ProjectRoot "requirements\INDEX.md"
    $indexYaml = Join-Path $ProjectRoot "requirements\INDEX.yaml"
    $dupFound = 0

    if (Test-Path $indexMd) {
        $mdLines = Get-Content $indexMd -Encoding UTF8
        $mdIds = @()
        foreach ($line in $mdLines) {
            # 表格行：| req-xxx | ... 或 | `req-xxx` | ...
            if ($line -match '^\|\s*`?(req-[A-Za-z0-9_-]+)`?\s*\|') {
                $mdIds += $Matches[1]
            }
        }
        $dupMd = $mdIds | Group-Object | Where-Object { $_.Count -gt 1 }
        foreach ($g in $dupMd) {
            Write-Err "INDEX.md 重复 req-id: $($g.Name)"
            $report.integrity.duplicates += @{ source = "INDEX.md"; id = $g.Name; count = $g.Count }
            $report.state.inconsistencies += @{ req_id = $g.Name; issues = @("INDEX.md 重复 req-id") }
            $dupFound++
        }
    }

    if (Test-Path $indexYaml) {
        $yamlLines = Get-Content $indexYaml -Encoding UTF8
        $yamlIds = @()
        foreach ($line in $yamlLines) {
            if ($line -match '^\s*-\s+id:\s*(\S+)') {
                $yamlIds += $Matches[1]
            }
        }
        $dupYaml = $yamlIds | Group-Object | Where-Object { $_.Count -gt 1 }
        foreach ($g in $dupYaml) {
            Write-Err "INDEX.yaml 重复 req-id: $($g.Name)"
            $report.integrity.duplicates += @{ source = "INDEX.yaml"; id = $g.Name; count = $g.Count }
            $report.state.inconsistencies += @{ req_id = $g.Name; issues = @("INDEX.yaml 重复 req-id") }
            $dupFound++
        }
    }

    if ($dupFound -eq 0) { Write-OK "5.1 INDEX 无重复 req-id" }

    # 5.2 process.txt 时间戳单调递增检测（入 warnings）
    $tsWarns = 0
    $reqDirsAll = @(Get-ChildItem (Join-Path $ProjectRoot "requirements") -Directory -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -like "req-*" })
    foreach ($dir in $reqDirsAll) {
        $pf = Join-Path $dir.FullName "process.txt"
        if (-not (Test-Path $pf)) { continue }
        $rid = $dir.Name
        $prevTs = $null
        $prevLineno = 0
        $lineno = 0
        foreach ($line in (Get-Content $pf -Encoding UTF8)) {
            $lineno++
            if ($line -match '^\[(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2})\]') {
                $curTs = $Matches[1]
                if ($prevTs -and ($curTs -lt $prevTs)) {
                    Write-Warn2 "$rid/process.txt:$lineno timestamp $curTs < prev (line $prevLineno: $prevTs)"
                    $report.integrity.warnings += @{
                        source = "$rid/process.txt"
                        line = $lineno
                        type = "timestamp_out_of_order"
                        detail = "$curTs < line ${prevLineno}: $prevTs"
                    }
                    $tsWarns++
                }
                $prevTs = $curTs
                $prevLineno = $lineno
            }
        }
    }
    if ($tsWarns -eq 0) { Write-OK "5.2 process.txt 时间戳单调递增" }

    # 5.3 verdict 枚举白名单（per 45-state-sync-protocol.mdc）
    $verdictWarns = 0
    foreach ($dir in $reqDirsAll) {
        $pf = Join-Path $dir.FullName "process.txt"
        if (-not (Test-Path $pf)) { continue }
        $rid = $dir.Name
        $lineno = 0
        foreach ($line in (Get-Content $pf -Encoding UTF8)) {
            $lineno++
            if ($line -match 'verdict=([A-Za-z0-9_-]+)') {
                $v = $Matches[1]
                $valid = switch -Regex ($v) {
                    '^(approve_go|tweak|redo|abort)$' { $true; break }
                    '^back_to_phase_.+' { $true; break }
                    '^delegate_.+' { $true; break }
                    default { $false }
                }
                if (-not $valid) {
                    Write-Warn2 "$rid/process.txt:$lineno 非法 verdict: $v (allowed: approve_go|tweak|redo|back_to_phase_<N>|delegate_<agent>|abort)"
                    $report.integrity.warnings += @{
                        source = "$rid/process.txt"
                        line = $lineno
                        type = "invalid_verdict"
                        detail = $v
                    }
                    $verdictWarns++
                }
            }
        }
    }
    if ($verdictWarns -eq 0) { Write-OK "5.3 verdict 枚举全部合法" }
}

# ============ 健康度判定 ============

$missingCount = $report.assets.missing.Count
$inconsistencyCount = $report.state.inconsistencies.Count
$brokenLinks = $report.links.broken.Count
$placeholderCount = $report.placeholders.remaining.Count
$integrityWarnCount = $report.integrity.warnings.Count

if ($missingCount -eq 0 -and $inconsistencyCount -eq 0 -and $brokenLinks -eq 0 -and $placeholderCount -eq 0 -and $integrityWarnCount -eq 0) {
    $report.health = "healthy"
} elseif ($brokenLinks -gt 0 -or $inconsistencyCount -gt 0 -or $missingCount -gt 0) {
    $report.health = "unhealthy"
} else {
    $report.health = "subhealthy"
}

# ============ 输出 ============

if ($Json) {
    $report | ConvertTo-Json -Depth 10
    exit 0
}

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║                  健康检查报告                          ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  时间:   $($report.timestamp)"
Write-Host "  根目录: $($report.project_root)"
Write-Host "  范围:   $($report.scope)"
Write-Host ""
Write-Host "  统计:" -ForegroundColor Cyan
Write-Host ("    资产缺失:     {0}" -f $missingCount)
Write-Host ("    状态不一致:   {0}" -f $inconsistencyCount)
Write-Host ("    状态告警:     {0}" -f $integrityWarnCount)
Write-Host ("    链接断裂:     {0} / {1}" -f $brokenLinks, $report.links.checked)
Write-Host ("    占位符遗留:   {0}" -f $placeholderCount)
Write-Host ""

$healthColor = switch ($report.health) {
    "healthy"     { "Green" }
    "subhealthy"  { "Yellow" }
    "unhealthy"   { "Red" }
    default       { "Gray" }
}
Write-Host "  健康度: $($report.health)" -ForegroundColor $healthColor
Write-Host ""

if ($report.health -ne "healthy") {
    Write-Host "  建议修复优先级:" -ForegroundColor Cyan
    if ($brokenLinks -gt 0)         { Write-Host "    [HIGH] 链接断裂 - 立即修（影响导航）" -ForegroundColor Red }
    if ($inconsistencyCount -gt 0)  { Write-Host "    [HIGH] 状态不一致 - 跑 /pm-continue 或手工核对" -ForegroundColor Red }
    if ($missingCount -gt 0)        { Write-Host "    [MED ] 资产缺失 - 检查是否项目刻意删除" -ForegroundColor Yellow }
    if ($integrityWarnCount -gt 0)  { Write-Host "    [MED ] 状态告警 - process.txt 时间序 / verdict 枚举（不阻塞，纪律提醒）" -ForegroundColor Yellow }
    if ($placeholderCount -gt 0)    { Write-Host "    [MED ] 占位符遗留 - 跑 .codebuddy/scripts/init.ps1 或手工填值" -ForegroundColor Yellow }
    Write-Host ""
}

# 退出码：健康=0 / 亚健康=1 / 不健康=2（便于 CI 集成）
$exitCode = switch ($report.health) {
    "healthy"     { 0 }
    "subhealthy"  { 1 }
    "unhealthy"   { 2 }
    default       { 3 }
}
exit $exitCode
