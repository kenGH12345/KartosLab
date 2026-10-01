# PHASE 1 — MODEL REPORT · Resistance in a Wire

**日期**：2026-09-27  
**Source**：1.8.0-dev.0  
**状态**：Phase 1 = **PASS** · Overall = NOT READY  
**View / Home**：NOT TOUCHED

---

## Summary

将 PhET `ResistanceInAWireModel` 忠实迁移到 Flutter Model 层，并用 oracle 锁定公式、范围、默认值、R 动态小数位、reset、边界、公式字母 scale（VD-02 无 cap）与生命周期。

```text
resistivityProperty (Ω·cm) ──┐
lengthProperty (cm)          ├──► resistanceProperty (Ω) = ρ·L/A
areaProperty (cm²)         ──┘
```

---

## Files

### Lib

| Path | Role |
|------|------|
| `lib/resistance_in_a_wire/model/resistance_in_a_wire_constants.dart` | Ranges, decimals, formula-scale numerator |
| `lib/resistance_in_a_wire/model/resistance_in_a_wire_property.dart` | Number / Derived Property + toFixed* |
| `lib/resistance_in_a_wire/model/resistance_in_a_wire_model.dart` | Root model |

### Tests

| Path | Count |
|------|-------|
| `test/resistance_in_a_wire/model/resistance_in_a_wire_model_test.dart` | **24** |

### Docs

| Path |
|------|
| `requirements/req-resistance-in-a-wire/MODEL_CONTRACT.md`（FROZEN） |
| `requirements/req-resistance-in-a-wire/PHASE_1_MODEL_REPORT.md` |

---

## Tests

```text
flutter test test/resistance_in_a_wire/model/resistance_in_a_wire_model_test.dart
→ All tests passed! (24)
```

## Analyze

```text
dart analyze lib/resistance_in_a_wire test/resistance_in_a_wire
→ No issues found!
```

---

## Contract corrections during Phase 1

| Item | Phase 0 draft | Source-correct (locked) |
|------|---------------|-------------------------|
| R = 20/15 formatted | `1.333` | **`1.33`**（1≤R<10 → 2 decimals） |

`PHASE_0_SOURCE_AUDIT.md` oracle 表已同步修正。

---

## VD-02

| Item | Decision |
|------|----------|
| Source `cappedSize: true` on R | Declared but **unused** in `addFormulaSymbol` |
| Flutter | Uncapped `scaleMagnitude = 7/default * value + 1` |
| Oracle | Max R=2000 → scale ≫ 1000 |

---

## Gate

| Item | Status |
|------|--------|
| Model | PASS |
| ρ / L / A / R | PASS |
| Formula `ρ*L/A` | PASS |
| Derived reactivity | PASS |
| Default `0.667` | PASS |
| Dynamic R decimals | PASS |
| Slider readout 2 dp | PASS |
| Reset | PASS |
| Boundary / finite | PASS |
| Formula scale / VD-02 | PASS |
| Lifecycle | PASS |
| Oracle | 24/24 |
| Analyze | CLEAN |
| P0 / P1 | 0 / 0 |
| View / Home | NOT TOUCHED |

**PHASE 1 STATUS: PASS** · Model = **FROZEN**

```text
Next: PHASE 2 — VIEW（ScreenView layout + Formula + Wire + ControlPanel + KratosResetAllButton radius 30）
Do NOT start Home until Phase 5.
```
