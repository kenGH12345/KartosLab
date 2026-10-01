# PHASE 1 — MODEL REPORT · Ohm's Law

**日期**：2026-09-27  
**Source**：1.5.0-dev.6  
**状态**：Phase 1 = **PASS** · Overall = NOT READY  
**View / Home**：NOT TOUCHED

---

## Summary

将 PhET `OhmsLawModel` 忠实迁移到 Flutter Model 层，并用 oracle 锁定公式、范围、默认值、单位状态、VD-03、`reset` 不恢复 Units、边界与生命周期。

```text
voltageProperty (V) ──┐
                      ├──► currentProperty (mA) = 1000·V/R
resistanceProperty (Ω)┘

currentUnitsProperty (display only; NOT reset)
        └──► getFixedCurrent()  // VD-03: AMPS → /100
```

---

## Files

### Lib

| Path | Role |
|------|------|
| `lib/ohms_law/model/ohms_law_constants.dart` | Ranges, sig figs, 1000× factor |
| `lib/ohms_law/model/current_units.dart` | `CurrentUnit` enum |
| `lib/ohms_law/model/ohms_law_property.dart` | Number / Derived / Enum Property + toFixed |
| `lib/ohms_law/model/ohms_law_model.dart` | Root model |

### Tests

| Path | Count |
|------|-------|
| `test/ohms_law/model/ohms_law_model_test.dart` | **27** |

### Docs

| Path |
|------|
| `requirements/req-ohms-law/MODEL_CONTRACT.md` |
| `requirements/req-ohms-law/PHASE_1_MODEL_REPORT.md` |

---

## Tests

```text
flutter test test/ohms_law
→ All tests passed! (27)
```

Peer smoke (unchanged modules):

```text
flutter test test/faradays_law/model/faradays_law_model_test.dart
           test/hookes_law/model/hookes_law_model_test.dart
→ (see regression section)
```

## Analyze

```text
dart analyze lib/ohms_law test/ohms_law
→ No issues found!
```

---

## VD-03

| Item | Decision |
|------|----------|
| Source AMPS path | `current / 100` then `toFixed(_, 3)` |
| Flutter | Identical |
| Corrected to /1000? | **No** |
| Oracle | `ohms_law_vd03_source_behavior_test` expects `"0.090"` not `"0.009"` |

---

## Gate

| Item | Status |
|------|--------|
| Model | PASS |
| Voltage / Resistance / Current | PASS |
| Formula `1000*V/R` | PASS |
| Derived reactivity | PASS |
| Units ≠ physics | PASS |
| Reset | PASS |
| Reset preserves units | PASS |
| VD-03 | PASS |
| Boundary / finite | PASS |
| Lifecycle | PASS |
| Oracle | 27/27 |
| Analyze | CLEAN |
| P0 / P1 | 0 / 0 |
| View / Home | NOT TOUCHED |

**PHASE 1 STATUS: PASS** · Model = **FROZEN**
