# Phase 2 / Visual QA — BASELINE · Collision Lab

> 更新日期：2026-09-03（P0 clipping + Grid drag 修复后）  
> 源码：`1.2.0-dev.0`

---

## 1. 问题分类与修复

| 问题 | 分类 | 修复 |
|---|---|---|
| 球越过边框后才消失 | **[迁移引入：Render clipping bug]** | `BallPainter`：`canvas.clipRect(playAreaRect)`，对齐 PhET `BallNode` `clipArea` |
| Grid ON 无法拖球 | **[迁移引入：Hit-test / interaction bug]** | `Listener` 手势层 + 视图空间 hit-test；ScaleBar/文字 `IgnorePointer`；grid 不消费 pointer |

**未改** CollisionEngine / 弹性 / Inelastic / 负步进 / mass-radius。

---

## 2. 截图资产

### PhET 参考（源码包）

`visual-qa/ref/screen{1..4}_*.png`

### Flutter（修复后）

| 文件 | 内容 |
|---|---|
| `flutter/flutter_intro_playarea.png` | Intro 默认 |
| `flutter/flutter_explore1d_playarea.png` | Explore 1D |
| `flutter/flutter_explore2d_playarea.png` | Explore 2D + grid + v |
| `flutter/flutter_inelastic_playarea.png` | Inelastic |
| `flutter/flutter_qa_A_near_edge.png` | A 球近右边界 |
| `flutter/flutter_qa_B_partial_outside.png` | B 中心在界外 · 应部分裁剪 |
| `flutter/flutter_qa_C_grid_on.png` | C Grid ON 拖拽吸附位 |
| `flutter/flutter_qa_D_grid_off.png` | D Grid OFF 拖拽位 |

**[待确认]** 本机浏览器 runtime 全页 overlay（仍缺）；当前用 assets + Flutter capture。

---

## 3. Clipping 语义（源码）

`BallNode.js`：球圆 + 标签包在 `clipArea: Shape.bounds(playAreaViewBounds)`。  
向量 / NumberDisplay **不**裁剪。  
`PlayAreaNode` border `dilated(lineWidth/2)`，描边跨在 clip 边两侧。

Flutter：

1. bg + grid  
2. balls(+paths+COM) **clipRect(playAreaRect)**  
3. border inflate(stroke/2) 叠在上层  
4. vectors / tip 不 clip  

---

## 4. Drag + Grid（源码）

`Ball.dragToPosition`：**每次 drag move** 若 `gridVisible` → snap 到 `MINOR_GRIDLINE_SPACING`（0.1）。  
Grid 不拦截 pointer；snap ≠ 禁止 drag start。
