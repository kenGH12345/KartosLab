# Phase 8 · Visual / Screen Integration

> 完成：2026-09-04 · 源码 `1.3.0-dev.0`  
> **未改**：Canonical / Transform / SnapPolicy / InteractionController / Angle 方向（sweep=−θ）

---

## 0. 结论摘要

| 项 | 标记 |
|---|---|
| EquationsResultant ≠ SumVector | [源码一致][行为一致] |
| Coefficient −5…5 default 1；NumberPicker（非 Dropdown） | [源码一致][行为一致] |
| Cartesian / Polar Equations scenes（a,b,c / d,e,f） | [源码一致][行为一致] |
| Base xy / mag·θ → Model → xy×coeff → RenderData | [数学一致][行为一致] |
| 四屏布局锚点相对 layout（非截图像素写死） | [视觉近似] |
| Arrow / angle 方向未改 | [源码一致] |
| Eraser 自定义几何（非 Material Icon） | [视觉近似] |
| Base Vectors NumberPicker 精修 / unsigned angle wrap | [待实现] 可续 Phase 9 |
| 像素级 typography 对齐 ref | [视觉近似][有意差异] |

测试：**88 passed** · analyze：**0 issues**

---

## 1. 四屏布局核对（相对锚点）

对照 `visual-qa/ref/screen{1..4}_*.png` 结构清单（BASELINE §2），Flutter 使用 `VaLayoutAnchors`：

| 区域 | Explore1D | Explore2D | Lab | Equations |
|---|---|---|---|---|
| Graph | ✅ 1D 取向 | ✅ + origin | ✅ 双 set | ✅ bottomLeft+40 |
| Values accordion | ✅ | ✅ | ✅ | ✅ |
| Control panel | 无 Angles/Components | ✅ | ✅ | ✅ + Base Vectors |
| Toolbox | 3 slots | 3 | **u/v**（≠ Explore） | **无** |
| Eraser | ✅ | ✅ | ✅ | **无** |
| Scene radio | H/V | C/P | C/P | C/P |
| Equation bar | — | — | — | coeff pickers + types |

截图：`visual-qa/flutter/screen{1..4}_final.png`

---

## 2. Equations（本阶段重点）

### Coefficient
| | 源码 | Flutter |
|---|---|---|
| 类型 | Integer | `int` |
| 范围 | −5…5 | 同 |
| 默认 | 1 | 同 |
| UI | NumberPicker up/down | `VaNumberPicker` |
| 更新 | `xy = base × coeff` → Resultant | 同；仍 `EquationsResultant` |

### Polar / Cartesian
| Scene | Vectors | Resultant | Snap | Palette |
|---|---|---|---|---|
| Cartesian | a,b | c | cartesian | blue/black |
| Polar | d,e | f | polar | pink/black |

Base pickers：Cartesian `x,y` ∈ [−10,10]；Polar `|v|` ∈ [−10,10]，`θ` ∈ [−180,180] step **5°**.

### Equation types
- `c = a+b` / `c = a−b` / `a+b+c=0` → `EquationsResultant`（**非** SumVector）

---

## 3. Visual QA 记录（归一化）

不以 mean RGB；结构对比：

| Screen | graph/controls/toolbox | 判定 |
|---|---|---|
| 1 Explore1D | 结构对齐；1D 无 angles | [视觉近似] |
| 2 Explore2D | origin + components | [视觉近似] |
| 3 Lab | u/v toolbox ≠ Explore2D | [行为一致][视觉近似] |
| 4 Equations | equation + pickers | [行为一致][视觉近似] |

delta：未用截图像素 offset 调布局；间距差异记为 **[有意差异]**（Flutter Material chips vs PhET radio）。

---

## 4. 自动进入 Phase 9

无 common / Navigation / Theme 修改；Equations 核心逻辑已确认 → **Phase 9 Final QA**
