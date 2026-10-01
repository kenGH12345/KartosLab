# Hooke's Law — Final Visual Matrix

Phase 5. Source of truth is the local PhET TypeScript, then scenery-phet. No official runtime screenshot diff was taken. `PASS` means the listed source node formula is now what Flutter draws. It is not a pixel-perfect claim. Sun (`../../../../sun`) is not in this repo, so exact button shading stays `VERSION_DELTA`.

| Screen | Item | Before | Fix | After | Status |
| ------ | ---- | ------ | --- | ----- | ------ |
| Intro | Arrow bevel | Flat gray triangle | Darker offset face, vertical gradient, black stroke. Hit size stays 22×28 | Source `ArrowButton` 3D structure. Pressed inset not in local source | VERSION_DELTA |
| Intro | Slider thumb | Flat 17×34 fill | `paintBeveledRRect`: top highlight, face gradient, 1.5 px side face, black stroke. Track gesture math unchanged | Thumb face matches the sun structure we can reconstruct. Exact sun stops unknown | VERSION_DELTA |
| Intro | Checkbox | Flat white 18×18 | Shared `paintBeveledBox` (highlight, shadow edge, check stroke) | boxWidth 18 kept. Exact sun image not vendored | VERSION_DELTA |
| Intro | Radio | Flat white 1/2 buttons, selected stroke 2 | Top-to-bottom face gradient. Selected line width stays 2 | `RectangularRadioButton` stroke matches. Face stops are reconstructed | VERSION_DELTA |
| Intro | Hinge | Arc body, no specular highlight | `HingeNode` close path plus two-arc highlight, scale 0.85, inset 3 | Shared with Systems and Energy via `paintRoboticArm` | PASS |
| Intro | Spring | Prolate cycloid, loops 12 | Not changed | Still `ParametricSpringNode`, not a sine wave or PNG | PASS |
| Intro | Force / displacement arrows | `bottom`/`top` offsets used as the tail | Tail = node bottom − 10 or node top + 10 (`vectorHeadWidth / 2`) | `IntroSystemNode` bottom/top | PASS |
| Intro | Values anchor | Width estimated as `text.length * 9` | Measured child width. Zero / short / long rules from `ForceVectorNode`. Displacement centered (`DisplacementVectorNode`) | Scrim bottom sits on the arrow top | PASS |
| Intro | Scene icon | pointsPerLoop 24, solid gray | loops 3, pointsPerLoop 40, xScale 2.5, lineWidth 5, scale 0.3, front/back gradients | `HookesLawIconFactory` scene-selection colors | PASS |
| Systems | Components spacing | Tails at `y−80` and `±18`; series used a guessed height 16 | Parallel: applied bottom = topSpring−80, components at total top/bottom. Series: left bottom = axis−65, right bottom = left.top−10. Half-extent 10 | `ParallelSystemNode` / `SeriesSystemNode` | PASS |
| Systems | Icon | Purple/yellow springs, scale 0.22, no wall | Gray scene-selection springs, scale 0.3, wall stroke 2. Series end-to-end. Parallel VBox spacing 5 | `createSeriesSystemIcon` / `createParallelSystemIcon` | PASS |
| Systems | Values anchor | `text.length * 9`, label top `y−28` or `y+16` | Measured width. Force text above the arrow. Displacement centered, top = arrow.bottom | Same rules as Intro | PASS |
| Systems | Parallel colors | Top purple, bottom yellow | Not changed | spring1 purple, spring2 yellow | PASS |
| Systems | Hinge | Same missing highlight as Intro | Shared hinge paint | `HingeNode` | PASS |
| Systems | Controls bevel | Flat checkbox, flat radio ring | Shared bevel box and aqua radio (radius 8, center dot) | Structure reconstructed. Sun stops unknown | VERSION_DELTA |
| Energy | Number avoidance | Force-plot Y label used a fixed −80 px. Scene values were not drawn | XYPointPlot dodge from measured text. Scene values use `ENERGY_UNIT_FORCE_X` 0.4 and unit 225 | Existing Values checkbox. Model unchanged | PASS |
| Energy | Force Plot anchor | Origin on the bar axis | Origin Y = bar axis − `forceYAxisLength / 2` (125). Energy plot stays on the bar axis | `forcePlot.bottom = barGraph.bottom` | PASS |
| Energy | Energy triangle | Two-point triangle, only when Energy is checked on Force Plot | Not changed | Still behind the force line. Hidden otherwise | PASS |
| Energy | Energy curve | Two quadratic Béziers | Not changed | Not a polyline | PASS |
| Energy | Bar graph | Always in the tree; moves to x = 15 when a plot is selected | Value label uses measured height (`bar.right+5`, center or axis) | Bar is not removed on plot switch | PASS |
| Energy | Hinge | Same missing highlight | Shared hinge paint | `HingeNode` | PASS |
| Energy | Controls bevel | Checkbox 16 px filled black when checked. Radio was a thick ring | Checkbox 18 with a check. Aqua radio radius 8 | Sun stops unknown | VERSION_DELTA |
| Shared | Viewport | 1024×618 contain scale | Not changed | Not 768×504. Nav bar not drawn | PASS |
| Shared | Reset All | `KratosResetAllButton` radius 20.5 | Not changed | Not a Material refresh icon | PASS |
| Shared | Typography | PhetFont Arial 18 for controls, graph labels at 12 | Plot values 18, axis titles 16 | Arial with sans-serif fallback. Installed face not pixel-checked | NOT VERIFIED |
| Shared | Runtime pixels | No official screenshot | Not taken | No pixel diff | NOT VERIFIED |
