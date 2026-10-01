@echo off
set "ProgramFiles(x86)=C:\Program Files (x86)"
cd /d D:\OneDrive\Desktop\KartosLab\KartosLab
flutter test test\pendulum_lab\pendulum_physics_test.dart --reporter expanded
flutter analyze lib\pendulum_lab test\pendulum_lab
