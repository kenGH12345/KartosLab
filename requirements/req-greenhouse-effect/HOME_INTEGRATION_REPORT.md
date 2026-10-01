# HOME_INTEGRATION_REPORT · Greenhouse Effect

> Date: 2026-09-21

## Architecture followed

Existing KartosLab Home (`lib/screens/home_screen.dart`):

```text
_SimEntry card
  → Navigator.push(MaterialPageRoute)
  → *Home widget
  → simulation
Back = AppBar BackButton → Navigator.pop → State.dispose
```

No new subject, category tree, or router.

## Placement

| Field | Value |
|---|---|
| Discipline | 物理 / Physics |
| Group | 热学与气体 |
| Title | Greenhouse Effect |
| Subtitle | 温室气体 · 能量平衡 · 地表温度 |
| Icon | `Icons.wb_sunny_rounded` (Home card only; sim assets unchanged) |
| Route | `GreenhouseEffectHome` → `GreenhouseEffectScreen` |

## Entry

`lib/greenhouse_effect/screens/greenhouse_effect_home.dart`

- Scaffold + AppBar title + automatic back
- Body is the existing `GreenhouseEffectScreen`
- No debug AppBar, demo hub, or QA wrapper
- Model / physics not rewritten

## Lifecycle

| Scenario | Result |
|---|---|
| Home → GE | Fresh screen, sunlight off, Waves tab |
| Switch Waves / Photons / Layer Model | Source-specific controls; new model per tab switch (existing behavior) |
| Play → Back | Screen disposed; clock disposed with State |
| Pause → Back | Disposed; no leftover screen |
| Re-enter | `Start Sunlight` again (not previous `Sunlight On`) |
| Open/close twice | No crash; pop count = 2 |

## Tests

`test/greenhouse_effect/home/home_lifecycle_test.dart` — PASS (included in greenhouse suite **42 PASS**)

Named Home regressions also PASS:

- Bending Light home integration
- Capacitor Lab Basics home lifecycle
- States of Matter home nav
- Energy Skate Park home smoke
- Vector Addition geometry lifecycle (includes Home card)
- Gravity and Orbits (`test/gravity_and_orbits` 16 PASS)

## Full suite

```text
flutter test
→ +2467 ~1 -56
```

Observed failures are visual-QA capture timeouts in other sims (States of Matter visual capture, Projectile Motion visual capture, Forces scenario timeout). They are not Greenhouse Effect tests. Greenhouse Effect itself is green.

## Physics

No Phase 1 model or energy equations were changed for Home.
