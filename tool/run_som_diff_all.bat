@echo off
setlocal
cd /d "%~dp0.."
set ORIG=requirements\req-states-of-matter\visual-qa\ORIGINAL
set FLUT=requirements\req-states-of-matter\visual-qa\FLUTTER
set DIFF=requirements\req-states-of-matter\visual-qa\DIFF
if not exist "%DIFF%" mkdir "%DIFF%"
set OUT=requirements\req-states-of-matter\visual-qa\diff_stats.jsonl
del /q "%OUT%" 2>nul
for %%F in (
  01_States_neon_solid_initial
  02_States_neon_liquid
  03_States_neon_gas
  04_States_argon_solid
  05_States_oxygen_solid
  06_States_water_solid
  07_States_heated
  08_States_paused
  09_States_reset
  10_PhaseChanges_initial
  11_PhaseChanges_compressed
  12_PhaseChanges_adjustable
  13_Interaction_neon_initial
  14_Interaction_forces_total
  15_Interaction_reset
) do (
  echo Diffing %%F ...
  python tool\diff_visual_qa.py "%ORIG%\%%F.png" "%FLUT%\%%F.png" "%DIFF%\%%F_diff.png" >> "%OUT%"
)
echo Wrote %OUT%
exit /b 0
