# PHASE 0 — SCREENSHOT AUDIT · Resistance in a Wire

依据优先级：

1. **用户提供原版截图**（本会话 Visual Gold Standard · 最高优先级视觉依据）
2. 本地 source layout / 绘制常量
3. 官方 runtime（后续 Phase 视觉 QA 对照）

**原则**：禁止凭感觉估尺寸；常量 > 截图测量 > runtime。  
截图场景：**Default / Initial State** — `ρ = 0.50`，`L = 10.00`，`A = 7.50`，`R = 0.667 ohms`（与 `RangeWithValue` 默认一致）。

---

## 1. Viewport / Background

| 项 | 截图观察 | Source 依据 | 判定 |
|---|---|---|---|
| 画布比例 | 横屏宽幅 | `ResistanceInAWireScreenView` **未**覆盖 `layoutBounds` → Joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` = **1024×618**（项目内已验证；禁止再用 768×504） | Flutter play area 锁定 **1024×618** |
| 背景 | 淡奶油黄 | `BACKGROUND_COLOR: '#ffffdf'` | **必须** `#FFFFDF`（注意：Ohm's Law 为 `#FFFFE8`，勿混用） |
| PhET chrome | 截图不含 navbar | Joist 导航非 play area | KartosLab 壳；play area 对齐 layout bounds |

---

## 2. Scene — Formula（左上）

| 项 | 截图 | Source | 备注 |
|---|---|---|---|
| 内容 | `R = ρ L / A`（ρ、L 分子，A 分母；无显式 `×`） | `FormulaNode`：R / `=` / ρ / L / A + 分数线 | **禁止**自行加 `×` / `·` |
| R | 大、红、衬线 | `RED_COLOR #F22`；scale = `7/R0*R+1` | 默认 scaleMagnitude=8 |
| = | 黑、固定大号 | Times **90**，局部 centerX=100 | 布局锚点 |
| ρ | 大、蓝、衬线 | `BLUE_COLOR #0f0ffb`；分子左 | 默认 scale=8 |
| L | 大、蓝 | 分子右 | 默认 scale=8 |
| A | 蓝、分母 | 分数线下方 | 默认 scale=8；字形可能显得略小 |
| 分数线 | 粗黑水平线 | Path `(150,8)→(400,8)`，`lineWidth: 6` | |
| 垂直位置 | 上半区偏中 | `formulaNode.centerY = 190` | 硬编码，非比例公式 |
| 水平位置 | 左半区中心 | `centerX = controlPanel.left / 2` | 依赖面板宽度 |
| Outline | 截图上字母边缘清晰 | `OutlinedTextNode` outline=`#ffffdf`，width 0.2 | 防重叠时对比度丢失 |

---

## 3. Scene — Wire（左下）

| 项 | 截图 | Source |
|---|---|---|
| 形体 | 3D 圆柱透视（右端椭圆面） | `WireNode`：body Path + left ellipse end |
| 颜色 | 铜/棕渐变，中间偏亮 | LinearGradient `#8C4828 → #E8B282 → #FCF5EE → #F8E8D9 → #8C4828`；端盖 `#E8B282` |
| 长度 | 中等偏长 | `lengthToWidth(10)` ∈ [15,500] 线性映射 |
| 粗细 | 中等 | `areaToHeight(7.5)` |
| 杂质点 | 散布黑点，中等密度 | `DotsCanvasNode`；ρ=0.5 → 约一半可见点数量级 |
| 水平对齐 | 与公式水平居中对齐 | `wireNode.centerX = formulaNode.centerX` |
| 垂直 | 公式下方 | `centerY = formulaNode.centerY + 270` |
| 箭头 | 白底黑边，水平向右，在导线下方 | `ArrowNode`；y=`layoutBounds.bottom-47`；**尺寸固定** |

**物理核对（截图 ↔ 公式）**：`R = 0.50 * 10.00 / 7.50 = 0.666… → 显示 0.667` ✅ 与 `getFormattedResistanceValue`（<1 → 3 位）一致。

---

## 4. Controls — Panel（右侧）

| 项 | 截图 | Source |
|---|---|---|
| 容器 | 白底、黑边、圆角 | sun `Panel`；`lineWidth: 3`，`xMargin: 30`，`yMargin: 20` |
| 标题 | 红字 `resistance = 0.667 ohms` | `resistanceText`；pattern `{0} = {1} {2}`；单位 **`ohms`** |
| 左滑条 | 大蓝 `ρ` + “resistivity” + `0.50` + `Ωcm` | 默认 0.5；2 位小数；单位拼接 Ω+cm |
| 中滑条 | 大蓝 `L` + “length” + `10.00` + `cm` | 默认 10 |
| 右滑条 | 大蓝 `A` + “area” + `7.50` + `cm²` | 默认 7.5；RichText 上标 2 |
| 滑条几何 | 竖轨黑细线 + 灰矩形 thumb | track `4×200`；thumb `45×22`；fill `#c3c4c5` |
| 标签色 | 截图为蓝系 | source `NAME_FONT`/`SYMBOL_FONT` fill = `#0f0ffb`（VD-05：勿改成紫） |
| 位置 | 右上 | `right = reset.right`；`top = 40` |

---

## 5. Reset All

| 项 | 截图 | Source |
|---|---|---|
| 外观 | 橙圆 + 白环形箭头 | scenery-phet ResetAll；基色 `#F79722` |
| 半径 | 目测偏大 | **显式 `radius: 30`**（非默认 20.5；亦非 Ohm's Law 的 28） |
| 位置 | 右下，与面板右对齐 | `right = layoutBounds.right - 30`；`bottom = layoutBounds.bottom - 20` |

Flutter：**`KratosResetAllButton(onPressed: …, radius: 30)`** — 禁止 `Icons.refresh`。

---

## 6. Layering / Fonts / Colors

| 项 | 要求 |
|---|---|
| Layering（示意） | 背景 → Formula → Wire（body→end→dots）→ Arrow → ResetAll → ControlPanel（最上） |
| Formula 字体 | `Times New Roman`（`FONT_FAMILY`） |
| 控件标签 | Symbol 60pt Times；name 16；readout/unit 28 |
| R / 读数色 | `#F22` |
| ρ / L / A 色 | `#0f0ffb` |
| 禁止 | Material Icons、Emoji、网络图、营销 PNG 冒充 |

---

## 7. 截图 ↔ Source 一致性判定

| 检查项 | 结果 |
|---|---|
| 默认三变量 + R 读数 | **PASS**（0.50 / 10.00 / 7.50 / 0.667 ohms） |
| 单 screen · 无 Units radio | **PASS**（本 sim 无电流单位切换） |
| 公式结构 R=ρL/A | **PASS** |
| 导线 + 杂质点 + 固定箭头 | **PASS** |
| 三竖滑条 + 橙 Reset | **PASS** |
| 行为合同 | **以 source 为准**（声音 bins、小数位规则、layout 常量） |

**未在用户截图中验证、但 source 要求实现的项：**

- 键盘步进 / a11y PDOM  
- Marimba sonification  
- R 极大时字母盖住分数线 / Reset focus 黑描边  
- Preferences / Pan-Zoom / Dynamic Locale（1.7；MVP 可延后）

---

## 8. Visual QA 后续提示（非本阶段）

Phase 4 建议至少覆盖：

1. Default（本 Gold Standard）  
2. ρ → max（点最密；R 增大）  
3. L → min / A → max（短粗线；R 极小）  
4. L → max / A → min（细长线；R 极大；公式 R 盖层）  
5. Reset 回 Default  

杂质点：**固定 seed**（VD-03）。

---

*Screenshot Audit complete. Visual Gold Standard locked to user-provided default frame.*
