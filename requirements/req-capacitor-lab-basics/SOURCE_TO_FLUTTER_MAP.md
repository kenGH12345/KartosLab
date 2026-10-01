# SOURCE_TO_FLUTTER_MAP — Capacitor Lab Basics

> Phase 1 · 2026-09-12  
> 原则：原图复用 · Scenery 几何 Canvas 重建 · 禁止 Material Icon / 替代图  
> Flutter 目标根：`lib/capacitor_lab_basics/`（见 ARCHITECTURE_PLAN）

---

## 1. 包 / 屏

| PhET | Flutter |
|------|---------|
| `capacitor-lab-basics-main.js` | `screens/capacitor_lab_basics_home.dart`（双 Tab） |
| `CapacitanceScreen` + View/Model | `capacitance/` screen + model + controller |
| `CLBLightBulbScreen` + View/Model | `light_bulb/` screen + model + controller |
| 共享 `switchUsedProperty` | `ClbSharedState.switchUsed`（顶层 ChangeNotifier 或 Inherited） |

---

## 2. Model

| PhET | Flutter | Phase |
|------|---------|-------|
| `CLBConstants` / `CapacitorConstants` | `clb_constants.dart` | 2 ✓ |
| `CLBModel` | `common/model/clb_model.dart` | 2 ✓ |
| `switchUsedProperty` | `ClbSharedState` | 2 ✓ |
| `CapacitanceModel` | `capacitance/model/capacitance_model.dart` | 2 ✓ |
| `CLBLightBulbModel` | `light_bulb/model/clb_light_bulb_model.dart` | 2 ✓ |
| `ParallelCircuit` | `common/model/parallel_circuit.dart` | 2 ✓ |
| `CapacitanceCircuit` / `LightBulbCircuit` | 同文件子类 | 2 ✓ |
| `Battery` / `Capacitor` / `LightBulb` | `battery.dart` / `capacitor.dart` / `light_bulb.dart` | 2 ✓ |
| `CircuitState` / `CircuitConfig` | `circuit_state.dart` / `circuit_config.dart` | 2 ✓ |
| `BarMeter` / `Voltmeter` | `bar_meter.dart` / `voltmeter.dart`（含 computeValue） | 2 ✓ / 5 ✓ |
| `ProbeTarget` / `CircuitPosition` | `probe_target.dart` / `circuit_position.dart` | 5 ✓ |
| `VoltmeterShapeCreator` / `getProbeTarget` | `voltmeter_shape_creator.dart` / `probe_hit_tester.dart` | 5 ✓ |
| `PlateChargeNode` / `EFieldNode` | `plate_charge_painter.dart` | 5 ✓ |
| `YawPitchModelViewTransform3` | `common/transform/yaw_pitch_mvt.dart` | 3 ✓ |
| `BoxShapeCreator` | `common/transform/box_shape_creator.dart` | 3 ✓ |
| Wire segment endpoints | `common/transform/circuit_geometry.dart` | 3 ✓ |
| Circuit view snapshot | `common/render/circuit_render_data.dart` | 3 ✓ |
| `BatteryGraphicNode` | `common/painters/battery_painter.dart` | 3 ✓ |
| `CapacitorNode` / plates | `common/painters/capacitor_plates_painter.dart` | 3 ✓ |
| `WireNode` | `common/painters/wire_painter.dart` | 3 ✓ |
| `CLBCircuitNode` static | `common/widgets/static_circuit_view.dart` | 3 ✓ |
| Capacitance ScreenView (static) | `capacitance/screens/capacitance_static_screen_body.dart` | 3 ✓ |
| Axon Property | 字段 + `ChangeNotifier` | 2 ✓ |
| `step(dt)` | `ClbModel.step` / circuit.step | 2 ✓ |
| Wire / Switch angle | geometry + SwitchGestureLayer | 3–4 ✓ |
| Voltmeter PNG overlays | StaticCircuitView / VoltmeterDragLayer | 3–4 ✓ |
| Interaction handlers | CapacitanceInteractiveScreenBody + widgets | 4 ✓ |
| `BatteryNode` VSlider | `battery_voltage_slider.dart` | 4 ✓ |
| `Plate*DragHandle*` | `plate_handles_painter` + gesture | 4 ✓ |
| `CLBViewControlPanel` | `clb_view_control_panel.dart` | 4 ✓ |
| `BarMeterPanel` | `bar_meter_panel.dart` | 4 ✓ |
| `ToolboxPanel` | `toolbox_panel.dart` | 4 ✓ |
| Capacitance ScreenView (interactive) | `capacitance_interactive_screen_body.dart` | 4 ✓ |

---

## 3. View / Painter / Widget

| PhET Node | Flutter | Asset 策略 |
|-----------|---------|------------|
| `BatteryGraphicNode` | `painters/battery_painter.dart` | **Canvas**（源码常量） |
| `BatteryNode` + VSlider | `battery_voltage_slider.dart` + BatteryPainter | 无图 |
| `CapacitorNode` / Plate / EField / Charge | `painters/capacitor_*.dart` | **Canvas** |
| `WireNode` | `painters/wire_painter.dart` | **Canvas** |
| `SwitchNode` + cue Image | `switch_tip_painter` + cue Image.asset | **原图+Canvas** |
| `BulbNode` | painter + `Image.asset(light_bulb_base)` | **原图+Canvas** |
| `CurrentIndicatorNode` | painter | **Canvas**（Phase 5+） |
| `VoltmeterBody/Probe` | `voltmeter_drag_layer` + assets | **原图** body/probes |
| `ProbeWireNode` | painter | **Canvas**（Phase 5） |
| `BarMeterPanel` / `BarNode` | `bar_meter_panel.dart` | **Canvas** |
| `Plate*DragHandle*` | `plate_handles_painter.dart` | **Canvas** |
| `CLBViewControlPanel` | `clb_view_control_panel.dart` | checkbox/radio 自绘 |
| `ToolboxPanel` | `toolbox_panel.dart` | voltmeter **原图** icon |
| `ResetAllButton` | `clb_reset_all_button.dart` | Canvas（无 Material Icons） |
| Screen icons | mipmap / bulb icon painter | **原图** / 绘制 |

---

## 4. Assets → Flutter 路径（Phase 2 再拷贝）

| Original | Flutter（计划） |
|----------|-----------------|
| `images/probeBlack.png` | `assets/simulations/capacitor_lab_basics/probe_black.png` |
| `images/probeRed.png` | `…/probe_red.png` |
| `images/voltmeterBody.png` | `…/voltmeter_body.png` |
| `images/switchCueArrow.png` | `…/switch_cue_arrow.png` |
| `mipmaps/capacitanceScreenIcon.png` | `…/capacitance_screen_icon.png` |
| `scenery-phet/mipmaps/lightBulbBase.png` | `…/light_bulb_base.png` |

**Phase 1 禁止拷贝**；实现前必须保留透明区与 intrinsic size。

---

## 5. Strings

| PhET JSON key | Flutter |
|---------------|---------|
| `capacitor-lab-basics-strings_en.json` | `clb_strings.dart`（先英文字面，后接 i18n 若项目有） |

---

## 6. 测试映射

| 源行为 | 建议测试 |
|--------|----------|
| C = ε₀ A / d | unit：默认几何 → C ≈ 2.95e-13 |
| Q = CV；欠压归零 | unit |
| U = ½CV² | unit |
| discharge exp | unit：固定 R,C,dt |
| snap voltage / plate drag quantize | unit `interaction_test` / physics_test |
| switch open/reconnect / switchUsed | unit `interaction_test` |
| voltmeter visible + reset probes | unit `interaction_test` |
| golden：默认两屏截图 | Phase 后期 visual QA |

---

## 7. 明确不映射

| PhET | 原因 |
|------|------|
| `DebugLayer` | 开发调试；Flutter 默认不上用户屏 |
| `assets/*.ai/*.psd` / 截图 PNG | 非运行时 |
| `lightBulbOn/Off.png` | 本 sim 未 import |
| PhET-iO tandem | 非 MVP |
