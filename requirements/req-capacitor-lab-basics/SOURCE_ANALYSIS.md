# Capacitor Lab: Basics · Source Analysis

> Phase 1 · Intake / Source Analysis · 2026-09-12  
> 本地源：`phet sourses/capacitor-lab-basics-main/capacitor-lab-basics-main`  
> 依赖：`phet sourses/scenery-phet`（capacitor 包 + lightBulb mipmaps）  
> 包版本：`1.8.0-dev.6`  
> 标记：`[已确认]` / `[推测]` / `[待确认]`  
> **本阶段未写 Flutter 业务代码、未拷贝 assets**

---

## PHASE: 1 — Source Analysis
## STATUS: DONE

配套产物：

| 文件 | 用途 |
|------|------|
| `ASSET_MAP.md` / `VISUAL_ASSET_POLICY.md` | 资源与强制视觉政策 |
| `SOURCE_TO_FLUTTER_MAP.md` | PhET → Flutter 映射 |
| `ARCHITECTURE_PLAN.md` | 目录 / 数据边界 / 阶段切分 |
| `SOURCE_BEHAVIOR_MATRIX.md` | Feature 行为矩阵 |
| `spec/需求简述.md` | AC / 功能规格 |
| `PHASE_1_REPORT.md` | 本阶段检查报告 |

---

## 0. 总览地图

```
Sim (capacitor-lab-basics-main.js)
├── switchUsedProperty (shared Boolean, false)
├── CapacitanceScreen
│   ├── Model: CapacitanceModel → CLBModel
│   │   └── CapacitanceCircuit → ParallelCircuit
│   │         Battery + Capacitor + Switches(2态) + Wires
│   ├── View: CapacitanceScreenView
│   │   circuit → barMeters → viewControl → toolbox → voltmeter → reset → Debug
│   ├── Interaction: V-slider / switch / plate drag / voltmeter / checkboxes
│   ├── Animation: current indicators (fade); NO TimeControl UI
│   └── Assets: voltmeter* / probes / switchCue / capacitanceScreenIcon
└── CLBLightBulbScreen
    ├── Model: CLBLightBulbModel → CLBModel
    │   └── LightBulbCircuit → ParallelCircuit + LightBulb
    │         (+ RC discharge when LIGHT_BULB_CONNECTED)
    ├── View: CLBLightBulbScreenView
    │   stopwatch → circuit → time+reset → bars → viewControl → toolbox → voltmeter
    ├── Interaction: + TimeControl / Stopwatch toolbox
    ├── Animation: discharge + current indicators + bulb halo
    └── Assets: + lightBulbBase (复合灯泡)
```

**两屏独立 Model 实例**；仅共享 `switchUsedProperty`。`[已确认]` `capacitor-lab-basics-main.js:33-44`

---

## 1. Layout / Coordinate

| 项 | 值 | 证据 | 标记 |
|----|-----|------|------|
| Design / world size | **1024 × 618** | `CLBModel.js:28` `CANVAS_RENDERING_SIZE`；ScreenView 未覆盖 layoutBounds | `[已确认]` world；`[推测]` ≡ joist DEFAULT_LAYOUT_BOUNDS |
| MVT scale | **12000** | `YawPitchModelViewTransform3.js:39-41` | `[已确认]` |
| MVT pitch | **30°** | 同上 | `[已确认]` |
| MVT yaw | **−45°** | 同上；探针 `rotate(-yaw)` ⇒ **+45°** | `[已确认]` |
| Background | `rgb(153, 193, 255)` | `CLBConstants.js:92` | `[已确认]` |
| Battery model pos | `(0.0065, 0.030, 0)` m | `CLBConstants.js:35` | `[已确认]` |
| Capacitor offset | Capacitance：`+ (0.024, 0, 0)`；LightBulb：`+(0.018, 0.001, 0)` | `CircuitConfig.js` / `CLBLightBulbModel.js` | `[已确认]` |
| Bulb offset | capacitor + `LIGHT_BULB_X_SPACING(0.023)`；view center +`(0.002,0,0)` | `CLBConstants.js:34` · `LightBulbCircuitNode.js:53` | `[已确认]` |
| Play area | Circuit Node（无额外 translation）；形状已在 view 坐标 | `CLBCircuitNode.js:158-161` | `[已确认]` |
| Measurement area | `BarMeterPanel`：`left = topWire.left - 40`，`top = layoutBounds.top + 10`；`minWidth=580` | Cap/LB ScreenView · `BarMeterPanel.js` | `[已确认]` |
| Control panel | `CLBViewControlPanel.rightTop = layoutBounds.rightTop + (−10,10)` | ScreenView | `[已确认]` |
| Toolbox | `rightTop = viewControl.rightBottom + (0,10)` | ScreenView | `[已确认]` |
| Reset | Cap：`bottom−30, right−30, r=25` 且 `moveToBack`；LB：与 TimeControl 同 HBox `bottom−20, right−30, spacing=50` | ScreenViews | `[已确认]` |
| Responsive | **无** availableBounds 重排面板；仅 Stopwatch 用 `visibleBoundsProperty` 作拖界 | ScreenViews | `[已确认]` |

### 1.1 Capacitance 屏图层（底→顶，Reset 最终置底）

1. capacitanceCircuitNode  
2. barMeterPanel  
3. viewControlPanel  
4. toolboxPanel  
5. voltmeterNode  
6. resetAllButton → **`moveToBack()`**  
7. DebugLayer  

`CapacitanceScreenView.js:78-89` `[已确认]`

### 1.2 Light Bulb 屏图层

1. stopwatchNode  
2. lightBulbCircuitNode  
3. simControlHBox（TimeControl + Reset）  
4. barMeterPanel  
5. viewControlPanel  
6. toolboxPanel  
7. voltmeterNode  
8. DebugLayer  

`CLBLightBulbScreenView.js:71,134-141` `[已确认]`

---

## 2. Model / Property

### 2.1 电路状态 `CircuitState`

`BATTERY_CONNECTED | OPEN_CIRCUIT | LIGHT_BULB_CONNECTED | SWITCH_IN_TRANSIT`  
Capacitance 仅前两者；Light Bulb 默认三态（query `switch=twoState` 时去掉 OPEN）。

### 2.2 核心公式 `[已确认]`

| 量 | 公式 | 文件 |
|----|------|------|
| C | `ε₀ · w · depth / separation`（真空） | `Capacitor.js` |
| Q | `C·V`；`|Q|<MIN_PLATE_CHARGE(1e-14)` → 0 | 同上 |
| U | `½ C V²` | 同上 |
| E | `|Q|<min → 0`；else `V/d` | 同上 |
| 断路 V | `Q_disconnected / C` | CapacitanceCircuit / LightBulbCircuit |
| 接电池 V | `V_battery` | 同上 |
| 放电 | `V *= exp(-dt/(R·C))`，`R=5e12` | `Capacitor.discharge` |
| 电流（非灯） | `≈ dQ/dt` | `ParallelCircuit` |
| 电流（接灯） | `V/R` | `LightBulbCircuit` |

### 2.3 关键 Property 初值（节选）

| Property | 初值 | Reset |
|----------|------|-------|
| battery.voltage | 0 ∈ [−1.5, 1.5]；\|V\|<0.15 snap 0 | yes |
| plateSeparation | 0.006 m ∈ [0.002, 0.01] | yes |
| plateWidth | √(2e-4) ≈ 0.014142 m ∈ [0.01, 0.02] | yes |
| plateChargesVisible | true | yes |
| electricFieldVisible | false | yes |
| capacitanceMeterVisible | true | yes |
| topPlateCharge / storedEnergy meter | false | yes（经 meter.reset / LB 显式） |
| barGraphsVisible | true | yes |
| voltmeterVisible | false | yes |
| currentVisible | true | yes |
| currentOrientation | 0（电子）/ π（常规） | yes |
| isPlaying | true | yes |
| timeSpeed | NORMAL（SLOW → dt×0.125） | yes |
| circuitConnection | BATTERY_CONNECTED | yes |
| switchUsed | false（跨屏共享） | yes |

完整表见子代理取证；`CLBModel.js:53-227`。

### 2.4 Clock

- Joist 驱动 `model.step(dt)`。  
- Capacitance：**无** TimeControl UI，但 `isPlaying` 默认 true → 持续 step（电流指示动画）。  
- Light Bulb：TimeControl；`manualStep(dt=0.2)`。  
- `stepEmitter` → CurrentIndicator 1.5s 淡出。

---

## 3. View Node Hierarchy（电路）

`CLBCircuitNode` 底→顶 `[已确认]`：

connectionAreas → bottomWire → battery → capacitor → topWire → topSwitch → batteryCurrentIndicators → plateSeparationHandle → plateAreaHandle → bottomSwitch  

Light Bulb 追加：lightBulb → bulbCurrentIndicators  

`CapacitorNode`：bottomPlate → eField → topPlate  

---

## 4. 六原图深挖（必须复用）

| Asset | Intrinsic | Parent | Scale | Rotation | Origin/Anchor | Layer | 交互 | 使用位置 |
|-------|-----------|--------|-------|----------|---------------|-------|------|----------|
| `probeBlack.png` | **63×510** | `VoltmeterProbeNode` Image | **0.25** | Node `rotate(-yaw)` ≈ **+45°** | Image `translate(-w/2,0)` 顶中心；线接 `centerBottom` | Voltmeter 子树（黑探针） | **拖** | 负探针；toolbox icon 内缩略 |
| `probeRed.png` | **62×501** | 同上 | **0.25** | 同 | 同 | 红探针 | **拖** | 正探针 |
| `voltmeterBody.png` | **405×502** | `VoltmeterBodyNode` | **0.336**；`hitTestPixels` | 0 | 默认左上；Node=`MVT(bodyPos)` | Voltmeter 底层 | **拖** body | 机身；读数 Rect+Text 叠加 |
| （icon）同 body | 同 | `VoltmeterIconNode` | body **0.17**；probe **0.10**；toolbox 再 ×0.6 若有 timer | probe 不 yaw | probes `centerBottom=body.centerBottom±(40,15)` | icon 组合 | 转发拖出 | Toolbox |
| `switchCueArrow.png` | **157×117** | `SwitchNode` | **25/height**；底开关再 `scale(1,-1)` | 竖直翻转（底） | `leftTop=wireSwitch.center` 后 `translate(-80,-250)` | Switch 最先子节点 | **否** | `!switchUsed` 时显示 |
| `capacitanceScreenIcon.png` | **549×374** | `ScreenIcon(Image)` | proportion 1 | 0 | Home 图标 | N/A | **否** | Capacitance 屏图标 |
| `lightBulbBase.png` | **89×71** | `BulbNode` Image | **42/height** | 整泡 `rotate(π)` | `centerY=0; left=0` | fill→wires→filament→halo→**base**→outline | **否** | 灯座；屏图标复用绘制 |

证据：`VoltmeterProbeNode.js:38-49` · `VoltmeterBodyNode.js:57+` · `SwitchNode.js:136-153` · `CapacitanceScreen.js:31-34` · `BulbNode.js:110-176`  
磁盘尺寸：本机 PNG 实测 `[已确认]`

---

## 5. Canvas 重建对象（源码几何，禁止臆造）

| 对象 | 源码 | 关键常量（摘要） |
|------|------|------------------|
| Battery | `BatteryGraphicNode` + `BatteryNode` | H=511,R=158, persp=0.304；色/渐变见源；view `scale:0.30`；VSlider |
| Plates | `PlateNode`/`BoxNode`/`BoxShapeCreator` | 板色 (245,245,245)；三面 Path；`PLATE_HEIGHT=0.0005` |
| E-field | `EFieldNode` | ARROW 6×7；`SPACING_CONSTANT=0.0258`；`spacing∝1/√|E|` |
| Charge | `PlateChargeNode` | n∈[1,625]；− 7×2；+ 双矩形 |
| Wires | `WireShapeCreator`/`WireNode` | stroke 厚 7 round → strokedShape；fill/stroke 灰 |
| Bar meter | `BarNode` 280×18；panel minWidth 580；max 2.7e-12 | |
| Drag handle | 箭头长 45；sep 线 60 / area 线 22；绿 rgb(61,179,79) | |
| Switch | r=8 触点；hinge 8/5；`SWITCH_ANGLE=π/4`；线长 0.0064 m | |
| Current | 箭头长 88；fade 1.5s 0.75→0 | |
| Bulb body | Path + halo；电流 map 0..5e-13 → scale 0..225 | |

---

## 6. Interaction / Reset / Strings / QP

见 `SOURCE_BEHAVIOR_MATRIX.md` + `spec/需求简述.md`。

Query：`switch=threeState|twoState`（默认 three）；`showDebugAreas`。

Strings：`capacitor-lab-basics-strings_en.json`（26 keys）——电压/电容/电荷/能量单位格式串齐全。

---

## 7. AC 摘要（功能）

1. 双屏：Capacitance / Light Bulb；共享首次开关提示状态。  
2. 电池电压可调 −1.5…1.5 V，极性翻转电池图形。  
3. 板面积与间距可拖，C/Q/U/E 实时更新。  
4. 开关：接电池 / 开路（Cap）；+ 接灯泡与 RC 放电（LB）。  
5. 条形表三量；电场/电荷/电流方向可视化。  
6. 电压表可从工具箱拖出，双探针测电位差。  
7. Light Bulb：时间控制 + 秒表 + 灯泡亮度随电流。  
8. Reset All 恢复模型与共享 cue。  
9. 视觉：原图 6 资产复用；其余按 Scenery 几何重建；Substituted=0。

---

## 8. 缺口

| 项 | 状态 |
|----|------|
| joist `DEFAULT_LAYOUT_BOUNDS` 本地文件 | `[待确认]`（有 1024×618 强相关） |
| Capacitance 2-connection 下 snap 右区 | `[待确认]` 运行时 |
| DebugLayer 是否进 Flutter | 默认 **不进** 用户 UI `[已确认]` 源码存在 |
| PhetColorScheme.RED_COLORBLIND 精确色值 | `[待确认]` 查 scenery-phet 常量 |
