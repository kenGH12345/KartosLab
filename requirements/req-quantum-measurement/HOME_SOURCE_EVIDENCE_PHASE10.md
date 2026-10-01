# HOME_SOURCE_EVIDENCE_PHASE10

> Audit of KartosLab Home before Quantum Measurement platform integration.
> Date: 2026-09-30

## Governance

| Item | Status |
|---|---|
| `requirements/platform-governance/**` | **Absent** in this workspace |
| `.cursor/rules` | PhET visual / Reset / engineering — no Simulation Contract file |
| Existing `SimulationRegistry` / `SimulationDescriptor` in `lib/` | **None** |

→ PHASE 10 introduces a **minimal** Registry + Descriptor under `lib/common/simulation/` without inventing course/analytics backends.

## Current Home architecture

| Aspect | Implementation | File |
|---|---|---|
| Entry list | Hard-coded `_SimEntry` inside `HomeScreen` | `lib/screens/home_screen.dart` |
| Grouping | `_Discipline` (物理/化学) → `_SubjectGroup` → `_SimEntry` | same |
| Navigation | `Navigator.push(MaterialPageRoute(builder: sim.builder))` | `_SimCard` |
| Card UI | Uniform white card, 88px height, optional `iconAsset` | `_SimCard` |
| Semantics | `Semantics(button: true, label: title)` | `_SimCard` |
| Multi-screen sims | `*Home` + `KratosTabbedScreen` (e.g. Membrane Transport) | pattern |

## Quantum-related existing entries (光学与波动)

| Title | Builder target | Notes |
|---|---|---|
| Quantum Wave Interference | `QuantumWaveInterferenceHome` | separate sim |
| 量子抛硬币 | `QuantumCoinTossHome` | QCT — **must not** be QM entry; QM Coins embeds QCT path internally |

## Category decision for Quantum Measurement

Reuse existing group:

```text
物理 → 光学与波动
```

Do **not** create a new top-level `Quantum` category.

## Navigation pattern to follow

```text
Home (_SimCard tap)
  → Navigator.push
  → QuantumMeasurementHome (Entry Wrapper / KratosTabbedScreen)
      → Coins | Photons | Spin | Bloch (internal tabs)
  → AppBar Back / system Back
  → Home (route pop → dispose)
```

## Reusable patterns

- `_SimEntry` + `_SimCard` metadata display
- `KratosTabbedScreen` + `TickerMode` only on active tab
- `iconAsset` for PhET screen icon on Home card
- Lazy `WidgetBuilder` (runtime constructed only on push)

## What must change

| Change | Scope |
|---|---|
| Add minimal `SimulationDescriptor` / `SimulationRegistry` | new `lib/common/simulation/` |
| Add `QuantumMeasurementHome` entry | new QM screen shell |
| Register `id: quantum-measurement` | module + `main.dart` |
| One new `_SimEntry` in 光学与波动 | Home only — **no** mass migration of other sims |

## Explicit non-goals (this phase)

- Full Home → Registry rewrite of all ~60 sims
- Course / score / cloud / AI agents
- Session persistence implementation
- Analytics network backend
