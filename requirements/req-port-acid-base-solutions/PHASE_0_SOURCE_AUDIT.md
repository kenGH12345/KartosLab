# PHASE 0 — SOURCE AUDIT / Migration Blueprint

**Sim:** PhET Acid-Base Solutions → Flutter (KartosLab)  
**Req id:** `req-port-acid-base-solutions`  
**Local source:** `phet sourses/acid-base-solutions-main/acid-base-solutions-main`  
**package.json version:** `1.4.0-dev.8`  
**dependencies.json stamp:** `1.4.0-dev.8` (Tue Jul 16 2024)  
**Entry:** `js/acid-base-solutions-main.ts`  
**Official runtime:** `https://phet.colorado.edu/sims/html/acid-base-solutions/latest/acid-base-solutions_all.html`  
**Official screen count claim:** 2 interactive screens  

---

## PHASE 0 STATUS: PASS

判定依据：

- 生产 Screen 2 个，与入口注册一致（Intro / My Solution）
- 核心 Model 层级与化学计算链已从 local source + `doc/model.md` 对齐
- Interaction / Reset / Layout bounds / Assets / Dependencies / Tests 现状可解释
- **无未解释的核心 source behavior**
- Flutter UI / Home / Runtime / Android：**未开始 / 未触碰 / 未验证**

```text
Flutter UI: NOT STARTED
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
```

---

## 1. Source Truth 优先级（本审计遵守）

```text
1. Local PhET source (js/, images/, doc/)
2. Local original assets (images/, assets/ screenshots)
3. User-provided original screenshots
4. Official runtime
5. Inference (仅标注)
```

行为 / 数据 / 化学 / 状态机 → **source 优先**。  
截图 → layout / visual / spacing / controls 外观。

---

## 2. Source Structure

```text
acid-base-solutions-main/
├── js/
│   ├── acid-base-solutions-main.ts          # Sim entry · 注册 2 screens
│   ├── acidBaseSolutions.ts                 # namespace
│   ├── AcidBaseSolutionsStrings.ts
│   ├── acid-base-solutions-phet-io-overrides.js
│   ├── common/
│   │   ├── ABSConstants.ts
│   │   ├── ABSColors.ts
│   │   ├── ABSQueryParameters.ts
│   │   ├── model/
│   │   │   ├── ABSModel.ts
│   │   │   ├── ABSPreferences.ts
│   │   │   ├── Beaker.ts
│   │   │   ├── PHMeter.ts / PHPaper.ts / ConductivityTester.ts
│   │   │   └── solutions/
│   │   │       ├── AqueousSolution.ts       # abstract base
│   │   │       ├── Water.ts
│   │   │       ├── StrongAcid.ts / WeakAcid.ts
│   │   │       ├── StrongBase.ts / WeakBase.ts
│   │   │       └── Particle.ts              # ParticleKey + Particle type
│   │   └── view/
│   │       ├── ABSScreenView.ts             # shared play/control layout
│   │       ├── ABSViewProperties.ts
│   │       ├── BeakerNode / ParticlesNode / ParticlesCanvasNode
│   │       ├── ConcentrationGraphNode / ConcentrationBarNode
│   │       ├── PHMeterNode / PHPaperNode / PHColorKeyNode
│   │       ├── ABSConductivityTesterNode
│   │       ├── ReactionEquationNode / ReactionEquationFactory
│   │       ├── ViewsPanel / ToolsRadioButtonGroup
│   │       ├── createParticleNode / AtomNode
│   │       └── LogSlider / ShowSolventControl / ABSPreferencesNode
│   ├── intro/
│   │   ├── IntroScreen.ts
│   │   ├── model/IntroModel.ts
│   │   └── view/IntroScreenView.ts / IntroSolutionPanel.ts / IntroKeyboardHelpContent.ts
│   └── mysolution/
│       ├── MySolutionScreen.ts
│       ├── model/MySolutionModel.ts
│       └── view/MySolutionScreenView.ts / MySolutionPanel.ts
│           + AcidBaseSwitch / InitialConcentrationControl / StrengthControl ...
├── images/          # 3 PNG + generated *_png.ts
├── assets/          # marketing screenshots only
├── doc/
│   ├── model.md                 # 化学公式权威文档（与代码一致）
│   ├── implementation-notes.md  # 无 MVT；粒子算法 PDF
│   ├── HA_A-_ratio_model.pdf    # 浓度→粒子数映射
│   └── release-notes.md
├── acid-base-solutions-strings_en.json
├── package.json / dependencies.json / Gruntfile.cjs / README.md
└── (无 sounds/ 目录 · 无 js/*Tests.js)
```

**js 文件数：** 58（含 strings / main）

---

## 3. Screens

### Official Screen Count: 2  
### Local Screen Count: 2  

入口 `acid-base-solutions-main.ts`：

```ts
const screens = [
  new IntroScreen( Tandem.ROOT.createTandem( 'introScreen' ) ),
  new MySolutionScreen( Tandem.ROOT.createTandem( 'mySolutionScreen' ) )
];
```

`package.json` → `phet.screenNameKeys`:

- `ACID_BASE_SOLUTIONS/screen.introduction` → UI 显示 **"Intro"**（string key 仍为 introduction）
- `ACID_BASE_SOLUTIONS/screen.mySolution` → **"My Solution"**

### Screen 1: Intro

| 字段 | Source |
|---|---|
| Class | `IntroScreen` |
| Title | `AcidBaseSolutionsStrings.screen.introductionStringProperty` → **"Intro"** |
| Icon | Procedural：烧杯 + 水 + 放大镜（`createScreenIcon`） |
| Model | `IntroModel` extends `ABSModel` |
| View | `IntroScreenView` extends `ABSScreenView` |
| Screen-specific | `mutableSolutionProperty`；5 个 preset solutions（含 Water） |
| Initial | solution = Water；viewMode = particles；toolMode = pHMeter |
| Reset | 见 §16 |
| Transition | joist `Sim` home ↔ screen（标准 PhET） |

### Screen 2: My Solution

| 字段 | Source |
|---|---|
| Class | `MySolutionScreen` |
| Title | `screen.mySolution` → **"My Solution"** |
| Icon | Procedural：H3O + OH 粒子 |
| Model | `MySolutionModel` extends `ABSModel` |
| View | `MySolutionScreenView` extends `ABSScreenView` |
| Screen-specific | `isAcidProperty` / `isWeakProperty` / `concentrationProperty` / `strengthProperty`；**无 Water** |
| Initial | Acid + weak → WeakAcid；c = 0.01 mol/L；Ka = 1e-7 |
| Reset | 见 §16 |

### NON-PRODUCTION / TEST ONLY

**无。** 无隐藏 screen、无 test screen 注册。

---

## 4. Architecture

```text
Simulation (Sim)
├── IntroScreen
│   ├── IntroModel (ABSModel)
│   │   ├── solutions: Water, StrongAcid, WeakAcid, StrongBase, WeakBase
│   │   ├── mutableSolutionProperty → solutionProperty
│   │   ├── pHProperty (derived from selected solution)
│   │   ├── Beaker
│   │   └── tools: PHMeter, PHPaper, ConductivityTester
│   ├── IntroScreenView (ABSScreenView)
│   │   └── IntroSolutionPanel (radio presets)
│   └── ABSViewProperties (viewMode, toolMode)
├── MySolutionScreen
│   ├── MySolutionModel (ABSModel)
│   │   ├── solutions: StrongAcid, WeakAcid, StrongBase, WeakBase (no Water)
│   │   ├── isAcidProperty / isWeakProperty → Derived solutionProperty
│   │   ├── concentrationProperty → sync all solutions
│   │   ├── strengthProperty → sync weak solutions only
│   │   ├── Beaker + tools (独立实例)
│   └── MySolutionScreenView
│       └── MySolutionPanel (Acid/Base · Concentration · Strength)
├── Shared: ABSConstants, ABSColors, Particles*, BeakerNode, Graph, Equations, Tools
├── Assets: images/*.png
├── Preferences: ABSPreferences.showSolventProperty (global)
├── Audio: framework slider sounds only (no local clips)
└── Dependencies: axon, scenery, sun, joist, … (see §22)
```

### Data / View flow

```text
Screen
  ↓
Model (IntroModel | MySolutionModel)
  ↓
Properties / DerivedProperties
  (solution · concentration · strength · pH · tool positions · brightness)
  ↓
View (ABSScreenView + screen panel)
  ↓
Interaction (radio / switch / slider / spinner / drag)
  ↓
Model mutation
  ↓
Derived: [H3O+] [OH-] particle counts · pH · graph bars · bulb brightness · paper color
```

**重要：** Intro 与 My Solution **共享类定义，不共享 Model 实例**。后续 Flutter **禁止合并成单一 Screen Model**。

---

## 5. Models（完整清单）

| Model | Path | Role |
|---|---|---|
| `ABSModel` | `common/model/ABSModel.ts` | 两屏基类：solutions、solutionProperty、pHProperty、Beaker、三工具 |
| `IntroModel` | `intro/model/IntroModel.ts` | 5 presets + mutable selection |
| `MySolutionModel` | `mysolution/model/MySolutionModel.ts` | Acid/Weak switches + c/strength sync |
| `AqueousSolution` | abstract | strength / concentration / pHProperty + 浓度抽象方法 |
| `Water` / `StrongAcid` / `WeakAcid` / `StrongBase` / `WeakBase` | solutions/* | 化学公式实现 |
| `Particle` (type) | `Particle.ts` | `{ key, color, getConcentration }` |
| `Beaker` | 几何 | size 360×270，position (230, 410)，origin = bottom-center |
| `PHMeter` | 工具 | tip 位置；`isInSolutionProperty` |
| `PHPaper` | 工具 | paperSize 16×110；`percentColoredProperty`；`colorProperty` |
| `ConductivityTester` | 工具 | probes + `brightnessProperty` ∈ [0,1] |
| `ABSPreferences` | 全局 | `showSolventProperty`（Particles 视图是否显示溶剂图） |
| `ABSViewProperties` | 每屏 view | `viewModeProperty` / `toolModeProperty` |

---

## 6. Core Chemistry（源码实际语义）

常量（`ABSConstants` + `doc/model.md`）：

| Symbol | Value | Meaning |
|---|---|---|
| W | `WATER_CONCENTRATION = 55.6` | 纯水浓度 mol/L |
| Kw | `WATER_EQUILIBRIUM_CONSTANT = 1E-14` | 水自解离常数 |
| C | `concentrationProperty` | 酸/碱初始浓度 mol/L |
| Ka / Kb | `strengthProperty` | 弱酸/弱碱电离常数（unitless，文档称 ionization constant） |

### 6.1 Water

- `[H3O+] = sqrt(Kw)`
- `[OH-] = [H3O+]`
- `[H2O] = W`（= concentrationProperty，常数 55.6）
- solute/product = 0
- Particles: H2O, H3O, OH

### 6.2 Strong Acid (HA)

- `[HA] = 0`
- `[A-] = C`
- `[H3O+] = C`
- `[OH-] = Kw / [H3O+]`
- `[H2O] = W - C`
- Particles: HA, H2O, A, H3O  
- strength = 常数 `STRONG_STRENGTH = 101`（> WEAK max，仅标记“强”，不参与弱酸公式）

### 6.3 Weak Acid (HA)

- `[H3O+] = (-Ka + sqrt(Ka² + 4·Ka·C)) / 2`
- `[A-] = [H3O+]`
- `[HA] = C - [H3O+]`
- `[OH-] = Kw / [H3O+]`
- `[H2O] = W - [A-]`
- Particles: HA, H2O, A, H3O

### 6.4 Strong Base (MOH)

- `[MOH] = 0`
- `[M+] = C`
- `[OH-] = C`
- `[H3O+] = Kw / [OH-]`
- `[H2O] = W`（**不减 C**）
- Particles: MOH, M, OH（**无 H2O / H3O 粒子层**）

### 6.5 Weak Base (B)

- `[BH+] = (-Kb + sqrt(Kb² + 4·Kb·C)) / 2`
- `[B] = C - [BH+]`
- `[OH-] = [BH+]`
- `[H3O+] = Kw / [OH-]`
- `[H2O] = W - [BH+]`
- Particles: B, H2O, BH, OH

### 源码 **不存在**

- pOH Property
- 可变 volume / dilution / amount（烧杯固定满标 **1 L** 刻度，仅视觉）
- 教科书外的“缓冲溶液 / 滴定”模型
- 粒子动力学 / 碰撞 / 反应动画（仅静态比例可视化）

---

## 7. pH Calculation Chain（必须照搬）

```text
solution.concentrationProperty + solution.strengthProperty
        ↓
solution.getH3OConcentration()   // 各子类公式不同
        ↓
pHProperty = -roundSymmetric(100 * log10([H3O+])) / 100
        ↓
ABSModel.pHProperty 同步当前选中 solution.pHProperty
        ↓
PHMeter 显示 / PHPaper 颜色 / ConductivityTester 亮度
```

实现（`AqueousSolution.ts`）：

```ts
// pH = -log10( [H3O+] )
this.pHProperty = new DerivedProperty( [ this.strengthProperty, this.concentrationProperty ],
  ( strength, concentration ) =>
    -Utils.roundSymmetric( 100 * Utils.log10( this.getH3OConcentration() ) ) / 100, {
      isValidValue: pH => ABSConstants.PH_RANGE.contains( pH ), // [0, 14]
    } );
```

| 项 | Source 事实 |
|---|---|
| pH 来源 | 仅由 `[H3O+]` |
| pOH | **不存在** |
| 水自解离 | Kw = 1e-14；Water 用 sqrt(Kw) |
| 强酸/强碱 | 完全解离近似：`[H3O+]=C` 或 `[OH-]=C` |
| 弱酸/弱碱 | 二次方程（忽略水贡献的简化） |
| 中性 | Water → pH = 7（精确 round 后） |
| 极端 | PH_RANGE [0, 14]；C∈[0.001, 1] |
| Display | `Utils.toFixed(pH, 2)`；探针未入液则空字符串 |
| Rounding | 先 `roundSymmetric(100 * log10)` 再 /100 → **两位小数对称舍入** |

**Oracle 样例（与 source 公式一致，Phase 0 已手算）：**

| Case | Expected pH |
|---|---|
| Water | 7 |
| StrongAcid C=0.010 | 2 |
| StrongAcid C=0.001 | 3 |
| StrongAcid C=1 | 0 |
| WeakAcid Ka=1e-7, C=0.010 | 4.5 |
| StrongBase C=0.010 | 12 |
| WeakBase Kb=1e-7, C=0.010 | 9.5 |

---

## 8. Solution Types / Dataset

### Intro presets（UI 可选）

1. Water (H₂O) — `Water`
2. Strong Acid (HA) — `StrongAcid`
3. Weak Acid (HA) — `WeakAcid`
4. Strong Base (MOH) — `StrongBase`
5. Weak Base (B) — `WeakBase`

Intro **无** 浓度/强度 UI；各 solution 使用各自 `NumberProperty` 默认值（酸/碱 C=0.01；弱 Ka/Kb=1e-7）。PhET-iO 可读/写（非 Water）。

### My Solution custom

| Switch | Maps to |
|---|---|
| Acid + weak | WeakAcid |
| Acid + strong | StrongAcid |
| Base + weak | WeakBase |
| Base + strong | StrongBase |

- **无 Water**
- `concentrationProperty` 写入全部 4 个 solution
- `strengthProperty` **仅**写入 WeakAcid / WeakBase
- Strong strength 保持常数，不同步

---

## 9. Intro Screen Audit

### Play Area

- Beaker（满液 + 右侧刻度 + **1L** 标签）
- Particles magnifying glass（viewMode=particles）或 Concentration graph（graph）或隐藏
- Reaction equation + particle legend（烧杯下方）
- Active tool overlay：pHMeter / pHPaper(+color key) / ConductivityTester

### Control Area

- **Solution** panel：5 AquaRadioButtons（Water…Weak Base）+ 粒子图标
- **Views** panel：Particles / Graph / Hide Views
- **Tools** radio group：pHMeter / pHPaper / conductivityTester
- **Reset All**（右下）

### Controls 明细

| Control | Property | Range | Default | Step | Unit | Mutation | Reset |
|---|---|---|---|---|---|---|---|
| Solution radios | `mutableSolutionProperty` | 5 solutions | Water | n/a | n/a | 切换选中 solution | → Water；各 solution.reset() |
| Views radios | `viewModeProperty` | particles\|graph\|hideViews | particles | n/a | n/a | 切换视图可见性 | → particles |
| Tools radios | `toolModeProperty` | pHMeter\|pHPaper\|conductivityTester（类型含 none 但 UI 无） | pHMeter | n/a | n/a | 切换工具可见；interruptSubtreeInput | → pHMeter |
| pH meter drag | `pHMeter.positionProperty` | Y ∈ [beaker.top−5, beaker.top+60]，X 固定 | (right−65, top−5) | continuous | view units | tip in/out → 显示/清空 pH | 位置复位 |
| pH paper drag | `pHPaper.positionProperty` | dragBounds 在烧杯内 | (right−60, top−10) | continuous | view units | 浸入加深着色%；松手可上浮 | 位置+着色复位 |
| Conductivity probes | ±probe position | Y relative bulb | 初始在烧杯两侧上方 | continuous | view units | 双探针入液 → brightness | 探针复位 |
| Reset All | — | — | — | — | — | model.reset + viewProperties.reset | — |

Intro **无** concentration / strength 控件。

---

## 10. My Solution Screen Audit

### 与 Intro 的共享 / 独立

| | Shared（类） | Independent（实例） |
|---|---|---|
| ABSModel / Beaker / Tools / ABSScreenView / Particles / Graph / Equations | ✓ | 每屏各自 new |
| Solution classes | ✓ | Intro 5 实例；MySolution 4 实例 |
| Water | 仅 Intro | My Solution **无** |
| concentration / strength UI | — | **仅 My Solution** |
| isAcid / isWeak | — | **仅 My Solution** |

### Control Area（My Solution Panel）

| Control | Property | Range | Default | Step / Notes | Unit | Mutation | Reset |
|---|---|---|---|---|---|---|---|
| Acid/Base ABSwitch | `isAcidProperty` | bool | true (Acid) | toggle | — | 重选 solution 类型 | → true |
| Initial Concentration spinner | `concentrationProperty` | 0.001–1 | 0.010 | Δ=0.001；toFixed 3 | mol/L | 写入全部 solutions | → 0.01 |
| Initial Concentration LogSlider | same | log ticks 0.001,0.01,0.1,1 | 0.01 | continuous log | mol/L | same | same |
| Weak/Strong ABSwitch | `isWeakProperty` | bool | true (weak) | toggle；strong 时隐藏 strength slider 但保留占位 | — | 重选 solution | → true |
| Strength LogSlider | `strengthProperty` | 1e-10 … 1e2（WEAK_STRENGTH_RANGE） | 1e-7 | log；仅 weak 可见可拖 | unitless (Ka/Kb) | 写入 weak solutions | → 1e-7 |
| Views / Tools / drags / Reset | 同 Intro 共享 view 结构 | | | | | | |

---

## 11. Play Area / Control Area（精确组成）

### Intro

```text
Play Area:
  - BeakerNode (solution fill + ticks + 1L)
  - ParticlesNode XOR ConcentrationGraphNode XOR none (viewMode)
  - ReactionEquationNode (equation + particle icons)
  - PHMeterNode | PHPaperNode+PHColorKeyNode | ABSConductivityTesterNode

Control Area:
  - IntroSolutionPanel
  - ViewsPanel
  - ToolsRadioButtonGroup
  - ResetAllButton
```

### My Solution

```text
Play Area:  (同 Intro 结构；溶液语义由 MySolutionModel 驱动)
  - BeakerNode / Particles|Graph / Equation / Tools

Control Area:
  - MySolutionPanel (AcidBaseSwitch · InitialConcentrationControl · StrengthControl)
  - ViewsPanel
  - ToolsRadioButtonGroup
  - ResetAllButton
```

布局：`controlsParent` 水平居中于「放大镜把手右侧剩余空间」；垂直 `layoutBounds.centerY`。

---

## 12. Particle / Molecule Visualization

### Particle keys（全集）

`A | B | BH | H2O | H3O | HA | M | MOH | OH`

### Visual

- `createParticleNode(key)` → `AtomNode`（RadialGradient 3D 球）组合；MOH 含 PlusNode/MinusNode 电荷标记
- 颜色：`ABSColors`（H3O=红盲橙 `PhetColorScheme.RED_COLORBLIND`；OH 蓝；A 青；等）
- **H2O 在放大镜内：** 默认不画粒子 canvas；可选 Preferences `showSolvent` → 静态 `solvent.png`（opacity 0.6）
- Canvas：`ParticlesCanvasNode` 预渲染各 particle 到 HTMLCanvas，再 drawImage

### Count logic（**非**布朗运动）

文档：`doc/HA_A-_ratio_model.pdf`  
代码：`getParticleCount(concentration)`：

```text
BASE_CONCENTRATION = 1e-7
BASE_DOTS = 2
MAX_PARTICLES = 200

raiseFactor = log10(c / BASE_CONCENTRATION)
baseFactor = (MAX_PARTICLES/BASE_DOTS) ^ (1 / log10(1/BASE_CONCENTRATION))
count = roundSymmetric(BASE_DOTS * baseFactor^raiseFactor)
```

样例：纯水 [H3O+]=1e-7 → **2** 个；C=0.01 → **54** 个。

### Position

- 极坐标均匀随机：`distance = R * sqrt(U)`，`angle = 2πU`
- **切换溶液 / 改 strength·concentration 时重新采样新增粒子**；减少时截断 count
- **位置非 PhET-iO stateful**（source 注释明确）
- **无 step 驱动的粒子运动** — 静态比例可视化

### Simulation step

- **仅** `PHPaperNode.step(dt)`：松手后纸浸入过深时以 **250 px/s** 上浮到液面附近
- 粒子 **无** clock integration

---

## 13. Chemistry Semantics Table

| Entity | Source class / field | Meaning | Units | Mutable | Derived |
|---|---|---|---|---|---|
| Solution | `AqueousSolution` subclass | 水溶液类型 | — | selection / switches | — |
| Concentration (solute) | `concentrationProperty` | 酸/碱初始浓度 C | mol/L | Intro: default/PhET-iO；MySolution: UI | particle counts, pH, … |
| Water concentration W | `WATER_CONCENTRATION` / Water.concentration | 溶剂水 | mol/L | constant | — |
| Volume | Beaker ticks label only | 视觉 1 L | L | **不可变** | — |
| Strength | `strengthProperty` | Ka 或 Kb | unitless | weak only (MySolution) | [H3O+]/[BH+] |
| pH | `pHProperty` | −log10([H3O+]) rounded | — | no | yes |
| H3O+ | `getH3OConcentration()` | 水合氢离子浓度 | mol/L | no | yes |
| OH- | `getOHConcentration()` | 氢氧根浓度 | mol/L | no | yes |
| Solute [HA]/[B]/… | `getSoluteConcentration()` | 未解离溶质 | mol/L | no | yes |
| Product [A-]/[M+]/[BH+] | `getProductConcentration()` | 解离产物 | mol/L | no | yes |
| Conductivity brightness | `brightnessProperty` | 灯泡亮度 | 0–1 | no | from pH + probe immersion |
| Particle count | `ParticlesCanvasNode` | 可视化数量 | count | no | from concentration |

---

## 14. Numeric Ranges

| Quantity | min | max | default | notes |
|---|---|---|---|---|
| pH | 0 | 14 | (derived) | `PH_RANGE`；display 2 decimals |
| concentration (acid/base) | 1e-3 | 1 | 1e-2 | mol/L；spinner step 0.001 |
| weak strength (Ka/Kb) | 1e-10 | 1e2 | 1e-7 | `WEAK_STRENGTH_RANGE` |
| strong strength | 101 | 101 | 101 | constant marker |
| water concentration | 55.6 | 55.6 | 55.6 | constant |
| water strength | 0 | 0 | 0 | constant |
| particle count | 0 | 200 | — | per particle type |
| conductivity brightness | 0 | 1 | — | pH===7 → **0**（蒸馏水开路，见 issues/233） |
| beaker size | — | — | 360×270 | model units = view px |
| layoutBounds | — | — | **768×504** | ABSScreenView |
| pH paper size | — | — | 16×110 | |
| paper float speed | — | — | 250 px/s | |

**无 dilution range。无可变 volume range。**

---

## 15. Units

Source 实际出现：

| Unit | Where |
|---|---|
| mol/L | concentrationProperty.units；graph Y 轴；Initial Concentration 标签 |
| L | 烧杯刻度 `1L`（`liters` string） |
| pH | 无量纲显示 |
| unitless | strength（Ka/Kb） |
| view pixels | Beaker / drag / paper animation |

Display formatting：

- pH：2 位小数
- concentration spinner：3 位小数
- graph bar：科学计数 / `negligible`（&lt; 1e-13）

**无 mL、无 ions/molecules 物理单位（粒子数为无量纲可视化 count）。**

---

## 16. Reset / Initial State

### Intro initial

- solution = Water
- 各 solution strength/concentration = 各自 Range 默认
- viewMode = particles；toolMode = pHMeter
- pH meter tip **在液面上方**（空白 pH）
- paper percentColored = 0；probes 默认位置

### Intro reset (`IntroModel.reset` → `ABSModel.reset`)

1. 每个 solution.reset()
2. solutionProperty → Water
3. pHMeter / pHPaper / conductivityTester.reset()
4. viewProperties.reset()（via ResetAllButton listener）

### My Solution initial

- isAcid = true；isWeak = true → **WeakAcid**
- concentration = 0.01；strength = 1e-7
- view/tools 同 Intro 默认

### My Solution reset

1. isAcid / isWeak / concentration / strength reset
2. tools reset
3. viewProperties reset

### 不随 Reset All

- `ABSPreferences.showSolventProperty`（Preferences 全局）

---

## 17. Interaction Audit

| Interaction | Target | Continuous? | Model mutation | Release behavior |
|---|---|---|---|---|
| Click AquaRadio | Intro solution | no | `mutableSolutionProperty` | particles canvas reset+rebuild |
| Click AquaRadio | viewMode | no | viewModeProperty | show/hide Particles/Graph |
| Click RectangularRadio | toolMode | no | toolModeProperty | interrupt tool input；切换可见 |
| Drag / KeyboardDrag | pH meter | yes (Y only) | positionProperty | if tip in beaker → show pH |
| Drag / KeyboardDrag | pH paper | yes | positionProperty；percentColored 单调增 | 未按住时 step 上浮 |
| Drag probes | conductivity | yes (Y) | probe positions | both in → brightness from pH |
| ABSwitch Acid/Base | MySolution | no | isAcidProperty | solutionProperty derive |
| ABSwitch weak/strong | MySolution | no | isWeakProperty | hide/show strength slider |
| NumberSpinner ± | concentration | discrete 0.001 | concentrationProperty | sync all solutions |
| LogSlider | concentration | yes | concentrationProperty | same |
| LogSlider | strength | yes | strengthProperty | sync weak only |
| ResetAllButton | all | no | model.reset + viewProperties.reset | — |
| Preferences ToggleSwitch | showSolvent | no | ABSPreferences | solvent.png 可见性 |

Keyboard：两屏均有 KeyboardHelp（拖拽 / Intro 无 slider help；My Solution 含 SliderControls）。

---

## 18. Clock / Animation

```text
Clock source: joist ScreenView.step(dt) → ABSScreenView.step(dt)
dt: frame delta (seconds)
Used by: PHPaperNode.step only (float-up animation @ 250 px/s)
Particles: NO motion integration
Chemistry: instantaneous DerivedProperty (no ODE timestep)
```

语义：**视觉动画 ≠ 化学动力学模拟**。Flutter 不得用 `Random()+Timer` 冒充化学粒子演化。

---

## 19. Assets Audit

### Original raster（`images/`）

| File | Used by | Role |
|---|---|---|
| `solvent.png` | ParticlesNode | Preferences 开启时放大镜内 H2O 背景 |
| `magnifyingGlassIcon.png` | ViewsPanel | Particles 选项图标 |
| `lightBulbIcon.png` | ToolsRadioButtonGroup | 电导率工具图标 |

license.json：PhET 版权；solvent 注明 “screenshot from Java sim”。

### Procedural（禁止擅自换成 PNG）

| Element | Source construction |
|---|---|
| Beaker + liquid + ticks | `BeakerNode` Path/Rectangle |
| Magnifying glass lens/handle | `ParticlesNode` Path/Rectangle |
| Molecules / ions | `AtomNode` + `createParticleNode` |
| Reaction equations / arrows | `ReactionEquationFactory` |
| Concentration bars / graph chrome | `ConcentrationGraphNode` / `ConcentrationBarNode` |
| pH meter / paper / color key | PH*Node |
| Conductivity tester body | scenery-phet `ConductivityTesterNode` |
| Screen icons | IntroScreen / MySolutionScreen factories |
| Reset All | scenery-phet `ResetAllButton`（Flutter → `KratosResetAllButton`） |
| Graph / Hide Views icons | ConcentrationGraphNode.createIcon / BeakerNode.createIcon |

### `assets/` 目录

仅营销截图（alt1/2/3、screen1/2），**非运行时加载**。

---

## 20. Asset Availability

```text
Asset Audit
Required (runtime visual): 3 PNG
Found: 3
Missing: 0
Assets substituted: 0
```

| Asset | Source references | Local file | Available | Impact |
|---|---|---|---|---|
| solvent.png | ParticlesNode | images/solvent.png | YES | — |
| magnifyingGlassIcon.png | ViewsPanel | images/magnifyingGlassIcon.png | YES | — |
| lightBulbIcon.png | ToolsRadioButtonGroup | images/lightBulbIcon.png | YES | — |

依赖库内资源（ResetAll、ConductivityTester 灯泡动画等）属 scenery-phet / tambo 框架，迁移时按 L0/scenery-phet 对等组件处理，**不记为 sim-local missing**。

---

## 21. Audio

```text
Local audio count: 0  (无 sounds/ 目录)
Source audio references: Slider valueChangeSoundGeneratorOptions
  (InitialConcentrationSlider / StrengthSlider · NUMBER_OF_MIDDLE_THRESHOLDS = 23)
Direct SoundClip/SoundPlayer imports in sim js: 0
package.json simFeatures.supportsSound: true
Missing local clips: N/A (uses shared PhET framework sounds)
Used by: My Solution logarithmic sliders
```

**P2 candidate：** Flutter 阶段可用 L0 滑条音效策略；**禁止生成假音频文件**。

---

## 22. Dependencies

### Declared (`dependencies.json`)

acid-base-solutions, assert, axon, brand, chipper, dot, joist, kite, perennial-alias, phet-core, phet-io, phet-io-sim-specific, phet-io-wrappers, phetcommon, phetmarks, query-string-machine, scenery, scenery-phet, sherpa, studio, sun, tambo, tandem, twixt, utterance-queue

### Used by sim `js/` imports（直接）

| Dep | Status |
|---|---|
| axon | Used |
| dot | Used |
| kite | Used |
| joist | Used |
| phet-core | Used |
| phetcommon | Used |
| query-string-machine | Used |
| scenery | Used |
| scenery-phet | Used |
| sun | Used |
| tandem | Used |

### Declared but not directly imported by sim js

| Dep | Notes |
|---|---|
| tambo | 经 sun Slider 音效间接；sim 无直接 import |
| twixt | **Declared but unused** by this sim’s source |
| assert / brand / chipper / sherpa / phetmarks / perennial-alias | 构建/运行时基础设施 |
| phet-io / phet-io-* / studio | PhET-iO 工具链 |
| utterance-queue | a11y 间接 |

---

## 23. Source Tests

```text
Source Tests: 0
```

- 无 `js/*Tests.js`
- 无 `tests/` 目录
- 化学真值文档：`doc/model.md` + `doc/HA_A-_ratio_model.pdf`

**不能因此跳过自建 oracle。**

---

## 24. Chemistry Oracle Candidates（Phase 1 用 · 本阶段不实现）

### Oracle A — Known solution → expected pH

| Input | Expected |
|---|---|
| Water | 7.00 |
| StrongAcid C=1e-2 | 2.00 |
| StrongAcid C=1e-3 | 3.00 |
| StrongAcid C=1 | 0.00 |
| WeakAcid Ka=1e-7 C=1e-2 | 4.50 |
| StrongBase C=1e-2 | 12.00 |
| WeakBase Kb=1e-7 C=1e-2 | 9.50 |

实现须复用 source 的 `roundSymmetric(100*log10)/100`。

### Oracle B — Particle concentration relationships

- StrongAcid: `[HA]=0`, `[A-]=[H3O+]=C`, `[OH-]=Kw/C`
- WeakAcid: `[A-]=[H3O+]`, `[HA]=C-[H3O+]`
- StrongBase: `[MOH]=0`, `[M+]=[OH-]=C`
- WeakBase: `[OH-]=[BH+]`, `[B]=C-[BH+]`
- Water: `[H3O+]=[OH-]=1e-7`

### Oracle C — Concentration change → pH

- StrongAcid：C↑ → pH↓（pH ≈ −log10(C)）
- StrongBase：C↑ → pH↑
- Weak：单调但用二次方程验证若干点

### Oracle D — “Dilution”

Source **无 dilution 操作**。等价 oracle：降低 `concentrationProperty` 后验证浓度/pH/粒子数一致性（非体积稀释物理）。

### Oracle E — Reset → exact initial state

- Intro → Water + defaults + tool positions + viewMode/toolMode
- My Solution → Acid+weak + C=0.01 + strength=1e-7 + tools/view defaults

### Oracle F — Particle count mapping

对给定浓度验证 `getParticleCount`（允许与 PDF/代码 bit-identical）。**位置随机 → 不做像素级粒子位置 oracle。**

### Oracle G — Conductivity

- 开路（任一探针未入液）→ 0
- pH === 7 → **0**（source 特殊分支，**覆盖** model.md 中 C_neutral 公式）
- 否则 `0.05 + 0.95 * |pH-7|/7`

---

## 25. Screenshot Audit

### Screenshot A（用户图 1）

```text
Screen: Intro
State: Water selected; Particles; pHMeter selected; tip above liquid (pH blank); Reset visible
Major regions:
  Play: beaker 1L, magnifying glass with ~2 H3O + ~2 OH, equation 2 H2O ⇌ H3O+ + OH-
  Control: Solution (5 radios, Water on), Views (Particles on), Tools (pH meter on), Reset All
Colors: white bg; panel rgb(208,212,255); solution light cyan; H3O orange; OH blue
Typography: sans-serif PhET fonts
Assets: procedural particles; PNG icons in Views/Tools
```

与 source initial：**一致**（含 pH 空白 = tip 初始在 beaker.top−5）。

### Screenshot B（用户图 2）

```text
Screen: My Solution
State: Acid + weak; concentration 0.010; strength near weaker; Particles; pHMeter;
       equation HA + H2O ⇌ A- + H3O+; lens shows many HA (grey), some A (blue), H3O (orange)
Major regions: same Play/Control split; Solution panel = switches+sliders (not radios)
```

与 source My Solution initial：**一致**（WeakAcid @ 0.01 / 1e-7）。  
若截图中探针看似入液但 pH 仍空：以 source `isInSolutionProperty`（tip 必须在 beaker.bounds 内）为准，可能 tip 仍在液面外或截图压缩错觉。

---

## 26. Layout / Transform Truth

```text
layoutBounds: Bounds2(0, 0, 768, 504)   // ABSScreenView — 明确非默认时不要改（phet-io note）
ModelViewTransform: NONE
Coordinate frames: model ≡ view, 1:1, +x right, +y down
  (doc/implementation-notes.md)
Beaker: size 360×270, position (230, 410) bottom-center
Lens radius: 0.465 * beaker.height; center = beaker.position + (0, -height/2)
ResetAllButton: right/bottom margin 20; scale = layoutBounds.width / DEFAULT_LAYOUT_BOUNDS.width
Panel: fill controlPanelFill; xMargin 15; yMargin 6
Controls: VBox spacing 10; centered in remaining width right of magnifier handle
```

**未来 Flutter 布局真值起点：768×504 逻辑坐标 + 1:1 MVT。**

---

## 27. Screen State Matrix

```text
INTRO
├── Initial: Water · particles · pHMeter · tip out · pH blank
├── Solution variants: Water | StrongAcid | WeakAcid | StrongBase | WeakBase
│     └── equation / particle set / pH / graph bars 切换
├── Concentration variants: (UI 无；默认 C=0.01；PhET-iO 可改)
├── pH changes: 随 solution；meter 入液显示 2 位
├── Particle states: count(c) 静态随机位；solvent PNG optional
├── View modes: particles | graph | hideViews
├── Tools: pHMeter | pHPaper(+color key+float) | conductivityTester
└── Reset → Initial

MY SOLUTION
├── Initial: WeakAcid · C=0.01 · Ka=1e-7 · particles · pHMeter
├── Custom solution states: 2×2 (Acid/Base × weak/strong) → 4 solutions
├── Concentration changes: 0.001…1 (spinner+log slider) → 全溶液同步
├── Strength changes: 1e-10…100 (weak only) → weak 溶液同步
├── pH / particles / graph: 同共享 view 链
├── Particle states: 同上
└── Reset → Initial (含 isAcid/isWeak/c/strength)
```

---

## 28. P0 / P1 / P2

### P0（阻塞迁移启动）

**无。**

核心化学、双屏、Model、交互、资源均可从 local source 解释。

### P1（Phase 1+ 必须认真处理）

1. **弱酸/弱碱二次方程 + pH 两位对称舍入** — 必须 bit-compatible oracle  
2. **粒子数映射算法**（PDF + `getParticleCount`）— 禁止随意 Random 密度  
3. **Conductivity pH===7 → 0** 与 `model.md` 公式差异 — **以代码为准**  
4. **Intro vs MySolution Model 分离** — 禁止合并  
5. **scenery-phet ConductivityTesterNode / ResetAllButton** — Flutter L0 对等  
6. **粒子位置非确定性** — QA 不可要求像素级粒子坐标一致  
7. **Source tests = 0** — 必须自建 Oracle A–G  

### P2

1. 本地无 audio 文件；滑条音效依赖框架（P2 candidate）  
2. `twixt` declared but unused  
3. ToolMode `'none'` 仅类型层，UI 未暴露  
4. ViewsPanel 文件头注释仍提 Solvent checkbox；实际 Solvent 在 Preferences（注释过时，非行为风险）  
5. `assets/` 营销图非运行时依赖  

---

## 29. Prohibitions Checklist（本阶段遵守）

- [x] 未开始正式 Flutter View migration  
- [x] 未写 fake chemistry / 未发明 pH 公式  
- [x] 未用随机粒子替代 source semantics（仅审计）  
- [x] 未搭 Material 近似 UI  
- [x] 未替换 / 生成 assets 或 audio  
- [x] 未修改 Home  
- [x] 未宣布 READY  
- [x] 未把截图当行为唯一真值  
- [x] 已读 local source（不仅官方页）  
- [x] 已设计 chemistry oracle（未实现测试）  

---

## 30. Phase 0 Executive Summary（交付格式）

```text
PHASE 0 STATUS: PASS

Official Screen Count: 2
Local Screen Count: 2

Screens:
1. Intro (IntroScreen / IntroModel / IntroScreenView) — presets include Water
2. My Solution (MySolutionScreen / MySolutionModel / MySolutionScreenView) — no Water; Acid/Base × weak/strong + C + strength

Source Structure:
  js/{common,intro,mysolution} · images/ · doc/model.md · no sounds/ · no tests/

Models:
  ABSModel, IntroModel, MySolutionModel,
  AqueousSolution,{Water,StrongAcid,WeakAcid,StrongBase,WeakBase},
  Beaker, PHMeter, PHPaper, ConductivityTester, ABSPreferences, ABSViewProperties

Core Chemistry:
  Solution: 5 types (Intro) / 4 types (My Solution)
  Acid/Base: HA / MOH / B generics
  Strong/Weak: complete dissociation vs Ka/Kb quadratic
  Concentration: C mol/L in [1e-3,1], default 1e-2
  Volume: fixed visual 1 L (not a model Property)
  pH: -log10([H3O+]) with symmetric 2-decimal rounding; range [0,14]
  H3O+ / OH-: per subclass formulas; Kw=1e-14; W=55.6
  Equilibrium: documented in doc/model.md; matches TypeScript

Chemistry Formula / Calculation Chain:
  C, Ka/Kb → getH3OConcentration() → pHProperty → tools/graph/particles

Units: mol/L, L (label), pH, unitless strength, view pixels

Numeric Ranges: see §14

Initial State / Reset: see §16

Interactions: radios, ABSwitches, log sliders, spinner, tool drags, Reset All (§17)

Clock / Animation: PHPaper float only; particles static (§18)

Play Area / Control Area: §11

MVT / Layout: none; 768×504; 1:1 (§26)

Assets:
  Total required PNG: 3
  Found: 3
  Missing: 0
  Assets substituted: 0

Audio:
  Local: 0
  Source references: slider value-change sounds (framework)
  Missing: N/A (P2)

Dependencies:
  Used: axon, dot, kite, joist, phet-core, phetcommon, query-string-machine, scenery, scenery-phet, sun, tandem
  Declared but unused (direct): twixt; tambo indirect via sliders

Source Tests: 0

Chemistry Oracle Candidates: A–G (§24)

Screenshot Audit: A=Intro Water initial; B=My Solution WeakAcid initial (§25)

P0: (none)
P1: weak quadratic+pH rounding; particle count algorithm; conductivity pH=7 special case; dual models; ConductivityTester/ResetAll L0; non-deterministic particle positions; build oracles
P2: no local audio; twixt unused; ToolMode none; stale ViewsPanel comment

Flutter UI: NOT STARTED
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED

Report: requirements/req-port-acid-base-solutions/PHASE_0_SOURCE_AUDIT.md
```

---

*Phase 0 complete. Do not start Phase 1 until product owner explicitly requests Model migration.*
