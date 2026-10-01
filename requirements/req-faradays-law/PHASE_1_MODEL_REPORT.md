# PHASE 1 — MODEL REPORT · Faraday's Law

**日期**：2026-09-22  
**状态**：Phase 1 = COMPLETE · Overall = NOT READY  
**Home**：NOT STARTED · **Android**：NOT VERIFIED

---

## Summary

实现了 Faraday's Law 的 native Dart Model 与单元测试，严格沿本地 PhET source 的标定 B / EMF / 针动力学链，未实现 View / Home。

数据链：

```text
Magnet.position + orientation
        ↓
calibrated B (near saturation / dipole power-2)
        ↓
EMF = N * ΔB / dt
        ↓
signal = 0.2 * Σemf
        ↓
voltage (needle angle dynamics)
        ↓
┌──────────────┬──────────────┐
│ Voltmeter    │ Bulb |V|     │
└──────────────┴──────────────┘
```

---

## Files changed

### Lib

| Path | Role |
|------|------|
| `lib/faradays_law/faradays_law_constants.dart` | Layout / coil / voltmeter / bulb / clock constants |
| `lib/faradays_law/model/magnet_orientation.dart` | NS / SN + B sign |
| `lib/faradays_law/model/magnet.dart` | Position, polarity, field-lines flag |
| `lib/faradays_law/model/magnetic_field.dart` | Pure `magneticFieldAtCoil` |
| `lib/faradays_law/model/coil.dart` | B + EMF step |
| `lib/faradays_law/model/field_lines.dart` | Predefined ellipse specs + geometry snapshot |
| `lib/faradays_law/model/voltmeter_model.dart` | Signal 0.2 + needle dynamics |
| `lib/faradays_law/model/bulb_model.dart` | haloScale / brightness from \|V\| |
| `lib/faradays_law/model/faradays_law_model.dart` | Root: step / reset / coil mode / drag clamp |

### Tests

| Path |
|------|
| `test/faradays_law/model/magnet_test.dart` |
| `test/faradays_law/model/magnetic_field_test.dart` |
| `test/faradays_law/model/coil_test.dart` |
| `test/faradays_law/model/field_lines_test.dart` |
| `test/faradays_law/model/induced_voltage_test.dart` |
| `test/faradays_law/model/voltmeter_model_test.dart` |
| `test/faradays_law/model/bulb_model_test.dart` |
| `test/faradays_law/model/faradays_law_model_test.dart` |

### Docs

| Path |
|------|
| `requirements/req-faradays-law/PHASE_1_MODEL_REPORT.md` |
| `requirements/req-faradays-law/PHASE_1_MODEL_SOURCE_MAP.md` |
| `requirements/req-faradays-law/PHASE_1_MODEL_REGRESSION.md` |
| `requirements/req-faradays-law/meta.yaml` |
| `requirements/req-faradays-law/process.txt` |

---

## Tests

```text
flutter test test/faradays_law/
→ All tests passed!
→ 49 tests
```

## Analyze

```text
dart analyze lib/faradays_law test/faradays_law
→ No issues found!
```

## P0 / P1 / P2

| | |
|--|--|
| P0 | n/a（无 View） |
| P1 | n/a |
| P2 | n/a |
| Substituted assets | n/a（Phase 1 无 UI） |

## Gate checklist

| Item | Status |
|------|--------|
| Model implemented | PASS |
| Magnet / polarity | PASS |
| Coil topCoilVisible | PASS |
| Field line state | PASS |
| B / EMF | PASS |
| Voltage / voltmeter | PASS |
| Bulb \|V\| | PASS |
| Reset | PASS |
| Clock step / maxDT | PASS |
| Tests all PASS | PASS |
| Analyze clean | PASS |

## Overall Status

```text
Phase 1 = COMPLETE
Overall = NOT READY
Home    = NOT STARTED
Android = NOT VERIFIED
```

**Next**：PHASE 2 — Play Area / Core View（禁止在未获指示时自动开始）
