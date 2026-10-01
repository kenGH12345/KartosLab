# PHASE 0 — SOURCE AUDIT / MODEL-CONTRACT / VIEW-CONTRACT / PRODUCT-UX BASELINE

**Sim：** Ohm's Law  
**本地基准：** `phet sourses/ohms-law-main/ohms-law-main`  
**入口：** `js/ohms-law-main.js`  
**package.json 版本：** `1.5.0-dev.6`  
**dependencies.json 注释：** `# ohms-law 1.5.0-dev.6 Tue Mar 28 2023`  
**ohms-law sha：** `8c35be1c46f986a1084a5b1d2ce4a90eb4b15783`  
**官方 runtime：** https://phet.colorado.edu/sims/html/ohms-law/latest/ohms-law_en.html  
**官方 GitHub：** https://github.com/phetsims/ohms-law  

**Visual Gold Standard：** 用户会话附件原版截图（Default：4.5 V / 500 Ω / 9.0 mA）  
**本阶段：** 只审计合同，**不写** Flutter simulation implementation，**不改** Home。  

| 字段 | 值 |
|---|---|
| PHASE 0 STATUS | **PASS** |
| Flutter `lib/ohms_law/` | **不存在**（正确） |
| FINAL / READY | **NOT STARTED**（禁止宣布） |

---

# 0. Authority Order（阻塞级）

```text
1. 本地 HTML5 source（本目录）     → 行为 / 公式 / 范围 / 交互 / 布局常量
2. 用户提供原版截图                 → 视觉 Gold Standard
3. doc/model.md + implementation_notes.md → 设计意图补充（不得覆盖 source 代码）
4. 禁止：物理常识猜测、旧版 Java PhET、网络截图补全当前 source
```

冲突时：**行为以本地 source 为准；像素观感以用户截图为准并回源常量解释。**

---

# 1. Source Version & Tree

## 1.1 Version

| 项 | 值 |
|---|---|
| Sim title | `Ohm's Law`（`ohms-law-strings_en.json`） |
| package version | **1.5.0-dev.6** |
| 已发布 notes | `doc/release-notes.md`：1.5 增加 Units radio（mA/A）、Preferences、a11y Fluent 等 |
| 本地 git | **无**（非独立 git 树）；SHA 仅来自 `dependencies.json` |
| 语言 | JS（`js/ohms-law/**`）+ 少量 TS strings |

## 1.2 Tree（运行时相关）

```text
js/
  ohms-law-main.js              # Sim 入口；单 Screen
  ohmsLaw.js / OhmsLawStrings.ts
  ohms-law/
    OhmsLawConstants.js
    OhmsLawScreen.js
    model/
      OhmsLawModel.js
      CurrentUnit.js
    view/
      OhmsLawScreenView.js
      FormulaNode.js
      WireBox.js / BatteriesView.js / BatteryView.js
      ResistorNode.js / RightAngleArrow.js / ReadoutPanel.js
      ControlPanel.js / SliderUnit.js
      UnitsRadioButtonContainer.js
      CurrentSoundGenerator.js
      *Describer.js / OhmsLawScreenSummaryNode.js   # a11y
sounds/currentV3Loop.mp3
doc/model.md, implementation_notes.md, release-notes.md
```

**无**独立 `test/` 单元测试目录（Phase 0：无上游 oracle 测试可移植）。

---

# 2. Screen Structure

## Screens = 1

来源：`ohms-law-main.js`：

```js
const sim = new Sim( ohmsLawTitleStringProperty, [
  new OhmsLawScreen( tandem.createTandem( 'ohmsLawScreen' ) )
], simOptions );
```

| 项 | 值 |
|---|---|
| screen 数量 | **1** |
| screen 类 | `OhmsLawScreen` |
| Model | `OhmsLawModel` |
| View | `OhmsLawScreenView` |
| 背景 | `#ffffe8` |
| keyboard help | `SliderControlsAndBasicActionsKeyboardHelpContent` |
| layoutBounds | **未自定义** → Joist `ScreenView` 默认（暂定 **768×504**，见 VD-01） |

```text
Ohm's Law
└── OhmsLawScreen
    ├── OhmsLawModel
    └── OhmsLawScreenView
         ├── FormulaNode
         ├── WireBox
         │    ├── BatteriesView / BatteryView×N
         │    ├── ResistorNode
         │    ├── RightAngleArrow×2
         │    └── ReadoutPanel
         ├── ControlPanel (SliderUnit V + SliderUnit R)
         ├── UnitsRadioButtonContainer
         └── ResetAllButton (radius 28)
```

**禁止**依据截图臆造多 screen。

---

# 3. MODEL CONTRACT

> 实现 Phase 1 时必须满足本契约。禁止用「常识 Ohm 定律」改范围或单位语义。

## 3.1 根状态

| Property | 类型 | 默认 | 范围 | 单位 | reset? |
|---|---|---|---|---|---|
| `voltageProperty` | `NumberProperty` | **4.5** | **0.1 … 9** | V | ✅ |
| `resistanceProperty` | `NumberProperty` | **500** | **10 … 1000** | Ω | ✅ |
| `currentProperty` | `DerivedProperty` | f(V,R) | 见下 | **mA** | 派生 |
| `currentUnitsProperty` | `EnumerationDeprecatedProperty` | **MILLIAMPS** | MILLIAMPS \| AMPS | display | ❌ **reset 不恢复** |

常量出处：`OhmsLawConstants.VOLTAGE_RANGE` / `RESISTANCE_RANGE`（`RangeWithValue`）。

## 3.2 核心公式（唯一真相）

```js
// OhmsLawModel.js — computeCurrent
function computeCurrent( voltage, resistance ) {
  return 1000 * voltage / resistance; // milliamps
}
```

| 量 | 公式 | 备注 |
|---|---|---|
| I (mA) | `1000 * V / R` | **不是**裸 `V/R` 当 mA |
| I 显示 (mA) | `toFixed(I, 1)` | `CURRENT_MILLIAMPS_SIG_FIGS = 1` |
| I 显示 (A) | `toFixed(I / 100, 3)` | source **字面**如此（VD-03） |

**Oracle 样例（与 source 一致，手算）：**

| V (V) | R (Ω) | I (mA) | 截图/默认 |
|---|---|---|---|
| 4.5 | 500 | **9.0** | Gold Standard ✅ |
| 0.1 | 1000 | 0.1 | min |
| 9 | 10 | 900 | max |
| 9 | 1000 | 9.0 | |
| 0.1 | 10 | 10.0 | |

`getMaxCurrent()` = `computeCurrent(9, 10)` = **900** mA  
`getMinCurrent()` = `computeCurrent(0.1, 1000)` = **0.1** mA  

`OhmsLawConstants.CURRENT_RANGE`（用于声音 log 归一）= `V/R` **安培**范围：`0.1/1000 … 9/10` = `1e-4 … 0.9` A（与 `currentProperty` 的 mA 不同维度 — 见声音合同）。

## 3.3 归一化（驱动公式字母大小）

```text
normV = (V - 0.1) / (9 - 0.1)
normR = (R - 10) / (1000 - 10)
normI = (I_mA - I_min) / (I_max - I_min)   // I_min=0.1, I_max=900
```

## 3.4 显示格式

| 量 | 小数位 | 约束 |
|---|---|---|
| V | 1 | slider `constrainValue` → `toFixedNumber(_, 1)` |
| R | 0 | 整数欧姆 |
| I (mA) | 1 | |
| I (A) | 3 | 经 `getFixedCurrent` |

## 3.5 `reset()` 语义

```js
reset() {
  this.voltageProperty.reset();
  this.resistanceProperty.reset();
  // currentUnitsProperty 不 reset
}
```

View 侧 ResetAll 额外：`currentSoundGenerator.reset()`。

## 3.6 Model 非职责（禁止塞进 Model）

- 字母像素尺寸、电池几何、电阻黑点、箭头 path  
- 滑条音效 / 电流 loop 播放  
- a11y 描述字符串  

以上属 View。

## 3.7 Clock

| 项 | Source |
|---|---|
| Model.step | **无** |
| View.step | `OhmsLawScreenView.step(dt)` → 仅 `CurrentSoundGenerator.step` |
| 物理积分 | **无**；电流纯代数派生 |

Flutter：无需物理 Ticker；若做电流音效衰减才需要轻量 `step(dt)`。

---

# 4. VIEW CONTRACT

## 4.1 布局（`OhmsLawScreenView`）

| Node | 规则 |
|---|---|
| `formulaNode` | `centerY = layoutBounds.bottom / 4.75`；水平由内部硬编码相对 `=` |
| `wireBox` | `centerX = formulaNode.centerX`；`bottom = layoutBounds.bottom - 30` |
| `controlPanel` | `right = width - 50`；`top = top + 20` |
| `unitsRadioButtonContainer` | `left = controlPanel.left`；`centerY = wireBox.centerY + 4` |
| `resetAllButton` | `right = controlPanel.right`；`bottom = bottom - 20`；**radius 28** |

## 4.2 FormulaNode

| 字母 | fill | 初始 font | scale 公式 | 相对 `=` 的 x |
|---|---|---|---|---|
| V | blue | Times 20 bold | `16*normV + 4` | centerX − 150 |
| = | black | Times **140** bold | 固定 | centerX = 300（局部） |
| I | `#FF5500` | Times 20 bold | `150*normI + 1` | centerX + 80 |
| R | blue | Times 20 bold | `16*normR + 4` | centerX + 240 |

- **无**乘号节点（截图与 source 均为 `V = I R` 并置）。  
- z-order：先加 I（巨大时不挡）、再 R、V，最后 `=` 置顶。  
- Anti-artifact：字母外包 dilated(1) 透明 Rectangle。

## 4.3 WireBox / 电路

| 部件 | 关键常量 |
|---|---|
| 线框 | 505×165，stroke 10，圆角 4 |
| 电池数 | `MAX_NUMBER_OF_BATTERIES = ceil(9/1.5) = 6` |
| 单节宽 | `(505 - 2*30) / 6` |
| 单节高 | 38；nub 高 = 0.3×38 |
| 可见节 | `voltageBattery = min(1.5, V - index*1.5)`；`> 0` 才显示 |
| 不满 1.5 V 的节 | `mainBody` 宽度按 `LinearFunction(0.1→1.5 → 0.0001→1)` 缩短；标签上移 |
| 电阻 | width≈`505/2.123`，height≈`165/2.75`；红白渐变；黑点 `AREA_PER_DOT=40`；可见点数线性映射 R∈[10,1000] → `[0.05*MAX, MAX]` |
| 箭头 | 固定 polygon；`scale = (I_mA * 0.1)^0.7`（`lazyLink`，初始 options.scale 0.85） |
| 读数 | Panel；文案 `current` + `=` + value + `mA`\|`A` |

## 4.4 ControlPanel / SliderUnit

| 项 | 值 |
|---|---|
| 结构 | HBox：Voltage SliderUnit \| Resistance SliderUnit；spacing 30 |
| Panel | lineWidth 3；`preventFit: true` |
| Track | 黑，`4 × 210` |
| Thumb | `#c3c4c5`，`45 × 22` |
| V keyboardStep | 0.5 V |
| R keyboardStep | 20 Ω；shiftKeyboardStep 1 Ω |
| Slider 内置 sound | **关闭**（`soundGenerator: null`）；由 ScreenView DiscreteSoundGenerator 接管 |

## 4.5 UnitsRadioButtonContainer

- 标题：`Units`  
- Radio：`Milliamps (mA)` / `Amps (A)`  
- 绑定 `currentUnitsProperty`  
- 改变只影响 **显示**（`getFixedCurrent` + 单位字符串），不改 `currentProperty`（仍为 mA）

## 4.6 Reset All

```text
KratosResetAllButton
  radius: 28                    // source 显式值，非 20.5/20.8 默认
  baseColor: #F79722
  onPressed → model.reset() + currentSoundGenerator.reset()
```

## 4.7 Sound（View）

| 触发 | 实现 |
|---|---|
| V / R 变化 | `DiscreteSoundGenerator(click_mp3)`，`numBins: 6`，level 0.25；键盘拖动时 `alwaysPlayOnChanges` |
| I 变化 | `CurrentSoundGenerator`：loop `currentV3Loop`；playbackRate = `0.5 + 1.5 * normalizedCurrent^2`；归一用 `log((I/1000)/Imin_A)`；短时全音量后指数衰减 |
| Reset | 停 loop |

MVP 可分阶段：核心交互无声亦可先通；完整 sonification 记 P1/P2，但契约保留。

## 4.8 a11y

大量 PDOM / Fluent / Describer。Flutter MVP：**Semantics + 键盘步进**；完整 Voicing = P2（VD-04）。

---

# 5. PRODUCT-UX BASELINE

依据：用户 Gold Standard 截图 + source 1.5 行为。

## 5.1 用户任务（唯一主路径）

1. 拖 / 键盘调 **V** 或 **R**  
2. 观察：**公式字母大小**、**电池数量/长度**、**电阻黑点密度**、**箭头大小**、**电流读数** 同步变化  
3. （1.5）切换 **mA / A** 仅改读数单位  
4. **Reset All** 恢复 V/R 默认（及声音）；**不**强制恢复 Units

## 5.2 初始态（必须像素级可对）

| 项 | 值 |
|---|---|
| V | 4.5 V → **3** 节满电 AA |
| R | 500 Ω → 中等黑点密度 |
| I | 9.0 mA |
| Units | mA |
| 公式 | V、R 大；I 明显更小 |
| 背景 | `#FFFFE8` |

## 5.3 交互地图

| 输入 | 目标 | 结果 |
|---|---|---|
| 拖 V thumb / 点轨 | `voltageProperty` | 派生 I；电池数；字母 V/I；箭头；读数；click 音 |
| 拖 R thumb | `resistanceProperty` | 派生 I；黑点数；字母 R/I；箭头；读数；click 音 |
| 键盘（slider focused） | 同上 | V±0.5；R±20（Shift±1） |
| Units radio | `currentUnitsProperty` | 读数字符串/单位；字母尺寸仍跟 mA 数值 |
| Reset All | model + sound | 回初始 V/R |

**不可拖：** 公式、电路、电池、电阻、箭头、读数面板（`pickable: false` on formula/wireBox）。

## 5.4 非目标（本 sim 不做）

- 多 screen / 示波器 / 真实导线电阻  
- 可拖拽电路元件  
- 交流 / 非欧姆器件  
- 用 Material 控件冒充 PhET  

## 5.5 Home / 导航

- Phase 0–N：**不改** Home，直至专门 Home 阶段  
- Sim 标题字符串：`Ohm's Law`

---

# 6. INTERACTION / ANIMATION / LIFECYCLE

| 项 | 事实 |
|---|---|
| 拖拽对象 | 仅两枚 VSlider thumb |
| 动画 | **无**位移动画；字母/箭头/电池为 Property → 即时重绘 |
| Clock | 仅声音 fade 需要 `dt` |
| dispose | Sound generators unlink；Flutter 须取消 listen |
| re-entry | 新 Model/View 实例；无 static 物理缓存（电阻点用 `dotRandom` **每次构造重采样位置** — VD-05） |

---

# 7. ASSETS 摘要

详见 `ASSET_MAP.md`。

- **运行时位图：0**（电路全绘制）  
- **运行时音频：** `currentV3Loop.mp3` + tambo `click` + reset shared  
- **Substituted 目标：0**

---

# 8. Known VERSION_DELTA

| ID | 描述 | 迁移影响 |
|---|---|---|
| **VD-01** | 本地无 `joist`；`layoutBounds` 未在 ohms-law 覆盖 | 暂定 768×504（Friction 同类）；Phase 1/2 用 joist SHA `994b7407…` 复核 `ScreenView` 默认 |
| **VD-02** | 用户 Gold Standard 截图**未见** Units UI；source 1.5 **有** | **必须实现 Units**；补 runtime 截图对齐位置 |
| **VD-03** | `getFixedCurrent` 在 AMPS 时 `current / 100`（mA→A 物理上应为 `/1000`）；声音路径用 `/1000` | Phase 1 写 oracle：**先忠实复刻 source 字面**，再产品决定是否修；禁止静默「纠正」不记录 |
| **VD-04** | 完整 PDOM / Fluent / Voicing | MVP 可降级；不可省略滑条与 Reset |
| **VD-05** | `ResistorNode` 黑点 xy 每次 `new` 随机 | Reset 不重建 Node 则点位不变；Flutter 需固定 seed 或接受会话内稳定/重建策略并记录 |
| **VD-06** | `RightAngleArrow` 用 `lazyLink`：首帧 scale=0.85，直至 I 首次变化 | 对齐时注意初始箭头尺寸 |
| **VD-07** | `model.reset` **不**重置 `currentUnitsProperty` | Reset UX 必须与 source 一致 |
| **VD-08** | `implementation_notes` 写 ControlPanel「to the left」与代码 `right` 布局矛盾 | **以代码为准** |
| **VD-09** | `assets/slider-click-001.wav` 未被 import | 勿当作已接线资源；click 来自 tambo |

---

# 9. P0 / P1 风险登记

| 级 | 项 |
|---|---|
| P0 | 公式/电流用错单位（漏 `*1000`） |
| P0 | Reset All 不用 `KratosResetAllButton` 或 radius≠28 |
| P0 | 用 Icons/Emoji/PNG 截图冒充电池/电阻/箭头 |
| P0 | 默认态偏离 4.5 / 500 / 9.0 mA |
| P1 | Units A 显示与 VD-03 策略未文档化 |
| P1 | 电阻点随机导致 visual golden 不稳定 |
| P1 | 电流/滑条声未做 |
| P2 | 完整 a11y / PhET-iO / Preferences / Pan-Zoom |

---

# 10. Phase 0 完成条件

| 条件 | 状态 |
|---|---|
| Screen 结构明确（=1） | ✅ |
| Model contract（公式/范围/reset/units） | ✅ |
| View contract（布局/绘制/控件） | ✅ |
| Product-UX baseline（任务/初始态/交互） | ✅ |
| Screenshot audit | ✅ `PHASE_0_SCREENSHOT_AUDIT.md` |
| Asset map | ✅ `ASSET_MAP.md` |
| VERSION_DELTA 记录 | ✅ |
| Flutter UI 未开始 | ✅ |
| Home 未改 | ✅ |

```text
PHASE 0 STATUS: PASS
P0 blockers: 0
Next: PHASE 1 — MODEL（lib/ohms_law/model/ + 单元测试 oracle）
Do NOT start Flutter UI / Home until product owner explicitly requests Phase 1+.
```

---

*Phase 0 complete. Behavior Reference = local HTML5 source. Visual Gold Standard = user screenshot.*
