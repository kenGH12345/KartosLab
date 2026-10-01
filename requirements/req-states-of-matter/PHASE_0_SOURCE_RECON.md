# PHASE 0 — Source Recon · States of Matter

> 源码根：`phet sourses/states-of-matter-main/states-of-matter-main`  
> 版本：**states-of-matter 1.3.0-dev.3**（`package.json`）  
> 侦察日期：2026-09-15 · **PRIMARY = 本地源码**（网页仅交叉验证）

---

## Source Tree

```
states-of-matter-main/
├── js/
│   ├── states-of-matter-main.ts          # Sim 入口
│   ├── statesOfMatter.ts / StatesOfMatterStrings.ts
│   ├── states/                           # Screen 1 · States
│   │   ├── StatesScreen.ts / StatesIcon.ts
│   │   └── view/ StatesScreenView · StatesMoleculesControlPanel · StatesPhaseControlNode
│   ├── phase-changes/                    # Screen 2 · Phase Changes
│   │   ├── PhaseChangesScreen.ts / PhaseChangesModel.ts / PhaseChangesIcon.ts
│   │   └── view/ PhaseChangesScreenView · PhaseDiagram* · InteractionPotential* · EpsilonControl*
│   ├── atomic-interactions/              # Screen 3 · Interaction
│   │   ├── AtomicInteractionsScreen.ts
│   │   ├── model/ DualAtomModel · MotionAtom · AtomPair · ForceDisplayMode
│   │   └── view/ AtomicInteractionsScreenView · InteractivePotentialGraph · Forces* · Hand/Pin
│   └── common/
│       ├── SOMConstants.ts · SubstanceType.ts · PhaseStateEnum.ts · SOMQueryParameters.ts
│       ├── model/
│       │   ├── MultipleParticleModel.ts          # ★ 多粒子核心
│       │   ├── MoleculeForceAndMotionDataSet.ts  # 归一化并行数组
│       │   ├── LjPotentialCalculator.ts          # 非归一化 LJ（图/双原子）
│       │   ├── InteractionStrengthTable.ts · SigmaTable.ts
│       │   ├── AtomType.ts · MovingAverage.ts · TimeSpanDataQueue.ts
│       │   ├── particle/ ScaledAtom.ts · HydrogenAtom.ts
│       │   └── engine/
│       │       ├── AbstractVerletAlgorithm + Monatomic/Diatomic/Water*
│       │       ├── AbstractPhaseStateChanger + Monatomic/Diatomic/Water*
│       │       ├── *AtomPositionUpdater · WaterMoleculeStructure
│       │       └── kinetic/ IsokineticThermostat · AndersenThermostat
│       └── view/
│           ├── ParticleContainerNode · ParticleImageCanvasNode
│           ├── CompositeThermometerNode · DialGaugeNode · PointingHandNode
│           ├── PotentialGraphNode · InteractionPotentialCanvasNode
│           ├── SubstanceSelectorNode · AtomAndMoleculeIconFactory
│           ├── TitledSlider · SOMColors
├── images/pushPin.png
├── mipmaps/ pointingHand · solidIcon · liquidIcon · gasIcon
├── assets/ 截图（非运行时 UI）
└── states-of-matter-strings_en.json
```

外部依赖（本树未内嵌）：`nitroglycerin/Element`（半径/质量/颜色）、`scenery-phet`（HeaterCoolerNode / BicyclePumpNode / ThermometerNode / GaugeNode / TimeControlNode / ResetAllButton）。

---

## Entry Point

- 文件：`js/states-of-matter-main.ts`
- `simLauncher.launch` → `new Sim(title, [StatesScreen, PhaseChangesScreen, AtomicInteractionsScreen], …)`
- Screen 顺序固定：
  1. `StatesScreen`
  2. `PhaseChangesScreen(true)` → 启用 interaction potential graph
  3. `AtomicInteractionsScreen(false, …)` → **异构分子关闭**（仅同种对）
- 布局：`SOMConstants.SCREEN_VIEW_OPTIONS.layoutBounds = Bounds2(0,0,834,504)`
- 偏好：`supportsProjectorMode: true`

---

## Screen Map

| # | Screen | Model | View | 默认关键 |
|---|---|---|---|---|
| 1 | States | `MultipleParticleModel`（物质不含 ADJUSTABLE） | `StatesScreenView` | Neon · Solid · playing · heater=0 |
| 2 | Phase Changes | `PhaseChangesModel` extends MPM | `PhaseChangesScreenView` | Neon · Solid · 容器高满 · 相图/势图展开 · Adjustable ε=MAX |
| 3 | Interaction | `DualAtomModel` | `AtomicInteractionsScreenView` | Neon-Neon · forces TOTAL/… · NORMAL speed |

跨屏状态：**不共享** Model。Reset All **仅当前屏**。

---

## Model Map

### `MultipleParticleModel`（核心）

| Property / 字段 | 含义 |
|---|---|
| `substanceProperty` | NEON / ARGON / DIATOMIC_OXYGEN / WATER（+ ADJUSTABLE 仅 Phase Changes） |
| `temperatureSetPointProperty` | 模型温度（0.15 solid / 0.34 liquid / 1.0 gas） |
| `temperatureInKelvinProperty` | Derived · 物质相关 triple/critical 分段映射；无原子 → null |
| `pressureProperty` | 显示用 atm（`5 * modelPressure`） |
| `containerHeightProperty` | 容器高度 pm（初值 10000） |
| `isExplodedProperty` | 超压爆炸 |
| `isPlayingProperty` | 播放 |
| `heatingCoolingAmountProperty` | [-1, 1] |
| `targetNumberOfMoleculesProperty` | 目标分子数（泵注入） |
| `moleculeDataSet` | 归一化力/运动数据集 |
| `scaledAtoms` | 视图用原子（pm） |
| 策略对象 | Verlet / PhaseStateChanger / Isokinetic / Andersen |

### `PhaseChangesModel` 增量

- `targetContainerHeightProperty` [1500, 10000]
- `adjustableAtomInteractionStrengthProperty` [MIN_ADJ_ε, MAX_ADJ_ε]
- `phaseDiagramExpandedProperty` / `interactionPotentialExpandedProperty`
- `lidAboveInjectionPointProperty`
- 限速伸缩：expand ≤ 1500/s · shrink ≤ 1250/s

### `DualAtomModel`

- `fixedAtom` / `movableAtom`（`MotionAtom`）
- `attractiveForce` / `repulsiveForce`
- `atomPairProperty` · `forcesDisplayModeProperty` · `timeSpeedProperty`
- `adjustableAtomDiameterProperty` / `adjustableAtomInteractionStrengthProperty`
- 1D LJ 沿 x · `LjPotentialCalculator` · 质量 kg 换算 `1.6605402e-27`

---

## Physics Map

| 层 | 实现 | 要点 |
|---|---|---|
| 积分 | Velocity Verlet（`AbstractVerletAlgorithm`） | 位置 → 力 → 速度；含重力 |
| 分子间力（多粒子） | **归一化 LJ**（直径=1） | `F = 48·r2inv·r6inv·(r6inv-0.5)·ε`；截断 r²&lt;6.25；下限 r²≥0.90 |
| 分子间力（图/双原子） | `LjPotentialCalculator` | `V=4εk[(σ/r)^12-(σ/r)^6]`；F_rep/F_att 分项 |
| 水 | `WaterVerletAlgorithm` | “hollywood◔” 电荷 + 排斥缩放 + 低温重力增强 |
| 墙碰撞 | 归一化 inset=1；顶盖叠 lid 速度 | 侧墙累加压力（y&gt;0.3H） |
| 恒温器 | Isokinetic / Andersen | 按温度区间与状态切换；**禁止**简单 `v∝T` 替代 |
| 相配置 | `*PhaseStateChanger` | Solid 晶格 / Liquid **硬编码快照** / Gas 随机；再设 T |
| 压力 | Verlet 墙冲量 → 时间窗平均 → ×5 atm | **非** PV=nRT 主算 |
| 爆炸 | model P&gt;41 持续 &gt;1s | 盖飞离；高度膨胀 |

**禁止**：用气体族 `GasLawSolver` / 硬球碰撞替换本引擎。

---

## State Map

| 枚举 | 值 |
|---|---|
| `SubstanceType` | NEON · ARGON · DIATOMIC_OXYGEN · WATER · ADJUSTABLE_ATOM |
| `AtomType` | NEON · ARGON · OXYGEN · HYDROGEN · ADJUSTABLE |
| `PhaseStateEnum` | SOLID · LIQUID · GAS · UNKNOWN |
| `ForceDisplayMode` | COMPONENTS · TOTAL · HIDDEN |
| `AtomPair`（Interaction） | NEON_NEON · ARGON_ARGON · ADJUSTABLE（异构关闭） |

相变 UI 按钮 → `setPhase` → **重排粒子 + 设温度**，不是运行时 `if (T>x) gas`。

---

## Clock Map

| 项 | 值 / 行为 |
|---|---|
| Screen `maxDT` | `SOMConstants.MAX_DT = 0.320` |
| 标称步 | `NOMINAL_TIME_STEP = 1/60` |
| 多粒子加速 | `PARTICLE_SPEED_UP_FACTOR = 4` |
| 子步上限 | `MAX_PARTICLE_MOTION_TIME_STEP = 0.025` + residualTime |
| Pause | `isPlayingProperty=false` → 不推进物理；读数保持 |
| Step | `stepInTime(NOMINAL_TIME_STEP)` 单步 |
| DualAtom | NORMAL×2 / SLOW×0.5；内部 max 0.005 |
| Flutter | **复用** `lib/common/simulation_clock.dart` 驱动 `step(dt)` |

---

## View Map

### States

`ParticleContainerNode` · `HeaterCoolerNode` · `StatesMoleculesControlPanel` · `StatesPhaseControlNode` · `TimeControlNode` · `ResetAllButton`

### Phase Changes

上列 + `BicyclePumpNode` · `PointingHandNode` / lid Handle · `DialGaugeNode` · `returnLidButton` · `PhaseDiagramAccordionBox` · `InteractionPotentialAccordionBox` / `EpsilonControlPotentialGraph` · `PhaseChangesMoleculesControlPanel`（含 Adjustable + ε slider）

### Interaction

`InteractivePotentialGraph` · `ForcesAccordionBox` · `GrabbableParticleNode` · `HandNode` · `PushPinNode` · 控制面板 · TimeControl · ResetAll

### Container 内层

`ParticleImageCanvasNode`（运行时生成精灵）· 透视容器 Path · lid · `CompositeThermometerNode` ·（可选）压力表 / 手

---

## Interaction Map

| 交互 | 绑定 |
|---|---|
| 加热/冷却拖条 | `heatingCoolingAmountProperty`；paused/exploded 禁用 |
| 物质单选 | `substanceProperty` → 重建粒子 |
| 相态按钮（States） | `setPhase(SOLID/LIQUID/GAS)` |
| 活塞手拖（Phase Changes） | `setTargetContainerHeight` |
| 打气筒 | 每泵注入 3 分子 → `targetNumberOfMoleculesProperty` |
| Return Lid | `returnLid()` |
| ε / σ 拖（图） | adjustable strength / diameter |
| 可动原子拖（Interaction） | 暂停运动 · 改 x · 释放继续 |
| Play/Pause/Step | `isPlayingProperty` / `stepInTime` |
| Reset All | `model.reset()` + 视图子节点 reset |

---

## Measurement / Readout Map

| 仪器 | 源 | 单位 / 备注 |
|---|---|---|
| Thermometer | `temperatureInKelvinProperty` | K（可选 °C query） |
| DialGauge | `pressureProperty` | atm；周期 ~100ms；overload 文案 |
| Phase Diagram marker | 温度历史平均 + 压力 | Adjustable 时隐藏 |
| Potential graph | ε,σ + 当前距离标记 | Phase Changes / Interaction |
| Force arrows | F_att / F_rep / total | Interaction |

---

## Reset Map

`MultipleParticleModel.reset()`：

- 所有 Property 复位
- 恒温器 bias 清零
- 若物质未变：清原子 → `initializeAtoms(SOLID)`
- 重力复位 · `resetEmitter.emit()`

Phase Changes 额外：target height / ε / accordion 展开态 / 泵 / 温度历史。  
Interaction：原子对、力显示、可调参数、位置。

---

## Asset Map（运行时）

| 资源 | 路径 | 用途 |
|---|---|---|
| `pointingHand.png` | `mipmaps/` | 活塞手 |
| `solidIcon.png` / `liquidIcon.png` / `gasIcon.png` | `mipmaps/` | 相态按钮 |
| `pushPin.png` | `images/` | Interaction 固定针 |
| 粒子球体 | **Canvas 运行时生成**（非静态 PNG） | `ParticleImageCanvasNode` |
| 容器 / 温度计 / 表盘 / 加热器 / 泵 | scenery-phet 程序绘制 | Flutter 用 Painter / 已有气体族几何参考 |

**Substituted Assets 目标：0。** 禁止 Material Icons / emoji。

Element 属性（自 nitroglycerin，与 `BamElement` 一致）：

| 原子 | r_vdW (pm) | mass (u) | color |
|---|---|---|---|
| Ne | 154 | 20.1797 | `#1AFFFB` |
| Ar | 188 | 39.948 | `#FFAFAF` |
| O | 152 | 15.9994 | `#FF5500`（RED_COLORBLIND） |
| H | 120 | 1.00794 | `#FFFFFF` |
| Adjustable | 175 | 25 | `#CC66CC` |

---

## Reusable KARTOSLAB Components

| 项 | 决策 | 路径 |
|---|---|---|
| `SimulationClock` | REUSE | `lib/common/simulation_clock.dart` |
| `KratosTabbedScreen` | REUSE | `lib/common/widgets/kratos_tab_bar.dart` |
| Slider / Radio / Combo | REUSE（PhET 外观包装） | `lib/common/controls/*` |
| Chart | REUSE 模式 | `lib/common/chart/*`（势图多为自定义 Painter） |
| `shaded_sphere` | REUSE 绘制 | `lib/gas_properties/painters/shaded_sphere.dart` |
| Thermometer / Gauge painters | EXTEND 几何 | `lib/gases_intro/painters/*` |
| HeaterCooler UI | EXTEND 资产模式 | `lib/energy_forms_and_changes/.../heater_cooler_control.dart` |
| Gas IdealGas / hard-sphere solvers | **DO NOT REUSE as physics** | — |
| Visual QA toolchain | REUSE | `tool/capture_*.js` · `tool/diff_visual_qa.py` |
| Home | **DEFER** | `lib/screens/home_screen.dart`（Final Gate 后） |

代码落点：`lib/chemistry/states_of_matter/`（对齐 molecule_polarity）。

---

## Risks / Unknowns

1. **Liquid / Water solid 硬编码快照**（`MonatomicPhaseStateChanger.ts` ~2091 行）必须原样移植，不可算法“近似”。
2. **O(N²) 归一化 LJ** + N≤500 → Dart 热循环性能需实测；优先单 Canvas。
3. **Water hollywood 电荷模型** 非教科书物理，必须跟源码。
4. **恒温器切换阈值** 对“看起来像固/液/气”极敏感。
5. scenery-phet 控件（泵、加热器）需资产级对齐，不可 Material 替代。
6. 本地源码 vs 网页 latest 若有差 → **以本地 1.3.0-dev.3 为准**。
7. Projector mode / stickyBurners / defaultCelsius query → P2 可后置，但需登记。

---

## Coordinate Notes

- Model 原点：容器左下；**Y 向上**；宽高初值 **10000 pm**
- 归一化：`x_norm = x_pm / particleDiameter`
- MVT：`createSinglePointScaleInvertedYMapping` · 模型 (0,0) → `(0.325W, 0.75H)` · scale = `280/10000`
- Flutter Screen Y 向下 → 必须统一 transform，禁止散落 magic numbers
