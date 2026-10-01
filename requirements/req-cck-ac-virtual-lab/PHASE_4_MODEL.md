# Phase 4 — Model / State

日期：2026-09-02  
状态：完成，自动进入 Phase 5

## 完成了什么

- `CckCircuit` 拓扑、库存、SNAP 合并、reset
- MNA QR + LTA companion（电容/电感 trapezoidal）
- `CckAcController.tick`：播放 `1/60`，暂停 `PAUSED_DT=1e-6`，`dt>=0.5` 丢弃
- AC：`V = -Vmax * sin(2π f t + phase°·π/180)`
- 保险丝：`R=0.06/rating`，`|I|>rating+1e-6` 立即熔断
- 导线：`R=ρL/A`，`L_m=viewPx*0.0005`
- `CckRenderData` 为只读 DTO；亮度在 builder 计算一次

## 测试

`flutter test test/cck_ac_virtual_lab` 中模型/求解器用例通过（含 PhET QUnit 4V/2Ω、RC 充电、snap、reset）。

## analyze

`flutter analyze lib/cck_ac_virtual_lab`：0 issues（本阶段结束时）

## blocked

无

## 视觉状态

本阶段无视觉。[待确认：缺少原版运行截图]

## 下一阶段

Phase 5 Static Render
