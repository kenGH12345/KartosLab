# ASSET_MAP — pH Scale

**req-id:** `req-port-ph-scale`  
**Substituted Assets:** **0**

Truth: local PhET `ph-scale` + scenery-phet faucet / eyeDropper PNGs copied into Flutter assets.

| Original Path | Used By | Flutter Path | Scale | Rotation | Crop | Opacity | Transform |
|---|---|---|---|---|---|---|---|
| scenery-phet `eyeDropperBackground.png` | DropperNode | `assets/simulations/ph_scale/images/eyeDropperBackground.png` | 0.85 | 0 | none | 1 | position from model |
| scenery-phet `eyeDropperForeground.png` | DropperNode | `assets/simulations/ph_scale/images/eyeDropperForeground.png` | 0.85 | 0 | none | 1 | overlay |
| scenery-phet `faucetBody.png` | PhScaleFaucetNode | `assets/simulations/ph_scale/images/faucetBody.png` | 0.6 + flip | 0 / mirror X | none | 1 | FaucetNode layout |
| scenery-phet `faucetFlange.png` | PhScaleFaucetNode shooter | `…/faucetFlange.png` | 0.6 + flip | 0 / mirror X | none | 1 | shaft→flange |
| scenery-phet `faucetFlangeDisabled.png` | PhScaleFaucetNode | `…/faucetFlangeDisabled.png` | 0.6 + flip | 0 / mirror X | none | 1 | disabled |
| scenery-phet `faucetHorizontalPipe.png` | PhScaleFaucetNode | `…/faucetHorizontalPipe.png` | 0.6 stretch | 0 / mirror X | none | 1 | tiled/stretched to pipeMinX |
| scenery-phet `faucetKnob.png` | PhScaleFaucetNode shooter | `…/faucetKnob.png` | 0.6×0.6 | 0 / mirror X | none | 1 | knobScale 0.6 |
| scenery-phet `faucetKnobDisabled.png` | PhScaleFaucetNode | `…/faucetKnobDisabled.png` | 0.6×0.6 | 0 / mirror X | none | 1 | disabled |
| scenery-phet `faucetShaft.png` | PhScaleFaucetNode shooter | `…/faucetShaft.png` | 0.6 + flip | 0 / mirror X | none | 1 | shooter shaft |
| scenery-phet `faucetSpout.png` | PhScaleFaucetNode | `…/faucetSpout.png` | 0.6 + flip | 0 / mirror X | none | 1 | origin bottom-center |
| scenery-phet `faucetStop.png` | PhScaleFaucetNode shooter | `…/faucetStop.png` | 0.6 + flip | 0 / mirror X | none | 1 | on shaft |
| scenery-phet `faucetTrack.png` | PhScaleFaucetNode | `…/faucetTrack.png` | 0.6 + flip | 0 / mirror X | none | 1 | shooter track |
| scenery-phet `faucetVerticalPipe.png` | PhScaleFaucetNode | `…/faucetVerticalPipe.png` | 0.6 stretch Y | 0 | none | 1 | Water len=20 / Drain len=5 |
| ph-scale `macroNavbarIcon.png` | PhScaleScreen Tab | `assets/simulations/ph_scale/icons/macroNavbarIcon.png` | h=28 | 0 | none | 1 | Tab icon |
| ph-scale `microNavbarIcon.png` | PhScaleScreen Tab | `…/microNavbarIcon.png` | h=28 | 0 | none | 1 | Tab icon |
| ph-scale `mySolutionNavbarIcon.png` | PhScaleScreen Tab | `…/mySolutionNavbarIcon.png` | h=28 | 0 | none | 1 | Tab icon |
| ph-scale `macroHomeScreenIcon.png` | (available) | `…/macroHomeScreenIcon.png` | — | — | — | — | Home uses catalog Material icon (project convention) |
| ph-scale `microHomeScreenIcon.png` | (available) | `…/microHomeScreenIcon.png` | — | — | — | — | reserved |
| ph-scale `mySolutionHomeScreenIcon.png` | (available) | `…/mySolutionHomeScreenIcon.png` | — | — | — | — | reserved |

## Procedural (source-equivalent, not substituted)

| Element | Source | Flutter |
|---|---|---|
| Ratio particles | Canvas circles r=3 | `RatioParticlesPainter` |
| Molecule icons | ShadedSphere | `MoleculeIcon` |
| Beaker / solution / scale | Path/Node painters | `BeakerPainter` / `SolutionPainter` / `PhScaleBarPainter` |
| Graph indicators | GraphIndicatorNode | `GraphIndicator` |
| Reset All | scenery-phet ResetAllButton | L0 `KratosResetAllButton` |

```text
Original Assets: 19 PNG (images + icons)
Substituted: 0
```

## Changelog

- **2026-09-22 post–Phase 9 UX:** `PhScaleFaucetNode` uses full scenery-phet layout (all faucet PNGs above) + `tapToDispense` 0.05 L / 333 ms; Graph callout formula/molecule size bumped for readability — still no substituted assets.
