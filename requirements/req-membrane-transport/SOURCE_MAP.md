# Membrane Transport · SOURCE_MAP

> PHASE 0 — Source Archaeology  
> 本地源：`phet sourses/membrane-transport-main/membrane-transport-main`  
> 官方：https://phet.colorado.edu/sims/html/membrane-transport/latest/membrane-transport_all.html  
> 标记：`[已确认]` / `[推测]` / `[待确认]`  
> **本阶段未写 Flutter 业务代码、未拷贝 assets 到 Flutter**

---

## PHASE: 0 — Source Archaeology
## STATUS: DONE (archaeology) · Flutter: NOT STARTED

配套产物：

| 文件 | 状态 |
|------|------|
| `FUNCTION_MAP.md` | DONE |
| `NUMERICAL_MODEL.md` | DRAFT from source |
| `RESET_SEMANTICS.md` | DONE |
| `VISUAL_ASSET_AUDIT.md` | DONE (inventory) |
| `RISK_REGISTER.md` | DONE |
| `COMPONENT_MAP.md` | STUB |
| `LAYOUT_SPEC.md` | STUB → Phase 1 |

---

## 1. Simulation Identity

| 项 | 值 | 证据 | 标记 |
|----|-----|------|------|
| Name | Membrane Transport | `package.json` / README | `[已确认]` |
| package.json version | `1.1.0-dev.0` | `package.json` | `[已确认]` |
| dependencies snapshot | `1.0.0-dev.28` (2025-09-09) | `dependencies.json` comment | `[已确认]` |
| Published release | **1.0** (Oct 1, 2025) | `doc/release-notes.md` | `[已确认]` |
| Main commit (deps) | `a06047f9b76e381390548f9f7318a1fcd3294e32` | `dependencies.json` → membrane-transport.sha | `[已确认]` |
| License | GPL-3.0 | `package.json` | `[已确认]` |
| Namespace | `MEMBRANE_TRANSPORT` | `package.json` phet.requirejsNamespace | `[已确认]` |
| Tech stack | TypeScript + Scenery/Joist/Axon/Dot/Sun/Tambo | README clone list | `[已确认]` |
| Origin | HTML5 port of Java Membrane Transport | `doc/implementation-notes.md` | `[已确认]` |

### 1.1 Dependencies (from `dependencies.json`)

核心运行时：`assert`, `axon`, `dot`, `joist`, `kite`, `phet-core`, `phetcommon`, `scenery`, `scenery-phet`, `sun`, `tambo`, `tandem`, `twixt`, `utterance-queue`, `query-string-machine`, `brand`, `chipper`, `sherpa`  
PhET-iO（本迁移可降级）：`phet-io`, `phet-io-sim-specific`, `phet-io-wrappers`, `studio`

---

## 2. Entry & Screen Structure

### 2.1 Entry

`js/membrane-transport-main.ts` → `simLauncher.launch` → `new Sim(title, screens, options)`

Screens in order `[已确认]`：

1. `SimpleDiffusionScreen` → featureSet `'simpleDiffusion'`
2. `FacilitatedDiffusionScreen` → `'facilitatedDiffusion'`
3. `ActiveTransportScreen` → `'activeTransport'`
4. `PlaygroundScreen` → `'playground'`

### 2.2 Model Sharing — CRITICAL

```text
每个 Screen 独立：
  () => new MembraneTransportModel(featureSet, { tandem: ... })
```

证据：`MembraneTransportScreen.ts:32`  
官方文档：`doc/implementation-notes.md` — “All screens share nearly identical code… features determined by MembraneTransportFeatureSet”

**Flutter 必须：4 个独立 Model 实例。禁止 global singleton。** `[已确认]`

### 2.3 FeatureSet Matrix

| Feature | simpleDiffusion | facilitatedDiffusion | activeTransport | playground |
|---------|-----------------|----------------------|-----------------|------------|
| Solutes selectable | O₂ CO₂ Na⁺ K⁺ Glucose | same | + **ATP** | + ATP |
| ADP / Phosphate | — (runtime from ATP) | — | yes (from pump) | yes |
| Proteins | **none** | Leakage ×2, Voltage ×2, Ligand ×2 | Na⁺/K⁺ Pump, Na⁺/Glucose Cotransporter | **all 8** |
| Membrane potential | no | yes (−70/−50/+30) | no | yes |
| Charges checkbox | no | yes (default **true**) | no | yes (default false*) |
| Ligands / Add Ligands | no | yes | no | yes |
| Transport protein panel | no | yes | yes | yes |

\* `chargesVisibleProperty` 默认：`featureSet === 'facilitatedDiffusion'` → true，否则 false。`[已确认]` `MembraneTransportModel.ts:221`

证据：`MembraneTransportFeatureSet.ts` 全文。

---

## 3. Architecture Map

```
membrane-transport-main.ts
└── Sim
    ├── SimpleDiffusionScreen      → MembraneTransportScreen('simpleDiffusion')
    ├── FacilitatedDiffusionScreen → MembraneTransportScreen('facilitatedDiffusion')
    ├── ActiveTransportScreen      → MembraneTransportScreen('activeTransport')
    └── PlaygroundScreen           → MembraneTransportScreen('playground')
         │
         ├── Model: MembraneTransportModel(featureSet)
         │     ├── solutes: Solute[]          (dynamic)
         │     ├── ligands: Ligand[]          (eager ×7 per type; not cleared on reset)
         │     ├── membraneSlots: Slot[7]
         │     ├── fluxEntries / descriptionEventQueue
         │     ├── Properties: isPlaying, timeSpeed, solute, membranePotential, …
         │     └── Particle.mode FSM (RandomWalk / PassiveDiffusion / protein modes…)
         │
         └── View: MembraneTransportScreenView
               ├── ObservationWindow (534×400)
               │     ├── ObservationWindowCanvasNode  (phospholipids + solute sprites)
               │     ├── ObservationWindowTransportProteinLayer
               │     └── InteractiveSlotsNode / LigandNode / …
               ├── SolutesPanel + SoluteControl (Outside/Inside)
               ├── cell.svg + ThumbnailNode
               ├── TransportProteinPanel (feature-gated)
               ├── SoluteConcentrationsAccordionBox (bar charts)
               ├── EraserButton / TimeControlNode / Checkboxes
               └── ResetAllButton
```

---

## 4. Models

| 类 | 路径 | 职责 |
|----|------|------|
| `MembraneTransportModel` | `common/model/MembraneTransportModel.ts` | 中央模型：粒子、槽位、时间、浓度计数、梯度偏置、reset/step |
| `Particle` / `Solute` / `Ligand` | `common/model/` | 粒子基类与子类；FSM `mode` |
| `Slot` | `common/model/Slot.ts` | 膜上 7 个蛋白槽；`transportProteinProperty` |
| `TransportProtein` + 子类 | `common/model/proteins/` | Leakage / Voltage / Ligand / NaKPump / NaGlucose |
| `BaseParticleMode` + 15 modes | `common/model/particleModes/` | 运动与跨膜状态机 |
| `SoluteCrossedMembraneEvent` | `common/model/` | 跨膜事件（a11y + sound + highlight） |
| `RandomWalkUtils` | `common/model/RandomWalkUtils.ts` | 布朗运动采样 |

### 4.1 Particle Modes (FSM)

| Mode | 用途 |
|------|------|
| `RandomWalkMode` | 默认布朗运动；触膜/蛋白交互入口 |
| `PassiveDiffusionMode` | O₂/CO₂ 直接穿膜 |
| `DirectionalMovementMode` | 定向穿膜基类 |
| `EnteringTransportProteinMode` | 进入通道 |
| `MoveToCenterOfChannelMode` | 移向通道中心 |
| `MovingThroughTransportProteinMode` | 穿过蛋白 |
| `MoveToLigandBindingLocationMode` / `LigandBoundMode` | 配体结合 |
| `MoveToSodiumPotassiumPumpMode` / `WaitingInSodiumPotassiumPumpMode` | 钠钾泵 |
| `MoveToSodiumGlucoseTransporterMode` / `WaitingInSodiumGlucoseCotransporterMode` | 共转运 |
| `MoveToTargetMode` | 通用目标移动 |
| `UserControlledMode` / `UserOverMode` | 用户拖拽配体 |

---

## 5. Views / Controllers

| 类 | 职责 |
|----|------|
| `MembraneTransportScreenView` | 整屏布局、Reset/Time/Eraser、面板组装 |
| `ObservationWindow` | 仿真视口 |
| `ObservationWindowCanvasNode` | Canvas：磷脂 + 溶质 Image mipmap |
| `Phospholipid` | **程序绘制** 膜脂质（非 asset） |
| `SolutesPanel` / `SoluteControl` | 溶质选择 + Outside/Inside 增减 |
| `TransportProteinPanel` / `ToolNode` / `DragNode` | 蛋白工具箱与拖放 |
| `SoluteConcentrationsAccordionBox` / `SoluteBarChartNode` | 浓度条形图 |
| `MembraneTransportDescriber` | Interactive Description |
| `MembraneTransportKeyboardHelpNode` | 键盘帮助 |
| `MembraneTransportPreferencesNode` | Preferences：animateLipids / glucoseMetabolism |
| `MembraneTransportSounds` | 音效编排 |

无独立 Controller 层；Joist Screen = Model factory + View；交互在 View/Node 内。`[已确认]`

---

## 6. Physics / Science Model (摘要)

详见 `NUMERICAL_MODEL.md`。要点：

- **坐标**：模型空间宽 `MODEL_WIDTH=200`；高按 observation aspect；膜 `MEMBRANE_BOUNDS` y∈[-10,10]；y>0 Outside，y<0 Inside
- **时间**：`model.step(dt)`；`isPlaying`；`TimeSpeed.NORMAL=1` / `SLOW=0.5`；**无 Step Forward**（`includeStepForwardButton: false`）
- **随机**：全程 `dotRandom`；布朗直线时长 ~ boxMuller(0.1,0.2) clamp [0.01,1]
- **被动气体**：触膜后有概率穿膜；梯度偏置 `BIAS_THRESHOLD=0.1`, `GRADIENT_BIAS_STRENGTH=0.9`；近平衡时气体 `P(cross)=0.90`
- **离子/葡萄糖**：不能直接穿磷脂；需对应通道/转运体
- **浓度**：= 该侧粒子计数（`position.y` 符号）；图为计数条 + 近 1s flux 滚动
- **Slots**：7 个，x ∈ [-84, +84] 等距

---

## 7. Randomness

| 位置 | 用途 |
|------|------|
| `RandomWalkUtils` | 方向角、直行时长 |
| `MembraneTransportModel.addParticles` | 生成位置 |
| `removeSolutes` | shuffle 再删 |
| `checkGradientForCrossing` | 逆梯度 veto |
| `RandomWalkMode` 气体近平衡 | `nextDouble() < 0.90` |
| `Phospholipid` | 尾部控制点初态与步进噪声 |
| `ObservationWindowCanvasNode` | phospholipid shuffle 绘制序 |
| 蛋白 mode / binding site 选择 | `dotRandom.sample` |

**Flutter 要求**：可注入 seeded RNG；禁止裸 `Random()` / `DateTime.now()` 作核心种子。

---

## 8. Animation

| 类型 | 驱动 | 说明 |
|------|------|------|
| Simulation clock | `model.step(dt)` via ScreenView `stepEmitter` | 粒子位置、蛋白状态 |
| Lipid wiggle | `Phospholipid.step(dt)` if `animateLipidsProperty` | Preferences / QP |
| Protein return-to-toolbox | `animateProteinReturn.ts` (twixt) | **render animation**，非物理 |
| Crossing highlight | view overlay / canvas highlight | 事件驱动短时显示 |

**禁止**用 Flutter `AnimationController` 代替 model time 推进粒子。

---

## 9. Assets

### Images (`images/`) — 35 SVG + `_svg.ts` wrappers

| 类别 | 文件 |
|------|------|
| Solutes | `oxygen`, `carbonDioxide`, `sodiumIon`, `potassiumIon`, `glucose`, `atp`, `adp`, `phosphate` |
| Ligands | `sodiumLigand`, `potassiumLigand` (+ highlight) |
| Channels | leakage / voltage open·closed / ligand open·closed（Na & K） |
| Pumps | `naKPumpState1/2`, `sodiumGlucoseCotransporterState1/3` |
| Cell | `cell.svg` |
| Screen icons | `*_home_icon.svg`, `*_nav_icon.svg` ×4 screens |

**粒子渲染**：`createParticleNode` → `Image(svg)` → Canvas `drawImage` mipmap。`[已确认]` 必须用原 SVG。  
**膜磷脂**：**程序绘制**（`Phospholipid.ts`），非图片。`[已确认]`

### Audio (`sounds/`) — 27 MP3

跨膜、通道开闭、配体粘/脱、泵形变、ATP/葡萄糖激活、工具箱回落、滑块、Add/Remove Ligands 等。

### Other

- `assets/*.png` — 截图/营销，非运行时
- `i18n` + Fluent strings — `membrane-transport-strings_en.yaml` + `MembraneTransportFluent.ts`
- **无自定义字体文件**（用 `PhetFont`）

完整表见 `VISUAL_ASSET_AUDIT.md`。

---

## 10. Audio / Preferences / Query Parameters

| QP / Pref | 默认 | 作用 |
|-----------|------|------|
| `animateLipids` | true | 磷脂摆动 |
| `glucoseMetabolism` | false | 胞内葡萄糖自动代谢消失 |
| `stereoCrossingSoundsEnabled` | false | 立体声跨膜音 |

Screen checkboxes：`crossingHighlights` / `crossingSounds` 默认 true。

---

## 11. Accessibility

- `supportsInteractiveDescription`, `supportsVoicing`, `supportsSound`, `supportsDynamicLocale` — `package.json`
- `MembraneTransportDescriber` + `descriptionEventQueue`
- Keyboard：`MembraneTransportHotkeyData` — Tab/Space/Enter/Arrows/WASD/Shift+fine/Escape/Backspace/Delete
- `MembraneTransportKeyboardHelpNode`

Flutter：Semantics 覆盖主要控件；仅实现 source 已有快捷键。

---

## 12. Reset Semantics

见 `RESET_SEMANTICS.md`。摘要：

| 动作 | 行为 |
|------|------|
| **Reset All** | `model.reset()` + `view.reset()` |
| **Eraser** | `model.clearSolutes()` only（不清蛋白/配体开关/电压） |
| Ligands | **reset 不清空** ligand 数组；仅 reset `areLigandsAddedProperty` |

---

## 13. Responsive Layout

- Design canvas：Joist `ScreenView.layoutBounds` — **本地无 joist**；PhET HTML5 惯例 **`768 × 504`** `[推测]` → Phase 1 必须核实
- Observation：固定 **534 × 400**，水平居中，`y = SCREEN_VIEW_Y_MARGIN(8)` `[已确认]`
- 面板相对 observation / layoutBounds 锚定（ManualConstraint / left/right/center）
- `visibleBoundsProperty` 用于拖界；无复杂 reflow `[已确认]` from ScreenView usage

---

## 14. Time Controls

| 控件 | Source |
|------|--------|
| Play/Pause | `isPlayingProperty` default **true** |
| Speed | NORMAL / SLOW only |
| Step | **不存在**（`includeStepForwardButton: false`） |

---

## 15. Official Docs in Repo

| 文件 | 用途 |
|------|------|
| `doc/model.md` | 教学向科学概念 |
| `doc/implementation-notes.md` | 技术架构（FeatureSet、坐标、内存、a11y、性能） |
| `doc/release-notes.md` | 1.0 功能清单 |

---

## 16. Flutter 迁移硬约束（从 Source 导出）

1. 4 Screen × 独立 Model（FeatureSet）
2. 原版 SVG/MP3 优先；磷脂程序绘制
3. 粒子 Canvas 批绘，禁止每粒子 Widget
4. Seeded RNG 替换 `dotRandom`
5. Model time → position → RenderData
6. Reset ≠ Eraser
7. Layout 从 layoutBounds + 公式推导（Phase 1）
8. Reset All → `KratosResetAllButton`（工程规则 86）

---

## 17. Next Phase

**PHASE 1 — Numerical Model Mapping 收尾 + Layout Archaeology**  
产出完整 `LAYOUT_SPEC.md`（含 Root Regions 测量与公式），再进入 Core Model 实现。
