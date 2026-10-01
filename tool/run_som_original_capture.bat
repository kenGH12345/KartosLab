@echo off
cd /d "%~dp0.."
node tool/capture_states_of_matter_original.js
exit /b %ERRORLEVEL%
