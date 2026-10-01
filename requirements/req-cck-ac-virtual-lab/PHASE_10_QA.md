# Phase 10 — Final QA

日期：2026-09-02

## 功能

- 单屏 Lab 可运行；工具箱两页元件可放入画布
- DC 回路求解、AC 源、C/L companion、保险丝熔断
- 电压表 / 串联安培计 / 简易时序图 / 时间控制 / Reset / Zoom / Lifelike-Schematic

## 行为

- 正常 / 开路开关 / 熔断 / reset / 暂停微步 / 再进入重新初始化：有测试覆盖

## 视觉

[视觉近似] 见 `visual-qa/PHASE_9.md` 与 `visual-qa/BASELINE.md`  
[待确认：缺少原版运行截图]

## 工程

`flutter analyze lib/cck_ac_virtual_lab lib/screens/home_screen.dart` → 0 issues

## 测试

- `flutter test test/cck_ac_virtual_lab` → 19 passed
- `flutter test test/widget_test.dart test/magnetism/magnet_home_nav_test.dart` → 9 passed（Home 回归）

## 构建

`flutter build apk --debug` → `build/app/outputs/flutter-apk/app-debug.apk`  
Gradle 提示未来 Kotlin plugin 迁移：工程既有警告，未改 android 工程。

Release 未强制构建（debug 已稳定）。
