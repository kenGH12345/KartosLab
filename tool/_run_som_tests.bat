@echo off
set "PROGRAMFILES(X86)=C:\Program Files (x86)"
cd /d d:\OneDrive\Desktop\KartosLab\KartosLab
flutter test test/states_of_matter --reporter compact
exit /b %ERRORLEVEL%
