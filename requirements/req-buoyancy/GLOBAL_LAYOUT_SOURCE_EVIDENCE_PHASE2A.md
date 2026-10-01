# GLOBAL_LAYOUT_SOURCE_EVIDENCE_PHASE2A

| Feature | Source File | Class / Symbol | Evidence | Confidence |
| ------- | ----------- | -------------- | -------- | ---------- |
| Design bounds | joist ScreenView (via Compare) | `ScreenView.DEFAULT_LAYOUT_BOUNDS` | Compare L63 passes layoutBounds | HIGH |
| Margin / spacing | `DensityBuoyancyCommonConstants.ts` | MARGIN=10, MARGIN_SMALL=5 | L32–49 | HIGH |
| AlignBox shell | `DensityBuoyancyScreenView.ts` | `addAlignBox` | L483–489 | HIGH |
| Camera defaults | `DensityBuoyancyScreenView.ts` | scaleIncrease=3.5, zoom=1.75× | L122–152 | HIGH |
| Buoyancy lookAt | `DensityBuoyancyCommonConstants.ts` | `BUOYANCY_CAMERA_LOOK_AT` | L103 | HIGH |
| Compare lookAt/offset | Constants + CompareScreenView | BASICS lookAt + viewOffset (−25,0) | Constants L104–107; Compare L58–61 | HIGH |
| THREE MVT | MassView / MobiusScreenView | `THREEModelViewTransform` | imports; `modelToViewPoint` | HIGH (API); matrix internals UNKNOWN without mobius checkout |
| Debug 2D MVT | `DebugView.ts` | inverted-Y scale 600 at center | L46 | HIGH (debug only) |
| Force arrow scale | `ForceDiagramNode.ts` | `× vectorZoom × 20` | L130 | HIGH |
| ResetAll | DensityBuoyancyScreenView | AlignBox right/bottom | addAlignBox pattern | HIGH |
| Panel chrome | Constants PANEL_OPTIONS | cornerRadius 5, margins 10 | L82–87 | HIGH |
| Typography | Constants TITLE/ITEM/RADIO/READOUT fonts | 16 bold / 14 bold / 14 | L54–64 | HIGH |
| Provenance | meta | LOCAL 0c835c64 vs PINNED 0295f8f6 | OPEN P1 (frozen) | HIGH |
