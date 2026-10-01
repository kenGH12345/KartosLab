@echo off
rem Gate test run: excludes pendulum_visual_qa_capture_test.dart (screenshot
rem tool — its tests end in expected TimeoutException after writing PNGs,
rem see header comment in that file).
set "ProgramFiles(x86)=C:\Program Files (x86)"
cd /d D:\OneDrive\Desktop\KartosLab\KartosLab
flutter test test\pendulum_lab\pendulum_physics_test.dart test\pendulum_lab\pendulum_interaction_qa_test.dart test\pendulum_lab\pendulum_lab_widget_test.dart --reporter expanded
