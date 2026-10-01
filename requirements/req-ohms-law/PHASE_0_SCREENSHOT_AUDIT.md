# PHASE 0 — SCREENSHOT AUDIT · Ohm's Law

依据优先级：

1. **用户提供原版截图**（本会话 Visual Gold Standard · 最高优先级视觉依据）
2. 本地 source layout / 绘制常量
3. 官方 runtime（后续 Phase 视觉 QA 对照）

**原则**：禁止凭感觉估尺寸；常量 > 截图测量 > runtime。  
截图场景：**Default / Initial State** — `V = 4.5 V`，`R = 500 Ω`，`I = 9.0 mA`（与 `RangeWithValue` 默认一致）。

---

## 1. Viewport / Background

| 项 | 截图观察 | Source 依据 | 判定 |
|---|---|---|---|
| 画布比例 | 横屏宽幅 | `OhmsLawScreenView` **未**覆盖 `layoutBounds` → 继承 Joist `ScreenView` 默认；同类 classic sim（Friction）为 **768×504**；本地无 `joist` 树，记为 **暂定 768×504**（VD-01） | Flutter play area 锁定 source layout |
| 背景 | 淡奶油黄 | `new Color( '#ffffe8' )` | **必须** `#FFFFE8` |
| PhET chrome | 截图可能含/不含 navbar | Joist 导航非 play area | KartosLab 壳；play area 对齐 layout bounds |

---

## 2. Scene — Formula（左上）

| 项 | 截图 | Source | 备注 |
|---|---|---|---|
| 内容 | `V = I R`（无显式 `·` 乘号） | `FormulaNode`：仅 V / `=` / I / R 四个 Text | **禁止**自行加 `×` / `·` |
| V | 大、蓝、衬线 | `BLUE_COLOR` + Times；scale = `16*normV + 4` | 默认 normV≈0.494 → scale≈11.9 |
| = | 黑、固定大号 | font size **140**，centerX=300 | 布局锚点 |
| I | **很小**、橙 | `PhetColorScheme.RED_COLORBLIND`；scale = `150*normI + 1` | 默认 I=9 mA → scale≈2.5 |
| R | 大、蓝、衬线 | 同 V 的 OTHERS_SCALE | 默认与 V 接近 |
| 垂直位置 | 上半区 | `formulaNode.centerY = layoutBounds.bottom / 4.75` | |

---

## 3. Scene — Circuit / WireBox（左下）

| 项 | 截图 | Source |
|---|---|---|
| 线框 | 粗黑矩形环 | `WIRE_WIDTH=505`，`WIRE_HEIGHT=165`，`lineWidth=10`，corner 4 |
| 电池 | **3** 节可见，各标 `1.5 V` | `AA_VOLTAGE=1.5`；`ceil(4.5/1.5)=3` 可见；`MAX=6` |
| 电池朝向 | 正极朝右（金/铜端在右） | `BatteryView` 注释：positive pole right |
| 电阻 | 底边中间粉红/红圆柱 + 黑点 | `ResistorNode`；点数 ∝ R |
| 电流读数 | `current = 9.0 mA`，橙字 | `ReadoutPanel`；默认单位 mA |
| 箭头 | 底边左右两枚橙色直角箭头 | `RightAngleArrow`；方向示意顺时针（常规电流） |
| 水平对齐 | 与公式水平居中对齐 | `wireBox.centerX = formulaNode.centerX` |
| 底边距 | 贴底 | `wireBox.bottom = layoutBounds.bottom - 30` |

**物理核对（截图 ↔ 公式）**：`I = 1000 * V / R = 1000 * 4.5 / 500 = 9.0 mA` ✅ 与 source `computeCurrent` 一致。

---

## 4. Controls — Panel（右侧）

| 项 | 截图 | Source |
|---|---|---|
| 容器 | 白底、黑边、圆角 | `ControlPanel` → sun `Panel`；`lineWidth: 3`，`xMargin: 30`，`yMargin: 10` |
| 左滑条 | 大蓝 `V` + “voltage” + 灰 thumb + `4.5 V` | `SliderUnit` + `VOLTAGE_RANGE` 默认 4.5；1 位小数 |
| 右滑条 | 大蓝 `R` + “resistance” + `500 Ω` | 默认 500；0 位小数；Ω 来自 SceneryPhetFluent |
| 滑条几何 | 竖轨黑细线 + 灰矩形 thumb | track `4×210`；thumb `45×22`；fill `#c3c4c5` |
| 位置 | 右上 | `right = width - 50`；`top = top + 20` |

---

## 5. Controls — Units（源码有 · 截图未见）

| 项 | 截图 | Source |
|---|---|---|
| Units 标题 + mA/A radio | **用户 Gold Standard 截图中不可见** | `UnitsRadioButtonContainer`：`left = controlPanel.left`，`centerY = wireBox.centerY + 4` |
| 默认 | — | `CurrentUnit.MILLIAMPS` |

**判定（VD-02）**：1.5 release notes 新增 Units；截图可能来自 pre-1.5 或裁切。  
**行为以本地 1.5.0-dev.6 source 为准必须实现 Units**；视觉位置以 source layout 为准，再用 runtime 补截图对齐。

---

## 6. Reset All

| 项 | 截图 | Source |
|---|---|---|
| 外观 | 橙圆 + 白环形箭头 | scenery-phet ResetAll；基色 `#F79722` |
| 半径 | 目测偏大 | **显式 `radius: 28`**（非默认 20.8） |
| 位置 | 右下 | `right = controlPanel.right`；`bottom = layoutBounds.bottom - 20` |

Flutter：**`KratosResetAllButton(onPressed: …, radius: 28)`** — 禁止 `Icons.refresh`。

---

## 7. Layering / Fonts / Colors

| 项 | 要求 |
|---|---|
| Layering（示意） | 背景 → Formula → WireBox（线框→电池→电阻→箭头→读数）→ ControlPanel → Units → ResetAll |
| Formula 字体 | `Times New Roman`（`FONT_FAMILY`） |
| 控件标签 | Slider symbol 60pt Times；name 16；readout/unit 28 |
| I / 电流色 | `#FF5500`（RED_COLORBLIND） |
| V / R 色 | `rgb(0,0,225)` |
| 禁止 | Material Icons、Emoji、网络图冒充 |

---

## 8. Phase 视觉矩阵预登记（本阶段不拍 Flutter 图）

| ID | 状态 | 目的 |
|---|---|---|
| S0 | Default 4.5 V / 500 Ω | Gold Standard 对齐 |
| S1 | V min 0.1 / R max 1000 | 最小电流、I 字母极小、1 节短电池、密点 |
| S2 | V max 9 / R min 10 | 最大电流、I 巨大、6 节电池、箭头大 |
| S3 | Units = A | 读数单位与小数位 |
| S4 | Reset after dirty | 回到 S0；Units **不**回退（见 Model reset） |

---

## 9. Screenshot Audit Gate

| 条件 | 状态 |
|---|---|
| Default 态与 source 默认 Property 一致 | ✅ |
| 背景色锁定 | ✅ `#FFFFE8` |
| Formula / Circuit / Sliders / Reset 要素齐全 | ✅ |
| Units UI 截图缺口已记录 | ✅ VD-02 |
| 未凭截图发明乘号/电池 PNG/Material icon | ✅ |
