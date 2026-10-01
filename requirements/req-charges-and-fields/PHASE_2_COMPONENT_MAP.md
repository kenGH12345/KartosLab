# PHASE 2 — Component Map · Charges and Fields

> Flutter 包根：`lib/charges_and_fields/`  
> L0 优先；禁止平行实现 Reset / Clock。

---

## Classification

| 类别 | Flutter 目标 | 源码对应 | 策略 |
|---|---|---|---|
| **Charge** | `model/charged_particle.dart` | ChargedParticle | 新建 |
| **Charge Visual** | `painters/charge_painter.dart` + widget | ChargedParticleRepresentationNode | Canvas 重建渐变 ± |
| **ChargeControl / Bin** | `widgets/charges_and_sensors_panel.dart` | ChargesAndSensorsPanel | 新建 |
| **ElectricFieldModel** | `model/charges_and_fields_model.dart` → `getElectricField` | ChargesAndFieldsModel | 新建（核心） |
| **PotentialModel** | 同 model → `getElectricPotential` | 同上 | 同文件、独立方法 |
| **FieldVector (grid)** | `painters/electric_field_grid_painter.dart` | ElectricFieldCanvasNode | 新建 |
| **FieldVector (sensor)** | sensor widget + ArrowPainter | ElectricFieldSensorNode | 新建 + L0 Arrow |
| **EquipotentialLine** | `model/electric_potential_line.dart` | ElectricPotentialLine | 新建（完整算法） |
| **Equipotential View** | `painters/equipotential_lines_painter.dart` | ElectricPotentialLinesNode | 新建 |
| **Potential Grid** | `painters/electric_potential_grid_painter.dart` | ElectricPotentialCanvasNode | Canvas fallback |
| **E-Field Sensor** | `model/electric_field_sensor.dart` + widget | ElectricFieldSensor* | 新建 |
| **Voltmeter** | `model/electric_potential_sensor.dart` + widget | ElectricPotentialSensorNode | 新建 + asset outline |
| **Meter pencil/eraser** | voltmeter controls | PencilButton / eraser | asset pencil |
| **Grid** | `painters/grid_painter.dart` | GridNode | 新建 |
| **MeasuringTape** | `model/measuring_tape.dart` + widget | MeasuringTape* | 新建（参考 GAO/PM） |
| **Transform** | `transform/caf_mvt.dart` | ModelViewTransform2 | 新建 InvertedY |
| **Controls** | `widgets/control_panel.dart` | ChargesAndFieldsControlPanel | 新建 |
| **Toolbox** | `widgets/toolbox_panel.dart` | ChargesAndFieldsToolboxPanel | 新建 |
| **Reset** | `KratosResetAllButton` | ResetAllButton | **L0 复用** radius 20.8 |
| **Animation** | SimulationClock / AnimationController | TWEEN | L0 / Flutter |
| **Screen** | `screens/charges_and_fields_screen.dart` | ScreenView | 新建 |
| **Home (standalone)** | `screens/charges_and_fields_home.dart` | Sim shell | 独立入口；Final Gate 前不挂 Home |
| **Capture** | `screens/charges_and_fields_capture_main.dart` | — | Visual QA |

---

## File Plan

```
lib/charges_and_fields/
├── caf_constants.dart
├── caf_colors.dart
├── caf_strings.dart
├── caf_assets.dart
├── charges_and_fields.dart          # library export
├── model/
│   ├── vec2.dart
│   ├── charged_particle.dart
│   ├── model_element.dart
│   ├── electric_field_sensor.dart
│   ├── electric_potential_sensor.dart
│   ├── electric_potential_line.dart
│   ├── measuring_tape.dart
│   └── charges_and_fields_model.dart
├── transform/
│   └── caf_mvt.dart
├── painters/
│   ├── charge_painter.dart
│   ├── electric_field_grid_painter.dart
│   ├── electric_potential_grid_painter.dart
│   ├── equipotential_lines_painter.dart
│   └── grid_painter.dart
├── widgets/
│   ├── control_panel.dart
│   ├── toolbox_panel.dart
│   ├── charges_and_sensors_panel.dart
│   ├── charged_particle_node.dart
│   ├── electric_field_sensor_node.dart
│   ├── electric_potential_sensor_node.dart
│   └── measuring_tape_node.dart
└── screens/
    ├── charges_and_fields_home.dart
    ├── charges_and_fields_screen.dart
    └── charges_and_fields_capture_main.dart
```

---

## Dependency Direction

```
Model (pure Dart)
  ↑
Transform / Painters
  ↑
Widgets / Screen
  ↑
Home (standalone) → [Final Gate] → KARTOSLAB Home
```

Model **零** Flutter UI 依赖（`dart:ui` Offset 除外可选；优先自有 `CafVec2`）。
