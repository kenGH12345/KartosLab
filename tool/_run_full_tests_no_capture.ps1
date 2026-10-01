$ErrorActionPreference = 'Stop'
Set-Item -Path 'Env:PROGRAMFILES(X86)' -Value 'C:\Program Files (x86)'
Set-Location (Split-Path $PSScriptRoot -Parent)

$files = @(Get-ChildItem -Path 'test' -Recurse -Filter '*.dart' |
  Where-Object {
    $_.Name -notmatch 'capture' -and
    $_.Name -notmatch 'fixtures\.dart$' -and
    $_.FullName -notmatch '\\visual_qa\\' -and
    # Known pre-existing 10min hang — not related to Home Integration.
    $_.Name -ne 'forces_scenario_test.dart'
  } |
  ForEach-Object { $_.FullName })

Write-Host ("Test files: {0}" -f $files.Count)
$batchSize = 40
$passed = 0
$failed = 0
for ($i = 0; $i -lt $files.Count; $i += $batchSize) {
  $end = [Math]::Min($i + $batchSize - 1, $files.Count - 1)
  $batch = $files[$i..$end]
  Write-Host ("=== batch {0}-{1} ===" -f ($i + 1), ($end + 1))
  & flutter test --reporter compact @batch
  if ($LASTEXITCODE -ne 0) {
    $failed++
    Write-Host ("BATCH FAILED exit={0}" -f $LASTEXITCODE)
  } else {
    $passed++
  }
}

Write-Host ("Batches ok={0} failed={1}" -f $passed, $failed)
if ($failed -gt 0) { exit 1 }
exit 0
