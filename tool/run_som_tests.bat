@echo off
set "PROGRAMFILES(X86)=C:\Program Files (x86)"
cd /d D:\OneDrive\Desktop\KartosLab\KartosLab
echo === TESTS ===
flutter test test/states_of_matter test/chemistry/states_of_matter/som_home_nav_test.dart
echo TEST_EXIT=%ERRORLEVEL%
echo === ANALYZE ===
flutter analyze lib/chemistry/states_of_matter test/states_of_matter test/chemistry/states_of_matter
echo ANALYZE_EXIT=%ERRORLEVEL%
