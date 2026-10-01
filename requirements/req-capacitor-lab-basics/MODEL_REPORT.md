# MODEL_REPORT — Capacitor Lab Basics

> Phase 2 · 2026-09-12  
> 唯一行为基准：本地 PhET `capacitor-lab-basics` + `scenery-phet/capacitor`  
> 标记：`[已确认]` / `[推测]` / `[待确认]` / `[BLOCKED]`

---

## STATUS: DONE（Model 电气层）

---

## 1. SSOT 分层

```
source state (V, geometry, connection, visibility flags, play/speed, switchUsed)
        ↓
derived (C, Q, U, E, currentAmplitude, arrowStyle, maxQ/maxE)
        ↓
render data — Phase 3+（本阶段未实现）
```

**未**放入 Model：颜色 ARGB、字体、asset path、view 像素坐标、Painter 缓存。  
**已**放入 Model（因 PhET `CLBModel` 源码如此）：可见性开关、`currentOrientation`、秒表累计时间。`[已确认]`

---

## 2. ParallelCircuit 取证 → 实现

| 行为 | PhET 证据 | Dart | 标记 |
|------|-----------|------|------|
| 名称 “parallel” | 电池与电容经开关并联拓扑；非通用网表 | `ParallelCircuit` 专用类 | `[已确认]` |
| 默认连接 | `BATTERY_CONNECTED` | 同 | `[已确认]` |
| 接电池时 V_plate = V_bat | CapacitanceCircuit / LightBulbCircuit | `updatePlateVoltages` | `[已确认]` |
| 离开电池时存 Q | `disconnectedPlateCharge = getTotalCharge()` | `setCircuitConnection` | `[已确认]` |
| 开路 V = Q/C | Capacitance：非电池；LB：仅 OPEN | 子类分别实现 | `[已确认]` |
| 电流 I≈dQ/dt | ParallelCircuit.updateCurrentAmplitude | 同 | `[已确认]` |
| 接灯 I=V/R + 截止 | LightBulbCircuit | 同 | `[已确认]` |
| 放电 V*=exp(−dt/RC) | Capacitor.discharge + LB.step | 同 | `[已确认]` |
| \|V\|≤1e-3 置零 | LightBulbCircuit.step | 同 | `[已确认]` |
| C 变且接灯时 Vo 调整 | updateDischargeParameters | Capacitor._afterCapacitanceChange | `[已确认]` |
| reset | battery/capacitor/I/connection/Q/prevQ | 同 | `[已确认]` |
| Wire Shape / probe hit | ParallelCircuit.shapeTouchesWireGroup 等 | **未实现** | `[待确认]`→ Phase 5 |
| CircuitSwitch 角度 | CircuitSwitch.js | **未实现**（连接用 enum） | `[待确认]`→ Phase 4 交互 |

**无效状态**：Capacitance 不允许 `lightBulbConnected` → `ArgumentError`。`[已确认]` 配置约束；PhET 靠 connections 数组限制 UI，未 throw —— Dart 显式守卫。`[推测]` 等价于 UI 不可达。

---

## 3. CLBModel

| 字段 | 初值 | Reset（base） | 标记 |
|------|------|---------------|------|
| plateChargesVisible | true | yes | `[已确认]` |
| electricFieldVisible | false | yes | `[已确认]` |
| capacitanceMeterVisible | true | yes | `[已确认]` |
| topPlateChargeMeterVisible | false | **base 不 reset**；由 BarMeter/屏 reset | `[已确认]` |
| storedEnergyMeterVisible | false | 同上 | `[已确认]` |
| barGraphsVisible | true | yes | `[已确认]` |
| voltmeterVisible | false | yes | `[已确认]` |
| currentVisible | true | yes | `[已确认]` |
| currentOrientation | 0 | yes | `[已确认]` |
| isPlaying | true | yes | `[已确认]` |
| timeSpeed | NORMAL | yes | `[已确认]` |
| switchUsed | shared | yes via shared.reset | `[已确认]` |
| maxPlateCharge / maxE | 公式 | derived | `[已确认]` |

Voltmeter：**位姿 + measuredVoltage 状态与 reset** `[已确认]`；探针测压算法 `[待确认]` Phase 5。

---

## 4. 双屏 Model

| | CapacitanceModel | ClbLightBulbModel |
|--|------------------|-------------------|
| Circuit | CapacitanceCircuit（2 态） | LightBulbCircuit（3 态默认） |
| 间距 | 0.024 / 0 | 0.018 / 0.001 | `[已确认]` |
| TimeControl | 无 UI，仍 step | step + slow×0.125；再 updateCurrentAmplitude | `[已确认]` |
| Reset | meters→VM→circuit→super | 显式 flags→meters→VM→circuit→super | `[已确认]` |
| 共享 | `ClbSharedState.switchUsed` | 同实例 | `[已确认]` |
| 独立 | 各自 circuit / meters / voltmeter | 同 | `[已确认]` |

`twoStateSwitch` 构造参数对齐 query `switch=twoState`；默认 three。`[已确认]`

---

## 5. 文件清单

```
lib/capacitor_lab_basics/
  clb_constants.dart / clb_colors.dart / clb_strings.dart
  common/model/
    circuit_state.dart, circuit_config.dart, time_speed.dart
    capacitor_physics.dart, battery.dart, capacitor.dart
    light_bulb.dart, bar_meter.dart, voltmeter.dart
    parallel_circuit.dart  (ParallelCircuit + CapacitanceCircuit + LightBulbCircuit)
    clb_model.dart         (ClbModel + ClbSharedState)
  capacitance/model/capacitance_model.dart
  light_bulb/model/clb_light_bulb_model.dart
test/capacitor_lab_basics/
  capacitor_physics_test.dart
  circuit_model_test.dart
```

---

## 6. BLOCKED / 后续

| 项 | 状态 |
|----|------|
| Wire 几何 / Switch 角度 | `[BLOCKED]` 等 Phase 3–4 需要 view 坐标时再补 model 段 |
| Voltmeter computeValue | `[BLOCKED]` 需 Shape + ProbeTarget |
| RenderData | 有意推迟 Phase 3 |
