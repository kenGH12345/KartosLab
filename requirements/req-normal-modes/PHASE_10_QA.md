# Phase 10 — Final QA

> 日期：2026-09-03

## flutter analyze

`flutter analyze lib/normal_modes lib/screens/home_screen.dart test/normal_modes` → **No issues found**

全工程 analyze 若有既有问题：**只记录不修**。

## 测试

`flutter test test/normal_modes` → **45 passed**（模型 / MVT / 动画 / Home 进出 / Tab / Spectrum collapse 保 label / Reset）

未删除任何 screenshot 测试（本 sim 无 golden 文件；缺原版实拍故未强上 toImage golden）。

## 构建

见 COMPLETION_REPORT 构建节。

## 分类问题

| 项 | 类 |
|---|---|
| 无原版运行截图 | 5 证据不足 |
| 系统字体 vs PhetFont | 有意差异 |
| SimulationClock vs 墙钟 dt | 3 既有 common，本 sim 未改 API |
| 无 PNG 资源 | 4 原版即矢量，非缺失 |
