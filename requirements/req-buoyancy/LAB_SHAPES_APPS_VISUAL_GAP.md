# Lab / Shapes / Applications · 对齐状态（2026-10-01）

## Lab / Shapes / Applications 控件树

均已对齐原版 AlignBox 树（Forces / FluidDensity / 右侧面板 / 秤 / Reset）。

## P1 残留 · 已关闭

- [x] FluidDensity ComboNumberControl 密度滑条（kg/L 0.5–15 → custom）
- [x] ShapesInfoDialog 原文案（`shapesInfoDialog` EN）
- [x] resetBoat 使用原版 `resetArrow.png`
- [x] BlocksMode 使用原版 single/double cuboid 图标
- [x] % Submerged 读数（0–100，不再 ×100）
- [x] 秤 LED 读数条视觉细化
- [x] 并入 KartosLab Home（`密度与浮力` → 浮力）+ `BuoyancyModule` 注册
- [x] PoolScaleHeightControl 锚在池外（`maxX + MARGIN_SMALL`，五屏）
- [x] Lab Fluid Displaced 烧杯 + `fluid_displaced_scale_icon.png`
- [x] Shapes Object Density / % Submerged 展开裁切
- [x] Applications 瓶横躺半透 + 船铝灰（非全黑）

## 已知非阻塞

- 瓶/船：源网格 + 实体/半透着色；未接 BottleView clip-plane / Phong 多层 / 独立红盖
- Fluid Displaced 以外部分 overlay 读数仍可能需交互或局部 ticker 刷新

## 报告

详见 `P1_VISUAL_POLISH_CLOSURE_REPORT.md`。
