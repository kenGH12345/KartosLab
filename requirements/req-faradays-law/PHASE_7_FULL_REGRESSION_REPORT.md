# PHASE 7 — FULL REGRESSION REPORT · Faraday's Law

## Faraday suite

```bash
flutter test test/faradays_law/
```

```
136 PASS
Faraday failures = 0
```

Unchanged vs Phase 6 baseline (136).

## Analyze

```bash
dart analyze lib/faradays_law test/faradays_law lib/screens/home_screen.dart
```

```
No issues found!
```

## Full project

```bash
flutter test
```

| Metric | Phase 6 | Phase 7 |
| --- | --- | --- |
| Passed | 2805 | **2805** |
| Skipped | 1 | **1** |
| Failed | 56 | **56** |
| Faraday failures | 0 | **0** |
| New Faraday-related failures | — | **0** |
| New failures caused by Faraday | — | **0** |

```
Result = PASS WITH KNOWN UNRELATED FAILURES
Regression comparison vs Phase 6 = IDENTICAL counts
```

## Known unrelated failures (KNOWN UNRELATED)

Do **not** modify these sims for Faraday acceptance:

- States of Matter visual QA capture timeouts
- Pendulum Lab visual QA capture timeouts
- Projectile Motion visual QA capture timeouts
- Forces `netforce-tug` hang / 10 min timeout
- (and remaining capture/golden failures in the −56 set)

## Git

```
Git = unavailable
```

No forced `git init`. Phase 7 performed **CODE CHANGES = 0** on simulation/Home code.
