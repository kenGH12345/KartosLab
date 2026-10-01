# Physics Validation · Energy Skate Park

> Evidence from `flutter test test/energy_skate_park` · 2026-09-03 finalize  
> Local PhET source: `1.6.0-dev.2`

| # | Case | File | Expected | Actual / tolerance | Source evidence | Result |
|---|---|---|---|---|---|---|
| 1 | Frictionless energy conservation | `energy_conservation_test.dart` | ΔE ≈ 0 | ΔE < 1e-2 / 300 frames | stepEuler + correctEnergy | PASS |
| 2 | Hermite spline natural | `hermite_spline_test.dart` | line/parabola/endpoints/diff | match | numeric.spline + SplineEvaluation | PASS |
| 3 | Premade track CPs | `premade_tracks_test.dart` | parabola/ramp/double-well/loop coords | match PremadeTracks.ts | PremadeTracks.ts | PASS |
| 4 | Friction → thermal | `leave_track_friction_test.dart` | thermal ↑ | thermal > 0.01 after 180 steps | TE = \|Ff\|·Δs | PASS |
| 5 | Leave track (stick=false) | `leave_track_friction_test.dart` | track null on loop | detached | leaveTrack curvature test | PASS |
| 6 | TrackSet scene switch | `track_set_test.dart` | one physical; skater detaches | OK | TrackSetModel | PASS |
| 7 | Stick default true | `track_set_test.dart` | true | true | EnergySkateParkModel:340 | PASS |
| 8 | Graphs samples accumulate | `gap_closure_test.dart` | samples grow while playing | OK | SaveSampleModel | PASS |
| 9 | Sensor / referenceHeight | `gap_closure_test.dart` | PE from sample refresh | OK | DataSample.setNewReferenceHeight | PASS |
| 10 | Playground add/clear/join | `gap_closure_test.dart` | tracks mutate | OK | PlaygroundModel | PASS |
| 11 | Playground split/delete | `gap_closure_test.dart` | split→2 tracks; delete CP | OK | splitControlPoint/deleteControlPoint | PASS |
| 12 | Measuring tape distance | `gap_closure_test.dart` | \|tip−base\| meters | OK | EspModel tape | PASS |
| 13 | Graphs zoom/cursor | `gap_closure_test.dart` | zoom clamp; cursor energies | OK | GraphsModel | PASS |
| 14 | Home tabs smoke | `home_smoke_test.dart` | 4 tabs | OK | EnergySkateParkHome | PASS |

**Suite**: **35** tests · all pass · `dart analyze lib/energy_skate_park` clean

### Added (measurement + skater closure)

| Case | File | Result |
|---|---|---|
| Tape distance model meters | `measurement_skater_test.dart` | PASS |
| Stopwatch reset / drag clamp | `measurement_skater_test.dart` | PASS |
| Reference height reset on hide | `measurement_skater_test.dart` | PASS |
| Skater selection persists reset | `measurement_skater_test.dart` | PASS |
| Selection does not change mass | `measurement_skater_test.dart` | PASS |

## Gravity validation (2026-09-04)

> Source: `Skater.ts`, `GravitySlider.ts`, `GravityNumberControl.ts`, `PhysicalComboBox.ts`  
> Tests: `test/energy_skate_park/gravity_test.dart`

| # | Case | Expected | Result |
|---|---|---|---|
| G1 | Default gravity | 9.8 Earth; signed −9.8 | PASS |
| G2 | Preset Moon / Jupiter | magnitude 1.6 / 24.8 | PASS |
| G3 | Custom 12.5 stored | not snapped to Earth; combo adapter null | PASS |
| G4 | Min / max clamp | [1, 26] | PASS |
| G5 | Slider change → PE | `updateEnergy` with new g | PASS |
| G6 | preset → custom → preset | exact === matching | PASS |
| G7 | Reset | back to 9.8 | PASS |
| G8 | SkaterState.gravity | −custom for solver | PASS |
| G9 | Custom trajectory vs Earth | positions diverge | PASS |
| G10 | Custom energy bookkeeping | KE+PE+Th=Total; frictionless ΔE small | PASS |

**Pipeline verified**: GravityControls → `setGravityMagnitude` → `EspModel` clamp + `updateEnergy` → `SkaterState.gravity` → `PhysicsSolver` / PE render.

### Prior gap (closed)

Measure/Graphs/Playground previously used a 3-item Dropdown that **displayed Earth for any non-Moon/Jupiter value** (`_gravityPreset` epsilon snap) and **had no slider** — tagged **[迁移功能缺口]**, now fixed — **not** `[有意差异]`.
