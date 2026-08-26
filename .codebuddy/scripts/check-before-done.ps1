# check-before-done.ps1 - Windows mirror of check-before-done.sh
#
# NOTE: uses $args[0] instead of a param() block on purpose — PowerShell 5.1's
# `-File` mode mishandles position parameters when a param() block is combined
# with non-trivial script bodies. $args is an automatic variable and always works.
# Version: 1.3.0
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .codebuddy\scripts\check-before-done.ps1 <req-id>
#
# Checks before marking status=done:
#   1. final_summary_path is not null
#   2. spec/最终需求.md exists
#   3. process.txt has closer completion log
#   4. Experience quality gate: auto-extracted experiences with status=draft
#   5. Experience cap: no more than 5 entries per source_req
#
# All pass -> exit 0
# Any fail -> list missing items + exit 1
#
# Exemption: if process.txt contains "verdict=approve_go" AND "skip closer", treat as explicit user exemption -> exit 0

$ErrorActionPreference = 'Stop'

$ReqId = if ($args.Count -gt 0) { $args[0] } else { "" }

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)

if ([string]::IsNullOrWhiteSpace($ReqId)) {
    Write-Host "Usage: check-before-done.ps1 <req-id>"
    exit 1
}

$reqDir = Join-Path $projectRoot "requirements\$ReqId"
if (-not (Test-Path $reqDir -PathType Container)) {
    Write-Host "Requirement directory not found: $reqDir"
    exit 1
}

$metaFile = Join-Path $reqDir "meta.yaml"
$processFile = Join-Path $reqDir "process.txt"
$errors = @()

# === Exemption check ===
# Bilingual match: 'skip closer' | '跳过 closer' (aligned with check-before-done.sh)
# -Encoding UTF8: 无 BOM 的 UTF-8 在中文 Windows 默认按 ANSI 读会乱码导致正则失配
$processContent = Get-Content $processFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
if ($processContent -match '(skip closer|跳过 closer)' -and $processContent -match 'verdict=approve_go') {
    Write-Host "User explicitly exempted closer (verdict + skip closer logged)"
    exit 0
}

# === Check 1: final_summary_path ===
$metaContent = Get-Content $metaFile -Raw -ErrorAction SilentlyContinue
if ($metaContent -match 'final_summary_path:\s*"?null"?' -or -not ($metaContent -match 'final_summary_path:')) {
    $errors += "meta.yaml.final_summary_path is null/empty (closer did not fill it)"
}

# === Check 2: Final requirement document exists ===
$foundFinal = $false
foreach ($name in @('最终需求.md', '最终需求简述.md')) {
    $path = Join-Path $reqDir "spec\$name"
    if (Test-Path $path -PathType Leaf) {
        $foundFinal = $true
        break
    }
}
if (-not $foundFinal) {
    $errors += "spec/最终需求.md missing (closer did not produce it)"
}

# === Check 3: process.txt has closer completion log ===
# Bilingual match: completed|done|finished|完成 (aligned with check-before-done.sh)
if (-not ($processContent -match 'closer.*(completed|done|finished|完成)')) {
    $errors += "No closer completion log in process.txt"
}

# === Check 4: Experience quality gate (Phase 1 addition) ===
$autoExtractDir = Join-Path $projectRoot "context\shared\experiences\auto-extracted"
if (Test-Path $autoExtractDir -PathType Container) {
    $unverifiedFiles = Get-ChildItem $autoExtractDir -Filter "*.md" -Recurse |
        Where-Object { (Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue) -match '^status:\s*draft' }
    $unverifiedCount = ($unverifiedFiles | Measure-Object).Count
    if ($unverifiedCount -gt 0) {
        Write-Host "WARNING: $unverifiedCount unverified auto-extracted experiences (status=draft)"
        Write-Host "    Location: context/shared/experiences/auto-extracted/"
        Write-Host "    Fix: add 'analysis' and 'solution' sections then change status: final"
        # Non-blocking warning
    }
}

# === Check 5: Experience cap ===
$expDir = Join-Path $projectRoot "context\shared\experiences"
if (Test-Path $expDir -PathType Container) {
    $allExpFiles = Get-ChildItem $expDir -Filter "*.md" -Recurse
    $sourceReqs = $allExpFiles | ForEach-Object {
        $c = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        if ($c -match 'source_req:\s*(\S+)') { $Matches[1] }
    } | Group-Object | Where-Object { $_.Count -gt 5 }
    foreach ($grp in $sourceReqs) {
        Write-Host "WARNING: Experience cap exceeded for $($grp.Name): $($grp.Count) entries (max 5)"
    }
}

# === Check 6: AI feature test evidence chain (v0.2.0 · automation-first) ===
# agile-vibe SOP phase 3 requires test-report/ac-verification.md + integration-test.log; missing -> warning (non-blocking, blocked by code-reviewer step 2.5)
$acVerify = Join-Path $reqDir "test-report\ac-verification.md"
$integLog = Join-Path $reqDir "test-report\integration-test.log"
if (-not (Test-Path $acVerify -PathType Leaf)) {
    # Exemption: meta.yaml has test_exempt: true + non-empty test_exempt_reason
    if ($metaContent -match 'test_exempt:\s*true') {
        $exemptReason = ""
        if ($metaContent -match 'test_exempt_reason:\s*"?([^"\r\n]+)"?') {
            $exemptReason = $Matches[1].Trim()
        }
        if ([string]::IsNullOrWhiteSpace($exemptReason)) {
            Write-Host "WARNING: test_exempt=true but test_exempt_reason is empty (agile-vibe SOP 9.5)"
        } else {
            Write-Host "OK: Feature test exempted (reason: $exemptReason)"
        }
    } else {
        Write-Host "WARNING: test-report/ac-verification.md not found (agile-vibe SOP phase 3 v0.2.0 required output)"
        Write-Host "    For pure doc/retrospective needs, add test_exempt: true + test_exempt_reason: <reason> to meta.yaml"
        # Non-blocking: enforced by code-reviewer step 2.5
    }
} else {
    # Verify honesty declaration checkbox count
    $acContent = Get-Content $acVerify -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    $checkedCount = ([regex]::Matches($acContent, '^- \[x\]', 'Multiline')).Count
    if ($checkedCount -lt 3) {
        Write-Host "WARNING: ac-verification.md exists but honesty declaration checkboxes < 3 (current: $checkedCount, agile-vibe SOP 9.4)"
    }

    # v0.2.0 new: check integration-test.log presence (automation-first assertion main line)
    if (-not (Test-Path $integLog -PathType Leaf)) {
        Write-Host "WARNING: test-report/integration-test.log not found (v0.2.0 automation-first assertion main line · blocked by code-reviewer step 2.5)"
    }

    # === Check 6.5: Zero real-operation detection (self-testing SKILL v0.2.0 semantic adjustment) ===
    # Warning-level: if all AC rows are ⚠️/未验证/需人工抽验 but honesty declaration is checked
    # AND header doesn't contain 'self-test not executed' -> WARNING (not blocking)
    $acRows = ([regex]::Matches($acContent, '^\| AC-\d', 'Multiline')).Count
    $warnRows = ([regex]::Matches($acContent, '^\| AC-\d.*(⚠️|未验证|需人工抽验)', 'Multiline')).Count
    $hasNotExecHeader = ([regex]::Matches($acContent, 'self-test not executed')).Count
    if ($acRows -gt 0 -and $warnRows -eq $acRows -and $hasNotExecHeader -eq 0 -and $checkedCount -ge 3) {
        Write-Host "WARNING: Zero real-operation violation - all $acRows AC(s) are ⚠️/unverified/manual-spot-check-needed but honesty declaration checked without 'self-test not executed' header"
        Write-Host "    See: .codebuddy/skills/core/self-testing/SKILL.md#zero-real-operation-boundary (v0.2.0)"
        Write-Host "    Fix: add at least 1 integration_test-passing AC OR add 'self-test not executed - reason: <...>' to report header"
    }
}

# === Result ===
if ($errors.Count -eq 0) {
    Write-Host "All done-gate checks passed. Safe to mark status=done"
    exit 0
} else {
    Write-Host ""
    Write-Host "CANNOT mark status=done. Failed checks:"
    Write-Host ""
    foreach ($err in $errors) {
        Write-Host "  - $err"
    }
    Write-Host ""
    Write-Host "Resolution:"
    Write-Host "  1. Complete closing flow (code-reviewer -> closer -> knowledge-maintainer)"
    Write-Host "  2. Or user explicit exemption: add 'verdict=approve_go / note: skip closer' to process.txt"
    Write-Host ""
    exit 1
}