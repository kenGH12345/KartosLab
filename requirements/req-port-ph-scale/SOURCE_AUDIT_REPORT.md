# pH Scale — Phase 0 Source Audit Report

> **req-id**: `req-port-ph-scale`  
> **Audit date**: 2026-09-22  
> **Auditor**: KartosLab Flutter migration agent  
> **Priority order used**: Local PhET source → original assets → user screenshots → online sim → Flutter convenience  
> **Gate**: Phase 0 — **PASS**（完整审计完成；未写 Flutter UI）

---

## 1. Version

| Field | Value |
|-------|-------|
| Package name | `ph-scale` |
| `package.json` version | **1.8.0-dev.0** |
| `dependencies.json` comment | ph-scale **1.7.0-dev.6** (Wed Sep 03 2025) |
| Local tree SHA (`dependencies.json` → `ph-scale.sha`) | `9026dbeca73543f3cc3967dac553ae412bfbca18` (branch `main`) |
| Local checkout | **NO_GIT**（zip 解压树，无 `.git`） |
| License | GPL-3.0 |
| Repo | https://github.com/phetsims/ph-scale.git |
| Online sim | https://phet.colorado.edu/sims/html/ph-scale/latest/ph-scale_all.html |
| Local path | `phet sourses/ph-scale-main/ph-scale-main` |
| Entry | `js/ph-scale-main.ts` |
| Screens (confirmed from source) | **3**：Macro → Micro → My Solution |

### Key dependency SHAs (`dependencies.json`)

| Repo | SHA |
|------|-----|
| axon | `ed97fe3915f9f87f9fe9f988c222ad3939afc3ea` |
| joist | `b00004aff22150077bdcd4958ad47c0c5d9078e8` |
| scenery | *(in dependencies.json)* |
| scenery-phet | *(local sibling present)* |
| sun | *(declared)* |
| phet-core | `065ce7313d388e44428eb30de8aaf10622330ae7` |
| dot | `fc882c815833b67ec5e5a093fb972aef234ff424` |

Local sibling available: `phet sourses/scenery-phet`（FaucetNode / EyeDropperNode / ProbeNode / ResetAllButton / ShadedSphereNode 资产与实现）。

---

## 2. Screens

**Confirmed exclusively from source** — not from screenshots.

```22:26:phet sourses/ph-scale-main/ph-scale-main/js/ph-scale-main.ts
  const screens = [
    new MacroScreen( Tandem.ROOT.createTandem( 'macroScreen' ) ),
    new MicroScreen( Tandem.ROOT.createTandem( 'microScreen' ) ),
    new MySolutionScreen( Tandem.ROOT.createTandem( 'mySolutionScreen' ) )
  ];
```

`package.json` `screenNameKeys`（同序）:

1. `PH_SCALE/screen.macro`
2. `PH_SCALE/screen.micro`
3. `PH_SCALE/screen.mySolution`

| # | Screen | Model | View | Key differentiators |
|---|--------|-------|------|---------------------|
| 1 | **Macro** | `MacroModel` → `MacroSolution` + `MacroPHMeter` | `MacroScreenView` | 可拖探针 + 0–14 色标 + 导线；无 Graph / Ratio / Particle Counts |
| 2 | **Micro** | `MicroModel` → `MicroSolution` + `SolutionDerivedProperties` | `MicroScreenView` | 只读 pH Accordion；对数+**线性** Graph；Ratio / Particle Counts |
| 3 | **My Solution** | `MySolutionModel` → `MySolution` | `MySolutionScreenView` | **无**溶质/滴管/水龙头；可编辑 pH Spinner；仅对数 Graph（**可拖指标改 pH**） |

**迁移硬性要求：三屏全部迁移，禁止只做 Macro。**

---

## 3. Models

### 3.1 Architecture

```
TModel
├── PHModel<T extends Solution>          // Macro / Micro 公共
│   ├── dropper, waterFaucet, drainFaucet
│   ├── beaker (1.2 L)
│   ├── solution: T
│   ├── isAutofillingProperty
│   ├── step(dt) / reset() / startAutofill()
│   ├── MacroModel  → + MacroPHMeter + probeJumpPositions
│   └── MicroModel
│
└── MySolutionModel                      // 独立
      └── MySolution (pH + totalVolume)

PhetioObject
├── Solution                             // Macro/Micro 基类
│   ├── MacroSolution                    // 无 derivedProperties
│   └── MicroSolution                    // + SolutionDerivedProperties
└── MySolution                           // 不继承 Solution
```

`SolutionDerivedProperties`：组合挂载（Micro / My Solution），提供 `[H2O]/[H3O+]/[OH-]`、moles、particle counts。

### 3.2 Base state（最高优先级结论）

| Screen | **Independent state** | Derived |
|--------|----------------------|---------|
| Macro / Micro | `soluteVolume` (L) + `waterVolume` (L) + `solute.pH`（库存） | `totalVolume`, `pH`, `color`；（Micro）浓度/摩尔/粒子数 |
| My Solution | **`pH`** + **`totalVolume`** | 浓度/摩尔/粒子数；颜色恒为水 |

**禁止**把 pH 当作 Macro/Micro 的独立 Slider 基态。  
**禁止**把 concentration 当作基态——浓度由 pH + volume 派生。

### 3.3 Default state

| Screen | Default |
|--------|---------|
| Macro | `Solute.WATER`；启动 autofill → **0.5 L** 水；探针初位在烧杯外/附近 → 未浸入时 pH 显示 `null`（破折号）；浸入后 ~7.00 |
| Micro | 同 autofill 0.5 L Water；pH Accordion 展开只读 7.00；Graph 展开、对数、mol/L；Ratio/ParticleCounts **关** |
| My Solution | `pH=7`，`volume=0.5 L`，水色；无龙头/滴管；Spinner + 对数 Graph |

---

## 4. Chemistry

### 4.1 核心结论（反直觉，必须遵守）

1. **无 Ka/Kb、无强弱电解质区分、无缓冲方程**  
   每个 `Solute` 只有固定库存 `pH` + 颜色。稀释 = 体积加权 `[H3O+]`（酸）或 `[OH-]`（碱）。
2. **水浓度 = 55 mol/L，不是 55.6**（`Water.ts` L16）。
3. **隐含 Kw**：全程硬编码常数 `14`（`pH + pOH = 14`），源码无 `Kw` 符号。
4. **Avogadro = `6.023E23`**（`PHModel.ts` L30）——非 `6.022×10²³`。

### 4.2 Formulas（`PHModel.ts`）

| 关系 | 公式 | 行号 |
|------|------|------|
| 酸混合 | `pH = -log10( (10^(-pHs)·Vs + 10^(-7)·Vw) / V )` | L247–249 |
| 碱混合 | `pH = 14 + log10( (10^(pHs-14)·Vs + 10^(7-14)·Vw) / V )` | L250–252 |
| `[H3O+] = 10^(-pH)` | `pHToConcentrationH3O` | L310–312 |
| `[OH-] = 10^(-(14-pH))` | `pHToConcentrationOH` | L319–321 |
| `pH = -log10([H3O+])` | `concentrationH3OToPH` | L261–263 |
| `pH = 14 - (-log10([OH-]))` | `concentrationOHToPH` | L270–273 |
| `[H2O] = 55`（V>0） | `volumeToConcentrationH20` | L300–302 |
| `N = c·V·6.023e23` | `computeParticleCount` | L326–328 |
| `moles = c·V` | `computeMoles` | L333–335 |

边界：

- `V=0` → pH = `null`
- `Vw=0` → pH = `solutePH`（防 log 浮点误差）
- `Vs=0` → pH = `Water.pH`（7）

### 4.3 Solute table（库存 pH）

| Solute | pH | stockColor RGB | colorStop（稀释插值，可选） |
|--------|-----|----------------|---------------------------|
| Battery Acid | 1 | (255,255,0) | (255,224,204) |
| Vomit | 2 | (255,171,120) | (255,224,204) |
| Soda | 2.5 | (204,255,102) | (238,255,204) |
| Orange Juice | 3.5 | (255,180,0) | (255,242,204) |
| Coffee | 5 | (164,99,7) | (255,240,204) |
| Chicken Soup | 5.8 | (255,240,104) | (255,250,204) |
| Milk | 6.5 | (250,250,250) | — |
| Water | 7 | (224,255,255) | — |
| Blood | 7.4 | (211,79,68) | (255,207,204) |
| Spit | 7.4 | (202,240,239) | — |
| Hand Soap | 10 | (224,141,242) | (232,204,255) |
| Drain Cleaner | 13 | (255,255,0) | (255,255,204) |

ComboBox 顺序：英文字母序（`PHModel.ts` SOLUTES 数组）。

### 4.4 Dilution / volume ops

| Op | Method | Behavior |
|----|--------|----------|
| 加水 | `addWater` | ↑ `waterVolume`，受 `maxVolume` |
| 加溶质 | `addSolute` | ↑ `soluteVolume` |
| 排水 | `drainSolution` | **按比例**同时减水与溶质；`< MIN_VOLUME(0.01)` 清零 |
| 换溶质 | `soluteProperty` link | **清空**体积 → autofill 0.5 L 新溶质（若 preferences autofill） |

Faucet / Dropper rates：

| | maxFlowRate |
|--|------------|
| Water / Drain faucet | **0.25 L/s** |
| Dropper（手动） | **0.05 L/s** |
| Autofill dropper | **0.45 L/s** → 目标 **0.5 L** |
| tapToDispense | 0.05 L / 333 ms |

Beaker capacity：`BEAKER_VOLUME = 1.2` L。

### 4.5 Solution color

- **Macro/Micro**：`Solution.colorProperty`  
  - V=0 → 黑（不显示）  
  - 无溶质 **或** 显示 pH ≈ 7.00（`isPHofWater`）→ `Water.color`  
  - 否则 `solute.computeColor(soluteVol/total)`（可选两段插值 `colorStopRatio` 默认 0.25）
- **My Solution**：颜色 **恒为** `Water.color`，**不随 pH 变**

**禁止**三段式 `pH<7→红 / =7→绿 / >7→蓝`。

### 4.6 Macro pH probe

- Model：`MacroPHMeter.pHProperty` 初值 `null`；**不在 model 判断浸入**
- View（`MacroPHMeterNode`）碰撞检测：

| Probe overlaps | Display |
|----------------|---------|
| Beaker solution / drain stream | `solution.pH` |
| Water faucet stream | `Water.pH` (7) |
| Dropper fluid | `dropper.solute.pH` |
| Else | `null`（破折号） |

---

## 5. Particle Model

### 5.1 两套粒子系统（禁止混淆）

| System | Where | Count formula | Visual |
|--------|-------|---------------|--------|
| **Particle Counts**（真实化学） | `SolutionDerivedProperties` + `ParticleCountsNode` | `N = c·V·6.023e23`，科学计数法显示 | 球分子图例：`H2ONode`/`H3ONode`/`OHNode` = `ShadedSphereNode`（O⌀30, H⌀15） |
| **Ratio view**（视觉缩放） | `RatioNode` → `ParticlesCanvas` | 中性各 50（共 100）；pH∈[6,8] 对数；外推至 max 3000；少数物种最少 5 | **扁平圆点** r=3，红/蓝，Canvas 批量绘制；**无运动动画** |

Ratio 常数（`RatioNode.ts` L42–45）：

```
TOTAL_PARTICLES_AT_PH_7 = 100
MAX_MAJORITY_PARTICLES = 3000
MIN_MINORITY_PARTICLES = 5
LOG_PH_RANGE = [6, 8]
```

物种：**仅** H₂O / H₃O⁺ / OH⁻。**无溶质分子粒子。**

### 5.2 Flutter 实现约束

- Ratio：`CustomPainter` / Canvas，禁止每粒子一个 StatefulWidget
- Particle Counts：数字 + 球分子图例（几何球体，非 PNG）
- 禁止用无关 `Timer + random circles` 冒充最终 Ratio / Counts

---

## 6. Graph

| Feature | Micro | My Solution |
|---------|-------|-------------|
| Logarithmic | ✅（默认） | ✅（唯一） |
| Linear | ✅ `hasLinearFeature: true` | ❌ |
| Units switch | Concentration ↔ Quantity | 同 |
| Default units | `MOLES_PER_LITER` | 同 |
| Default scale | `LOGARITHMIC` | 同 |
| Log exponent range | −16 … 2 | 同 |
| Linear exponent | −14 … 1；mantissa 0…8 | — |
| Draggable H3O+/OH− indicators | ❌（DerivedProperty 只读） | ✅ → 写入 `pHProperty` |
| H2O indicator | 只读 | 只读 |

驱动量：`concentrationH2O/H3O/OH` 或 `quantityH2O/H3O/OH`。  
**禁止**用 Flutter Chart package 生成「差不多」的图。

---

## 7. Views / Controls

### Shared（Macro + Micro）

- `BeakerNode`, `SolutionNode`, `VolumeIndicatorNode`
- `PHDropperNode` ← scenery-phet `EyeDropperNode`
- `WaterFaucetNode` / `DrainFaucetNode` ← scenery-phet `FaucetNode`
- `FaucetFluidNode` / `DropperFluidNode`（矩形流）
- `SoluteComboBox`
- `ResetAllButton`（scenery-phet，scale **1.32**）

### Macro-only

- `MacroPHMeterNode` + `MacroPHProbeNode` + `WireNode` + `ScaleNode` + `PHIndicatorNode`
- `NeutralIndicatorNode`（显示 pH≈7.00 时）

### Micro / My Solution

- `PHAccordionBox`（Micro 只读 NumberDisplay；My Solution + `PHSpinnerNode`）
- `GraphNode` + switches
- `BeakerControlPanel`：`H3O+/OH- Ratio`、`Particle Counts`（默认关）
- `RatioNode`, `ParticleCountsNode`

### Pause / Step

**不存在。** `ph-scale-main.ts` 未配置 `hasStepButton` / play-pause。  
Macro/Micro 仅有 joist 时钟驱动的 `step(dt)` 做流体体积积分。

---

## 8. Assets

### 8.1 ph-scale 仓库运行时贴图（仅 6 个屏幕图标）

| Original | Usage |
|----------|-------|
| `images/macroHomeScreenIcon.png` | Macro home icon |
| `images/macroNavbarIcon.png` | Macro navbar |
| `images/microHomeScreenIcon.png` | Micro home |
| `images/microNavbarIcon.png` | Micro navbar |
| `images/mySolutionHomeScreenIcon.png` | My Solution home |
| `images/mySolutionNavbarIcon.png` | My Solution navbar |

**无 mipmap、无 SVG。** 烧杯、色标、流体、粒子、探针主体均为程序绘制。

### 8.2 scenery-phet 依赖资产（必须复用）

| Asset | Path under `phet sourses/scenery-phet/images/` |
|-------|-----------------------------------------------|
| Faucet body / pipes / handle（约 11 PNG） | faucet*.png |
| Eye dropper | `eyeDropperBackground.png`, `eyeDropperForeground.png` |

探针：`ProbeNode` 程序绘制（非 PNG）。  
分子图例：`ShadedSphereNode` 几何。

### 8.3 ASSET_MAP 目标

Phase 5 建立 `ASSET_MAP.md`：

```
Original reused = YES
Substituted = 0
```

禁止 Material Icons / Emoji 冒充水龙头、滴管、Reset。

---

## 9. Layout

| Constant | Value | Source |
|----------|-------|--------|
| layoutBounds | **1100 × 700** | `PHScaleConstants.ts` L27 |
| BEAKER_VOLUME | 1.2 L | L54 |
| BEAKER_POSITION | (750, 580) | L55 |
| BEAKER_SIZE | 450 × 300 | L56 |
| PH_RANGE | −1 … 15，default 7 | L60 |
| PH decimal places | 2 | L61 |
| VOLUME decimal places | 2 | L69 |
| MIN_SOLUTION_VOLUME（可见） | 0.015 L | L70 |
| Model↔View | **Identity** transform | Screen factories |
| Volume → liquid height | `linear(0, beaker.volume, 0, height, V)` | `SolutionNode.ts` |
| Dropper | beaker.x−50, above beaker −15 | `PHModel.ts` |
| Water faucet | beaker.right−50, above | `PHModel.ts` |
| Drain faucet | beaker.left−75, beaker.y+43 | `PHModel.ts` |
| Reset All | layoutBounds.right−40, bottom−20；scale 1.32 | ScreenViews |
| Macro ScaleNode | ~55×450（meter 内）/ 默认 75×450 | ScaleNode / Meter |
| Scale gradient | top=basic `#4681CE` → mid=white → bottom=acidic `#EE4F49` | `ScaleNode.ts` |

---

## 10. Animations

| Kind | Mechanism |
|------|-----------|
| Fluid fill/drain | `PHModel.step(dt)` 积分 flowRate |
| Autofill | dropper 0.45 L/s → 0.5 L |
| Faucet/dropper stream | 矩形宽/高 ∝ flowRate（非粒子） |
| Ratio particles | **无运动**；pH 变时重算位置与数量 |
| My Solution | **无** `step` |

生命周期要求（Flutter）：

```
enter screen → start ticker (Macro/Micro only)
leave screen → stop ticker
reset → restore model + view properties
no duplicate timers / listeners
```

---

## 11. Reset

| Object | Restores |
|--------|----------|
| `Solution` | volumes → 0 |
| `PHModel` | dropper + solution + faucets → `startAutofill()` |
| `MacroModel` | + meter (pH→null, probe position) |
| `MySolution` | pH→7, volume→0.5 |
| Graph / view props | expanded、units、scale、checkboxes |

Acceptance：任意改变后 Reset All → 与首次启动一致（含 autofill 后的 0.5 L）。

---

## 12. Preferences（次要，需记录）

- `autoFillEnabledProperty`：query `autofill` 默认 **true**
- 自定义 Preferences 面板：`PHScalePreferencesNode`

Flutter MVP：默认开启 autofill；Preferences UI 可后置为 P2（除非 Home 规范要求）。

---

## 13. Flutter placement（预备）

| Item | Plan |
|------|------|
| Dart package path | `lib/chemistry/ph_scale/` |
| Home category | **化学**（`lib/chemistry/` 已有 molarity / build_a_molecule / …） |
| L0 reuse | `KratosResetAllButton`；faucet/dropper 优先移植 scenery-phet PNG |
| Tests | `test/ph_scale/`（model 优先）+ Home lifecycle |
| Requirements | `requirements/req-port-ph-scale/` |

当前仓库：**无**既有 `ph_scale` 实现。

---

## 14. Phase plan (aligned to source)

| Phase | Focus | Gate |
|-------|-------|------|
| **0** | Source Audit（本文件） | ✅ PASS |
| **1** | Model：Water / Solute / Solution / PHModel 公式 / MySolution + unit tests | Model tests PASS |
| **2** | Core View：Beaker / liquid / faucets / dropper / combo / Macro meter+scale | Macro interactive |
| **3** | Particles：Ratio Canvas + Particle Counts + 球分子图例 | Ratio/Counts PASS |
| **4** | Graph（log+linear）+ Micro + My Solution 全屏 | All 3 Screens PASS |
| **5** | Visual Reconstruction + ASSET_MAP | Visual CANDIDATE/PASS |
| **6** | Behavioral Acceptance | Behavior PASS |
| **7** | Full Regression `flutter test` + `dart analyze` | Regression PASS |
| **8** | Home Integration + lifecycle | Home PASS |
| **9** | Platform verify + Final Status | READY / READY CANDIDATE |

---

## 15. Unknowns / Risks

| ID | Item | Mitigation |
|----|------|------------|
| U1 | sun / joist / scenery 未完整 sibling checkout | 行为以 ph-scale 源码为准；控件视觉对照 scenery-phet + 截图 |
| U2 | Macro 探针初位 vs 截图「未浸入显示破折号」 | 严格按 MacroPHMeterNode 碰撞逻辑；默认探针位置对齐源码 |
| U3 | Ratio 随机位置种子 | 查 `PHScaleQueryParameters` / `dotRandom`；可接受视觉随机，数量算法必须一致 |
| U4 | Autofill preferences | 默认 true；与官方一致 |
| U5 | ResetAllButton scale 1.32 vs 项目 L0 radius 20.5 | 视觉对齐源码 scale；实施时用 `KratosResetAllButton` 调 radius 匹配 |
| U6 | 无 Pause/Step | 不实现；不报告为缺失功能 |

---

## 16. Phase 0 Checklist (Gate)

| Required section | Status |
|------------------|--------|
| Version | ✅ |
| Commit / SHA | ✅ `9026dbec…` |
| Screens (count/names/order) | ✅ 3 confirmed |
| Models | ✅ |
| Views | ✅ |
| Assets | ✅ |
| Controls | ✅ |
| Chemistry | ✅ |
| Particle Model | ✅ |
| Graph | ✅ |
| Animations | ✅ |
| Reset | ✅ |
| Default State | ✅ |
| Layout | ✅ |
| Unknowns | ✅ |

---

## Phase 0 Status

```text
Status: PASS

Tests: N/A (audit only)
Analyze: N/A
Model: UNCHANGED (not started)
View: UNCHANGED (not started — gate forbids UI before Phase 0)
Assets: Original inventory complete; Substituted: N/A

P0: 0
P1: 0
P2: 0

Visual: N/A
Known Issues: none blocking Phase 1
Next Gate: PHASE 1 — Model reconstruction + chemistry unit tests
```
