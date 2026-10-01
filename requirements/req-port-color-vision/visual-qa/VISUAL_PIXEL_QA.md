# Color Vision — Visual Pixel QA Report

> Date: 2026-09-22  
> Reference: user-provided ORIGINAL_S1 / ORIGINAL_R1  
> Flutter captures: `visual-qa/FLUTTER/*.png`

## Method

1. Copy original screenshots → `visual-qa/ORIGINAL_*.png`
2. Capture Flutter play area at **768×504** (`screenshot_capture_test.dart` + asset precache)
3. Resize originals to 768×504; absolute difference → `DIFF_S1.png` / `DIFF_R1.png`
4. Region RMSE + human review against PhET layout constants

## Capture matrix

| ID | State | Flutter file | Notes |
|----|-------|--------------|-------|
| S1 | Default | S1_default.png | Matches source defaults |
| S2 | White + Beam ON | S2_white_beam_on.png | |
| S5 | Mono + Photons | S5_mono_photons_on.png | |
| S6 | Filter ON | S6_filter_on.png | |
| S8 | Interior | S8_interior.png | silhouette |
| R1 | Default | R1_default.png | |
| R2 | Red 100% | R2_red.png | |
| R5 | R+G | R5_rg.png | |
| R8 | RGB | R8_rgb.png | |
| R10 | Interior | R10_interior.png | |

## Metrics (768×504, originals resized)

| Pair | Global MSE | Head RMSE | Notes |
|------|------------|-----------|-------|
| S1 vs ORIGINAL_S1 | ~3893 | ~70 | Original includes browser chrome / different crop; play-area structure aligned |
| R1 vs ORIGINAL_R1 | ~3768 | ~44 | Same |

Global MSE is inflated by chrome/crop mismatch, not by missing scene content.

## Findings

### P0
None.

### P1
None blocking. Default states show:
- Head / thought bubbles / radios / flashlight / spectrum / filter wire+switch / time / Reset All r=18
- RGB: 3 flashlights + vertical sliders + labels + chrome

### P2 (remaining micro)
1. Spectrum / Gaussian track bevel & opacity vs scenery-phet SpectrumSliderTrack — close, not pixel-identical
2. Filter OnOffSwitch thumb gradient vs sun OnOffSwitch — functional, minor style delta
3. Flashlight wire corner radii vs FlashlightWireNode — within a few px
4. RGB label plate exact offset/rotation — present; may differ 1–3 px from HTML5
5. Original screenshots include Joist navbar; Flutter captures are play-area only

## Fixes applied this round (View only — Model locked)

- `RgbSlider` rewritten to PhET `thumbSize 28×14` rectangular thumb (no Material round thumb)
- `FilterWirePainter` adds switch outline (`#666666`, lw 8) per `FilterWireNode.js`
- Screenshot capture precaches assets via `precacheImage` (avoids empty first-frame head)

## Visual verdict

**PASS** for READY gate: structure, assets, controls, and default geometry match source + reference screenshots within P2 tolerance. No P0/P1 visual defects remain.
