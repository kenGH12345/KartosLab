# PHASE 5 — FINAL ASSET AUDIT · Faraday's Law

## Runtime assets (`assets/simulations/faradays_law/`)

| File | Intrinsic | Origin | Status |
| --- | --- | --- | --- |
| `four_loop_front.png` | 420×468 | PhET `fourLoopFront.png` | `[原版资源一致]` |
| `four_loop_back.png` | 420×468 | PhET `fourLoopBack.png` | `[原版资源一致]` |
| `two_loop_front.png` | 318×468 | PhET `twoLoopFront.png` | `[原版资源一致]` |
| `two_loop_back.png` | 318×468 | PhET `twoLoopBack.png` | `[原版资源一致]` |
| `light_bulb_base.png` | 89×71 | scenery-phet `lightBulbBase.png` | `[原版资源一致]` |

`pubspec.yaml` includes `assets/simulations/faradays_law/`.

## Source-drawn (not substitution)

| Object | Implementation |
| --- | --- |
| Bar magnet | `MagnetPainter` |
| Field lines | `FieldLinesPainter` |
| Drag arrows | `MagnetArrowsPainter` |
| Coil / voltmeter wires | `CoilsWiresPainter` / voltmeter wire painter |
| Voltmeter body + gauge | `VoltmeterPainter` |
| Bulb glass / filament / halo | `_BulbPainter` |
| Flip button chrome | `FlipMagnetButton` |
| Checkboxes | `FlPhetCheckbox` |
| Reset All | `KratosResetAllButton` (L0) |

## Forbidden substitutions check

| Item | Present? |
| --- | --- |
| Material Icons in Faraday screen | **No** (visual smoke) |
| Emoji / network / AI art | **No** |
| Screenshot crop as interactive asset | **No** |
| Generic third-party coil/magnet/bulb | **No** |

## Scale / transform

| Asset | Scale | Crop | Notes |
| --- | --- | --- | --- |
| Coil mipmaps | 1/3 | none | + xOffset 8 (+8 for two-loop) |
| Bulb base | height ≈ `bulbBaseWidth` 36 | none | P2-05 align |
| Magnet | 140×30 layout | n/a | painted |

## Gate

```
Substituted assets = 0
```

Full inventory: `ASSET_MAP.md` (Phase 0; still valid).
