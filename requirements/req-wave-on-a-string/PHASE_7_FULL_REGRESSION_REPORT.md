# PHASE 7 — FULL REGRESSION REPORT

## Wave suite

```bash
flutter test test/wave_on_a_string/
```

```text
+174 All tests passed!
Wave failures = 0
```

## Analyze

```bash
dart analyze lib/wave_on_a_string lib/screens/home_screen.dart test/wave_on_a_string
```

```text
No issues found!
```

## Full project

```bash
flutter test
```

| Metric | Value |
| ------ | ----: |
| Passed | 2980 |
| Skipped | 1 |
| Failed | 56 |
| Wave failures | **0** |
| New Wave/Home-caused failures | **0** |

### Delta vs Phase 6 note (~+2805 / −56)

| | Phase 6 (reported) | Phase 7 |
| - | -----------------: | ------: |
| Passed | ~2805 | 2980 |
| Failed | 56 | 56 |
| Skipped | 1 | 1 |

Passed ↑ ≈ Wave suite size (+174). Failed count **unchanged** → no new global regression from Wave/Home.

### Failed suites = KNOWN UNRELATED

| Suite | Count (approx) | Classification |
| ----- | -------------: | -------------- |
| `projectile_motion/...capture_test.dart` | ~20 | KNOWN UNRELATED · visual capture / timeout |
| `pendulum_lab/...capture_test.dart` | ~18 | KNOWN UNRELATED · visual capture / timeout |
| `states_of_matter/...capture_test.dart` | ~14 | KNOWN UNRELATED · visual capture / timeout |
| `gas_properties/...screenshot_capture_test.dart` | ~2 | KNOWN UNRELATED · golden/capture |
| `forces/forces_scenario_test.dart` | 1 | KNOWN UNRELATED · timeout/hang |

**No** `test/wave_on_a_string/**` entries in failing list.

Peer smoke (isolated): `test/faradays_law/home/` + `test/wave_on_a_string/home/` → PASS.
