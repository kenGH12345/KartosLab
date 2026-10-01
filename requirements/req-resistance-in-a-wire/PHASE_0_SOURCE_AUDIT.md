# PHASE 0 — SOURCE AUDIT / MODEL-CONTRACT / VIEW-CONTRACT / PRODUCT-UX BASELINE

**Sim：** Resistance in a Wire  
**本地基准：** `phet sourses/resistance-in-a-wire-main/resistance-in-a-wire-main`  
**入口：** `js/resistance-in-a-wire-main.ts`  
**package.json 版本：** `1.8.0-dev.0`  
**dependencies.json 注释：** `# resistance-in-a-wire 1.7.0-dev.11 Fri May 15 2026`  
**resistance-in-a-wire sha：** `cb399ded34cf5ee619722e980ec03f5b50140abb`  
**官方 runtime：** https://phet.colorado.edu/sims/html/resistance-in-a-wire/latest/resistance-in-a-wire_en.html  
**官方 GitHub：** https://github.com/phetsims/resistance-in-a-wire  

**Visual Gold Standard：** 用户会话附件原版截图（Default：ρ = 0.50 Ω·cm / L = 10.00 cm / A = 7.50 cm² / R = 0.667 ohms）  
**本阶段：** 只审计合同，**不写** Flutter simulation implementation，**不改** Home。  

| 字段 | 值 |
|---|---|
| PHASE 0 STATUS | **PASS** |
| Flutter `lib/resistance_in_a_wire/` | **不存在**（正确） |
| FINAL / READY | **NOT STARTED**（禁止宣布） |

---

# 0. Authority Order（阻塞级）

```text
1. 本地 HTML5 source（本目录）     → 行为 / 公式 / 范围 / 交互 / 布局常量
2. 用户提供原版截图                 → 视觉 Gold Standard
3. doc/model.md + implementation-notes.md → 设计意图补充（不得覆盖 source 代码）
4. 禁止：物理常识猜测、旧版 Java PhET、网络截图补全当前 source
```

冲突时：**行为以本地 source 为准；像素观感以用户截图为准并回源常量解释。**

---

# 1. Source Version & Tree

## 1.1 Version

| 项 | 值 |
|---|---|
| Sim title | `Resistance in a Wire`（`resistance-in-a-wire-strings_en.json`） |
| package version | **1.8.0-dev.0** |
| 已发布 notes | `doc/release-notes.md`：1.7 增加 Preferences / TS / Dynamic Locale / Interactive Highlights / Pan-Zoom / PhET-iO；1.6 增加 Interactive Description + Sound |
| 本地 git | **无**（非独立 git 树）；SHA 仅来自 `dependencies.json` |
| 语言 | **TypeScript**（`js/resistance-in-a-wire/**`） |

## 1.2 Tree（运行时相关）

```text
js/
  resistance-in-a-wire-main.ts     # Sim 入口；单 Screen
  resistanceInAWire.ts / ResistanceInAWireStrings.ts / ResistanceInAWireFluent.ts
  resistance-in-a-wire/
    ResistanceInAWireConstants.ts
    ResistanceInAWireScreen.ts
    model/
      ResistanceInAWireModel.ts
    view/
      ResistanceInAWireScreenView.ts
      FormulaNode.ts / OutlinedTextNode.ts
      WireNode.ts / WireShapeConstants.ts / DotsCanvasNode.ts
      ControlPanel.ts / SliderUnit.ts
      ResistanceSoundGenerator.ts
      ResistanceInAWireDescriber.ts / ResistanceInAWireScreenSummaryNode.ts
doc/model.md, implementation-notes.md, release-notes.md
assets/*.png                       # 营销截图 only · 非运行时
```

**无** `sounds/` 目录（音效来自 tambo `brightMarimbaShort_mp3`）。  
**无**独立 `test/` 单元测试目录（Phase 0：无上游 oracle 测试可移植）。

---

# 2. Screen Structure

## Screens = 1

来源：`resistance-in-a-wire-main.ts`：

```ts
const sim = new Sim( resistanceInAWireTitleStringProperty, [
  new ResistanceInAWireScreen( tandem.createTandem( 'resistanceInAWireScreen' ) )
], simOptions );
```

| 项 | 值 |
|---|---|
| screen 数量 | **1** |
| screen 类 | `ResistanceInAWireScreen` |
| Model | `ResistanceInAWireModel` |
| View | `ResistanceInAWireScreenView` |
| 背景 | `#ffffdf` |
| keyboard help | `SliderControlsAndBasicActionsKeyboardHelpContent` |
| layoutBounds | **未自定义** → Joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` = **1024×618**（项目内 Ohm's Law / Hooke's Law / WOAS 已验证；见 VD-01） |

```text
Resistance in a Wire
└── ResistanceInAWireScreen
    ├── ResistanceInAWireModel
    └── ResistanceInAWireScreenView
         ├── FormulaNode          (R = ρ L / A，字母动态缩放)
         ├── WireNode             (3D 导线体 + 端盖 + 杂质点)
         ├── ArrowNode            (导线下方静态白箭头)
         ├── ControlPanel         (R 读数 + ρ/L/A 三竖滑条)
         └── ResetAllButton       (radius: 30)
```

**禁止**依据截图臆造多 screen。

---

# 3. MODEL CONTRACT

> 实现 Phase 1 时必须满足本契约。禁止用「常识导线电阻」改范围、单位或小数位语义。

## 3.1 根状态

| Property | 类型 | 默认 | 范围 | 单位 | reset? |
|---|---|---|---|---|---|
| `resistivityProperty` | `NumberProperty` | **0.5** | **0.01 … 1.00** | Ω·cm | ✅ |
| `lengthProperty` | `NumberProperty` | **10** | **0.1 … 20** | cm | ✅ |
| `areaProperty` | `NumberProperty` | **7.5** | **0.01 … 15** | cm² | ✅ |
| `resistanceProperty` | `DerivedProperty` | f(ρ,L,A) | 见下 | **Ω** | 派生 |

常量出处：`ResistanceInAWireConstants.RESISTIVITY_RANGE` / `LENGTH_RANGE` / `AREA_RANGE`（`RangeWithValue`）。

## 3.2 核心公式（唯一真相）

```ts
// ResistanceInAWireModel.ts
( resistivity, length, area ) => resistivity * length / area
```

| 量 | 公式 | 备注 |
|---|---|---|
| R (Ω) | `ρ * L / A` | 与 `doc/model.md` 一致 |
| R 显示 | `getFormattedResistanceValue(R)` | 动态小数位，见 3.4 |

**`RESISTANCE_RANGE`（用于声音归一 / a11y 大变化阈值）：**

```text
R_min = ρ_min * L_min / A_max = 0.01 * 0.1 / 15 ≈ 6.666e-5 Ω
R_max = ρ_max * L_max / A_min = 1.00 * 20 / 0.01 = 2000 Ω
```

**Oracle 样例（与 source 一致，手算）：**

| ρ (Ω·cm) | L (cm) | A (cm²) | R (Ω) | 显示字符串 |
|---|---|---|---|---|
| **0.5** | **10** | **7.5** | **≈0.6666…** | **`0.667`** ← Gold Standard ✅ |
| 0.01 | 0.1 | 15 | ≈6.666e-5 | `0.0001`（<0.001 → 4 位） |
| 1.00 | 20 | 0.01 | 2000 | `2000`（≥100 → 0 位） |
| 0.01 | 0.1 | 0.01 | 0.1 | `0.100`（<1 → 3 位） |
| 1.00 | 20 | 15 | ≈1.333… | `1.33`（1≤R<10 → 2 位） |
| 0.50 | 10 | 0.01 | 500 | `500` |
| 0.25 | 5 | 5 | 0.25 | `0.250` |

## 3.3 公式字母归一化（View 缩放，但公式在此记录）

`FormulaNode.addFormulaSymbol`：

```text
scaleFactor = 7 / property.defaultValue   // 构造时捕获初始值
scaleMagnitude = scaleFactor * value + 1
```

默认态：ρ / L / A / R 的 `scaleMagnitude` **均为 8**（字母「同量级」；视觉差来自字形宽度与位置，非不同 scale）。

## 3.4 显示格式

### Slider 读数（ρ / L / A）

| 项 | 值 |
|---|---|
| 小数位 | **始终 2**（`toFixed(value, 2)`） |
| constrain | `toFixedNumber(value, 2)` |
| 默认显示 | `0.50` / `10.00` / `7.50` |

### Resistance 读数（面板标题 + a11y）

```ts
getResistanceDecimals( resistance ):
  ≥ 100 → 0
  ≥ 10  → 1
  < 0.001 → 4
  < 1   → 3
  else  → 2   // 1 ≤ R < 10
```

`getFormattedResistanceValue` = `Utils.toFixed(value, getResistanceDecimals(value))`。

面板文案 pattern：`{0} = {1} {2}` → `resistance = 0.667 ohms`（单位字符串为复数 **`ohms`**，非 `Ω`）。

## 3.5 `reset()` 语义

```ts
reset() {
  this.resistivityProperty.reset();
  this.lengthProperty.reset();
  this.areaProperty.reset();
  // resistanceProperty 自动派生；无额外 display-unit property
}
```

View 侧 ResetAll：**仅** `model.reset()`（无独立 sound `.reset()` — 音效为 one-shot marimba，非 loop）。

## 3.6 Model 非职责（禁止塞进 Model）

- 公式字母像素尺寸、导线 Path/Gradient、杂质点坐标  
- 滑条 marimba 音效  
- a11y 描述字符串 / Fluent  

以上属 View。

## 3.7 Clock

| 项 | Source |
|---|---|
| Model.step | **无** |
| View.step | **无** |
| 物理积分 | **无**；电阻纯代数派生 |

Flutter：无需物理 Ticker。

---

# 4. VIEW CONTRACT

## 4.1 布局（`ResistanceInAWireScreenView`）

常量：`CONTROL_PANEL_TOP = 40`，`CONTROL_PANEL_RIGHT_MARGIN = 30`。

| Node | 规则 |
|---|---|
| `resetAllButton` | `right = layoutBounds.right - 30`；`bottom = layoutBounds.bottom - 20`；**radius 30** |
| `controlPanel` | `right = resetAllButton.right`；`top = 40`（ManualConstraint） |
| `formulaNode` | `centerX = controlPanel.left / 2`；`centerY = 190` |
| `wireNode` | `centerX = formulaNode.centerX`；`centerY = formulaNode.centerY + 270` |
| `arrowNode` | 水平：`wireNode.centerX ± TAIL_LENGTH/2`；y = `layoutBounds.bottom - 47` |

z-order（children 添加顺序）：formula → wire → arrow → reset → **controlPanel 最后**（始终在最上）。  
PDOM：playArea = formula / wire / arrow / controlPanel；controlArea = resetAll。

## 4.2 FormulaNode

布局锚点：`=` 的 `center = (100, 0)`，font Times **90**。

| 字母 | fill | 初始 font | center（相对局部） | scale |
|---|---|---|---|---|
| R | `#F22` | Times 15 | `equals.centerX - 100, 0` | `7/R0 * R + 1` |
| ρ | `#0f0ffb` | Times 15 | `equals.centerX + 120, -90` | `7/ρ0 * ρ + 1` |
| L | `#0f0ffb` | Times 15 | `equals.centerX + 220, -90` | `7/L0 * L + 1` |
| A | `#0f0ffb` | Times 15 | `equals.centerX + 170, 90 (+ ChromeOS +5)` | `7/A0 * A + 1` |
| = | black | Times **90** | `(100, 0)` | 固定 |
| 分数线 | black | Path | `(150,8)→(400,8)`，`lineWidth: 6` | 固定 |

- 形式：视觉为 `R = ρ L / A`（ρ、L 在线上，A 在线下；**无**显式 `×` 乘号节点）。  
- 每个字母：`OutlinedTextNode`（outline stroke = 背景色 `#ffffdf`，lineWidth **0.2**）+ dilated(1) 透明 anti-artifact Rectangle。  
- Safari：`lettersNode.renderer = 'canvas'`。  
- `cappedSize: true` 传入 R **但未在 `addFormulaSymbol` 中使用** → 见 VD-02（当前 **无** R 缩放上限）。  
- z-order：letters 先加；`=` 与分数线后加（R 过大时仍盖住分数线右侧）。

## 4.3 WireNode / Dots

### 几何映射（`WireShapeConstants`）

| 常量 | 值 |
|---|---|
| `PERSPECTIVE_FACTOR` | **0.4** |
| `WIRE_VIEW_WIDTH_RANGE` | **15 … 500** |
| `WIRE_VIEW_HEIGHT_RANGE` | **3 … 180** |
| `DOT_RADIUS` | **2** |
| `lengthToWidth` | LinearFunction(L_min→L_max → 15→500)，clamp |
| `areaToHeight(A)` | `180 / WIRE_DIAMETER_MAX * (2*√(A/π))` |
| `WIRE_DIAMETER_MAX` | `2 * √(A_max / π)`，`A_max=15` |

### 外观

| 部件 | 规则 |
|---|---|
| `wireBody` | Path：底边水平线 + 右侧椭圆弧 + 顶边回；stroke black；fill **竖向 LinearGradient** `#8C4828 → #E8B282 → #FCF5EE → #F8E8D9 → #8C4828` |
| `wireEnd` | 左端椭圆盖，fill `#E8B282`，stroke black |
| Android | `wireBody`/`wireEnd` renderer = `'canvas'`（issue #158） |
| origin | **导线中心 = (0,0)**；节点用 centerX/centerY 定位 |

### 杂质点（`DotsCanvasNode`）

```text
MAX_WIDTH_INCLUDING_ROUNDED_ENDS = 500 + 2*180*0.4 = 644
AREA_PER_DOT = 200
NUMBER_OF_DOTS = 644 * 180 / 200 = 579.6  // JS 浮点循环上界
resistivity → visibleDots: LinearFunction(ρ_min→ρ_max → 0.05*N → N)
dotCenters: 构造时 dotRandom 采样；reset 不重建则点位不变
clip: 近似椭圆弧（9 segments），非 Shape.ellipticalArc（性能）
```

## 4.4 ArrowNode（静态）

| 项 | 值 |
|---|---|
| 类型 | scenery-phet `ArrowNode` |
| `TAIL_LENGTH` | 140 |
| `HEAD_HEIGHT` / `HEAD_WIDTH` / `TAIL_WIDTH` | 45 / 30 / 10 |
| fill / stroke | white / black，`lineWidth: 1` |
| 行为 | **不**随 R 缩放；纯方向指示（左→右） |

## 4.5 ControlPanel / SliderUnit

| 项 | 值 |
|---|---|
| Panel | `xMargin: 30`，`yMargin: 20`，`lineWidth: 3`，`resize: true`，`preventFit: true` |
| 标题 | 红字 `resistance = {formatted} ohms`；`font` READOUT 28；**centerX=0 只定位一次**（不随 R 跳动，issue #181） |
| 滑条间距 | `SLIDER_SPACING = 50` |
| 结构 | 左→右：ρ · L · A；标题在滑条上方 `bottom = sliders.top - 12` |
| Track | 黑，`4 × (SLIDER_HEIGHT-30)` = **4 × 200** |
| Thumb | `#c3c4c5`，高亮 `#dedede`，`45 × 22` |
| Symbol | Times **60**，蓝 `#0f0ffb` |
| Name | 16pt，蓝（**非**截图描述中的「紫」— 以 source 为准） |
| Value / Unit | 28pt；value 黑；unit 蓝；A 单位为 RichText `cm<sup>2</sup>` |
| ρ 单位 | pattern `{Ω}{cm}` → `Ωcm`（无中间点号；source 用 `symbol.ohms` + `cm`） |
| Slider 内置 sound | **关闭**（`soundGenerator: null`）；由 `ResistanceSoundGenerator` 接管 |

### Keyboard steps

| Slider | keyboardStep | shiftKeyboardStep |
|---|---|---|
| ρ | **0.05** | 0.01（默认） |
| L | **1**（默认） | 0.01 |
| A | **1**（默认） | 0.01 |

`roundToStepSize: true`；`mapPDOMValue` / constrain 均 2 位小数。

## 4.6 Reset All

```text
KratosResetAllButton
  radius: 30                    // source 显式值（非 20.5 / 20.8 / 28）
  baseColor: #F79722
  onPressed → model.reset()
  focusHighlight outerStroke: black  // R 过大时仍可见
```

## 4.7 Sound（View）

| 项 | 实现 |
|---|---|
| Clip | tambo `brightMarimbaShort_mp3` |
| 触发 | 各参数跨 **9 bins**、或触达 min/max、或 **键盘拖动时每次变化** |
| Pitch | `normalizedR = log(R/Rmin) / log(Rmax/Rmin)`；`playbackRate = 2^((1-n)*3) / 3` |
| Level | `initialOutputLevel: 0.5` |
| Reset | 无 loop 可停；无需 sound.reset |

MVP 可分阶段：核心交互无声亦可先通；完整 sonification 记 P1/P2，但契约保留。

## 4.8 a11y

| 层 | Source |
|---|---|
| Screen summary | `ResistanceInAWireScreenSummaryNode` + Describer summaries |
| Formula | accessibleHeading + paragraph + 相对尺寸 Fluent |
| Wire | accessibleHeading + 长度/粗细/杂质定性描述 + R |
| Sliders | accessibleName；aria value + 单位；end-drag context response |
| Keyboard help | `SliderControlsAndBasicActionsKeyboardHelpContent` |

Flutter MVP：**Semantics + 键盘步进**；完整 PDOM / Fluent / Voicing = P2（VD-04）。

---

# 5. PRODUCT-UX BASELINE

依据：用户 Gold Standard 截图 + source 1.8 行为。

## 5.1 用户任务（唯一主路径）

1. 拖 / 键盘调 **ρ / L / A**  
2. 观察：**公式字母大小**、**导线长宽/杂质点密度**、**面板 resistance 读数** 同步变化  
3. **Reset All** 恢复三独立变量默认（R 随之派生）

## 5.2 初始态（必须可对）

| 项 | 值 |
|---|---|
| ρ | **0.50** Ωcm |
| L | **10.00** cm |
| A | **7.50** cm² |
| R | **0.667** ohms |
| 公式 | R / ρ / L / A 同 scaleMagnitude=8；R 红，右侧蓝 |
| 导线 | 中等长度与粗细；中等杂质点密度 |
| 箭头 | 白底黑边，水平向右，固定尺寸 |
| 背景 | `#FFFFDF` |

## 5.3 交互地图

| 输入 | 目标 | 结果 |
|---|---|---|
| 拖 ρ thumb / 点轨 | `resistivityProperty` | 派生 R；公式 ρ/R；点数；读数；marimba |
| 拖 L thumb | `lengthProperty` | 派生 R；公式 L/R；导线宽度；读数；marimba |
| 拖 A thumb | `areaProperty` | 派生 R；公式 A/R；导线高度；读数；marimba |
| 键盘（slider focused） | 同上 | ρ±0.05；L/A±1（Shift±0.01） |
| Reset All | model.reset | 回初始三变量 |

**不可拖：** 公式、导线、箭头、读数标题（非 interactive）。

## 5.4 非目标（本 sim 不做）

- 多 screen / 真实材料表 / 温度系数  
- 可拖拽导线几何手柄（仅滑条改 L/A）  
- 交流 / 非欧姆器件  
- 用 Material 控件 / Icons.refresh 冒充 PhET  

## 5.5 Home / 导航

- Phase 0–N：**不改** Home，直至专门 Home 阶段  
- Sim 标题字符串：`Resistance in a Wire`  
- 建议 Home 分类（后续）：物理 → 电学与电路（与 Ohm's Law 同组）

---

# 6. INTERACTION / ANIMATION / LIFECYCLE

| 项 | 事实 |
|---|---|
| 拖拽对象 | 仅三枚 VSlider thumb |
| 动画 | **无**位移动画；字母/导线/点为 Property → 即时重绘 |
| Clock | **无** `step(dt)` |
| dispose | Sound ParameterMonitor unlink；Flutter 须取消 listen |
| re-entry | 新 Model/View；杂质点用 `dotRandom` **每次 DotsCanvasNode 构造重采样** — VD-03 |

---

# 7. ASSETS 摘要

详见 `ASSET_MAP.md`。

- **运行时位图：0**（公式/导线/控件全绘制）  
- **运行时音频：** tambo `brightMarimbaShort` + ResetAll shared  
- **仓库 `assets/*.png`：** 仅营销截图，**禁止**当 UI asset  
- **Substituted 目标：0**

---

# 8. AUDIO CONTRACT（展开）

| 触发源 | 条件 | 播放内容 |
|---|---|---|
| ρ / L / A Property change | bin 变化 **或** 值=min/max **或** `keyboardDraggingProperty` | marimba，pitch ∝ 1/√-ish resistance（见 4.7） |
| Reset All | scenery-phet 默认 | shared reset click（L0 已有策略） |
| 无 | — | **无**持续 loop / ambient |

`BINS_PER_SLIDER = 9`（奇数，使默认中值落在 bin 中心附近）。

---

# 9. ACCESSIBILITY CONTRACT（展开）

| 能力 | Source | Flutter Phase 目标 |
|---|---|---|
| Screen summary | Fluent play/control/currentDetails | P2 |
| Formula / Wire 描述 | Describer 7-档定性 + 相对尺寸 | P2 |
| Slider name / value / unit | accessibleName + unit accessible strings | MVP Semantics |
| Context response（松手） | `getSliderChangeAlert` | P2 |
| Keyboard help dialog | SliderControlsAndBasicActions… | MVP 可延后 |
| Interactive Highlights / Preferences / Pan-Zoom | 1.7 features | P2 / 非 MVP |

---

# 10. Known VERSION_DELTA

| ID | 描述 | 迁移影响 |
|---|---|---|
| **VD-01** | sim **未**覆盖 `layoutBounds`；项目标准 Joist 默认为 **1024×618**（Ohm's Law 曾误用 768×504 后修正） | Phase 2 锁定 **1024×618**；禁止再猜 HomeScreen 尺寸 |
| **VD-02** | `FormulaSymbolEntry.cappedSize` 对 R 传入 `true`，但 `addFormulaSymbol` **忽略**该字段；历史 issue #28「防 R 过大」**当前未生效** | 忠实复刻：**不**擅自加 cap；若产品要 cap 须记 delta |
| **VD-03** | `DotsCanvasNode` 构造时 `dotRandom` 采样中心 | Phase 4 golden 需 **固定 seed** 或接受会话内稳定策略并记录 |
| **VD-04** | 完整 PDOM / Fluent / Voicing / Preferences / Pan-Zoom | MVP 可降级；不可省略三滑条与 Reset |
| **VD-05** | 截图/描述偶发把 name 标签看成「紫」；source `NAME_FONT` fill = **`#0f0ffb` 蓝** | 以 source 色为准 |
| **VD-06** | ρ 单位显示为拼接 `Ω`+`cm`（`Ωcm`），非 `Ω·cm`；Model units 注释为 `Ω·cm` | 显示跟 ControlPanel pattern；Model 元数据可保留中间点 |
| **VD-07** | package `1.8.0-dev.0` vs dependencies 注释 `1.7.0-dev.11` | 以 package + 当前 TS 源码树为准；注释仅作 SHA 锚点 |
| **VD-08** | `implementation-notes.md` 写 SliderUnit 含 HSlider；代码为 **VSlider** | **以代码为准** |
| **VD-09** | ChromeOS 对 A 符号 `AREA_SYMBOL_Y_OFFSET = 5` | Flutter 可忽略（非目标平台）或做平台分支并记录 |
| **VD-10** | ResetAll **radius 30**（Ohm's Law 为 28；L0 默认 20.5） | 必须显式传 `radius: 30` |

---

# 11. P0 / P1 风险登记

| 级 | 项 |
|---|---|
| P0 | 公式用错（漏乘除、单位混用） |
| P0 | 默认态偏离 0.50 / 10.00 / 7.50 / **0.667 ohms** |
| P0 | Reset All 不用 `KratosResetAllButton` 或 **radius≠30** |
| P0 | 用 Icons / Emoji / PNG 截图冒充导线或 Reset |
| P0 | Resistance 小数位规则未实现（尤其 <1 → 3 位） |
| P1 | 杂质点随机导致 visual golden 不稳定 |
| P1 | Marimba sonification 未做 |
| P1 | 导线透视椭圆 / 渐变与原版偏差 |
| P2 | 完整 a11y / PhET-iO / Preferences / Pan-Zoom |

---

# 12. Phase 0 完成条件

| 条件 | 状态 |
|---|---|
| Screen 结构明确（=1） | ✅ |
| Model contract（公式/范围/reset/精度） | ✅ |
| View contract（布局/绘制/控件） | ✅ |
| Interaction / Audio / A11y contract | ✅ |
| Product-UX baseline（任务/初始态/交互） | ✅ |
| Screenshot audit | ✅ `PHASE_0_SCREENSHOT_AUDIT.md` |
| Asset map | ✅ `ASSET_MAP.md` |
| VERSION_DELTA 记录 | ✅ |
| Flutter UI 未开始 | ✅ |
| Home 未改 | ✅ |

```text
PHASE 0 STATUS: PASS
P0 blockers: 0
Next: PHASE 1 — MODEL（lib/resistance_in_a_wire/model/ + 单元测试 oracle）
Do NOT start Flutter UI / Home until product owner explicitly requests Phase 1+.
```

---

*Phase 0 complete. Behavior Reference = local HTML5 source. Visual Gold Standard = user screenshot.*
