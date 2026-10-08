# PHASE 8 — real Android (adb) Chinese runtime evidence
$ErrorActionPreference = 'Continue'
$sdk = "$env:LOCALAPPDATA\Android\sdk"
$env:Path = "$sdk\platform-tools;$sdk\emulator;$env:Path"
$dev = 'emulator-5554'
$pkg = 'com.demo.kratos'
$out = 'requirements/localization/android_evidence'
New-Item -ItemType Directory -Force -Path $out | Out-Null

function Cap($name) {
  adb -s $dev shell screencap -p "/sdcard/$name.png" | Out-Null
  adb -s $dev pull "/sdcard/$name.png" "$out/$name.png" 2>$null | Out-Null
  $len = (Get-Item "$out/$name.png").Length
  Write-Host "CAP $name bytes=$len"
}

function DumpUi() {
  adb -s $dev shell uiautomator dump /sdcard/uidump.xml | Out-Null
  adb -s $dev pull /sdcard/uidump.xml "$out/uidump.xml" 2>$null | Out-Null
  Get-Content "$out/uidump.xml" -Raw -Encoding UTF8
}

function FindCenter([string]$xml, [string]$text) {
  # bounds="[x1,y1][x2,y2]" near text=
  $pat = [regex]::Escape($text)
  $m = [regex]::Match($xml, "text=`"$pat`"[^>]*bounds=`"\[(\d+),(\d+)\]\[(\d+),(\d+)\]`"")
  if (-not $m.Success) {
    $m = [regex]::Match($xml, "bounds=`"\[(\d+),(\d+)\]\[(\d+),(\d+)\]`"[^>]*text=`"$pat`"")
  }
  if (-not $m.Success) { return $null }
  $x1 = [int]$m.Groups[1].Value; $y1 = [int]$m.Groups[2].Value
  $x2 = [int]$m.Groups[3].Value; $y2 = [int]$m.Groups[4].Value
  return @{ x = [int](($x1 + $x2) / 2); y = [int](($y1 + $y2) / 2) }
}

function TapText([string]$text) {
  $xml = DumpUi
  $c = FindCenter $xml $text
  if ($null -eq $c) {
    Write-Host "MISS $text — swipe and retry"
    adb -s $dev shell input swipe 1280 1200 1280 400 400 | Out-Null
    Start-Sleep -Milliseconds 600
    $xml = DumpUi
    $c = FindCenter $xml $text
  }
  if ($null -eq $c) {
    Write-Host "FAIL find $text"
    return $false
  }
  Write-Host "TAP $text @ $($c.x),$($c.y)"
  adb -s $dev shell input tap $c.x $c.y | Out-Null
  Start-Sleep -Seconds 2
  return $true
}

function Back() {
  adb -s $dev shell input keyevent 4 | Out-Null
  Start-Sleep -Seconds 1
}

# Restart app
adb -s $dev shell am force-stop $pkg | Out-Null
adb -s $dev shell monkey -p $pkg -c android.intent.category.LAUNCHER 1 | Out-Null
Start-Sleep -Seconds 4
Cap '01_home'

# Lifecycle: background / resume
adb -s $dev shell input keyevent 3 | Out-Null  # HOME
Start-Sleep -Seconds 2
adb -s $dev shell monkey -p $pkg -c android.intent.category.LAUNCHER 1 | Out-Null
Start-Sleep -Seconds 3
Cap '02_home_after_resume'

# Domain path samples
$sims = @(
  @{ id = 'collision-lab'; title = '碰撞实验室' },
  @{ id = 'buoyancy'; title = '浮力' },
  @{ id = 'circuit'; title = '电路搭建' },
  @{ id = 'gas-properties'; title = '气体性质' },
  @{ id = 'quantum-measurement'; title = '量子测量' },
  @{ id = 'molarity'; title = '摩尔浓度' },
  @{ id = 'ph-scale'; title = 'pH 标度' },
  @{ id = 'states-of-matter'; title = '物质的状态' },
  @{ id = 'balancing-chemical-equations'; title = '化学方程式配平' },
  @{ id = 'acid-base-solutions'; title = '酸碱溶液' },
  @{ id = 'fourier-making-waves'; title = '傅里叶：合成波' },
  @{ id = 'cck-ac-virtual-lab'; title = '交流虚拟实验室' }
)

$results = @()
foreach ($s in $sims) {
  adb -s $dev shell am force-stop $pkg | Out-Null
  adb -s $dev shell monkey -p $pkg -c android.intent.category.LAUNCHER 1 | Out-Null
  Start-Sleep -Seconds 3
  # scroll from top
  for ($i = 0; $i -lt 8; $i++) {
    $ok = TapText $s.title
    if ($ok) { break }
  }
  if (-not $ok) {
    $results += "$($s.id)=ENTRY_FAIL"
    continue
  }
  Cap ("10_$($s.id)_enter")
  # drag gesture in center
  adb -s $dev shell input swipe 900 700 1100 850 350 | Out-Null
  Start-Sleep -Milliseconds 800
  Cap ("11_$($s.id)_drag")
  # try tap reset-ish area bottom-right (best effort)
  adb -s $dev shell input tap 2400 1400 | Out-Null
  Start-Sleep -Milliseconds 600
  Cap ("12_$($s.id)_after_interact")
  Back
  Start-Sleep -Seconds 1
  Cap ("13_$($s.id)_back_home")
  $results += "$($s.id)=OK"
}

# Crash check
$crashes = adb -s $dev logcat -d -t 200 *:E 2>$null | Select-String -Pattern 'FATAL|AndroidRuntime|com.demo.kratos' | Select-Object -Last 20
$crashes | Out-File "$out/logcat_errors.txt" -Encoding utf8
$results | Out-File "$out/adb_path_results.txt" -Encoding utf8
Write-Host "RESULTS:"
$results | ForEach-Object { Write-Host $_ }
Write-Host "DONE"
