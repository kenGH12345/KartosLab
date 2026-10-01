# Hooke's Law — Phase 5 Final Visual Report

## 1. Status

**READY CANDIDATE**

P0 = 0. Core geometry that the earlier QA called out now follows the local PhET node layout. A small set of `VERSION_DELTA` items remains because the `sun` package is not in this repo, and because no official runtime screenshot was diffed.

The whole simulator stays **NOT READY**. This phase does not start Home, Final Behavioral Acceptance, or release.

`PASS` in the matrix means the source expression is what the Flutter code now uses. It is not a claim that a screenshot matches pixel for pixel.

## 2. Intro Visual Reconstruction

- Spring stays a prolate cycloid (`ParametricSpringNode` parameters: loops 12, points per loop 40, radius 10, aspect 4). It was not replaced with an image or a sine wave.
- Robotic-arm hinge now closes the body and draws the two-arc white highlight from `HingeNode.ts` (scale 0.85, inset 3).
- Applied-force and spring-force tails use `bottom = spring.y - 50`, then subtract half the arrow height (10). The displacement tail uses `top = spring.y + 50`, then adds 10.
- Value labels use the laid-out text width. The old `text.length * 9` estimate is gone. Force labels follow `ForceVectorNode` (zero left/right, center when the text fits, otherwise sit off the tail). Displacement labels stay centered, matching `DisplacementVectorNode`.
- The 1-spring / 2-spring icons use the scene-selection spring (loops 3, line width 5, scale 0.3, gray gradient), not a solid stroke.
- 1↔2 animation, drag snap, and “change k keeps F” were not edited.

## 3. Systems Visual Reconstruction

- Parallel applied/total arrow bottom is `topSpring.y - 80`. Component arrows sit on that node’s top and bottom, 10 px apart from the total arrow’s center. The old `±18` offset is gone.
- Series left-spring arrows use bottom `axis - 65`. Right-end arrows use bottom `left.top - 10`. Left applied force stays on the same tail as the left spring force (spring2 yellow). Not vertically split.
- Parallel remains top purple (`spring1`) and bottom yellow (`spring2`).
- System-type icons follow `HookesLawIconFactory`: gray springs, black wall stroke 2, series springs end to end, parallel springs stacked with spacing 5.
- Value anchors use the same measured-width rules as Intro. Displacement is centered on the arrow.
- Hidden-system reset, screen-leave, Total/Components visibility, and drag snap were not edited.

## 4. Energy Visual Reconstruction

- Force Plot origin Y is `barAxisY - 125` (`forceYAxisLength / 2`), because `forcePlot.bottom = barGraph.bottom` and the downward axis is 125 px. The Energy Plot origin stays on the bar axis. The bar is not removed when a plot is selected; it still moves to x = 15.
- Plot value labels use `XYPointPlot` placement (center on the tick, or the 6 px / 10 px dodge) with the measured text size. The fixed −80 px Y label is gone.
- Bar value uses `bar.right + 5`, and sits on the axis or on the bar top from the measured height.
- Scene Values were missing. They now follow `EnergySystemNode`: applied force uses scale 0.4, displacement uses 225. The Values checkbox already existed. The spring model was not changed.
- The energy triangle is unchanged: it draws only when the graph is Force Plot and the Energy checkbox is on.
- The curve is still two quadratic Bézier segments from `EnergyGraphData`.

## 5. Shared Controls

`lib/hookes_law/view/phet_bevel.dart` is the shared face:

- lighter top, darker bottom, 1.5 px side face, black stroke, hairline highlight
- checkbox 18×18 with a check stroke
- aqua radio diameter 16, selected state is a center dot

Intro, Systems, and Energy all use it. Sizes stay source-specific (checkbox 18, aqua radius 8, thumb 17×34, Systems k track 120, other tracks 180). Slider hit testing is still the track, not the thumb.

No `BoxShadow` was added to fake a bevel.

## 6. Spring rendering

Play-area springs were not rewritten. Icon springs now use the same cycloid sampler as the play area, with icon parameters (3 loops, line width 5, scale 0.3) and the scene-selection gray gradient from `ParametricSpringNode` (middle → front/back → middle).

## 7. Hinge

One `_paintHinge` in `intro_play_painter.dart` is used by Intro, Systems, and Energy. Pivot trapezoid, white pin, black pin center, closed body, and the specular highlight match `HingeNode.ts`. No generic white dot was added.

## 8. Arrows

Arrow node half-extent is `vectorHeadWidth / 2` = 10, from `VECTOR_HEAD_SIZE.width` 20. Scene tails are derived from each screen’s `bottom` or `top`, not from a screen-wide translate.

Energy scene force length is still `appliedForce * 0.4`. Intro and Systems scene force length is still `* 1.45`. Force Plot Y is still `* 0.25`.

## 9. Typography

Controls stay `PhetFont` size 18, family Arial, fallback sans-serif. Graph plot values are 18. Axis titles and the bar value are 16. Whether this machine resolves Arial, or falls back, was not measured. That item is `NOT VERIFIED`.

## 10. Values anchors

Horizontal position comes from the child’s laid-out width:

- force 0 and `alignZero: left` → left = tail + 5
- force 0 and right → right = tail − 5
- text width + 10 < arrow length → center on the arrow
- otherwise the label sits just off the tail, on the arrow’s side

Vertical position: the scrim’s bottom meets the force arrow’s top; the displacement scrim’s top meets the displacement arrow’s bottom. Displacement is always centered.

Checked conceptually for short (`0`), long (`100`), and negative (`-100`) magnitudes because the sign is not drawn and the width is measured. A screenshot of each of those strings was not taken (`NOT VERIFIED` as pixels).

## 11. Graphs

- Bar graph: width 20, axis length 1.65×20, stroke 0.25, vertical arrow 250. Always painted.
- Energy Plot: two `quadraticBezierTo` calls. Domain and the energy scale were not changed.
- Force Plot: line and triangle still come from `EnergyGraphData`. Only the origin Y moved.
- No chart library.

## 12. Viewport

Still `1024 × 618`, uniform contain scale, centered. Not `768 × 504`. The home navigation bar is not drawn.

## 13. Transform

No screen-level `translate` was added to “look closer”. Arrow and plot shifts are the source `bottom` / `top` / `centerY` relations.

## 14. P0

**0.**

Viewport, spring cycloid, arrow direction, parallel/series positions, graph scales, and the missing Energy scene values are addressed. No clipping or overlap was introduced that the regression tests can see.

## 15. P1

**0 open structural items.**

The remaining control-face differences are listed under VERSION_DELTA, not left as an unnamed P1.

## 16. P2

- Panel corner radius stays 4. Source panels are close to that; the exact scenery corner was not re-measured.
- Slider track is still a flat bar at the source size (180×3, Systems k 120×3). Sun track shading is not vendored.
- Cycloid and hinge edges are Flutter-antialiased. A 1 px raster difference against scenery is expected and was not measured.
- Bevel highlight is a 1 px white line, not a sampled sun image.

## 17. Remaining VERSION_DELTA

| Item | Source | Current | Why unresolved | Behavior |
| ---- | ------ | ------- | -------------- | -------- |
| Arrow button, slider thumb, checkbox, aqua radio, rectangular 1/2 and system-type faces | `sun` 3D buttons: highlight, shadow, gradient, pressed inset, disabled face | Top-light / bottom-dark gradient, 1.5 px side, black stroke, center radio dot, check stroke. No pressed inset | `sun` is not in this repository. Guessing a pressed pixel shift would not be source-verified, and must not move slider coordinates | None. Hit targets and step sizes are unchanged |
| Official runtime pixels | PhET HTML5 canvas | Flutter canvas | No screenshot diff in this phase | None |

## 18. Tests

`flutter test test/hookes_law/`

**61 passed.** No test was weakened, skipped, or rewritten.

## 19. Analyze

`dart analyze lib/hookes_law test/hookes_law`

**No issues found.**

## 20. Regression Result

Model formulas, drag snap, Intro 1↔2 animation, Systems Total/Components, hidden-system reset, screen leave, and Energy graph switching were not modified. The Energy Values checkbox now draws the numbers the source already shows; it does not add a control or a model field.

Failed visual experiments were not papered over by changing assertions.

---

Next phase, not started here: **Final Behavioral Acceptance**, then Home integration.
