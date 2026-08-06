# AIVibeCodingProj — Sync Commands (.claude → .cursor)
#
# Usage:
#   .\scripts\sync-commands.ps1                 # sync all
#   .\scripts\sync-commands.ps1 -DryRun         # show what would change
#   .\scripts\sync-commands.ps1 -Quiet          # only print summary
#
# What it does:
#   For each .claude/commands/*.md, write a copy to .cursor/commands/<same>.md
#   with the YAML frontmatter (between leading `---` lines) stripped.
#   Cursor commands don't use frontmatter; they expect plain markdown content.
#
# Idempotent: safe to re-run.

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$SrcDir = Join-Path $ProjectRoot ".claude/commands"
$DstDir = Join-Path $ProjectRoot ".cursor/commands"

function Write-Step  { param([string]$Msg) if (-not $Quiet) { Write-Host "==> $Msg" -ForegroundColor Cyan } }
function Write-Ok    { param([string]$Msg) if (-not $Quiet) { Write-Host "  + $Msg" -ForegroundColor Green } }
function Write-Warn  { param([string]$Msg) Write-Host "  ! $Msg" -ForegroundColor Yellow }
function Write-Err   { param([string]$Msg) Write-Host "  x $Msg" -ForegroundColor Red }
function Write-Info  { param([string]$Msg) if (-not $Quiet) { Write-Host "    $Msg" -ForegroundColor DarkGray } }

if (-not (Test-Path $SrcDir)) { Write-Err "Source missing: $SrcDir"; exit 1 }

Write-Step "Sync .claude/commands/ -> .cursor/commands/"
Write-Info "src: $SrcDir"
Write-Info "dst: $DstDir"

# Strip YAML frontmatter (between leading --- lines)
function Remove-Frontmatter {
    param([string]$Path)
    $lines = Get-Content -LiteralPath $Path -Encoding UTF8
    if ($lines.Count -eq 0) { return @() }
    if ($lines[0] -ne '---') { return $lines }

    # Find the closing ---
    $closeIdx = -1
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -eq '---') { $closeIdx = $i; break }
    }
    if ($closeIdx -lt 0) { return $lines }  # no closing, treat as content

    $start = $closeIdx + 1
    # Skip a single leading blank line right after frontmatter (cosmetic)
    if ($start -lt $lines.Count -and $lines[$start] -eq '') { $start++ }

    if ($start -ge $lines.Count) { return @() }
    return $lines[$start..($lines.Count - 1)]
}

if ($DryRun) {
    Write-Step "[dry-run] would recreate $DstDir"
} else {
    if (Test-Path $DstDir) { Remove-Item -Recurse -Force $DstDir }
    New-Item -ItemType Directory -Force -Path $DstDir | Out-Null
}

$count = 0
Get-ChildItem -Path $SrcDir -Filter "*.md" -File | ForEach-Object {
    $name = $_.Name
    $dst = Join-Path $DstDir $name
    if ($DryRun) {
        Write-Info "[dry-run] $name"
    } else {
        $content = Remove-Frontmatter -Path $_.FullName
        # Use UTF8NoBOM so Cursor reads cleanly
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllLines($dst, $content, $utf8NoBom)
        Write-Info $name
    }
    $script:count++
}

Write-Ok "Synced $count command(s)"

if (-not $DryRun) {
    Write-Step "Verifying"
    $dstCount = (Get-ChildItem -Path $DstDir -Filter "*.md" -File).Count
    if ($dstCount -eq $count) {
        Write-Ok "Counts match: $count source = $dstCount synced"
    } else {
        Write-Err "Count mismatch: $count source vs $dstCount synced"
        exit 2
    }
}
