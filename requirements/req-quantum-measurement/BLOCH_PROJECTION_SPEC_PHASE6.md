# BLOCH_PROJECTION_SPEC_PHASE6

> Source of truth: `js/common/view/BlochSphereNode.ts`

## Constants

| Name | Value | Notes |
|---|---|---|
| sphereRadius (raw) | 100 | Geometry |
| ShadedSphereNode diameter | 200 | = 2R |
| Prep transform scale | 0.9 | Visible R ≈ 90; **do not** redefine raw R |
| Measure single scale | 1.0 | |
| Multi scale | 0.3 | |
| equatorInclination | 10° | |
| xAxisOffset | 20° | Oblique view |
| axes lineWidth | 0.4 | dashed `[2,2]` |
| LABELS_OFFSET | 5 | |

## Projection type

**Oblique orthographic** (ellipse equator + fixed axis offset). Not perspective.

## Mapping

```
Model: (θ polar from +Z, φ azimuthal from +X)
Screen local (origin = sphere center, +Y down as Scenery):

x = R * sin(φ + off) * sin(θ)
y = R * (−cos(θ) + cos(φ + off) * sin(incl) * sin(θ))
```

## Axis directions (local)

| Axis | Endpoint formula |
|---|---|
| +X | `pointOnTheEquator(0)` |
| −X | `pointOnTheEquator(π)` |
| +Y | `pointOnTheEquator(π/2)` |
| −Y | `pointOnTheEquator(−π/2)` |
| +Z | `(0, −R)` |
| −Z | `(0, +R)` |

## Depth convention

- Cartesian tip: `(sinθ cosφ, sinθ sinφ, cosθ)`
- Distance from middle-back `(-1,0,0)`
- Tip opacity = `(distance/2)²` (fixed to 3 decimals in source)
- Gradient fill from rgba(0,0,0,0.4) at tail to tip opacity
- **No** front/back hemisphere clipping of the arrow — z-order is always on top of sphere body

## Front/back rendering rule

Sphere body → equator → axes → angle indicators → state vector (last).

## Flutter

`lib/quantum_measurement/bloch_sphere/projection/bloch_projection.dart`
→ `BlochViewGeometry.fromState` → `BlochSpherePainter` (paint only).
