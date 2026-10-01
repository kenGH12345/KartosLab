@echo off
set "PROGRAMFILES(X86)=C:\Program Files (x86)"
cd /d "%~dp0.."
echo === flutter test (full project) ===
flutter test --reporter compact
set TEST_EXIT=%ERRORLEVEL%
echo === flutter analyze ===
flutter analyze
set ANALYZE_EXIT=%ERRORLEVEL%
exit /b %TEST_EXIT%
