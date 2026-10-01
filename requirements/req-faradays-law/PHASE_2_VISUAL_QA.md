# PHASE 2 — VISUAL QA · Faraday's Law

对照：用户原版截图 + Phase 0 screenshot audit + source View.

## Checklist (widget / model-backed; no golden pixel dump this phase)

| Scene | Verification | Severity if fail |
|-------|--------------|------------------|
| Initial | magnet right, single 4-coil, bulb off, voltmeter hidden, arrows on | P0 |
| Magnet left of coil | drag updates model.x leftward | P0 |
| Magnet near coil | EMF chain non-zero after step | P0 |
| NS / SN | `flipPolarity` updates painter orientation | P1 |
| Field lines on/off | `setFieldLinesVisible` | P1 |
| 4-spiral / 2+4 | `topCoilVisible` shows/hides top mipmaps | P1 |
| Voltmeter zero/+/- | needle from `clampedNeedleAngle`; body only if visible | P1 |
| Bulb dim/bright | `BulbModel.haloScale` from \|V\| | P1 |
| Coil sandwich z-order | front Image above magnet Positioned | P0 structure |
| Reset visual | `model.reset()` restores defaults | P1 |

## P0 / P1 / P2

| | Count | Notes |
|--|-------|-------|
| **P0** | **0** | Drag works; core components present; z-order implemented |
| **P1** | **0** | Original coil/bulb assets; magnet/voltmeter source-drawn |
| **P2** | recorded | See below |

### P2 accepted (record only)

| ID | Item |
|----|------|
| P2-01 | Magnet 3D bevel / font may differ slightly from Scenery anti-alias |
| P2-02 | Voltmeter `ShadedRectangle` simplified to flat fill + light stroke |
| P2-03 | Field-line arrow tangent approx may differ ~1–2° from Kite segment |
| P2-04 | Top-coil wire arc geometry simplified vs full quadratic chain |
| P2-05 | Bulb base Image alignment vs Path body may need Phase 5 pixel nudge |

## Asset substitution

| Asset | Status |
|-------|--------|
| `four_loop_front/back.png` | Original PhET mipmap |
| `two_loop_front/back.png` | Original PhET mipmap |
| `light_bulb_base.png` | Original scenery-phet |
| Magnet / field lines / voltmeter / wires / arrows | Source geometry CustomPainter (not substitution) |

**Substituted = 0**

## VERSION_DELTA (view)

| ID | Note |
|----|------|
| VD-DRAG | Continues Phase 1 AABB drag limits |
| VD-CTRL | Phase 2 has no control strip UI (Phase 3) |
| VD-SOUND | Sounds not wired yet |
| VD-A11Y | GrabDrag / keyboard not ported |
