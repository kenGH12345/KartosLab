# PHASE 2 — Component Map · Gravity and Orbits

> Flutter 落点：`lib/astronomy/gravity_and_orbits/`  
> Model **不依赖** Flutter；Painter **不跑** Physics。

---

## Model Components

| Component | Dart | 源 |
|---|---|---|
| GaoVec2 | `model/gao_vec.dart` | Vector2 精简 |
| BodyType | `model/body_type.dart` | BodyTypeEnum |
| BodyConfiguration / ModeConfig | `model/mode_config.dart` | ModeConfig + SceneFactory configs |
| GaoBody | `model/gao_body.dart` | Body（含 path / rewind） |
| BodyState | `model/body_state.dart` | BodyState |
| GaoModel (screen-level) | `model/gao_model.dart` | GravityAndOrbitsModel |
| GaoScene | `model/gao_scene.dart` | GravityAndOrbitsScene |

## Physics Components

| Component | Dart | 源 |
|---|---|---|
| PEFRL ModelState | `physics/model_state.dart` | ModelState.ts |
| PhysicsEngine | `physics/physics_engine.dart` | GravityAndOrbitsPhysicsEngine |
| Clock helpers | `physics/gao_clock.dart` | DEFAULT_DT / substeps |
| Constants | `gao_constants.dart` | G, XI/Λ/Χ, masses, FORCE_SCALE |

## Body / Vector / Trail

| Component | Dart |
|---|---|
| Force / Velocity display scale | `render/vector_display.dart` |
| Path buffer sync | 内嵌 GaoBody + `painters/path_painter.dart` |
| Body painter | `painters/bodies_painter.dart` |
| Grid painter | `painters/grid_painter.dart` |
| Explosion | `painters/explosion_painter.dart` |

## Transform

| Component | Dart |
|---|---|
| MVT (inverted Y rectangle) | `render/gao_mvt.dart` |
| Stage size / scale 0.8 | `gao_constants.dart` + layout |

## Interaction

| Component | Dart |
|---|---|
| Body drag | `controller/` + scene gesture |
| Velocity vector drag | `widgets/draggable_velocity_vector.dart` |
| Measuring tape | `widgets/gao_measuring_tape.dart`（To Scale） |

## Control / UI

| Component | Dart | L0 |
|---|---|---|
| Scene selector | `widgets/scene_selection_controls.dart` | — |
| Gravity radio | `widgets/gravity_control.dart` | KratosRadioGroup |
| Checkbox panel | `widgets/checkbox_panel.dart` | — |
| Mass sliders | `widgets/mass_control_panel.dart` | KratosSlider |
| Zoom | `widgets/zoom_control.dart` | KratosSlider |
| Time control | `widgets/gao_time_control.dart` | SimulationClock + 自研三速 |
| Time counter + Clear | `widgets/time_counter.dart` | — |
| Reset All | screen | **KratosResetAllButton** |
| Home tabs | `screens/gravity_and_orbits_home.dart` | KratosTabbedScreen |
| Screen | `screens/gravity_and_orbits_screen.dart` | — |

## Assets

| Asset | Flutter path |
|---|---|
| mipmaps/*.png | `assets/astronomy/gravity_and_orbits/` |
| images/*.png | 同上 |
| ASSET_MAP.md | `requirements/req-gravity-and-orbits/ASSET_MAP.md` |

## Tests

```
test/gravity_and_orbits/
  physics_engine_test.dart
  mode_config_center_test.dart
  clock_substeps_test.dart
  body_path_test.dart
  model_reset_test.dart
```

## Assembly Order

1. constants + vec + body_state + model_state (PEFRL)  
2. body + physics_engine + clock substeps  
3. mode_config presets + scene + model  
4. MVT + painters  
5. controls + screen assembly  
6. independent tests → Visual QA → Home
