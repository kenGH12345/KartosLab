# BLOCH_LAYOUT_SPEC

> Sources: `BlochSphereScreenView.ts`, `BlochSpherePreparationArea.ts`, `BlochSphereMeasurementArea.ts`, `BlochSphereNode.ts`

## 1. Source Evidence

| Claim | Evidence | Confidence |
|---|---|---|
| Divider X=350, top=70 | BlochSphereScreenView | HIGH |
| Prep centerX = mid(left, divider.left); top = top+10 | localBoundsProperty link | HIGH |
| Measurement left = 350+40=390; top = top+10 | BlochSphereScreenView | HIGH |
| sphereRadius = 100 | BlochSphereNode | HIGH |
| Prep sphere scale 0.9 | BlochSpherePreparationArea | HIGH |
| Pure-state angles θ,φ | AbstractBlochSphere / ComplexBlochSphere | HIGH |

## 2. Root Geometry

```
BlochSphereScreenView
├── BlochSpherePreparationArea (left)
├── ExperimentDividingLine (x=350, top=70)
├── BlochSphereMeasurementArea (left=390)
└── ResetAll
```

## 3. Coordinate Systems

| System | Definition |
|---|---|
| Layout | Divider, ResetAll, area placement |
| Sphere local | Origin at sphere center; +Y down in Scenery |
| Quantum | θ polar from +Z, φ azimuthal from +X; \|r\|=1 |

### Projection (Composer must port BlochSphereNode math)

- `ShadedSphereNode` diameter = `2 * sphereRadius`
- State arrow length ≈ sphereRadius
- Equator / axes use dashed Path with LABELS_OFFSET=5
- Node applies `xAxisOffsetAngle` for oblique view — **do not invent** isometric; port `pointOnTheEquator` / Multilink from source

Approximate tip (without azimuth offset):

```
tipX = r * sin(θ) * cos(φ)
tipY = -r * cos(θ)   // +Z toward top of screen
```

## 4. Module Tree

```
BlochSpherePreparationArea (VBox)
├── symbolic / numerical equations
├── BlochSphereNode (prep, scale 0.9)
├── ComboBox presets ±X±Y±Z Custom
├── polarAngleSlider [0,π]
└── azimuthalAngleSlider [0,2π]

BlochSphereMeasurementArea
├── equation readout + basis radios X/Y/Z
├── large BlochSphereNode(s) (single or ×10)
├── SystemUnderTestNode (Atom box + red particle)
├── MagneticFieldControl / arrows
├── histogram + Erase
├── Number of Atoms ×1/×10
├── Spin Measurement Axis radios
└── Observe button
```

## 5–8. Anchors

| Module | Rule | Mode |
|---|---|---|
| Divider | centerX=350, top=70 | FIXED |
| Prep | centerX mid-left column; top=Y_MARGIN | CONSTRAINED |
| Measurement | left=390, top=Y_MARGIN | FIXED left |
| Sphere radius | 100 × scale | FIXED |
| Sliders | DEFAULT_CONTROL_SLIDER_OPTIONS track 150×1 | FIXED |
| Observe | VBox under measurementControlPanel (sphere.right+60 column) | CONTENT_DRIVEN (relation HIGH; absolute XY SOURCE-DERIVED LIMITATION) |

## 9. Dynamic Geometry

| Driver | Effect |
|---|---|
| Single vs ×10 | One vs ten BlochSphereNodes visibility |
| Magnetic field + TIMING | Arrows visible; precession of φ (model); visual rotation |
| Measurement state PREPARED/OBSERVED | Button color / enabled (visual), not layout bounds |
| Erase | Clears histogram only — no layout change |

## 10. Responsive

Uniform ScreenView scale.

## 11. Z-Order (sphere node)

```
sphere body
axes / equator
projections
state vector arrow
labels
```

Follow BlochSphereNode child add order.

## 12. Asset Geometry

No PNG for Bloch sphere — **programmatic** ShadedSphereNode. Atom particle programmatic red sphere.

## 13. Typography

RichText kets; CONTROL_FONT tick labels; BOLD_HEADER titles.

## 14. Overlay

ComboBox popup (parent = ScreenView). Erase is in-panel button, not overlay.

## 15. Animation Geometry

Magnetic precession: φ advances; vector tip recomputed each frame (model step + view Multilink). No separate trajectory path.

## 16. Unknowns / R15 resolution (PHASE 6)

| Item | Status |
|---|---|
| MeasurementArea root left=390, top=10 | **HIGH** |
| Relations: sphere.top=equation.bottom+35; controls.left=sphere.right+60; B-checkbox.bottom=layout.bottom−30 | **HIGH** |
| Exact Observe absolute XY | **SOURCE-DERIVED LIMITATION** (content-driven VBox) |
| Multi-sphere lattice [3,2,3,2] spacing 70 scale 0.3 | **HIGH** |

## 17. Implementation Guidance

Port `BlochSphereNode` projection as shared view helper used by Spin + Bloch. LayoutSpec stores radius/divider/scales only — **not** measurement outcomes.
