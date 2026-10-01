@echo off
set "PROGRAMFILES(X86)=C:\Program Files (x86)"
cd /d d:\OneDrive\Desktop\KartosLab\KartosLab
flutter analyze lib/chemistry/states_of_matter test/states_of_matter
exit /b %ERRORLEVEL%
