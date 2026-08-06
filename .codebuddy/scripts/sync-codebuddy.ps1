# AIVibeCodingProj — Maintain three-way symlinks (.codebuddy -> .cursor / .claude)
#
# Usage:
#   .\scripts\sync-codebuddy.ps1               # rebuild all symlinks
#   .\scripts\sync-codebuddy.ps1 -DryRun       # show what would change
#   .\scripts\sync-codebuddy.ps1 -Quiet        # only print summary
#
# Architecture (since v0.2):
#   .codebuddy\ is the SINGLE SOURCE OF TRUTH for shared assets.
#   .cursor\ and .claude\ contain SYMLINKS into .codebuddy\.
#
#     .cursor\rules\*.mdc      -> ..\..\.codebuddy\rules\*.mdc
#     .cursor\commands\*.md    -> ..\..\.codebuddy\commands\*.md
#     .claude\agents\*.md      -> ..\..\.codebuddy\agents\*.md
#     .claude\commands\*.md    -> ..\..\.codebuddy\commands\*.md
#
#   Editing any of these paths edits the same underlying file. All three IDEs
#   (Claude Code, Cursor, CodeBuddy) see consistent content automatically.
#
#   Windows note: creating symlinks requires either:
#     - Developer Mode enabled (Settings -> Privacy & security -> For developers)
#     - OR running this script as Administrator
#   Without symlinks, this script falls back to file copies (legacy mirror mode)
#   so users on locked-down corporate machines still get a working repo.
#
# Idempotent: safe to re-run.

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

# $MyInvocation.MyCommand.Path includes the "scripts" segment, so we must go up 3 levels (scripts -> .codebuddy -> project root).
$ProjectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

function Write-Step  { param([string]$Msg) if (-not $Quiet) { Write-Host "==> $Msg" -ForegroundColor Cyan } }
function Write-Ok    { param([string]$Msg) if (-not $Quiet) { Write-Host "  + $Msg" -ForegroundColor Green } }
function Write-Warn  { param([string]$Msg) Write-Host "  ! $Msg" -ForegroundColor Yellow }
function Write-Err   { param([string]$Msg) Write-Host "  x $Msg" -ForegroundColor Red }
function Write-Info  { param([string]$Msg) if (-not $Quiet) { Write-Host "    $Msg" -ForegroundColor DarkGray } }

# Try to create a symlink and report whether the platform allows it
$script:CanSymlink = $null
function Test-CanSymlink {
    if ($null -ne $script:CanSymlink) { return $script:CanSymlink }
    $tmpTarget = [System.IO.Path]::GetTempFileName()
    $tmpLink   = "$tmpTarget.link"
    try {
        New-Item -ItemType SymbolicLink -Path $tmpLink -Target $tmpTarget -ErrorAction Stop | Out-Null
        Remove-Item $tmpLink, $tmpTarget -Force -ErrorAction SilentlyContinue
        $script:CanSymlink = $true
    } catch {
        Remove-Item $tmpTarget -Force -ErrorAction SilentlyContinue
        $script:CanSymlink = $false
    }
    return $script:CanSymlink
}

function Link-Set {
    param(
        [string]$SrcSubdir,
        [string]$LinkDirRel,
        [string]$Filter,
        [string]$Label
    )
    $src     = Join-Path $ProjectRoot ".codebuddy/$SrcSubdir"
    $linkDir = Join-Path $ProjectRoot $LinkDirRel

    if (-not (Test-Path $src)) {
        Write-Warn "skip ${Label}: source missing ($src)"
        return 0
    }

    if (-not $DryRun -and -not (Test-Path $linkDir)) {
        New-Item -ItemType Directory -Force -Path $linkDir | Out-Null
    }

    $files = Get-ChildItem -Path $src -Filter $Filter -File
    Write-Info "${Label}: $($files.Count) source file(s)"

    $useSymlink = Test-CanSymlink
    if (-not $useSymlink) {
        Write-Warn "$Label : symlink unsupported, falling back to copy (legacy mode)"
    }

    if ($DryRun) {
        $mode = if ($useSymlink) { 'symlink' } else { 'copy (fallback)' }
        foreach ($f in $files) {
            Write-Info "[dry-run] $LinkDirRel\$($f.Name) ($mode) -> ..\..\.codebuddy\$SrcSubdir\$($f.Name)"
        }
        return $files.Count
    }

    # Clean dangling symlinks
    if (Test-Path $linkDir) {
        Get-ChildItem -Path $linkDir -Force | Where-Object {
            $_.Attributes -band [System.IO.FileAttributes]::ReparsePoint
        } | ForEach-Object {
            if (-not (Test-Path $_.Target -PathType Any)) {
                Remove-Item -LiteralPath $_.FullName -Force
                Write-Info "removed dangling: $($_.Name)"
            }
        }
    }

    $count = 0
    foreach ($f in $files) {
        $targetPath = Join-Path $linkDir $f.Name
        # Absolute path, not "..\..\.codebuddy\...": Windows PowerShell resolves New-Item -Target relative paths against cwd, not the link's dir (unlike bash ln), which corrupted links when cwd != project root.
        $linkTarget = Join-Path $src $f.Name

        # If existing path is already correct symlink, skip
        if ($useSymlink -and (Test-Path $targetPath)) {
            $item = Get-Item -LiteralPath $targetPath -Force
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                # On PS5 .Target is array; on PS7 .Target is string. Normalise.
                $cur = if ($item.Target -is [array]) { $item.Target[0] } else { $item.Target }
                if ($cur -eq $linkTarget -or $cur -eq $f.FullName) {
                    $count++; continue
                }
            }
            Remove-Item -LiteralPath $targetPath -Force
        } elseif (Test-Path $targetPath) {
            if (-not $useSymlink) {
                # Fallback mode: just overwrite
                Remove-Item -LiteralPath $targetPath -Force
            } else {
                Write-Warn "$($f.Name) is a regular file, replacing with symlink (backup at $($f.Name).legacy)"
                Move-Item -LiteralPath $targetPath -Destination "$targetPath.legacy" -Force
            }
        }

        if ($useSymlink) {
            New-Item -ItemType SymbolicLink -Path $targetPath -Target $linkTarget | Out-Null
            Write-Info "$($f.Name) -> $linkTarget"
        } else {
            Copy-Item -LiteralPath $f.FullName -Destination $targetPath -Force
            Write-Info "$($f.Name) (copied)"
        }
        $count++
    }

    return $count
}

function Mirror-File {
    param([string]$Src, [string]$Dst, [string]$Label)
    if (-not (Test-Path $Src)) {
        Write-Warn "skip ${Label}: source missing ($Src)"
        return $false
    }
    Write-Info "${Label}: $Src"
    if ($DryRun) {
        Write-Info "[dry-run] would copy to $Dst"
        return $true
    }
    $dstDir = Split-Path -Parent $Dst
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
    Copy-Item -LiteralPath $Src -Destination $Dst -Force
    return $true
}

Write-Step "Maintain three-way symlinks (.codebuddy -> .cursor / .claude)"

$nRules    = Link-Set -SrcSubdir "rules"    -LinkDirRel ".cursor/rules"    -Filter "*.mdc" -Label "rules (.cursor/rules)"
$nCurCmds  = Link-Set -SrcSubdir "commands" -LinkDirRel ".cursor/commands" -Filter "*.md"  -Label "commands (.cursor/commands)"
$nAgents   = Link-Set -SrcSubdir "agents"   -LinkDirRel ".claude/agents"   -Filter "*.md"  -Label "agents (.claude/agents)"
$nClCmds   = Link-Set -SrcSubdir "commands" -LinkDirRel ".claude/commands" -Filter "*.md"  -Label "commands (.claude/commands)"

[void](Mirror-File `
    -Src (Join-Path $ProjectRoot ".claude/settings.json") `
    -Dst (Join-Path $ProjectRoot ".codebuddy/settings.json") `
    -Label "settings (cp)")

Write-Ok "Linked: $nRules rules / $nCurCmds cursor-cmds / $nAgents agents / $nClCmds claude-cmds  (+1 settings cp)"

if (-not $DryRun) {
    Write-Step "Verifying"
    $fail = 0

    $checks = @(
        @{ SrcSub = "rules";    Dst = ".cursor/rules";    Filter = "*.mdc"; Label = "rules" },
        @{ SrcSub = "commands"; Dst = ".cursor/commands"; Filter = "*.md";  Label = "cursor-cmds" },
        @{ SrcSub = "agents";   Dst = ".claude/agents";   Filter = "*.md";  Label = "agents" },
        @{ SrcSub = "commands"; Dst = ".claude/commands"; Filter = "*.md";  Label = "claude-cmds" }
    )
    foreach ($c in $checks) {
        $srcPath = Join-Path $ProjectRoot ".codebuddy/$($c.SrcSub)"
        $dstPath = Join-Path $ProjectRoot $c.Dst
        if (-not (Test-Path $srcPath)) { continue }
        $srcN = (Get-ChildItem -Path $srcPath -Filter $c.Filter -File).Count
        $dstN = (Get-ChildItem -Path $dstPath -Filter $c.Filter -Force).Count
        if ($srcN -eq $dstN) {
            Write-Ok "$($c.Label): $srcN source = $dstN entries"
        } else {
            Write-Err "$($c.Label) count mismatch: $srcN source vs $dstN entries"
            $fail++
        }
    }

    $clSettings = Join-Path $ProjectRoot ".claude/settings.json"
    $cbSettings = Join-Path $ProjectRoot ".codebuddy/settings.json"
    if (Test-Path $clSettings) {
        if ((Get-FileHash -LiteralPath $clSettings).Hash -eq (Get-FileHash -LiteralPath $cbSettings).Hash) {
            Write-Ok "settings: byte-identical"
        } else {
            Write-Err "settings: copy succeeded but contents differ"
            $fail++
        }
    }

    if ($fail -ne 0) { exit 2 }
}
