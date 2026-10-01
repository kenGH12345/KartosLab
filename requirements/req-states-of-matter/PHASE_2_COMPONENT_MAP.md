# PHASE 2 — Component Map · States of Matter

> Flutter 落点：`lib/chemistry/states_of_matter/`  
> 测试：`test/states_of_matter/`  
> 2026-09-15

---

## 1. Directory Layout

```
lib/chemistry/states_of_matter/
  states_of_matter.dart
  som_constants.dart
  som_colors.dart
  som_assets.dart
  som_strings.dart
  model/
    atom_type.dart
    substance_type.dart
    phase_state.dart
    atom_attributes.dart
    scaled_atom.dart
    molecule_force_and_motion_data_set.dart
    lj_potential_calculator.dart
    interaction_strength_table.dart
    sigma_table.dart
    multiple_particle_model.dart
    phase_changes_model.dart
    dual_atom_model.dart
    motion_atom.dart
    atom_pair.dart
    force_display_mode.dart
    engine/
      abstract_verlet_algorithm.dart
      monatomic_verlet_algorithm.dart
      diatomic_verlet_algorithm.dart
      water_verlet_algorithm.dart
      abstract_phase_state_changer.dart
      monatomic_phase_state_changer.dart   # 含 liquid 快照数据
      diatomic_phase_state_changer.dart
      water_phase_state_changer.dart
      *_atom_position_updater.dart
      water_molecule_structure.dart
      kinetic/
        isokinetic_thermostat.dart
        andersen_thermostat.dart
  controller/
    states_of_matter_controller.dart
  transform/
    som_coordinate_transform.dart
  painters/
    particle_canvas_painter.dart
    particle_container_painter.dart
    dial_gauge_painter.dart
    composite_thermometer_painter.dart
    phase_diagram_painter.dart
    potential_graph_painter.dart
    force_arrow_painter.dart
  widgets/
    heater_cooler_node.dart
    substance_selector.dart
    states_phase_control.dart
    pointing_hand_node.dart
    bicycle_pump_node.dart
    time_control_row.dart
    reset_all_button.dart
    interaction_potential_accordion.dart
    phase_diagram_accordion.dart
    forces_accordion.dart
  screens/
    states_of_matter_home.dart          # Tab shell（独立可跑；Home 后挂）
    states_screen.dart
    phase_changes_screen.dart
    atomic_interactions_screen.dart
    states_of_matter_capture_main.dart  # Visual QA
```

---

## 2. Model Components

| Component | Source | Flutter | Priority |
|---|---|---|---|
| Enums + attributes | SubstanceType / AtomType / PhaseStateEnum / SOMConstants | `model/*` + `som_constants.dart` | P0 |
| `MoleculeForceAndMotionDataSet` | 同名 | `molecule_force_and_motion_data_set.dart` | P0 |
| `LjPotentialCalculator` | 同名 | `lj_potential_calculator.dart` | P0 |
| `InteractionStrengthTable` / Sigma | 同名 | tables | P0 |
| Monatomic Verlet | `MonatomicVerletAlgorithm` | engine | P0 |
| Isokinetic / Andersen | kinetic/* | kinetic/ | P0 |
| `MultipleParticleModel` | 同名 | `multiple_particle_model.dart` | P0 |
| Phase changers + snapshots | `*PhaseStateChanger` | engine + data | P0 |
| Diatomic / Water Verlet+Changer | 同名 | engine | P1 |
| `PhaseChangesModel` | 同名 | `phase_changes_model.dart` | P1 |
| `DualAtomModel` | 同名 | `dual_atom_model.dart` | P1 |

**规则**：Painter **禁止**推进物理；Clock → Controller → Model.step。

---

## 3. Rendering Components

| UI 元素 | 策略 |
|---|---|
| Particles | 单 `CustomPainter` + shaded spheres（复用 gas shaded_sphere 算法） |
| Container / lid | Path Painter（对齐 ParticleContainerNode 几何） |
| Thermometer | Painter（参考 gases_intro + 源码 CompositeThermometerNode） |
| Dial gauge | Painter（参考 GaugeNode / DialGaugeNode） |
| Phase icons | **原 mipmap PNG** Image.asset |
| Pointing hand | **原 mipmap** |
| Push pin | **原 images/pushPin.png** |
| Heater/Cooler | 复用/扩展 EFAC 资产模式或 scenery 等价绘制 |
| Pump | 程序绘制对齐 BicyclePumpNode（无 emoji） |
| Potential / Phase diagrams | CustomPainter |
| Force arrows | CustomPainter |

---

## 4. Interaction Components

| Component | Notes |
|---|---|
| HeaterCooler drag | 绑定 heatingCoolingAmount；snapToZero |
| Phase buttons | setPhase |
| Substance radios | substanceProperty |
| Hand / lid drag | 约束高度；映射 targetContainerHeight |
| Pump press | +3 molecules queued |
| Movable atom drag | DualAtom；grab offset；release resume |
| Accordion expand | BooleanProperty |
| Graph handle drag | ε / σ |
| TimeControl | SimulationClock + isPlaying |
| ResetAll | model.reset + view resets |

---

## 5. UI Components（L0）

| Need | Action |
|---|---|
| Tabs | REUSE `KratosTabbedScreen` |
| Slider | REUSE `KratosSlider` + PhET thumb 样式包装 |
| Radio | REUSE `KratosRadioGroup` |
| Clock | REUSE `SimulationClock` |
| Charts | 势图自定义；通用 chart 仅作参考 |

---

## 6. Measurement / Chart Components

| Component | Screen |
|---|---|
| CompositeThermometer | States · Phase Changes |
| DialGauge | Phase Changes |
| PhaseDiagram | Phase Changes |
| InteractionPotential / EpsilonControl graph | Phase Changes |
| InteractivePotentialGraph + force display | Interaction |

---

## 7. Implementation Order（M3）

1. Constants / enums / atom attributes / LJ calculator + **unit tests**
2. DataSet + Monatomic Verlet + thermostats + **unit tests**
3. MultipleParticleModel（Neon solid init + step + heat + pause + reset）+ **tests**
4. Phase changer solid crystal + gas random；再接入 liquid snapshot dump
5. Particle + Container painters（独立 widget 测）
6. Thermometer / Heater / TimeControl / Substance / Phase controls
7. StatesScreen 组装
8. PhaseChangesModel + pump/lid/gauge/diagrams
9. DualAtomModel + Interaction screen
10. Visual QA harness

---

## 8. Test Plan（目录）

```
test/states_of_matter/
  lj_potential_calculator_test.dart
  molecule_data_set_test.dart
  monatomic_verlet_test.dart
  thermostat_test.dart
  multiple_particle_model_test.dart
  phase_state_changer_test.dart
  phase_changes_model_test.dart
  dual_atom_model_test.dart
  coordinate_transform_test.dart
  reset_lifecycle_test.dart
```

每组件最低：initial · binding · edge · reset。

---

## 9. Asset Copy Plan

```
assets/states_of_matter/
  mipmaps/pointingHand.png
  mipmaps/solidIcon.png
  mipmaps/liquidIcon.png
  mipmaps/gasIcon.png
  images/pushPin.png
```

`pubspec.yaml` 登记；`ASSET_MAP.md` 在实现期补全。

---

## 10. Reuse vs Create Summary

| REUSE | EXTEND | CREATE |
|---|---|---|
| SimulationClock, Tabs, L0 controls | Thermometer/Gauge painters, Heater UI, shaded sphere | Full Verlet/LJ/MPM/Phase/DualAtom + SoM views |
| Visual QA scripts pattern | capture_main per sim | SoM-specific capture + browser QA docs |

**明确不复用**：`gas_properties` IdealGasLaw / hard-sphere collision 作为主物理。
