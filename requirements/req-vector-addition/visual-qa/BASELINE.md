# Phase 2 — Visual Baseline · Vector Addition

> 需求：`req-vector-addition`  
> 日期：2026-09-04  
> 本地源：`1.3.0-dev.0`  
> 标记：`[已确认]` / `[推测]` / `[待确认]`

---

## 0. 结论摘要

1. 四屏参考截图已从本地 `assets/` 复制到 `visual-qa/ref/`。[已确认]
2. 布局锚点以 `SOURCE_ANALYSIS.md` §11 为准（相对 `layoutBounds` / `graph.viewBounds`），**不为截图写死 pixel**。[已确认]
3. 视觉验收：**不以 mean RGB 为唯一指标**；对照结构（图区、右面板、toolbox、sum/components、箭头几何）。[工程约束]
4. **[待确认]** 本机浏览器 runtime 全页截图尚未采集；当前基线 = 源码包官方截图。

---

## 1. 参考截图清单

| 文件 | Screen | 来源 |
|---|---|---|
| `ref/screen1_explore1d.png` | Explore 1D | `assets/vector-addition-screenshot-screen1.png` |
| `ref/screen2_explore2d.png` | Explore 2D | `assets/...-screen2.png` |
| `ref/screen3_lab.png` | Lab | `assets/...-screen3.png` |
| `ref/screen4_equations.png` | Equations | `assets/...-screen4.png` |
| `ref/overview.png` | 总览 | `assets/vector-addition-screenshot.png` |

---

## 2. 每屏视觉结构清单（对照用）

### Explore 1D
- 居中偏左：Graph（1D 水平或垂直 scene）
- 上中：Vector Values accordion
- 左下：Vector toolbox（a/b/c 或 d/e/f）
- 右上：Graph control（Values / Sum / Grid…；无 Angles / Components）
- 右下：Horizontal/Vertical scene radio + Reset All
- 图下方：Eraser

### Explore 2D（原型屏）
- Graph + origin manipulator
- 右上：Components radio（invisible/triangle/parallelogram/projection）+ Values/Angles/Sum/Grid
- 右下：Cartesian/Polar radio + Reset
- 左下：Toolbox
- 上中：Vector Values

### Lab
- 双 vector set / 双色 / 双 Sum
- Toolbox 每 set 一槽（可拖出最多 10 条）
- 其余类似 Explore 2D

### Equations
- 无 Toolbox / 无 Eraser
- 方程类型 radio + 系数/基向量 NumberPicker / Base Vectors accordion
- Resultant 恒可见于方程语义（Sum checkbox 语义见源码 Equations ViewProperties）
- Graph bottomLeft 下移 +40 view units

---

## 3. 颜色基线（源码默认 profile · 非 mean RGB）`[已确认 VectorAdditionColors.ts]`

| Token | Default |
|---|---|
| screenBackground | `#e5f7fe` |
| graphBackground | white |
| graphMajorLine | gray(212) |
| graphMinorLine | gray(225) |
| graphTickLine | black |
| graphTickLabel | gray(130) |
| panelStroke | gray(139) |
| origin | gray(150) |
| 共享蓝向量 / sum | `rgb(64,150,242)` / `#0a46fa` |
| 共享粉向量 / sum | `#f149ff` / `#a200de` |

分屏色板（Explore1D H/V、Explore2D C/P、Lab×4、Equations C/P）实现时整表移植到 `vector_addition_colors.dart`。

---

## 5. Flutter 捕获（Phase 8）

| 文件 | 说明 |
|---|---|
| `flutter/screen1_final.png` … `screen4_final.png` | 默认态最终捕获 |
| `flutter/screen1.png` … `screen4.png` | 同批中间产物 |

对照原则：结构清单 §2 + 相对锚点；**不为截图写死 pixel**。判定标签见 `PHASE_8_VISUAL.md`。

| 参数 | 值 |
|---|---|
| headWidth | 12 |
| headHeight | 14 |
| tailWidth | 3.5 |
| isHeadDynamic | true |
| fractionalHeadHeight | 0.5 |
| component dash | [6, 3], tailWidth 3 |

---

## 5. Graph 几何基线

| 项 | 值 |
|---|---|
| Model bounds（默认） | (-5,-5)-(45,25) |
| Scale | 14.5 view-units / model-unit |
| View size | 725 × 435 |
| Y | model ↑ · view ↓ · inverted mapping |
| Major/Minor | 5 / 1 model units |

---

## 6. Phase 2 完成标准

- [x] 四屏 ref 截图就位
- [x] 结构清单与 SOURCE_ANALYSIS 锚点对齐
- [x] Flutter baseline `visual-qa/flutter/screen{1..4}.png`（Phase 5）
- [ ] 3 视口回归截图（375 / 1024 / 1920）—— 后续
- [ ] 本机 runtime overlay（可选）

### Flutter ↔ Ref 映射（Phase 5）

| Flutter | Ref | 备注 |
|---|---|---|
| screen1.png | screen1_explore1d.png | 默认空图+toolbox |
| screen2.png | screen2_explore2d.png | 默认空图+toolbox |
| screen3.png | screen3_lab.png | 双 set toolbox u/v |
| screen4.png | screen4_equations.png | a,b + resultant c |

---

*Phase 2 · 更新 2026-09-04 Phase 5*
