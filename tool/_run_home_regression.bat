@echo off
REM Full-project regression for Home Integration, excluding Visual QA capture /
REM screenshot harnesses that intentionally timeout under compact CI load.
set "PROGRAMFILES(X86)=C:\Program Files (x86)"
cd /d "%~dp0.."

echo === flutter analyze (Home + SoM) ===
flutter analyze lib/screens/home_screen.dart lib/chemistry/states_of_matter test/chemistry/states_of_matter test/states_of_matter
if errorlevel 1 exit /b 1

echo === flutter test (exclude *capture*) ===
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_run_full_tests_no_capture.ps1"
exit /b %ERRORLEVEL%
