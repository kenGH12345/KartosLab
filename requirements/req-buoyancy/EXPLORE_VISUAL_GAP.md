# Explore 屏 · 原版 vs 移植版差距清单

> 源码：`BuoyancyExploreScreenView.ts` / `BuoyancyExploreModel.ts` / `BuoyancyScreenView.ts`

## 本轮已落地

- [x] 完整控件树：Forces / Fluid / ABControls / Object Density / % Submerged / ModeRadio@Reset / Reset
- [x] DisplayProperties 接线（力箭头、Mass Values、Depth Lines）
- [x] 陆地秤 (−0.65) + 池内秤视觉 + poolScaleHeightControl
- [x] A/B 色标 + 材质/质量/体积控制；Fluid 含 Fluid A/B
- [x] FluidDensity ComboNumberControl 密度滑条
- [x] BlocksMode 原版 cuboid 图标
- [x] % Submerged 读数修正

## 非阻塞

- 秤真实测力精细化（接触力已接 LED 读数）
