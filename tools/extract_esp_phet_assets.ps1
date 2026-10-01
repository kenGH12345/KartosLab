# Extract base64 images from PhET energy-skate-park *_png.ts / *_jpg.ts
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$srcRoot = Join-Path $repo "phet sourses\energy-skate-park-main\energy-skate-park-main\images"
$dstRoot = Join-Path $repo "assets\energy_skate_park"

function Extract-DataUrlFile {
    param([string]$FilePath, [string]$OutRelativeDir)
    $content = Get-Content -LiteralPath $FilePath -Raw -Encoding UTF8
    if ($content -match "data:image/(png|jpeg|jpg);base64,([^'\"]+)") {
        $ext = if ($matches[1] -eq 'png') { 'png' } else { 'jpg' }
        $baseName = [IO.Path]::GetFileNameWithoutExtension($FilePath)
        $baseName = $baseName -replace '_png$','' -replace '_jpg$','' -replace '_jpeg$',''
        $outName = "$baseName.$ext"
        $outDir = Join-Path $dstRoot $OutRelativeDir
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
        $bytes = [Convert]::FromBase64String($matches[2])
        $outPath = Join-Path $outDir $outName
        [IO.File]::WriteAllBytes($outPath, $bytes)
        return $outPath
    }
    return $null
}

$count = 0
Get-ChildItem -LiteralPath $srcRoot -Recurse -Include '*_png.ts','*_jpg.ts' | ForEach-Object {
    $rel = $_.DirectoryName.Substring($srcRoot.Length).TrimStart('\','/')
    $out = Extract-DataUrlFile -FilePath $_.FullName -OutRelativeDir $rel
    if ($out) { $count++; Write-Host "OK $out" }
}

# Root-level screen / scenery assets
Get-ChildItem -LiteralPath $srcRoot -File -Include '*_png.ts','*_jpg.ts' | ForEach-Object {
    $out = Extract-DataUrlFile -FilePath $_.FullName -OutRelativeDir ''
    if ($out) { $count++; Write-Host "OK $out" }
}

Write-Host "Extracted $count files to $dstRoot"
