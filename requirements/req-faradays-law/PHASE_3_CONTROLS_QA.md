# PHASE 3 — CONTROLS QA · Faraday's Law

## Interaction matrix

| Action | Model | View |
|--------|-------|------|
| Voltmeter ON/OFF | `voltmeterVisible` | VoltmeterWidget show/hide |
| Field Lines ON/OFF | `fieldLinesVisible` | FieldLinesPainter |
| 1 coil | `topCoilVisible=false` | top coil layers hidden |
| 2 coil | `topCoilVisible=true` | top coil layers shown |
| Flip | NS↔SN | MagnetPainter + field arrows |
| Reset | all defaults | full initial |

## Tests

| Suite | Count |
|-------|-------|
| Model (P1) | 49 |
| View (P2) | 10 |
| Controls (P3) | 10 |
| **Total** | **69 PASS** |

```text
flutter test test/faradays_law/
→ All tests passed!
dart analyze lib/faradays_law test/faradays_law
→ No issues found!
```

## Lifecycle

Dispose play area after controls interact: covered by existing dispose test + reset test.

## Regression

Phase 1 + Phase 2 tests remain green.
