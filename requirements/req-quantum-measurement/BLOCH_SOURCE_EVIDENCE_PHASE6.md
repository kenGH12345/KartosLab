# BLOCH_SOURCE_EVIDENCE_PHASE6

> Phase 6 source archaeology — Bloch Sphere Screen only.
> Primary tree: `phet sourses/quantum-measurement-main/js/bloch-sphere/` + `js/common/view/BlochSphereNode.ts`

## Feature → Source map

| Feature | Source File | Class / Constant | Geometry / Behavior Evidence | Flutter Mapping |
|---|---|---|---|---|
| Sphere | `common/view/BlochSphereNode.ts` | `sphereRadius = 100`; `ShadedSphereNode(2*R)` | Diameter 200; main `#0FF`, highlight `#FFF` | `BlochSpherePainter` radial sphere |
| X axis | BlochSphereNode | `pointOnTheEquator(0/π)`, dashed Path | Through ±X equator pts | `BlochProjection.plusX/minusX` |
| Y axis | BlochSphereNode | `pointOnTheEquator(±π/2)` | Through ±Y | `plusY/minusY` |
| Z axis | BlochSphereNode | `(0,-R)→(0,R)` | Vertical dashed | `plusZ/minusZ` |
| Bloch vector | BlochSphereNode Multilink | `pointOnTheSphere(φ,θ)`; ArrowNode | Opacity depth cue vs `(-1,0,0)` | `BlochViewGeometry` + painter arrow |
| Measurement | `BlochSphereMeasurementArea.ts` + Model | Observe/Reprepare; axis radios; ×1/×10 | Controls right of sphere (`right+60`) | `MeasurementControls` → Model API |
| +X…−Z presets | `BlochSpherePreparationArea.ts` | ComboBox `StateDirection` | Prep VBox + sliders θ/φ step π/12 | `StatePresetControls` → `setSpinState` |
| Magnetic Field | `MagneticFieldControl.ts` + Model | Checkbox; strength ∈[-1,1]; precession in TIMING | Bottom of measurement column | `MagneticFieldControl` + `model.step` |
| Erase | MeasurementArea `EraserButton` | `model.resetCounts()` | Clears histogram only | `model.erase()` |
| Reset All | ScreenView | `model.reset()` | Full model reset | `KratosResetAllButton` |
| Divider | `BlochSphereScreenView.ts` | `dividingLineX = 350`, top=70 | Empirically determined | `QmBlochLayoutSpec` |
| MeasurementArea root | ScreenView | `left: 350+40`, `top: Y_MARGIN` | **FIXED** | Composer `measurementArea` |
| Prep sphere scale | PreparationArea | `scale: 0.9` | Transform scale, raw R still 100 | `prepSphereScale=0.9` |
| Multi ×10 | MeasurementArea | lattice `[3,2,3,2]`, spacing 70, scale 0.3 | Content-driven grid | `BlochScene._multiSpheres` |
| Equation readout | `BlochSphereNumericalEquationNode` | Panel above measure sphere | Content-driven; `sphere.top = panel.bottom+35` | Deferred visual polish (P2) |
| Timer | `MeasurementTimerControl` | Delay when B-field on | Visible gated by `magneticFieldEnabled` | Slider + progress in controls |

## Projection (locked)

```
equatorInclination = 10°
xAxisOffset = 20°
pointOnTheSphere(φ, θ):
  x = R * sin(φ+off) * sin(θ)
  y = R * (−cos(θ) + cos(φ+off) * sin(incl) * sin(θ))
```

Orthographic / oblique (no perspective). Vector always painted last (z-order); depth = opacity only.

## R15 MeasurementArea — elevated

| Claim | Confidence | Notes |
|---|---|---|
| Root left=390, top=10 | **HIGH** | ScreenView literal |
| Internal child absolute XY | **CONTENT_DRIVEN** | VBox/HBox; no magic absolute for Observe |
| Relations: sphere.top = equation.bottom+35; controls.left = sphere.right+60; B-checkbox.bottom = layout.bottom−30 | **HIGH** | MeasurementArea lines |
| Exact Observe pixel XY | **SOURCE-DERIVED LIMITATION** | Content size of histogram/panel; not a frozen constant |

Status: R15 root + relations → HIGH; inventing Observe absolute XY from screenshot → forbidden.
