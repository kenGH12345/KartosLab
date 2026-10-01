@echo off
set "ProgramFiles(x86)=C:\Program Files (x86)"
cd /d D:\OneDrive\Desktop\KartosLab\KartosLab
echo === States of Matter FLUTTER Visual QA capture ===
flutter test test\chemistry\states_of_matter\states_of_matter_visual_qa_capture_test.dart --reporter expanded
exit /b %ERRORLEVEL%
