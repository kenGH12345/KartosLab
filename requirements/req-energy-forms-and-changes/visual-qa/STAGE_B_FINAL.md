# Stage B Final — Intro P0/P1 Convergence Report

> Updated: 2026-09-11 (P1 polish + fixtures)  
> Scope: Intro polish · Systems fixtures (Original bike-reset still BLOCKED)  
> meanΔ = auxiliary only

---

## P0 — cleared

| Item | Status |
|---|---|
| Block MVT node origin + blockFaceOffset | ✅ |
| HeaterCooler layer order + body ellipse | ✅ (flame/ice still BLOCKED D) |
| Coordinate shell / z-order | ✅ frozen |

---

## P1 — this round

### P1-1 Beaker grab layer ✅

PhET Scene Graph (`EFACIntroScreenView` + `BeakerView.ts:206-208`):
```
beakerBack (pickable=false)
→ beakerGrab (invisible Path + drag)
→ block
→ heaterFront
→ beakerFront (fluid+glass+steam, pickable=false)
```

Flutter: three `BeakerPaintLayer` passes; drag only on grab; front/back `IgnorePointer`.

Verified: grab 前 / 中 (`userControlled`) / release (`endBeakerDrag`) / reset — layer sandwich unchanged; z among beakers still `centerY`.

### P1-2 Thermometer ticks ✅

`TemperatureAndColorSensorNode` options: `tickSpacingTemperature=25`, major=10, minor=5.  
ElementFollower unchanged.

### P1-3 Speed Radio ✅

`TimeSpeedRadioGroup` ≈ `TimeSpeedRadioButtonGroup`: vertical Aqua radios, spacing 9, Normal→FF order, font 14.  
FF×4 multiplier untouched.

---

## Fixtures (`test/.../efac_runtime_fixtures.dart`)

| ID | elapsed | notes |
|---|---|---|
| intro_initial | 0 | pure reset, paused |
| intro_heater_active | **8.0 s** | linked + dual heat + cups + 2 thermometers; `manualStep` |
| intro_thermometer_attached | 0 | tip in water + follow |
| intro_linked_heaters | 0 | checkbox only |
| intro_after_reset | — | heater_active → Reset All |
| systems_bike_reset | 0 | bike→gen→beaker **Original BLOCKED** |
| systems_bike_active | **1.5 s** | documented user/EC/speed |
| systems_selector_faucet | 0 | source=faucet |
| systems_after_reset | — | bike_active → Reset |

heater_active meanΔ vs legacy alt1 is **auxiliary** — do not tune Model/geometry to lower it.

---

## Evidence (matched overlays only)

| Pair | meanΔ | hot>30% |
|---|---|---|
| intro_initial | 27.4 | 29.2% |
| intro_heater_active | 38.5 | 32.1% (state may ≠ Original alt1) |
| systems_bike_active | 45.1 | 40.5% |
| systems_initial | — | **BLOCKED** (no forge) |

---

## Tests / Analyze / Build

- `flutter test test/energy_forms_and_changes` → **65 PASS**
- `flutter analyze lib/energy_forms_and_changes` → **0 error**
- `flutter build apk --debug` → see COMPLETION_REPORT

## Blocked (not visual-complete)

- `[BLOCKED D]` flame / ice / Faucet pixel fidelity
- `[BLOCKED]` systems bike-reset Original runtime
