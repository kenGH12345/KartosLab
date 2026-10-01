# PHASE_3_BEHAVIORAL_QA — Molecules and Light

## Method

Re-validated **Phase 1 model** through view selectors and direct model regression. Physics strategies unchanged.

## 32-combination matrix

| Molecule | Microwave | Infrared | Visible | Ultraviolet |
|----------|-----------|----------|---------|-------------|
| CO | rotation | vibration | transmit | transmit |
| N₂ | transmit | transmit | transmit | transmit |
| O₂ | transmit | transmit | transmit | transmit |
| CO₂ | transmit | vibration | transmit | transmit |
| CH₄ | transmit | vibration | transmit | transmit |
| H₂O | rotation | vibration | transmit | transmit |
| NO₂ | rotation | vibration | excitation | break-apart |
| O₃ | rotation | vibration | transmit | break-apart |

Each cell verified: photon offered at absorption distance → expected strategy flags → photon lifecycle (held / transmitted / broken).

## Photon state regression

Absorbed IR photon identity survives switch to Visible/Ultraviolet; re-emitted wavelength remains infrared. Flying photons cleared on light change.

## State switch matrix

| Sequence | Result |
|----------|--------|
| playing → switch light | flying cleared; light updated |
| playing → switch molecule | fresh molecule; interaction flags reset |
| photon absorbed → switch light | absorbed wavelength retained |
| molecule vibrating → switch molecule | new molecule not vibrating |
| pause → step ×3 | discrete advance; `step()` while paused no-op |
| emission → reset | IR / OFF / CO / running / normal |

## Controls

| Control | Source | Result |
|---------|--------|--------|
| Normal / Slow | `SLOW_SPEED_FACTOR = 0.5` | PASS |
| Pause / Play | `running` gate on `step` | PASS |
| Step Forward | `manualStep(1/60)` | PASS |
| Light Spectrum Diagram | dialog; no model reset | PASS |
| Reset All | `KratosResetAllButton` r=18 | PASS |

## Lifecycle

`create → play → pause → reset → dispose` — `SimulationClock` disposed; no orphan tickers asserted via dispose pump test.

## Test command

```text
flutter test test/molecules_and_light/
→ 52 PASS
```
