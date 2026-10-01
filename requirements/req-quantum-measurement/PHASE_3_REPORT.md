# PHASE 3 STATUS

Scope:
Coins Visual Component + Composer

Classical Scene:
PASS

Quantum Scene:
PASS

Scene Switching:
PASS

QCT Embedded Component:
PASS

Original Assets:
PASS

10 Coins:
PASS

100 Coins:
PASS

10000 Coins:
PASS

10k Canvas Performance:
PASS

Controls:
PASS

Typography:
PASS (titles 20 bold underline; buttons 14; selector from QCT chrome)

Global Scaling:
PASS

Composer:
PASS

Component Tests:
11 PASS (`test/quantum_measurement/coins_phase3_test.dart`)

Composer Tests:
4 PASS (included in phase3 suite; prior layout_geometry 16 still PASS)

Analyze:
`dart analyze lib/quantum_measurement/coins` — clean after path fixes

P0:
none

P1:
- Prep/measure Y bands for coin areas still approximate within LayoutSpec-derived centers (PHASE 2 empirical bands); refine only with source Node bounds if golden diffs appear
- `flutter_svg` unhandled `<style/>` on classical SVG (original retained)

P2:
- Coin count radio is custom dots (not full scenery RadioButtonGroup chrome)
- Multi-coin 10/100 grid spacing is deterministic sqrt-grid; confirm against MultiCoinTestBox packing if golden requires micro-adjust
- Probability glyphs via unicode escapes (sun/moon/arrows)

Photons:
NOT STARTED

Spin:
NOT STARTED

Bloch:
NOT STARTED

Golden:
PREPARED (Classical / Quantum / 10 / 100 / 10000 states mountable)

Android:
NOT VERIFIED

Home:
NOT STARTED

Status:
READY CANDIDATE

---

## A. Component Inventory

| Component | Source Evidence | Reused | New | Status |
| --- | --- | --- | --- | --- |
| QuantumMeasurementCoinsScreen | CoinsScreenView.ts | SceneSelector + ResetAll L0 | Screen shell + design frame | PASS |
| ClassicalCoinsScene | CoinsExperimentSceneView.ts | primitives | Scene | PASS |
| QuantumCoinsScene | CoinsExperimentSceneView.ts | QuantumCoinNode | Scene | PASS |
| ClassicalCoinDisplay | ClassicalCoinNode.ts | CoinNode | QM SVG path | PASS |
| QuantumCoinDisplay | QuantumCoinNode.ts | QuantumCoinNode | showSuperposition owner | PASS |
| CoinControls | CoinExperimentButtonSet | colors | QM labels/state | PASS |
| CoinCountSelector | IdenticalCoins radio group | — | custom radio | PASS |
| CoinResultDisplay | ProbabilityOfSymbolBox labels | — | glyphs | PASS |
| MultiCoinDisplay | MultiCoinTestBox | — | grid + canvas switch | PASS |
| Coins10kPainter | CoinSetPixelRepresentation.ts | colors map | CustomPainter 100x100 | PASS |
| CoinsComposer | CoinsLayoutSpec PHASE 2 | LayoutSpec | geometry apply | PASS |
| KratosResetAllButton | scenery-phet ResetAll | L0 | — | PASS |

## B. Composer Geometry

| Module | LayoutSpec Rule | Composer Rule | Status |
| --- | --- | --- | --- |
| Design frame | 1024x618 uniform scale | `designFrame(viewport)` | PASS |
| Scene origin | (0, 75) | `sceneOrigin` | PASS |
| Divider prep | floor(1024*0.38)=389 | `dividerXDuringPreparation` | PASS |
| Divider measure | ceil(1024*0.2)=205 | `dividerXDuringMeasurement` | PASS |
| Prep center X | d/2 | `preparationCenterX` | PASS |
| Measure center X | d+(1024-d)/2 | `measurementCenterX` | PASS |
| Start measurement | cy=245 on divider | `startMeasurementCenter` | PASS |
| Single box | 165x145 | `singleTestBox` | PASS |
| Multi box | 200x200 | `multiTestBox` | PASS |
| 10k grid | side=100 | `pixelGridSideLength` | PASS |
| Reset All | margin 10 BR | `KratosResetAllButton` | PASS |

## C. Coin Rendering

| Count | Rendering Strategy | Widget Count | Source Fidelity |
| --- | --- | ---: | --- |
| 10 | individual grid (5 cols) | O(10) | PASS |
| 100 | individual grid (10 cols) | O(100) | PASS |
| 10000 | 100x100 CustomPainter | O(1) | PASS |

## D. QCT Integration

| QCT Element | Reuse | Adapter Needed | Forbidden | Status |
| --- | --- | --- | --- | --- |
| CoinNode | YES | ClassicalCoinDisplay | — | PASS |
| QuantumCoinNode | YES | QuantumCoinDisplay | — | PASS |
| Colors / SceneSelector | YES | none | — | PASS |
| QuantumCoinTossHome | NO | — | YES | PASS (not used) |
| QCT CoinsScreenView | NO | — | YES | PASS (not used) |
| QCT CoinsModel | NO | — | YES | PASS (QM model) |

## Architecture delivered

```
lib/quantum_measurement/coins/
  view/coins_screen.dart
  view/classical_coins_scene.dart
  view/quantum_coins_scene.dart
  composer/coins_composer.dart
  components/...
  rendering/coin_render_mode.dart
  rendering/coins_10k_painter.dart
  model/ (PHASE 1 unchanged semantics)
```

Entry: `QuantumMeasurementCoinsScreen` (alias `CoinsScreen`).

Product remains **NOT READY** (Photons / Spin / Bloch / Home / Android / Golden gates open).
