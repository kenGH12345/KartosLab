# Membrane Transport · VISUAL_ASSET_AUDIT

> PHASE 0 · Asset inventory + provenance  
> 源目录：`phet sourses/membrane-transport-main/membrane-transport-main`  
> Flutter destination：`NOT COPIED YET`（Phase 3+ 再拷贝）  
> 政策：原版有图必须用原版图；仅源码程序绘制才 CustomPainter

---

## 1. Rendering Policy Summary

| 视觉元素 | Source 实现 | Flutter 策略 |
|----------|-------------|--------------|
| O₂ CO₂ Na⁺ K⁺ Glucose ATP ADP Pi | SVG → Image → Canvas drawImage | **Image.asset 原 SVG** |
| Ligands (triangle/star) | `sodiumLigand.svg` / `potassiumLigand.svg` | **原 SVG** |
| Leakage / Voltage / Ligand channels | 对应 open/closed SVG | **原 SVG**（状态切换） |
| Na/K Pump | `naKPumpState1/2.svg` | **原 SVG** |
| Na/Glucose Cotransporter | `state1/3.svg` | **原 SVG** |
| Cell diagram | `cell.svg` | **原 SVG** |
| Screen / Nav icons | `*_home_icon.svg` / `*_nav_icon.svg` | **原 SVG**（Home + tabs） |
| Phospholipid bilayer | `Phospholipid.ts` Canvas 程序绘制 | **CustomPainter 等价几何**（非图片） |
| Membrane charges + / − | Text/节点程序绘制 | 程序绘制 |
| Eraser / Play / Checkbox / Radio | scenery-phet / sun 标准控件 | 复用 KartosLab L0 / PhET 风格组件 |
| Reset All | scenery-phet `ResetAllButton` | **`KratosResetAllButton`**（规则 86） |

**Substituted Assets 目标：0**（磷脂属程序绘制，不算 substituted）。

---

## 2. Image Inventory (`images/`)

共 **35** 个 `.svg`（另有并行 `*_svg.ts` 包装，不单独拷贝）。

| Original Path | Used By | Type | Flutter Dest | Transform | Status |
|---------------|---------|------|--------------|-----------|--------|
| `images/oxygen.svg` | createParticleNode / icons | solute | `assets/simulations/membrane_transport/images/oxygen.svg` | OVERALL_ARTWORK_SCALE 0.1；mipmap | **COPIED** |
| `images/carbonDioxide.svg` | 同上 | solute | …/carbonDioxide.svg | same | **COPIED** |
| `images/sodiumIon.svg` | 同上 | solute | …/sodiumIon.svg | same | **COPIED** |
| `images/potassiumIon.svg` | 同上 | solute | …/potassiumIon.svg | same | **COPIED** |
| `images/glucose.svg` | 同上 | solute | …/glucose.svg | same | **COPIED** |
| `images/atp.svg` | 同上 | solute | …/atp.svg | same | **COPIED** |
| `images/adp.svg` | 同上 | solute | …/adp.svg | same | **COPIED** |
| `images/phosphate.svg` | 同上 | solute | …/phosphate.svg | 绑定态旋转约 20°（source 注释） | **COPIED** |
| `images/cell.svg` | ScreenView Image | display | …/cell.svg | Thumbnail 对齐 | **COPIED** |
| `images/simple_diffusion_home_icon.svg` | ScreenIcon | home | … | maxIcon proportion 1 | **COPIED** |
| `images/simple_diffusion_nav_icon.svg` | nav | home | … | | **COPIED** |
| `images/facilitated_diffusion_*` | icons | home | … | | **COPIED** |
| `images/active_transport_*` | icons | home | … | | **COPIED** |
| `images/playground_*` | icons | home | … | | **COPIED** |
| `images/sodiumLeakage.svg` / `potassiumLeakage.svg` | LeakageChannelNode | protein | … | scale TRANSPORT_PROTEIN_WIDTH | **COPIED** |
| `images/*VoltageGated{Open,Closed}.svg` | VoltageGatedChannelNode | protein | … | state-driven | **COPIED** |
| `images/*LigandGated{Open,Closed}.svg` | LigandGatedChannelNode | protein | … | state-driven | **COPIED** |
| `images/sodiumLigand.svg` / `potassiumLigand.svg` | ligand particles | ligand | … | | **COPIED** |
| `images/*LigandHighlight.svg` | binding cue | ligand | … | drag cue (deferred) | **COPIED** |
| `images/naKPumpState1/2.svg` | SodiumPotassiumPumpNode | protein | … | | **COPIED** |
| `images/sodiumGlucoseCotransporterState1/3.svg` | CotransporterNode | protein | … | | **COPIED** |

---

## 3. Audio Inventory (`sounds/`)

共 **27** MP3（+ `_mp3.js` wrappers）。

| Original | Purpose |
|----------|---------|
| `soluteCrossingOxygen(.Outward).mp3` | O₂ 跨膜 |
| `soluteCrossingCarbonDioxide(.Outward).mp3` | CO₂ 跨膜 |
| `soluteCrossingSodium.mp3` / `Potassium.mp3` / `Generic.mp3` | 离子/通用跨膜 |
| `sodiumVoltageGatedChannelOpen/Close.mp3` | Na 电压门 |
| `potassiumVoltageGatedChannelOpen/Close.mp3` | K 电压门 |
| `sodiumLigandGatedChannelOpen/Close.mp3` | Na 配体门 |
| `potassiumLigandGatedChannelOpen/Close.mp3` | K 配体门 |
| `ligandsStickV3.mp3` / `ligandsUnstickV3.mp3` | 配体粘脱 |
| `addLigands.mp3` / `removeLigands.mp3` | 配体按钮 |
| `naPlusAttach.mp3` / `kPlusAttach.mp3` | 泵结合 |
| `atpActivateTransporter.mp3` / `glucoseActivateTransporter.mp3` | 激活 |
| `naKPumpChangedShape.mp3` / `coTransporterChangedShapeChord.mp3` | 构象 |
| `proteinReturnToToolbox.mp3` | 蛋白回工具箱 |
| `sliderMovement.mp3` | 滑块 |

Flutter Dest：`assets/sims/membrane_transport/sounds/*.mp3` — PENDING COPY。

---

## 4. Procedural (NOT assets)

| Element | Source | Notes |
|---------|--------|-------|
| Phospholipid heads/tails | `Phospholipid.ts` + Canvas | headRadius=1.3；双尾；噪声摆动 |
| Observation background halves | Colors ProfileColorProperty | outside `#dbefff` / inside `#fff9f0` |
| Screen background | `outsideCellColor` `#b8dfff` | |
| Charges +/− | view nodes | 相对膜上下排列 |
| Bar chart geometry | `SoluteBarChartNode` | 红线=膜；上下计数条 |
| Crossing highlight | color `#ffff94` | |

---

## 5. Colors (from MembraneTransportColors.ts)

| Token | Default |
|-------|---------|
| outsideCell (screen bg) | `#b8dfff` |
| insideCell | `#fdf4c9` |
| observation outside | `#dbefff` |
| observation inside | `#fff9f0` |
| lipidTail / lipidHead | rgb(229,68,143) / rgb(248,161,46) |
| phospholipidHead / Tail | rgb(220,120,39) / rgb(234,144,255) |
| O₂ / CO₂ / Na / K / Glucose / ATP | 见 Colors.ts |

---

## 6. Home Icon (PHASE 8)

| Field | Value |
|-------|--------|
| Home Icon | **Original** |
| Original path | `images/simple_diffusion_home_icon.svg` |
| Flutter path | `assets/simulations/membrane_transport/images/simple_diffusion_home_icon.svg` |
| Used by | KartosLab `HomeScreen` `_SimCard` → `MembraneTransportHome.homeIconAsset` |
| Category | 物理 → 热学与气体（无「生物」一级学科；与 Diffusion 同组） |
| Alternate screen home icons | `facilitated_diffusion_home_icon.svg` / `active_transport_home_icon.svg` / `playground_home_icon.svg`（原版已拷贝；tabs 用 `*_nav_icon.svg`） |

**Substituted for Home Icon：0**

---

## 7. Non-runtime assets (`assets/`)

截图 PNG / AI 源文件 — **不进入 Flutter 运行时**；可用于 Golden 对照：

- `membrane-transport-screenshot-screen1..4.png`
- 用户提供参考：`requirements/.../visual-qa/screen*_ref.png`

---

## 8. Audit Checklist (Final QA)

- [x] Substituted Assets = 0（Phase 5）
- [x] 所有 solute/protein/cell/icon SVG 来自原路径
- [x] Home Icon 使用原版 `simple_diffusion_home_icon.svg`（Phase 8）
- [ ] 磷脂仅程序绘制且几何对齐 source
- [ ] 无 Material Icons 冒充粒子/通道/Reset（Eraser/Play 仍为 Material → P2）
- [x] ASSET_MAP / 本审计含 Home Icon provenance
- [x] pubspec.yaml 注册 `assets/simulations/membrane_transport/images/`
- [ ] 音效路径与 Sounds 映射完整（或明确降级清单）

**Current Substituted count：0**
