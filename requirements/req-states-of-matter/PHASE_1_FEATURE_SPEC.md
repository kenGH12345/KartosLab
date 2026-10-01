# PHASE 1 — Feature Spec · States of Matter

> 基于本地源码逐项确认 · **禁止凭名字推测**  
> 版本：1.3.0-dev.3 · 2026-09-15

---

## 1. Screens（3）

| # | 名称（UI） | 源码 | 教学焦点 |
|---|---|---|---|
| 1 | States | `StatesScreen` | 选物质 + 固/液/气按钮 + 加热冷却，观察微观排列 |
| 2 | Phase Changes | `PhaseChangesScreen` | 体积（活塞）· 压力表 · 打气 · 相图 · LJ 势图 · 可调吸引 |
| 3 | Interaction | `AtomicInteractionsScreen` | 两原子拖拽 · 力分量/合力 · 势阱 · ε/σ |

无第四屏。无独立 “Basics” 变体在本入口。

---

## 2. Substances / Particle Types

| UI 名 | `SubstanceType` | 结构 | 出现屏 |
|---|---|---|---|
| Neon | `NEON` | 单原子 | States · Phase Changes · Interaction(对) |
| Argon | `ARGON` | 单原子 | 同上 |
| Oxygen | `DIATOMIC_OXYGEN` | 双原子分子 | States · Phase Changes |
| Water | `WATER` | H₂O（O+2H） | States · Phase Changes |
| Adjustable Attraction | `ADJUSTABLE_ATOM` | 单原子可调 ε | **仅 Phase Changes**（+ Interaction 可调对） |

**不要添加** 源码不存在的物质。

### 每物质参数（源码）

| 物质 | 显示原子 | r (pm) | mass (u) | particleDiameter | σ | ε/k (K) |
|---|---|---|---|---|---|---|
| Neon | Ne | 154 | 20.1797 | 308 | 308 | 35.8 |
| Argon | Ar | 188 | 39.948 | 376 | 376 | 111.84 |
| Oxygen | O×2 | 152 | 15.9994/atom | 304 | 365 | 113 |
| Water | O+H+H | O152/H120 | — | O·2.9（视觉） | 444 | 200 |
| Adjustable | 紫球 | 175 | 25 | 350 | 350 | 默认 225；可调 49.2–340 |

水分子几何：`THETA_HOH = 120°`；`DISTANCE_FROM_OXYGEN_TO_HYDROGEN = 1/3.12`（归一化）。  
双原子间距：`DIATOMIC_PARTICLE_DISTANCE = 0.9` 直径。

初始数量：按容器宽 / 直径经验公式（见 PHASE_0）；`MAX_NUM_ATOMS = 500`。

---

## 3. Phase / State of Matter

| UI | `PhaseStateEnum` | 如何进入 |
|---|---|---|
| Solid | `SOLID` | 按钮 `setPhase` → T=0.15 + 晶格/快照配置 |
| Liquid | `LIQUID` | T=0.34 + **硬编码 LIQUID_INITIAL_STATES** |
| Gas | `GAS` | T=1.0 + 随机位置（最小间距尝试） |

运行时相态**不是**单纯温度阈值动画；加热冷却改变动能/恒温器目标，粒子逐渐表现不同，但按钮会**强制重配**。

水固态：预存 snapshot（`WaterPhaseStateChanger.loadSavedState`）。

---

## 4. Controls（完整 Control Map）

### Screen 1 — States

| Control | Initial | Min | Max | Model | Interaction | Reset |
|---|---|---|---|---|---|---|
| Substance radio | Neon | — | — | `substanceProperty` | 重建 | Neon |
| Solid/Liquid/Gas buttons | Solid 高亮 | — | — | `setPhase` | 点击 | Solid |
| Heater/Cooler | 0 | -1 | 1 | `heatingCoolingAmountProperty` | 拖；pause/explode 禁用 | 0 |
| Play/Pause | playing | — | — | `isPlayingProperty` | 点击 | playing |
| Step | — | — | — | `stepInTime(1/60)` | 点击 | — |
| Reset All | — | — | — | `reset()` | 点击 | 全复位 |

### Screen 2 — Phase Changes（增量）

| Control | Initial | Range | Model |
|---|---|---|---|
| Substance（含 Adjustable） | Neon | 5 项 | `substanceProperty` |
| ε slider（Adjustable） | MAX_ADJ | 49.2–340 | `adjustableAtomInteractionStrengthProperty` |
| Lid / Hand drag | height=10000 | 1500–10000 | `targetContainerHeightProperty` |
| Bicycle pump | — | 注入≤max | `targetNumberOfMoleculesProperty` +=3/pump |
| Return Lid | hidden until exploded | — | `returnLid()` |
| Phase diagram accordion | expanded | — | `phaseDiagramExpandedProperty` |
| Interaction potential accordion | expanded | — | `interactionPotentialExpandedProperty` |
| ε 图拖拽 | — | MIN–MAX ε | 同 adjustable strength |
| Pressure gauge | 读 `pressureProperty` | 显示至 200 atm | 只读 |

无独立 “Phase” 三按钮于本屏（相变靠热/压/体）。

### Screen 3 — Interaction

| Control | Binding |
|---|---|
| Atom pair selector | `atomPairProperty` |
| Force display radios | `forcesDisplayModeProperty` |
| Time speed | `timeSpeedProperty` NORMAL/SLOW |
| Drag movable atom | x 位置；拖时 pause motion |
| Potential graph σ/ε handles（Adjustable） | diameter / strength |
| Play/Pause/Step · Reset | DualAtomModel |

---

## 5. Measurements

| 测量 | 有无 | 数据源 |
|---|---|---|
| Temperature (K) | ✅ 三屏容器/双原子相关 | Kelvin derived / DualAtom 动能 |
| Pressure (atm) | ✅ Phase Changes 表盘 | 墙碰撞平均 ×5 |
| Volume | ✅ 容器高度 → 几何体积 | `containerHeightProperty` |
| Phase diagram (P-T) | ✅ Phase Changes | 历史 T + P 映射 |
| LJ potential curve | ✅ Phase Changes + Interaction | ε,σ |
| Force readout / arrows | ✅ Interaction | F_att, F_rep |
| Energy time graph | ❌ 本版本无 | — |
| Particle speed histogram | ❌ 无（气体族才有） | — |

---

## 6. Visual Layers（z 序 · 多粒子屏）

典型（`ParticleContainerNode` + ScreenView）：

1. 背景（SOMColors / projector）
2. 容器后壁 / 透视 bevel
3. 粒子层（`ParticleImageCanvasNode`）
4. 容器前缘 / lid
5. Thermometer（叠在容器旁）
6. DialGauge / Hand / Pump（Phase Changes）
7. HeaterCooler（容器下方）
8. TimeControl
9. 右侧控制面板 / 相态按钮 / 手风琴图
10. Reset All

爆炸后：粒子可飞出容器（`insideContainer=false`）；lid 离开。

---

## 7. Experiments / 教学路径（源码能力）

1. 固定物质，切 Solid→Liquid→Gas，观察间距与运动
2. 加热/冷却，观察熔化/沸腾趋势（无离散相标签强制）
3. 换 Neon/Argon/O₂/Water，比较 ε 强弱
4. Phase Changes：压活塞增压 → 可能爆炸 → Return Lid
5. 打气增加粒子数
6. Adjustable：拖 ε，看势阱与凝聚
7. Interaction：拖原子看斥/吸力与势曲线

---

## 8. Acceptance Criteria（功能级）

- [ ] AC1：三屏可切换；默认首屏 States；布局 834×504 比例适配
- [ ] AC2：四种固定物质 + Adjustable（仅 PC）参数与源码一致
- [ ] AC3：Verlet + 归一化 LJ；非随机布朗替代
- [ ] AC4：相按钮重配粒子（含 liquid 快照）
- [ ] AC5：恒温器行为与源码区间一致（观感级）
- [ ] AC6：压力来自墙碰撞；显示 ×5 atm；超压可爆炸
- [ ] AC7：加热冷却改变 set point；pause 时冻结
- [ ] AC8：Phase Changes 活塞/泵/相图/势图可用
- [ ] AC9：Interaction 拖拽 + 力显示 + 势图
- [ ] AC10：Reset 恢复该屏全部状态
- [ ] AC11：原版 mipmap/png 复用；Substituted=0
- [ ] AC12：Final Gate 前不接 Home

---

## 9. Out of Scope（本轮）

- PhET-iO 仪器化
- 完整 projector 主题切换（可后置；颜色常量需预留）
- 异构原子对（入口 `enableHeterogeneousMolecules=false`）
- 用理想气体公式“纠正”压力
