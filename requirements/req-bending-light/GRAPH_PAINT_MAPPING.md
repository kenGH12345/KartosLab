# Graph Paint Mapping — FINAL QA-6

Source: `WaveSensorNode` body + `scenery-phet/js/ShadedRectangle.ts`.
Wave equation is unchanged.

## Order (source, back to front)

The body node paints its rectangles first. `ChartNode` is a child of the eroded inner-most rectangle, so the series is painted **on top of** the shaded fill and **under** the time label, which is a sibling positioned at `bodyNode.height * 0.82`.

```text
outer rounded rect (gradient fill, then gradient stroke)
→ inner 130×90 (#0078B0 fill, #0081BE stroke)
→ innerMost ShadedRectangle (white base, light from rightBottom)
→ ChartNode grid + series (clipped to eroded plot)
→ time label
```

Flutter `WaveSensorBodyPainter` follows that rectangle order. The chart painter and the time text are stacked above the body in `more_tools_play_area.dart`, after the toolbox. Toolbox stays in the earlier layer. That z-order is unchanged from QA-5.

## Highlight

`innerMost` is `Bounds2(10, 0, 132.3, 63)`, center `(67.5, 40)`, corner radius 5.

`new ShadedRectangle(innerMost, { baseColor: 'white', lightSource: 'rightBottom' })`.

Defaults from `ShadedRectangle.ts`:

| Factor | Value | On white |
| --- | --- | --- |
| lightFactor | 0.5 | stays white |
| lighterFactor | 0.1 | lighter = 0.6, stays white |
| darkFactor | 0.5 | dark = gray |
| darkerFactor | 0.1 | darker = darker gray |
| lightOffset | 0.525 × cornerRadius | |
| darkOffset | 0.375 × cornerRadius | |

`rightBottom` means light is **not** from the left and **not** from the top:

- top = darker
- left = dark
- right = light (white)
- bottom = lighter (white)

The vertical gradient fades those edge colors to alpha 0 toward the middle. The center remains the base color. This is not a flat white rectangle and not an opacity hack.

Flutter: `paintShadedRectangle` / `graphHighlightLuminance` in `lib/bending_light/components/wave_view.dart`.

## Not changed

- Fill stops `#5EB4DE` → `#005B86`
- Stroke `#2F9BCE` → `#00486A`, line width 2
- Inner `#0078B0` / `#0081BE`
- Grid `#D3D3D3`, dash `[10, 5]`, line width 2
- Series line width 2 and `cos(kx − ωt + φ)`
