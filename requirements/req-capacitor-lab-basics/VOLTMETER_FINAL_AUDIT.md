# VOLTMETER_FINAL_AUDIT — Interaction Verification

> Req: 2026-09-12  
> Baseline: local PhET `capacitor-lab-basics` + Flutter `lib/capacitor_lab_basics`  
> Scope: Voltmeter interaction / hit-test / reading chain only — **no Model/Circuit redesign**

## Verdict

**Voltmeter: [源码一致]** for the verified measurement and interaction chain below.

Manual UI smoke (drag feel on device) remains recommended for grab-offset continuity; automated coverage is listed under each item.

---

## Scorecard

| Check | Result |
|-------|--------|
| Toolbox Drag | PASS |
| Body Drag | PASS |
| Probe Drag | PASS |
| Probe Tip Measurement | PASS |
| Grab Offset | PASS |
| Signed Voltage | PASS |
| Invalid State | PASS |
| Wire Hit | PASS |
| Switch Hit | PASS |
| Battery Measurement | PASS |
| Live Refresh | PASS |
| Toolbox Return | PASS |
| Original Assets | PASS |

---

## Items

### Toolbox Drag — PASS

- **Source Evidence:** `ToolboxPanel.js` forwarding listener sets `visible`, places **body** only, then `bodyNode.dragListener.press`. Probe properties keep `POSITIVE_PROBE_POSITION` / `NEGATIVE_PROBE_POSITION` (`Voltmeter.js:32-33`) — not glued to body.
- **Flutter Implementation:** `placeVoltmeterFromToolbox` + `ToolboxPanel._extractAtPointer` / `_moveBodyOnly`.
- **Test Evidence:** `probe_grab_offset / toolbox extract` — absolute defaults after place; body view ≠ probe view.

### Body Drag — PASS

- **Source Evidence:** `VoltmeterBodyNode` drag updates only `bodyPositionProperty`.
- **Flutter Implementation:** `VoltmeterDragLayer` body `onPanUpdate` mutates `bodyX/Y` only.
- **Test Evidence:** `body_drag_does_not_move_probe`.

### Probe Drag — PASS

- **Source Evidence:** `VoltmeterProbeNode` independent tip drag listeners.
- **Flutter Implementation:** Separate red/black `_probe` pans; delta-only (no tip teleport on pan start).
- **Test Evidence:** `independent probe delta does not move body or other probe`.

### Probe Tip Measurement — PASS `[源码一致]`

- **Source Evidence:** `VoltmeterShapeCreator.js` — tip polygon at `probePosition + PROBE_TIP_OFFSET (0.00018, 0.00025)`, size `PROBE_TIP_SIZE (0.0003×0.0013)`. Hit uses tip shape only — not probe body/asset center.
- **Flutter Implementation:** `VoltmeterShapeCreator` + `Voltmeter.updateMeasuredVoltage` → `ProbeHitTester.getProbeTarget(tip)`.
- **Test Evidence:** `probe_tip_measurement_source`; plate tip placement in `live_reading_refresh` / measurement suite.

### Grab Offset — PASS

- **Source Evidence:** After extract, body drag uses DragListener grab. Toolbox extract itself centers body under pointer (`-width/2,-height/2`).
- **Flutter Implementation:** Icon-local → body-proportional grab on extract; subsequent body/probe pans use **delta** (preserves grab, no jump).
- **Test Evidence:** extract placement tests; probe delta independence.  
- **Note:** Extract grab mapping differs slightly from PhET center-under-pointer; continuous drag offset behavior matches user AC (不瞬移).

### Signed Voltage — PASS

- **Source Evidence:** `Voltmeter.computeValue` — `(isTop ? 1 : -1) * V`; **no abs**.
- **Flutter Implementation:** `Voltmeter.computeValue` same branches.
- **Test Evidence:** `red_black_sign_reversal`; existing `voltmeter_measurement_test` ±1.5.

### Invalid State — PASS

- **Source Evidence:** `NONE` → `measuredVoltage = null` → UI `"?"`.
- **Flutter Implementation:** `null` → `ClbStrings.voltsUnknown`.
- **Test Evidence:** `invalid_probe_region`.

### Wire Hit — PASS

- **Source Evidence:** `Wire.contacts` = tip ∩ **stroked wire shape** (`WireShapeCreator` lineWidth **7**), not a huge group AABB alone.
- **Flutter Implementation:** Per-segment `PathIntersection.wireSegmentCapsule(..., halfWidth: 3.5)`.
- **Test Evidence:** `wire_contact_boundary` — mid-segment hit; far miss; capsule bounds not oversized.

### Switch Hit — PASS

- **Source Evidence:** `CircuitSwitch.contacts` — **only** when connected (not OPEN / IN_TRANSIT); circle radius `CONNECTION_POINT_RADIUS` at hinge + dir × `SWITCH_WIRE_LENGTH`. Lever metal is **not** that target; switch wire is separate (`WIRE_SWITCH_*`). Visual blade tip uses ~0.9× length.
- **Flutter Implementation:** `_switchConnectionContacts` / `_touchesSwitchWire` order matches `ParallelCircuit.getProbeTarget`.
- **Test Evidence:** `switch_contact_boundary` — open ≠ SWITCH_CONNECTION; closed full-length circle = SWITCH_CONNECTION; mid-lever = WIRE_SWITCH (same `CircuitPosition` rail).

### Battery Measurement — PASS

- **Source Evidence:** `Battery.contacts` — **top terminal only** (bottom hidden in 3D). Bottom rail via wires. Voltage from `getTotalVoltage` when probes on opposite battery positions — not a hardcoded slider echo.
- **Flutter Implementation:** `_batteryContacts` + `computeValue` battery branch.
- **Test Evidence:** `battery_terminal_measurement` signed ±V and voltage follow.

### Live Refresh — PASS

- **Source Evidence:** `Voltmeter.js` links: visible, probe positions, plateVoltage, plateSeparation, plateSize, circuitConnection, battery.voltage, switch angle.
- **Flutter Implementation:** `ClbModel.refreshVoltmeterReading` via circuit listener + `notifyViewChanged` (tip/body drag). No whole-page `setState` outside model notify.
- **Test Evidence:** `live_reading_refresh`.

### Toolbox Return — PASS

- **Source Evidence:** `ToolboxPanel.js:156` — when `!isDragged` and `toolbox.bounds ∩ body.eroded(40)` → `visible=false` only (no snap animation). Screen `reset()` restores positions.
- **Flutter Implementation:** `maybeReturnVoltmeterToToolbox` — **eroded(40) only** (fixed this audit: removed extra full-body/center OR). Also `vm.reset()` for clean dock + next extract defaults (intentional vs PhET hide-only).
- **Test Evidence:** `toolbox_return`.

### Original Assets — PASS

- **Source Evidence / Flutter:** `voltmeter_body` / `probe_red` / `probe_black` via `Image.asset` (`ClbConstants.assetVoltmeterBody` …). Scales: body `0.336`, probe `0.25`. Visual probe top = model probe position; hit tip = model + tipOffset (PhET).

---

## Measurement chain (unchanged architecture)

```text
Probe Tip Shape
  → ProbeHitTester / getProbeTarget
  → ProbeTarget
  → CircuitPosition (+ remap)
  → signed computeValue
  → measuredVoltage | null ("?")
```

## Same-node rule

Distinct `ProbeTarget` values that share a `CircuitPosition` (e.g. `capacitorTop` + `wireCapacitorTop`) → **0**, not “same widget object”. Evidence: `same_node_measurement`.

## Residual / manual

1. Device smoke: toolbox grab continuity, free probe feel, tip visually on plate vs reading.  
2. Light Bulb wire/bulb-base hit — covered by same `ProbeHitTester` order; not re-exercised in this Capacitance-focused audit file.  
3. PhET return hides without reset; Flutter resets — documented intentional.

## Tests run

```text
flutter test test/capacitor_lab_basics/voltmeter_measurement_test.dart
               test/capacitor_lab_basics/voltmeter_interaction_audit_test.dart
→ 20 PASS
dart analyze (scoped) → clean
```
