# Phase 4 — Model / State

> 日期：2026-09-03  
> 测试：`flutter test test/normal_modes` 中模型/动画/MVT 用例全部通过

## SSOT

`OneDimensionModel` / `TwoDimensionsModel` 为唯一业务状态。Solver 为纯函数。Painter 不计算 ω。

## 公式（对照源码）

- 1D ω、叠加、Verlet、分解：[源码一致]
- 2D ω=hypot、Y 减号、sineProduct、maxAmplitude=0.3·2/(N+1)：[源码一致]
- Clock：墙钟 dt clamp 0.15，累积 FIXED_DT=1/60，slow×0.2：[源码一致]

## 测试覆盖

默认态 / N 边界 / 频率标签 0.77/1.41/1.85ω₀ / 往返分解 / Verlet 被拖质量 / 2D Y 符号 / toggle 格子 / reset

**状态：自动进入 Phase 5–8（静态渲染 + 交互 + 动画 + 屏集成已一并落地）。**
