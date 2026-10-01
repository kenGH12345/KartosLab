# VOLTMETER_INTERACTION — PhET 行为基准

> 源：`js/common/model/meter/Voltmeter.js`、`view/control/ToolboxPanel.js`、
> `view/meters/VoltmeterNode.js` / `VoltmeterProbeNode.js` / `VoltmeterBodyNode.js`、
> `ParallelCircuit.getProbeTarget` / `VoltmeterShapeCreator.js`
>
> 验收结论见：`VOLTMETER_FINAL_AUDIT.md` → **Voltmeter [源码一致]**

## 工具链（唯一合法）

```text
Toolbox icon grab
  → visible=true
  → bodyPosition = pointer − (bodyW/2, bodyH/2)（仅 body，中心对准指针）
  → probes = 保持绝对坐标（默认 POSITIVE/NEGATIVE；回库不 reset）
  → Body 独立拖 / Probe tip 独立拖
  → tip shape → getProbeTarget → computeValue
  → measuredVoltage null → "?" ；有符号 ΔV（非 abs）
  → body 拖回 toolbox（body.eroded(40) ∩ dock）→ visible=false（不 reset；Reset All 才 reset）
```

## Probe Tip 是唯一测量点 `[源码一致]`

- 测量 **不是** probe asset 中心、笔身 AABB、或 body 位置。
- 唯一输入：`VoltmeterShapeCreator.getPositive/NegativeProbeTipShape()`  
  = `probePosition + PROBE_TIP_OFFSET(0.00018, 0.00025)` 上的 tip 多边形  
  （`PROBE_TIP_SIZE` 0.0003 × 0.0013 m）。
- 视觉：probe 图顶部对齐 `probePosition`；hit tip 相对 tipOffset —— 与 PhET 一致。  
  **视觉 tip ≈ hit tip**；禁止用笔身中心做 hit。

## Switch / Wire 命中边界 `[源码一致]`

| 区域 | ProbeTarget | 条件 |
|------|-------------|------|
| Switch connection circle | `SWITCH_CONNECTION_*` | 已接通；半径 `CONNECTION_POINT_RADIUS`；位置 hinge+dir×`SWITCH_WIRE_LENGTH` |
| Switch lever / blade 中段 | `WIRE_SWITCH_*` | tip ∩ switch wire stroked path |
| OPEN / IN_TRANSIT | 无 SWITCH_CONNECTION | `CircuitSwitch.contacts` → false |
| Wire | `WIRE_*` | tip ∩ segment stroked shape（lineWidth 7），非巨型 wire group Rect |

`SWITCH_CONNECTION` 与 `WIRE_SWITCH` / 同侧板导线均映射到同一 `CircuitPosition` 轨 → ΔV 计算一致。

## 读数触发（实时）

PhET `updateValue` 链接：

- visible / probe positions / plateVoltage / plateSeparation / plateSize  
- circuitConnection / battery.voltage / switch angle  

Flutter：`ClbModel.refreshVoltmeterReading` ← circuit listener + `notifyViewChanged`（每次 tip/body 拖动）。

## computeValue（摘要）

| 条件 | 结果 |
|------|------|
| 任一 tip = NONE | `null` → `?` |
| OTHER_PROBE | `0` |
| 同一 CircuitPosition | `0` |
| BATTERY_CONNECTED：电容端 remap → 电池端 | 用 `getTotalVoltage` |
| LIGHT_BULB_CONNECTED：灯泡 remap → 电容端 | 用 `getCapacitorPlateVoltage` |
| 电池两端 | `(top? +1 : -1) * V_total` |
| 电容两端（未接到电池） | `(top? +1 : -1) * V_plate` |
| 其它 | `null` |

**禁止**默认 `abs(ΔV)`。

## Flutter 入口

- `placeVoltmeterFromToolbox` — 拖出（仅 body；中心对准指针）
- `VoltmeterDragLayer` — body / probe 独立  
- `ProbeHitTester` — tip → ProbeTarget  
- `Voltmeter.computeValue` — 与源码分支一致  
- `maybeReturnVoltmeterToToolbox` — 仅 `body.eroded(40) ∩ toolbox` → hide（不 reset）
