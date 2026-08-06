# AIVibeCodingProj — Sync MCP config (.mcp.json -> .cursor/mcp.json)
#
# Usage:
#   .\scripts\sync-mcp.ps1            # sync
#   .\scripts\sync-mcp.ps1 -DryRun    # show what would change
#
# What it does:
#   Copy .mcp.json (project-root MCP config; read directly by both Claude Code
#   and CodeBuddy) to .cursor/mcp.json (Cursor's project-level MCP config).
#   All three tools use the same `mcpServers` schema, so a straight copy works.
#   .codebuddy/ does NOT need a sync target — CodeBuddy reads the same root
#   .mcp.json that Claude Code reads.
#
# Idempotent: safe to re-run.

[CmdletBinding()]
param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Src = Join-Path $ProjectRoot ".mcp.json"
$Dst = Join-Path $ProjectRoot ".cursor/mcp.json"

function Write-Step  { param([string]$Msg) Write-Host "==> $Msg" -ForegroundColor Cyan }
function Write-Ok    { param([string]$Msg) Write-Host "  + $Msg" -ForegroundColor Green }
function Write-Err   { param([string]$Msg) Write-Host "  x $Msg" -ForegroundColor Red }
function Write-Info  { param([string]$Msg) Write-Host "    $Msg" -ForegroundColor DarkGray }

if (-not (Test-Path $Src)) { Write-Err "Source missing: $Src"; exit 1 }

Write-Step "Sync .mcp.json -> .cursor/mcp.json"
Write-Info "src: $Src"
Write-Info "dst: $Dst"

if ($DryRun) {
    if ((Test-Path $Dst) -and (Get-FileHash -LiteralPath $Src).Hash -eq (Get-FileHash -LiteralPath $Dst).Hash) {
        Write-Ok "[dry-run] already in sync"
    } else {
        Write-Info "[dry-run] would copy"
    }
    exit 0
}

$dstDir = Split-Path -Parent $Dst
if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }

Copy-Item -LiteralPath $Src -Destination $Dst -Force

if ((Get-FileHash -LiteralPath $Src).Hash -eq (Get-FileHash -LiteralPath $Dst).Hash) {
    $bytes = (Get-Item -LiteralPath $Dst).Length
    Write-Ok "Synced ($bytes bytes)"
} else {
    Write-Err "Copy succeeded but contents differ - investigate"
    exit 2
}
