# Energy Forms and Changes · Source Analysis

> Phase 1 · 2026-09-10  
> 本地源：`phet sourses/energy-forms-and-changes-main/energy-forms-and-changes-main`  
> 版本：`1.5.0-dev.5` · 证据格式 `file:line` · 标记 `[已确认]` / `[推测]` / `[待确认]`

---

## PHASE: 1 — Source Analysis
## STATUS: DONE

---

## 0. 总览地图

```
Sim (energy-forms-and-changes-main.ts)
├── Intro Screen (EFACIntroScreen)
│   ├── Model: EFACIntroModel
│   │   ├── Air, Burners×2, Blocks, Beakers, Thermometers×4
│   │   ├── EnergyChunkWanderController(s)
│   │   └── EnergyBalanceTracker + heat exchange
│   ├── View: EFACIntroScreenView
│   ├── Interaction: drag / heater-cooler / checkbox / time / reset
│   ├── Animation: EC wander, steam, fall, thermometer tween
│   └── Assets: shelf, textures, gasPipeIntro, energy* icons
└── Systems Screen (SystemsScreen)
    ├── Model: SystemsModel
    │   ├── Carousels: Sources×4 / Converters×2 / Users×4
    │   ├── Belt, EnergyChunkPathMover(s)
    │   └── stepModel: Source→Converter→User
    ├── View: SystemsScreenView
    ├── Interaction: carousel radios / element sliders / energy symbols / time / reset
    ├── Animation: twixt carousel 0.75s, fan/biker frames, water/steam/rays
    └── Assets: 大量系统元件 PNG + icons
```

**共享核心** `js/common/`：`EFACConstants`, `EnergyType`, `EnergyChunk*`, `Beaker`, `Burner`, `HeatTransferConstants`, view nodes。

**两屏不共享同一 Model 实例** `[已确认]`——各自构造。

---

## 1. Layout / Coordinate

| 项 | Intro | Systems | 证据 |
|---|---|---|---|
| layoutBounds | 1024×618 `[已确认 joist 默认]` | 同左 | `EFACConstants.ts:197` + joist#640 |
| MVT origin | `(W×0.5, H×0.85)` | `(W×0.5, H×0.475)` | IntroView:97-104 · SystemsView:124-129 |
| MVT scale | 1700 | 2200 | `EFACConstants.ts:150-151` |
| Model y=0 | 台面 | 管道中线附近 | 各 ScreenView 注释 |
| Model x 范围 | [-0.30, 0.30] m | carousel 选中位 | IntroModel:49-50 |
| 背景色 | RGB(249,244,205) | 同左 | `EFACConstants.ts:46-47,125-126` |

---

## 2. Intro — State Table（摘要）

| State | 初始 | 修改来源 | 限制 | View | Reset |
|---|---|---|---|---|---|
| `energyChunksVisibleProperty` | false | checkbox | bool | EC 显隐；块半透明 | reset |
| `linkedHeatersProperty` | false | checkbox（双 burner） | bool | 联动 heatCoolLevel | reset |
| `isPlayingProperty` | true | TimeControl | bool | gate stepModel | reset |
| `timeSpeedProperty` | NORMAL | TimeControl | NORMAL/FAST | dt×1 或 ×4 | reset |
| Burner.`heatCoolLevelProperty` | 0 | HeaterCooler | [-1,1] | 火/冰 | reset |
| Block/Beaker position | ground spots | drag / fall | constrainer | nodes | reset |
| Block/Beaker energy/T | room 296K | heat exchange | T≥273.15；beaker 沸腾泄能 | 颜色/蒸汽 | reset |
| Thermometer×4 | (100,100) inactive | drag / sticky | 4 | storage↔active | 回库 |
| Air energy | INITIAL | **changeEnergy 空操作** | 无限源/汇 | 空中 EC | reset |

**完整细节与行号**：见子代理取证（Intro deep-dive）；关键物理常数见 `EFACConstants.ts`。

---

## 3. Intro — Interaction Table

| Interaction | Input | Target | 条件 | 行为 | 边界 |
|---|---|---|---|---|---|
| 拖 Block/Beaker | pointer | ThermalElementDragHandler | — | userControlled；松手 fallToSurface | efacPositionConstrainer AABB |
| 拖 Thermometer | pointer | sensor node | — | sticky 吸附；回 storage tween | layoutBounds |
| Burner heat/cool | HeaterCooler | heatCoolLevel | — | ±能量注入 | [-1,1]；可 stickyBurners QP |
| Link heaters | checkbox | linkedHeaters | twoBurners | 同步 level | — |
| Energy Symbols | checkbox | energyChunksVisible | — | 显隐 EC | — |
| Play/Pause/Step/FF | TimeControl | isPlaying / timeSpeed | — | step / ×4 | maxDT 0.1 |
| Reset All | button | model+view | — | model.reset + 温度计回库 + beaker view reset | — |

---

## 4. Intro — Heat / Energy Chunk（核心行为）

### 4.1 stepModel 顺序 `[已确认]` `EFACIntroModel.ts:424-651`

1. fallToSurface（非 userControlled）  
2. beaker fluid displacement（块浸入抬液面）  
3. **连续热交换**（顺序敏感）：containers 两两 → burners→objects/air → containers↔air（浸没块跳过）  
4. **EC balance 交换**（`|balance| > ENERGY_PER_CHUNK`）  
5. air/burner/container.step  

### 4.2 换热公式 `[已确认]`

```
ΔE = (T_other - T_this) × contactLength × heatTransferFactor × dt
固体↔固体 factor=1000；↔AIR factor=30  (HeatTransferConstants.ts)
Burner→物体: 5000×heatCoolLevel×dt J；→空气: 1500×heatCoolLevel×dt
```

### 4.3 ENERGY_PER_CHUNK `[已确认公式]` / `[待确认数值]`

由 brick freezing↔room 能量映射线性差导出（`EFACConstants.ts:105-109`）。Phase 4 用同公式计算并单测固化。

### 4.4 Animation（Intro）

| Animation | Object | From→To | Duration/Speed | Easing | Interrupt/Reset |
|---|---|---|---|---|---|
| EC wander | EnergyChunk | →destination | 0.06–0.10 m/s | 方向每 0.4–0.8s 变 | dispose on arrive / reset |
| Steam | BeakerSteamCanvas | bp−10K 起 | 20–40 bubbles/s | — | T 降则停 |
| Thermometer return | sensor | →storage | 0.2 m/s, max 1s | CUBIC_IN_OUT | reset 强制回库 |
| Fall | block/beaker | →surface | g=-9.8 | — | userControlled 中断 |
| Flame/Ice | HeaterCooler | level | scenery-phet 内部 | — | `[推测]` 外部包 |

---

## 5. Systems — State / Pipeline

### 5.1 全局 `[已确认]`

| State | 初始 | 修改 | View | Reset |
|---|---|---|---|---|
| energyChunksVisible | false | checkbox | chunks + legend | reset |
| isPlaying | true | TimeControl | gate stepModel | reset |
| carousels targetIndex | 0 | radio | slide+fade | reset→首项 |
| belt visible | false | biker∧generator active | BeltNode | 随联动 |

**默认激活**：BIKER + GENERATOR + BEAKER_HEATER `[已确认]` `SystemsModel.ts:212-215`

### 5.2 Pipeline `[已确认]` `SystemsModel.ts:280-294`

```
energyFromSource = source.step(dt)
converter.injectEnergyChunks(source.extractOutgoingEnergyChunks())
energyFromConverter = converter.step(dt, energyFromSource)
user.injectEnergyChunks(converter.extractOutgoingEnergyChunks())
user.step(dt, energyFromConverter)
```

Carousel `step(dt)` **在 pause 时仍运行**（过渡动画）`[已确认]`。

### 5.3 元素能量类型速查 `[已确认]`

| Element | In / Produce | Out / Convert |
|---|---|---|
| Biker | CHEMICAL body | MECHANICAL（或 hub THERMAL） |
| Faucet | — | MECHANICAL drops |
| Sun | — | LIGHT |
| TeaKettle | THERMAL heat | MECHANICAL steam (~80%) |
| Generator | MECHANICAL | ELECTRICAL (+HIDDEN) |
| SolarPanel | LIGHT | ELECTRICAL (68% energy；chunk 3/4 转化) |
| Fan | ELECTRICAL | MECHANICAL / THERMAL |
| Incandescent | ELECTRICAL | 35% THERMAL / 65% LIGHT 辐射 |
| Fluorescent | ELECTRICAL | 20% THERMAL / 80% LIGHT |
| BeakerHeater | ELECTRICAL | THERMAL→beaker / radiate |

非法 source/converter 组合：**允许 UI 选择**，仅能量/chunk 不流动 `[已确认]`。

---

## 6. Systems — Interaction Table

| Interaction | Input | Target | 行为 |
|---|---|---|---|
| Carousel radio | RectangularRadioButtonGroup | targetElementName | 0.75s CUBIC_IN_OUT 位移+opacity；结束 activate |
| Biker speed | HSlider | targetCrankAngularVelocity | 0–3π rad/s |
| Feed Me | button | energyChunksRemaining | 仅剩余 0 时显示；补满 21 |
| Faucet | FaucetNode | flowProportion | setting→0.25+0.75×setting（0→0） |
| Sun clouds | VSlider | cloudinessProportion | 0–1 |
| TeaKettle | HeaterCooler | heatProportion | 同 faucet 映射 |
| Energy Symbols | checkbox | energyChunksVisible | + legend；preload chunks |
| Play/Pause/Step | TimeControl | isPlaying / manualStep | Systems **无** FastForward |
| Reset | ResetAll | model + steam nodes | carousel 回首项 |

---

## 7. Systems — Animation Table

| Animation | Object | Params | Evidence |
|---|---|---|---|
| Carousel slide/fade | elements | 0.75s CUBIC_IN_OUT；opacity=1−dist/\|offset\| | EnergySystemElementCarousel.ts:29,240-245 |
| Fan blades | 10 frames | bladePosition → index | FanNode |
| Biker legs | 18×2 frames | crankAngle | BikerNode |
| Biker torso tired | 4 levels | chunks remaining ratio | BikerNode |
| Generator wheel | rotation | wheelRotationalAngle | GeneratorNode |
| Falling water | Canvas drops | gravity −0.15 y；30/s | FaucetAndWater |
| TeaKettle steam | Canvas | energyProductionRate | TeaKettleSteamCanvasNode |
| Light rays | 20–40 rays | litProportion；chunks 可见时隐藏 | SunNode / LightBulbNode |
| EC path | PathMover | speed；MAX_HEIGHT=0.55 m | EnergyChunkPathMover |

---

## 8. Asset Table（摘要）

| Asset / 组 | 原路径 | 类型 | 用途 | Flutter 方案 |
|---|---|---|---|---|
| energyThermal/Electrical/… | `images/energy*_png.ts` | PNG 模块 | EC 图标 | 解码 base64→`assets/energy_forms_and_changes/` |
| brick/iron textures | `images/*Texture*_png.ts` | PNG | Intro 块 | 同上 |
| shelf, gasPipeIntro | `images/` | PNG | Intro 台面/气管 | 同上 |
| fan01–10, cyclist legs… | `images/` | PNG | Systems 动画帧 | 同上 |
| bicycle/generator/solar/bulb… | `images/` | PNG | 元件外观 | 同上 |
| intro/systems ScreenIcon | `images/` | PNG | Tab/Home 图标 | 同上 |
| HeaterCooler flame/ice | scenery-phet | 外部 | Intro/Systems 加热 | `[待确认]` 等价绘制或取 scenery-phet 源 |
| FaucetNode | scenery-phet | 外部 | 水龙头 | `[待确认]` 同上 |
| BurnerStand / Beaker / Sky / Steam | common view | 矢量/Canvas | 共享 | Flutter Path/CustomPainter 按源码几何 |
| Belt | Path stroke | 矢量 | 皮带 | Path |

**原则**：能导出的 `*_png.ts` **禁止重画近似图**。

---

## 9. Lifecycle / Reset / Clock

| 事件 | Intro | Systems |
|---|---|---|
| `step(dt)` | playing→stepModel(dt×speed)；thermometer 总是 step | carousel 总是 step；playing→stepModel |
| `manualStep` | 1/60 + view manualStep | 同 |
| `reset` | 全部 Property/元素/balance；温度计回库 | Property + carousel 回首 + 蒸汽 node reset |
| dispose | PhET-iO groups | 同 |

---

## 10. 跨屏共享 vs 独立

| 共享 | 独立 |
|---|---|
| EnergyType, EnergyChunk 视觉, Beaker 热学, EFACConstants, 背景色 | 根 Model、MVT、时间控件（Intro 有 FF）、交互集 |

Flutter 落地：`lib/energy_forms_and_changes/common/` + `intro/` + `systems/`。

---

## 11. Phase 报告框

1. **Completed**：Intro/Systems 行为地图；State/Interaction/Animation/Asset/Pipeline  
2. **Files**：`SOURCE_ANALYSIS.md`；更新 `process.txt` / `meta.yaml`  
3. **Evidence**：见各表；layout 1024×618 经 joist 公共证据确认  
4. **Tests**：未改代码  
5. **Analyze**：基线不变  
6. **Visual**：Phase 2  
7. **Blocked**：无  
8. **Known limitations**：scenery-phet 细节；ENERGY_PER_CHUNK 数值待算；BeakerHeater 线圈映射待逐行确认  
9. **Next**：Phase 2 Visual Baseline → Phase 3 Architecture

---

*Phase 1 完成 → 自动进入 Phase 2*
