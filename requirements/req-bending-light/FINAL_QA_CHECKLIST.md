# Final QA Checklist

Checked against local source `bending-light` 1.3.0-dev.0 and `flutter test test/bending_light/` (142 passed). Official PhET desktop was not launched, so rows that require a running official frame are **NOT VERIFIED**, not PASS.

| Category | Check | Source | Result |
|---|---|---|---|
| Model | Reset | `IntroModel.reset` / `MoreToolsModel.reset` / `PrismsModel.reset` | PASS |
| Model | lifecycle | screen `Ticker.dispose`; no `Timer`; `waveFrame` disposed with the model | PASS |
| Interaction | laser drag | `laser_interaction.dart` quadrant clamp + knob drag | PASS |
| Interaction | prism rotation | `Prism.rotate` then `updateModel` | PASS |
| Physics | Intro Snell | `intro_snell.dart` | PASS |
| Physics | Prisms ray trace | `vector_snell.dart` + `PrismsModel`, cap 50 | PASS |
| Physics | TIR | `VectorSnell.totalInternalReflection` | PASS |
| Dispersion | white light | `WhiteLightCanvasNode.paintCanvas` | PASS |
| Sensor | intensity | circle r=`1e-6`, 0/1/2 hits, midpoint | PASS |
| Sensor | velocity | `getVelocity`, arrow scale `1.5e-14`, `?` at 0 | PASS |
| Sensor | wave | `cos(kx-ωt+φ)` in model; view only paints | PASS |
| View | layout | official runtime | NOT VERIFIED |
| View | typography | official runtime | NOT VERIFIED |
| View | assets | `protractor.png`, `knob.png`, `laser.png` clip | PASS for those three. Laser body is a vector stand-in for `LaserPointerNode` (source is also vector, not `laser.png`) |
| View | z-order | source layer order: white-light canvas then prism layer | PASS vs source. Official runtime frame NOT VERIFIED |
| Performance | repaint scope | `waveFrame` only; ray trace on `updateModel` | PASS |

Graph numeric ticks were not added. `ChartNode` has none.

## QA-2 official runtime (2026-09-18)

`OFFICIAL VERSION MATCH = NOT VERIFIED`. Published HTML used: **1.2.5** (2026-06-24). Local source: **1.3.0-dev.0**. Details: `visual-qa/official/OFFICIAL_RUNTIME_INFO.md`.

Comparison images are the 834×504 stage after removing the Flutter demo AppBar and the PhET navbar, then scaled back to 834×504. Full-frame 1024×618 overlays are not used as layout evidence.

| Feature | Official Reference | Flutter | Match | Evidence |
|---|---|---|---|---|
| Viewport | 1024×618 CSS, DPR≈1, navbar from y=569 | 1024×618 CSS, AppBar 56px, stage FittedBox | MISMATCH | chrome differs; `OFFICIAL_RUNTIME_INFO.md` |
| Main panel | 1.2.5 Intro / Prisms / More Tools | debug web, same screens, default state | MISMATCH | `comparison/*_OVERLAY.png` mean abs RGB 8–18 |
| Play area | 834×504 scaled into area above navbar | 834×504 under AppBar | NOT VERIFIED as pixel match | stage registration; interface y within ~3px on Intro |
| Laser | vector body, default pose | vector body | NOT VERIFIED | overlay ghosting; metallic gradient still P2 |
| Prism | none placed by default | none placed by default | ACCEPTABLE for default empty | both default captures; no placed-prism overlay |
| Controls | Ray/Wave, material, wavelength | same labels in semantics | MISMATCH | overlay double edges; font not PhetFont |
| Typography | `PhetFont` (scenery-phet) | `fontSize` only, default family | MISMATCH | source `PhetFont(12/16/24/25)` vs Flutter 10–16, intensity label 11 |
| Protractor | image, no extra live degree text | image only; extra `readingDeg` text removed | NOT VERIFIED | official pixels not registered to the glyph; code no longer draws the extra label |
| Toolbox | tools inside toolbox | tools inside toolbox | NOT VERIFIED | More Tools overlay mean abs ≈16 |
| Graph | wave + sensor, paused | not captured in that state | NOT VERIFIED | `OFFICIAL_GRAPH.png` only |
| Sensors | intensity + velocity enabled at model positions | not captured in that state | NOT VERIFIED | `OFFICIAL_SENSORS.png` only |
| Z-order | observed in 1.2.5 frames | not overlay-proven | NOT VERIFIED | no laser-on / white-light Flutter pair |
| Clipping | navbar clips the stage | AppBar + FittedBox | NOT VERIFIED | different chrome |

Empty evidence is not PASS. Android runtime remains NOT VERIFIED. Home was not modified.

## QA-3 evidence (2026-09-18)

Official runtime is still **1.2.5**, not local **1.3.0-dev.0**. `OFFICIAL VERSION MATCH = NOT VERIFIED`. `VIEWPORT MISMATCH` (navbar vs AppBar). Stages compared at 834×504 after that crop. Layout `OFFICIAL | FLUTTER`.

Exit code 1 from the temporary Flutter web server is expected when that process is stopped after capture. It is not a launch failure.

| Item | Result | Evidence |
|---|---|---|
| Layout | MISMATCH | `comparison/INTRO_OVERLAY.png` mean abs RGB 11.16/8.41/12.30; `MORE_TOOLS_OVERLAY.png` 16.35/15.87/18.36; `PRISMS_OVERLAY.png` 11.79/11.92/15.78 |
| Typography | MISMATCH | same overlays (labels do not land on the same pixels). Source `PhetFont`; Flutter sets `fontSize` only |
| Controls | MISMATCH | `comparison/*_OVERLAY.png` panel double edges |
| Occlusion | MISMATCH | `FLUTTER_GRAPH.png` chart blue pixels bbox x=194–219 (25px) vs design width 126 |
| Protractor | NOT VERIFIED | extra degree text is not drawn; the tool is in the toolbox in these frames, so the glyph was not registered |
| Graph | MISMATCH | `comparison/GRAPH_OVERLAY.png` mean abs 23.06/23.72/26.01; chart mostly clipped |
| Sensors | MISMATCH | `comparison/SENSORS_OVERLAY.png` mean abs 17.93/16.48/21.25. Intensity probe position was already not the same formula as the 1.2.5 model read |
| White Light | MISMATCH | `comparison/WHITE_LIGHT_OVERLAY.png` mean abs 63.55/63.85/61.07. Flutter black fraction 0.825 |
| Z-order | MISMATCH | graph chart covered/clipped in `FLUTTER_GRAPH.png`. `bumpLeft` overlap still NOT VERIFIED |

No row above is PASS. A PASS still requires the overlay to show the same pixels, not a source comment.

## QA-4 visual convergence (2026-09-18)

Comparison basis changed. QA-3 used a 834×504 crop. QA-4 compares official 1024×618 with the Flutter simulation viewport only (AppBar and debug banner are outside that box). Stage metrics use y=0..568. The bottom 49px is the 1.2.5 joist navbar on the official side and an empty strip on the Flutter side. That strip is not painted as a fake navbar.

`OFFICIAL VERSION MATCH` remains **NOT VERIFIED** (runtime 1.2.5 vs local 1.3.0-dev.0).

| Item | Result | Evidence |
|---|---|---|
| Viewport | PASS for coordinate basis | `BendingLightViewport` is a fixed 1024×618 box. MVT stays 834×504. No AppBar offset in world coordinates. Intro water pixel at (500, 560) is official (200,226,246) vs Flutter (199,226,246) |
| Typography | MISMATCH | `PHET_FONT_MAPPING.md`. Family is source `Arial, sans-serif`. Sizes updated. Pixels still do not land on the official glyphs |
| White light beam | improved, scene still MISMATCH | beam cells y=160–240, x<640 mean abs under 4. Stage mean still 51.08 because the lower toolbox/control band does not match |
| Graph clipping | structural clip removed; fill still MISMATCH | blue body about 136×100 px, was 25 px. Stage mean 26.87, different-pixel ratio 0.406. Body is still a solid fill, not the source gradient |
| Sensors | MISMATCH | stage mean 19.66, ratio 0.356. Probe gradient not restyled |
| Protractor | NOT VERIFIED | still inside the toolbox in the default frames. Glyph not registered |
| Layout panels | MISMATCH | right panels and toolbox still move the mean on every scene |

`flutter test test/bending_light/` 142 passed. `dart analyze lib/bending_light` clean. Android NOT VERIFIED. Home UNCHANGED. Final status **NOT READY**.

