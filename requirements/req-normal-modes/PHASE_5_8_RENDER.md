# Phase 5–8 — Render / Interaction / Animation / Screen

> 日期：2026-09-03

## 目录

`lib/normal_modes/` 按 ARCHITECTURE_PLAN 落地。Home：`KratosTabbedScreen` 持有两个 Controller。NineGrid center = 1024×618 ScreenView。

## 交互（均有源码依据）

拖质量 / 振幅相位滑条 / 轴向 radio / N slider（2D 显示 n²）/ Show Springs / Show Phases / Initial / Zero / Play-Pause-Step-Speed / Reset / 2D 格子 toggle / Spectrum collapse 保留 frequency Text（`skipOffstage: false` 测试）

## 动画

Ticker 墙钟 dt → Model.step。非拖拽解析叠加，拖拽 Verlet。不用 AnimationController 驱动位置。

## 布局 [有意差异]

边格太窄，面板叠在 center 局部坐标内（对齐 PhET 单 ScreenView）。KARTOSLAB AppBar+Tab 为外壳。

**状态：进入 Phase 9。**
