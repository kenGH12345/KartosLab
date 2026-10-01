# HOME_INTEGRATION_REPORT — Molecules and Light

**Date:** 2026-03-21  
**Status contribution:** Home entry + lifecycle complete

## Catalog placement

| Field | Value |
|-------|-------|
| Discipline | **化学** (existing first-level) |
| Subject group | **光与分子** |
| Title | Molecules and Light |
| Subtitle | 光子吸收 · 分子振动 · 光谱 |
| Icon | `Icons.flare_rounded` (Home card chrome only) |
| Accent | `#4070CE` |
| Route | `HomeScreen` → `Navigator.push` → `MoleculesAndLightScreen` |

No new Navigator / category system. Neighbor cards (Molecule Polarity, States of Matter) unchanged.

## Entry

- Builder: `_buildMoleculesAndLight` → `const MoleculesAndLightScreen()`
- No demo hub / QA shell / temporary wrapper
- Thin production `AppBar` (title + system Back when `canPop`) for KartosLab navigation parity with single-screen sims such as Radio Waves
- Simulation body / Model / Spectrum unchanged from Phase 3 (dialog only made height-adaptive for AppBar viewport)

## Lifecycle

| Scenario | Result |
|----------|--------|
| A Initial → Back → Re-enter | PASS — fresh IR / OFF / CO |
| B Playing → Back → Re-enter | PASS — route gone; new model; defaults |
| C Spectrum open → Back | PASS — overlay destroyed; reopen closed |
| Reset vs Re-entry | PASS — distinct mechanisms |
| Open/close ×2 | PASS — no route leak |

On `dispose`:

- `SimulationClock.pause()`
- `onTick = null`
- `SimulationClock.dispose()` (Ticker released)

## Tests added

`test/molecules_and_light/home_lifecycle_test.dart` — 6 widget tests covering card, A/B/C, reset vs re-entry, double open/close.

## Forbidden checks

- Greenhouse Effect screens/models: **not introduced**
- Phase 1 physics: **unchanged**
- Other simulations: **untouched** (except Home catalog entry)
