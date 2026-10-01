# QUANTUM_COIN_EMBEDDING_PHASE3

> PHASE 3 · 2026-09-30

## Verdict

QCT is embedded as **visual primitives** under Quantum Measurement Coins Screen.
**Forbidden:** `Navigator.push(QuantumCoinTossHome)` / QCT page scaffold as QM Coins.

```
Quantum Measurement
  └── Coins Screen (QM-owned)
        ├── ClassicalCoinsScene  → ClassicalCoinDisplay → CoinNode + QM SVG
        └── QuantumCoinsScene    → QuantumCoinDisplay  → QuantumCoinNode
```

## Audit matrix

| Dimension | Reusable? | Notes |
|---|---|---|
| visual reusable | YES | `CoinNode`, `QuantumCoinNode`, colors, scene selector chrome |
| geometry reusable | PARTIAL | QCT layout ≠ QM LayoutSpec; QM uses `CoinsComposer` |
| rendering reusable | YES | Crossfade faces, arrow painters, SVG faces |
| interaction reusable | NO | Buttons wired to QM `CoinsModel` / `CoinSet` |
| state reusable | NO | QM PHASE 1 models are source of truth |

## Allowed reuse

| Element | Path | Status |
|---|---|---|
| CoinNode | `lib/quantum_coin_toss/coins/view/coin_node.dart` | EMBEDDED |
| QuantumCoinNode | `lib/quantum_coin_toss/coins/view/quantum_coin_node.dart` | EMBEDDED |
| QuantumMeasurementColors | `lib/quantum_coin_toss/common/quantum_measurement_colors.dart` | SHARED |
| SceneSelectorRadioButtonGroup | `lib/quantum_coin_toss/common/view/scene_selector_radio_button_group.dart` | SHARED |
| Classical SVG content | QM asset path (same PhET originals) | QM ASSETS |

## Forbidden reuse

| Element | Why |
|---|---|
| QuantumCoinTossHome | Would replace QM Coins Screen |
| CoinsScreenView (QCT) | QCT page scaffold / Reset placement / no design-frame scale |
| QCT CoinsModel | QM has injectable `QmRandom` PHASE 1 models |
| QCT AppBar / navigation | Home integration later; not this phase |

## Adapter

No separate `QuantumCoinViewAdapter` class required yet:

- `ClassicalCoinDisplay` wraps `CoinNode` + `QmAssets` SVG
- `QuantumCoinDisplay` wraps `QuantumCoinNode` + owns `showSuperposition` notifier
- Superposition visual = `stateProbability` crossfade (source `QuantumCoinNode.ts`), not inventing opacity-from-bias elsewhere

## Lifecycle

- Screen owns `CoinsModel`
- IndexedStack keeps Classical + Quantum scene state alive across mode switch
- Scene switch does **not** reset inactive scene (verified in tests)
- QCT Home lifecycle is never started

## Assets

```
assets/simulations/quantum_measurement/images/classicalCoinHeads.svg
assets/simulations/quantum_measurement/images/classicalCoinTails.svg
```

`flutter_svg` logs `unhandled element <style/>` — original SVG retained; repair renderer compatibility preferred over asset substitution. **Substituted Assets = 0.**
