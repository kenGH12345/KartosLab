# Membrane Transport · FUNCTION_MAP

> PHASE 0 · 功能考古 · 以源码为准  
> Status 列：`NOT STARTED`（Flutter 尚未实现）

---

## 功能分类总表

| ID | 分类 | 用户能力 | Original Source | Flutter | Status | Test |
|----|------|----------|-----------------|---------|--------|------|
| F-SD | CORE / USER | 进入 Simple Diffusion；仅气体被动扩散 | `SimpleDiffusionScreen` + FeatureSet | — | NOT STARTED | — |
| F-FD | CORE / USER | 进入 Facilitated Diffusion；通道 + 电压 + 配体 | `FacilitatedDiffusionScreen` | MembraneTransportScreenBody(FD) | PASS (MVP) | tap-place |
| F-AT | CORE / USER | 进入 Active Transport；泵 + 共转运 + ATP | `ActiveTransportScreen` | MembraneTransportScreenBody(AT) | PASS (MVP) | tap-place |
| F-PG | CORE / USER | 进入 Playground；全部功能 | `PlaygroundScreen` | MembraneTransportScreenBody(PG) | PASS (MVP) | tap-place |
| F-SOL-SEL | USER CONTROLS | 选择溶质类型（O₂/CO₂/Na⁺/K⁺/Glucose[/ATP]） | `SolutesPanel` + `soluteProperty` | — | NOT STARTED | — |
| F-SOL-ADD | USER CONTROLS | Outside/Inside：fine ±10 / coarse ±50 增减 | `SoluteControl` | — | NOT STARTED | — |
| F-SOL-MAX | USER CONTROLS | 双侧合计 ≤ `MAX_SOLUTE_COUNT`(200) | `MembraneTransportConstants` / SoluteControl | — | NOT STARTED | — |
| F-ERASE | USER CONTROLS | Eraser 清除全部溶质 | `clearSolutes()` | — | NOT STARTED | — |
| F-PLAY | LIFECYCLE | Play / Pause | `isPlayingProperty` | — | NOT STARTED | — |
| F-SPEED | LIFECYCLE | Normal / Slow (0.5×) | `timeSpeedProperty` | — | NOT STARTED | — |
| F-HL | DISPLAY | Crossing Highlights 开关 | `crossingHighlightsEnabledProperty` | — | NOT STARTED | — |
| F-SND | AUDIO | Crossing Sounds 开关 | `crossingSoundsEnabledProperty` | — | NOT STARTED | — |
| F-GRAPH | GRAPH | Solute Concentrations 折叠面板 + 5 条形图 | `SoluteConcentrationsAccordionBox` | — | NOT STARTED | — |
| F-RESET | RESET | Reset All | `model.reset` + `view.reset` | — | NOT STARTED | — |
| F-PROT-DRAG | USER CONTROLS | 从工具箱拖蛋白到膜 slot | `TransportProteinPanel` / DragNode | — | NOT STARTED | — |
| F-PROT-MOVE | USER CONTROLS | 膜上蛋白排序 / 删除 / 回工具箱 | ObservationWindowTransportProteinLayer | — | NOT STARTED | — |
| F-VOLT | USER CONTROLS | 膜电位 −70 / −50 / +30 | `membranePotentialProperty` | — | NOT STARTED | — |
| F-CHG | DISPLAY | Charges +/− 显示 | `chargesVisibleProperty` | — | NOT STARTED | — |
| F-LIG | USER CONTROLS | Add/Remove Ligands | `areLigandsAddedProperty` | — | NOT STARTED | — |
| F-LIG-DRAG | USER CONTROLS | 拖拽配体到配体门控通道 | `LigandNode` / LigandBoundMode | — | NOT STARTED | — |
| F-PASS-GAS | CORE PHYSICS | O₂/CO₂ 直接穿膜（概率 + 梯度偏置） | `RandomWalkMode.attemptMembraneInteraction` | — | NOT STARTED | — |
| F-PASS-CH | CORE PHYSICS | 离子经 leakage / voltage / ligand 通道 | protein modes | — | NOT STARTED | — |
| F-PUMP | CORE PHYSICS | Na⁺/K⁺ 泵 + ATP→ADP+Pi | `SodiumPotassiumPump` | — | NOT STARTED | — |
| F-COTRANS | CORE PHYSICS | Na⁺/Glucose 共转运（向内） | `SodiumGlucoseCotransporter` | — | NOT STARTED | — |
| F-RW | CORE PHYSICS | 布朗运动 + 边界弹回 + 左右环绕 | `RandomWalkMode` | — | NOT STARTED | — |
| F-BIAS | CORE PHYSICS | 逆梯度随机 veto | `checkGradientForCrossing` | — | NOT STARTED | — |
| F-FLUX | STATISTICS | 近 1s fluxEntries 滚动 | `stepFlux` | — | NOT STARTED | — |
| F-LIPID | DISPLAY | 磷脂程序动画 | `Phospholipid` + prefs | — | NOT STARTED | — |
| F-CELL | DISPLAY | 左侧 cell.svg + Thumbnail 连线 | `cell_svg` / `ThumbnailNode` | — | NOT STARTED | — |
| F-PREF | USER CONTROLS | Preferences：animateLipids / glucoseMetabolism / stereo sounds | Preferences | — | NOT STARTED | — |
| F-A11Y | ACCESSIBILITY | Interactive Description / Voicing / Keyboard | Describer + HotkeyData | — | NOT STARTED | — |
| F-AUDIO-FX | AUDIO | 通道/泵/跨膜/配体等 MP3 | `MembraneTransportSounds` + `sounds/` | — | NOT STARTED | — |

---

## 按 Screen 可用功能

### Simple Diffusion
- Solutes（无 ATP）、Outside/Inside spinners、Observation、Eraser、Play/Pause、Speed、Highlights、Sounds、Concentrations、Reset All
- **无**蛋白面板、电压、配体、Charges

### Facilitated Diffusion
- 上列 + Leakage / Voltage / Ligand 通道工具箱 + Membrane Potential + Charges（默认开）+ Add Ligands

### Active Transport
- Solutes **含 ATP** + Na⁺/K⁺ Pump + Na⁺/Glucose Cotransporter
- **无**电压/配体/Charges

### Playground
- 全部溶质与全部 8 种蛋白 + 电压 + 配体

---

## 明确不存在的功能（勿自行发明）

| 猜测项 | Source 事实 |
|--------|-------------|
| Step Forward / Step Back（时间步进） | **无**（TimeControl 关闭 step 按钮） |
| 连续浓度滑块改浓度 | **无**；用 ±10/±50 增减粒子 |
| 温度 / 压力 / pH | **无** |
| 膜弹性 / 弯曲 | **无**（doc/model.md） |
| 全局共享 Model | **无**；每屏独立 |
| Equilibrium 显式 UI 标签 | **无**；稳态由计数自然体现 |

---

## 正常用户实验路径（验收用）

```text
打开 sim
→ 选 Screen（如 Simple Diffusion）
→ 选溶质 O₂
→ Outside coarse +50 → 观察粒子 + 浓度条
→ 等待被动扩散进入 Inside
→ 切换 Na⁺ → 观察无法直接穿膜
→ Facilitated：拖入 Na⁺ leakage → 观察离子通过
→ 改膜电位 → 观察 voltage-gated 开闭
→ Add Ligands → 拖配体开门
→ Active：放泵 + 加 ATP → 观察逆梯度
→ Pause → 改条件 → Play
→ Eraser → 再加粒子
→ Reset All → 回到初始可再实验
```
