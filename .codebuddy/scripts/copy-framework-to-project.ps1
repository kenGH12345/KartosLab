# Copy the vibe-coding framework to another project.
#
# Usage:
#   .\copy-framework-to-project.ps1 -Destination "E:\MyNewProj"
#   .\copy-framework-to-project.ps1 -Destination "E:\MyNewProj" -WithData
#   .\copy-framework-to-project.ps1 -Destination "E:\MyNewProj" -DryRun
#
# What gets copied (framework only by default):
#   .codebuddy/                      single source of truth (rules/agents/commands/skills/sop/scripts)
#   .mcp.json                        read directly by all three IDEs (script does NOT sync this)
#   CLAUDE.md / CODEBUDDY.md / AGENTS.md   hand-maintained entry points (script does NOT sync)
#   README.md
#   .codebuddy/settings.local.json  local override (script does NOT sync)
#
# After copying, sync-codebuddy.ps1 is re-run in the destination to rebuild
# the .cursor/ and .claude/ symlink mirrors against the new project root.
#
# Optional -WithData also copies project collaboration data (.vibe/ context/ requirements/ output/).
# This is OFF by default because those are per-project artifacts, not framework.
#
# SVN: this script never commits. Local files only.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Destination,

    [switch]$WithData,
    [switch]$DryRun,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

# Script lives at <root>/.codebuddy/scripts/<name>.ps1 -> go up 3 levels for project root.
# $PSScriptRoot is unreliable when invoked via relative -File path, so derive from $MyInvocation.
$Source = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))
if (-not (Test-Path (Join-Path $Source '.codebuddy'))) {
    # Fall back to current location if script is invoked from elsewhere
    $Source = Get-Location
}

function Write-Step { param([string]$m) if (-not $Quiet) { Write-Host "==> $m" -ForegroundColor Cyan } }
function Write-Ok   { param([string]$m) if (-not $Quiet) { Write-Host "  + $m" -ForegroundColor Green } }
function Write-Info { param([string]$m) if (-not $Quiet) { Write-Host "    $m" -ForegroundColor DarkGray } }
function Write-Warn { param([string]$m) Write-Host "  ! $m" -ForegroundColor Yellow }

# Framework assets that MUST travel with the template (source-relative).
$frameworkItems = @(
    '.codebuddy',
    '.mcp.json',
    'CLAUDE.md',
    'CODEBUDDY.md',
    'AGENTS.md',
    'README.md'
)

# Items inside .codebuddy that the sync script deliberately does NOT copy.
$extraCodebuddyItems = @(
    (Join-Path '.codebuddy' 'settings.local.json')
)

# Per-project collaboration data (opt-in only).
$dataItems = @('.vibe', 'context', 'requirements', 'output')

$dest = Resolve-Path -Path $Destination -ErrorAction SilentlyContinue
if (-not $dest) {
    if ($DryRun) {
        $dest = $Destination
        Write-Warn "Destination does not exist; DryRun will show planned actions only."
    } else {
        Write-Warn "Creating destination: $Destination"
        New-Item -ItemType Directory -Force -Path $Destination | Out-Null
        $dest = Resolve-Path -Path $Destination
    }
}
$destPath = $dest.Path

Write-Step "Copy framework from $Source to $destPath"

$toCopy = $frameworkItems + $extraCodebuddyItems
if ($WithData) {
    Write-Info "WithData: including project collaboration data"
    $toCopy += $dataItems
}

foreach ($item in $toCopy) {
    $srcItem = Join-Path $Source $item
    if (-not (Test-Path $srcItem)) {
        Write-Warn "skip (not found at source): $item"
        continue
    }
    $dstItem = Join-Path $destPath $item
    if ($DryRun) {
        Write-Info "[dry-run] would copy $item -> $dstItem"
    } else {
        $dstParent = Split-Path -Parent $dstItem
        if (-not (Test-Path $dstParent)) { New-Item -ItemType Directory -Force -Path $dstParent | Out-Null }
        if ((Test-Path -LiteralPath $srcItem -PathType Container) -and $item -eq '.codebuddy') {
            # PowerShell Copy-Item -Recurse drops items when the destination dir already exists.
            # Use robocopy /MIR (native on Windows) for a reliable directory mirror.
            $null = robocopy $srcItem $dstItem /MIR /NFL /NDL /NJH /NJS /NC /NS /NP 2>$null
            if ($LASTEXITCODE -ge 8) { Write-Warn "robocopy issue for $item (exit $LASTEXITCODE)" }
        } else {
            Copy-Item -LiteralPath $srcItem -Destination $dstItem -Recurse -Force
        }
        Write-Ok "copied $item"
    }
}

if ($DryRun) {
    Write-Step "DryRun complete — no files written. Re-run without -DryRun to apply."
    return
}

# Rebuild the .cursor/ and .claude/ mirrors in the destination so symlinks point
# at the new project root (the source's absolute-path links would be stale).
Write-Step "Rebuilding IDE mirrors in destination (sync-codebuddy.ps1)"
$syncScript = Join-Path $destPath '.codebuddy/scripts/sync-codebuddy.ps1'
if (Test-Path $syncScript) {
    # Prefer pwsh (PS7); fall back to powershell (Windows PowerShell) if pwsh is absent.
    $psExe = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }
    & $psExe -NoProfile -File $syncScript -Quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "sync-codebuddy.ps1 completed"
    } else {
        Write-Warn "sync-codebuddy.ps1 exited with code $LASTEXITCODE — mirrors may need manual review"
    }
} else {
    Write-Warn "sync script not found at $syncScript; skipped mirror rebuild"
}

Write-Step "Done. Framework ready at $destPath"
Write-Info "Next: open the project in Cursor / Claude Code / CodeBuddy to pick up the new config."
