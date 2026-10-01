# SOURCE_BEHAVIOR_MATRIX — Capacitor Lab Basics

> Phase 1 · 2026-09-12 · 证据均来自本地 PhET 源码  
> 列定义：Feature | Source | State | Input | Output | Visual Response | Animation | Reset

---

## A. 全局 / 双屏共享

| Feature | Source | State | Input | Output | Visual Response | Animation | Reset |
| ------- | ------ | ----- | ----- | ------ | --------------- | --------- | ----- |
| Switch cue arrows | `SwitchNode` + `CLBCircuitNode` | `switchUsedProperty=false` 显示 | 用户首次改变开关连接 | `switchUsed=true` | 两屏箭头隐藏 | 无 | `switchUsed.reset()` → 箭头再出现 |
| Screen background | `CLBConstants.SCREEN_VIEW_BACKGROUND_COLOR` | 常量色 | — | — | `rgb(153,193,255)` | 无 | N/A |
| Design size | `CLBModel` `1024×618` | worldBounds | — | voltmeter drag 界 | 布局锚点相对 layoutBounds | 无 | N/A |

---

## B. 电池与电压

| Feature | Source | State | Input | Output | Visual Response | Animation | Reset |
| ------- | ------ | ----- | ----- | ------ | --------------- | --------- | ----- |
| Battery voltage | `Battery.voltageProperty` | 初值 0；范围 [−1.5,1.5] | `VSlider` 拖动；量化 0.05 V | V | 正极朝上/下切换 `BatteryGraphicNode`；刻度标签 | 无 | voltage.reset |
| Snap to zero | `BatteryNode` endDrag | \|V\|<0.15 | 松手 | V=0 | 滑条回零 | 无 | — |
| Polarity | `Battery.polarityProperty` | 由 V 符号派生 | V 变号 | POSITIVE/NEGATIVE | 电池图形翻转 | 无 | 随 V |

---

## C. 电容器几何与导出量

| Feature | Source | State | Input | Output | Visual Response | Animation | Reset |
| ------- | ------ | ----- | ----- | ------ | --------------- | --------- | ----- |
| Plate separation | `plateSeparationProperty` | 默认 0.006；[0.002,0.01] | 竖拖 handle；`round(5e3*s)/5e3` | d | 板间距、导线/开关铰链、C/E | 无 | yes |
| Plate area / width | `plateSizeProperty` | 默认 w=√(2e-4) | 对角拖；`setPlateWidth`；area 量化 | A,w | 板尺寸、电荷密度、C | 无 | yes |
| Capacitance C | Derived | C=ε₀·w·depth/d | 几何变 | C | 条形表电容；数值 | 无 | 派生 |
| Plate charge Q | Derived | Q=CV；\|Q\|<1e-14→0 | V 或 C | Q | 板电荷符号数；条形表 | 无 | 派生 |
| Stored energy U | Derived | U=½CV² | V,C | U | 黄色能量条 | 无 | 派生 |
| E-field | Derived + `EFieldNode` | E=V/d 或 0 | V,d,Q | E | 黑箭头场线；间距∝1/√\|E\| | 无 | 派生 |
| Plate charges toggle | `plateChargesVisibleProperty` | 默认 true | checkbox | visible | ± 符号显隐 | 无 | yes |
| E-field toggle | `electricFieldVisibleProperty` | 默认 false | checkbox | visible | 场线显隐 | 无 | yes |

---

## D. 电路连接 / 开关

| Feature | Source | State | Input | Output | Visual Response | Animation | Reset |
| ------- | ------ | ----- | ----- | ------ | --------------- | --------- | ----- |
| Capacitance connect | `circuitConnectionProperty` | 默认 BATTERY | 拖开关 / 点触点 | BATTERY \| OPEN | 开关臂角度；开路时存 Q | 拖中 SWITCH_IN_TRANSIT | connection.reset |
| Light Bulb connect | 同上 + LB circuit | 三态默认 | 拖/点 | BATTERY \| OPEN \| BULB | 臂指向；接灯时放电 | 拖中 transit | yes |
| Disconnected Q store | `disconnectedPlateChargeProperty` | 离 BATTERY 时写入 getTotalCharge | 连接变更 | Q_store | 开路 V=Q/C | 无 | yes |
| Switch lock | `switchLockedProperty` | 互斥 | 另一开关拖 | 阻止并发 | — | — | — |

---

## E. 放电与电流（Light Bulb）

| Feature | Source | State | Input | Output | Visual Response | Animation | Reset |
| ------- | ------ | ----- | ----- | ------ | --------------- | --------- | ----- |
| RC discharge | `Capacitor.discharge` | BULB 连接且 \|V\|>1e-3 | clock `dt` | V\*=exp(−dt/(RC)) | 电压/电荷/能量下降；灯泡变暗 | 连续 step | reset V |
| Current (battery path) | `ParallelCircuit.updateCurrentAmplitude` | 非灯连接 | dQ/dt | I | 电流箭头方向/可见 | 指示器 fade 1.5s | I→0 |
| Current (bulb) | `LightBulbCircuit` | BULB 连接 | I=V/R | I | 灯泡侧指示器 | 同上 | yes |
| Current visibility | `currentVisibleProperty` | 默认 true | checkbox | — | 指示器显隐 | — | yes |
| Current direction | `currentOrientationProperty` | 0 电子 / π 常规 | radio | arrowColor | 青箭 / 红箭 | — | yes |
| Bulb brightness | `BulbNode` | map \|I\| 0..5e-13 → scale 0..225 | I | halo scale | halo 显隐/大小 | 随 I | 断路熄灭 |

---

## F. 条形表 / 控制面板

| Feature | Source | State | Input | Output | Visual Response | Animation | Reset |
| ------- | ------ | ----- | ----- | ------ | --------------- | --------- | ----- |
| Capacitance meter | `BarMeter` + panel | visible 默认 true | checkbox | 条长∝C/2.7e-12 | 绿色条 + pF 文案 | 无 | meter.reset |
| Top plate charge meter | 同上 | visible 默认 false | checkbox | ∝Q | 电荷色条 + pC | 无 | yes |
| Stored energy meter | 同上 | visible 默认 false | checkbox | ∝U | 黄色条 + pJ | 无 | yes |
| Bar graphs master | `barGraphsVisibleProperty` | 默认 true | view checkbox | panel.visible | 整板显隐 | 无 | yes |

---

## G. 电压表

| Feature | Source | State | Input | Output | Visual Response | Animation | Reset |
| ------- | ------ | ----- | ----- | ------ | --------------- | --------- | ----- |
| Show voltmeter | `voltmeterVisibleProperty` | 默认 false | 从 toolbox 拖出 | true | 显示 body+双探针+软线 | 无 | false + 位姿 reset |
| Drag body | `bodyPositionProperty` | 初 (0,0,0) | DragListener | 位置 | 整表移动；`moveToFront` | 无 | yes |
| Drag probes | probe position props | 初值见 Voltmeter.js | 独立拖 | 位置 | 探针+软线；yaw 旋转 | 无 | yes |
| Measured V | `measuredVoltageProperty` | null→“?” | 探针目标/板压 multilink | V 或 null | 读数框 | 无 | null |
| Return to toolbox | ToolboxPanel | 与 toolbox bounds eroded(40) 相交 | 松手 | visible=false | 收回 | 无 | — |

---

## H. 时间 / 秒表（仅 Light Bulb 屏）

| Feature | Source | State | Input | Output | Visual Response | Animation | Reset |
| ------- | ------ | ----- | ----- | ------ | --------------- | --------- | ----- |
| Play/Pause | `isPlayingProperty` | 默认 true | TimeControl | gate step | — | 暂停停放电 | yes |
| Slow | `timeSpeedProperty` | NORMAL / SLOW | TimeControl | dt×0.125 | — | 放电变慢 | yes |
| Step | `manualStep` | — | 按钮 | dt=0.2 强制 step | 一帧更新 | — | — |
| Stopwatch | scenery-phet Stopwatch | toolbox | 拖出/回 | 计时 | 表盘 | step 累加 | stopwatch.reset |

Capacitance 屏：`includeTimer:false`；无 TimeControl；仍持续 `step`（电流动画）。

---

## I. Reset All

| Feature | Source | State | Input | Output | Visual Response | Animation | Reset |
| ------- | ------ | ----- | ----- | ------ | --------------- | --------- | ----- |
| Reset All | ScreenView `ResetAllButton` | — | 点击 | `model.reset()` 链 | 全部回默认；cue 再现 | 无 | **本行即 Reset** |

Capacitance 顺序：meters → voltmeter → circuit → super。  
Light Bulb：额外显式部分 visible flags → meters → voltmeter → circuit → super。

---

## J. 非用户功能

| Feature | Source | State | Input | Output | Visual Response | Animation | Reset |
| ------- | ------ | ----- | ----- | ------ | --------------- | --------- | ----- |
| DebugLayer | `DebugLayer.js` | query / 总是 addChild | — | 调试形状 | Flutter **不上线** | — | — |

## L. Phase 3 Static Render（2026-09-12）

| Feature | Source | Flutter | Result |
| ------- | ------ | ------- | ------ |
| MVT | YawPitchModelViewTransform3 | YawPitchMvt | `[源码一致]` |
| Battery graphic | BatteryGraphicNode + scale 0.30 | BatteryPainter | `[源码一致]` / gradient `[视觉近似]` |
| Plates | BoxShapeCreator / PlateNode | CapacitorPlatesPainter | `[源码一致]` |
| Wires | WireShapeCreator endpoints | CircuitGeometry + WirePainter | `[源码一致]` |
| Voltmeter/probes/cue PNG | images/* | Image.asset overlays | `[源码一致]` |
| Layer order | CLBCircuitNode | StaticCircuitView Stack | `[源码一致]` |
| Interaction | — | deferred Phase 4 | — |

| Feature | Source | Dart Model | Tests | 标记 |
| ------- | ------ | ---------- | ----- | ---- |
| C/Q/U/E formulas | Capacitor.js | CapacitorPhysics + Capacitor | physics_test | `[已确认]` |
| Battery V + snap | Battery.js / BatteryNode | Battery | physics + circuit | `[已确认]` |
| Capacitance connect / open | CapacitanceCircuit | CapacitanceCircuit | circuit_model_test | `[已确认]` |
| LB discharge + I=V/R | LightBulbCircuit | LightBulbCircuit | circuit_model_test | `[已确认]` |
| CLB visibility + step/slow | CLBModel | ClbModel | circuit_model_test | `[已确认]` |
| Dual screen + shared switchUsed | main.js | CapacitanceModel + ClbLightBulbModel + ClbSharedState | circuit_model_test | `[已确认]` |
| Switch angle drag | CircuitSwitch | ParallelCircuit angles + SwitchGestureLayer | interaction_test | `[已确认]` Phase 4 |
| VSlider / plate handles / toolbox | BatteryNode / Plate* / Toolbox | widgets in capacitor_lab_basics | interaction_test | `[已确认]` Phase 4 |

## M. Phase 4 Interaction（2026-09-12）

| Feature | Source | Flutter | Result |
| ------- | ------ | ------- | ------ |
| VSlider | BatteryNode | BatteryVoltageSlider | `[源码一致]` |
| Switch 2-state | CircuitSwitchDragHandler | SwitchGestureLayer + CircuitGeometry | `[源码一致]` |
| Plate sep/area | Plate*DragHandle* | PlateHandlesPainter + gesture | `[布局已对齐]` / area ΔX `[待确认]` |
| View / bar / toolbox | CLBViewControlPanel / BarMeterPanel / ToolboxPanel | widgets | `[布局已对齐]` |
| Voltmeter drag | Voltmeter*Node | VoltmeterDragLayer | `[原版资源一致]`；测压 `computeValue` `[已确认]` Phase 5 |
| Voltmeter measure | Voltmeter.js | Voltmeter + ProbeHitTester | `[已确认]` Capacitance；bulb hit Phase 6 |
| Plate charges | PlateChargeNode | PlateChargePainter | `[已确认]` Phase 5 |
| E-field | EFieldNode | EFieldPainter | `[已确认]` Phase 5 |
| Reset All | ResetAllButton | ClbResetAllButton → model.reset() | `[源码一致]` |
