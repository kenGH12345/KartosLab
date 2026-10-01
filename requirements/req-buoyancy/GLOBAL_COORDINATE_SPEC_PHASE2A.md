# GLOBAL_COORDINATE_SPEC_PHASE2A

## Spaces (must not conflate)

| Space | Units | +Y | Used for |
| ----- | ----- | -- | -------- |
| Model / Physics | meters | **up** | Mass.matrix, poolBounds, fluidY |
| THREE world | meters | up | Same as model; camera projects |
| Design (layoutBounds) | pixels | **down** | AlignBox, Panel layout in ScreenView |
| Viewport | pixels | down | After Joist layout matrix |
| Scenery overlay | design/view pixels | down | ForceDiagramNode, labels after `modelToViewPoint` |
| Asset / mesh | source-specific | — | THREE BufferGeometry, Bottle/Boat vertices |

## Transforms

```
Model meters
    → THREE camera (Mobius THREEModelViewTransform)
    → Scenery overlay point (modelToViewPoint)
    → (optional) localToGlobalPoint for pointers

ScreenView.layout(viewBounds)
    → uniform scale + center
    → design pixels ↔ viewport pixels
```

## Forbidden

- `Model.position` as Flutter `Offset` pixels
- Using DebugView scale=600 as production MVT without labeling APPROXIMATE
- Hardcoding waterline / mass Y in design pixels

## Flutter contract (Phase 3+)

`BuoyancyMvtContract` documents production = THREE projection. Exact camera matrix requires mobius source (not in local tree) → **implementation helper may be APPROXIMATE until mobius is available**; archaeology of API surface = PASS.
