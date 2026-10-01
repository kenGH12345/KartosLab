# PHASE 6 — HOME SOURCE MAP

## Existing Home Pattern → Wave on a String

| Existing Home Pattern | Wave on a String |
| --------------------- | ---------------- |
| Home root | `lib/screens/home_screen.dart` · `HomeScreen` |
| Category | **物理 → 光学与波动** (existing group; peer Sound / Waves Intro / 波的干涉 / 电磁波) |
| Card | `_SimEntry` title/subtitle/icon/color/builder |
| Entry | `Navigator.push(MaterialPageRoute(builder: _buildWaveOnAString))` |
| Route | Direct push — **no** intermediate Hub |
| Back | AppBar `BackButton` → pop → dispose Screen |
| Model owner | `WoasScreenState` creates `WoasModel()` when injected null; disposes if owned |
| Clock owner | `WoasPlayAreaState` · one `SimulationClock` → `model.step(dt)` |
| Dispose | Screen dispose → model.dispose; PlayArea dispose → clock.dispose + removeListener |
| Re-entry | New route → new `WoasScreen` → new `WoasModel` · **fresh source initial** |

## Ownership (single)

```text
Model owner   = WoasScreenState (_ownsModel)
Clock owner   = WoasPlayAreaState
Dispose owner = Screen (model) + PlayArea (clock/listeners)
Entry owner   = HomeScreen._SimCard → MaterialPageRoute → WoasScreen()
```

## Pattern peer

Single-screen Faraday's Law:

```text
Home → FaradaysLawScreen() → owns FaradaysLawModel → PlayArea owns clock
```

WOAS mirrors this exactly (Screens = 1). No WaveOnAStringHome wrapper.

## Re-entry policy

```text
Re-entry policy = Back → dispose · Re-entry → fresh Model
```

Matches Faraday / KartosLab MaterialPageRoute sims (no shared singleton).
