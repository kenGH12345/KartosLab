# Phase 9 — Visual Fix

日期：2026-09-02

对照链：源码公式 → Flutter 等价语义 → 截图。  
**禁止**用 mean RGB、禁止为截图写死像素。

## P0 主坐标 / 主锚点

- 画布 = NineGrid center，模型坐标在 zoom=1 时等于 center 局部像素
- Zoom 绕画布中心 `[源码一致：ZoomAnimation 0.35s cubic-in-out]`
- [待确认：缺少原版运行视口截图，无法做 overlay/diff]

## P1 大块容器

- 背景 `#99c1ff` [源码一致 CCKCColors]
- 面板 `#f1f1f2` + stroke black + cornerRadius 6 + lineWidth 1.3 [源码一致]
- [有意差异] joist 底栏 → KARTOSLAB AppBar + NineGrid footer

## P2 局部布局

- 工具箱垂直、两页×8、每页以 Wire 开头 [源码一致 LabScreenView]
- [视觉近似] 边格窄，工具箱图标为压缩 glyph 而非 60×31 原图标位图铺满

## P3 Typography

- FONT_SIZE=14 [源码一致]
- 仪表精度 2 位 [源码一致]

## P4 Color / Gradient

- 导线 4-stop 渐变与 `WireNode.ts` colorStops 一致
- Reset `#F15A24`（工程 Reset 橙，对齐其它 sim；PhET ResetAllButton 默认橙）

## P5 Icon / Micro Geometry

- 焊点 r=11.2、顶点 hit r=16、高亮 r=30 lineWidth=5 [源码一致]
- AC 圆直径 54、正弦 `9*sin(x)` 采样 [源码一致]
- 火花 polyline 抄自 `FuseTripAnimation.ts` [源码一致]
- [视觉近似] 电容 3D 板、灯泡 filament 电荷路径用直线 `viewLength`

## 结论

**[视觉近似]** 不是「完全一模一样」。缺原版运行截图，未做 Rect overlay diff。
