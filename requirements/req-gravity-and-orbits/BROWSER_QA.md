# BROWSER_QA · Gravity and Orbits

> Original URL: https://phet.colorado.edu/sims/html/gravity-and-orbits/latest/gravity-and-orbits_all.html  
> Local source truth: 1.7.0-dev.7  
> Note: latest webpage may differ slightly; behavior below validated against **local source** + spot-check on webpage.

## Checklist (source-driven)

| Action | Source expected | Flutter | Status |
|---|---|---|---|
| Model / To Scale tabs | 2 screens | GravityAndOrbitsHome | PASS |
| 4 scene presets | icon combos | SceneSelectionControls | PASS |
| Gravity on/off | radio | GravityControl | PASS |
| Force / Velocity / Path / Grid | checkboxes | CheckboxPanel | PASS |
| Mass / Tape (To Scale only) | show flags | flags + widgets | PASS |
| Mass 0.5–2.0× | MassSlider | MassControlPanel | PASS |
| Play / Pause / Step / Rewind | TimeControl | GaoTimeControl | PASS |
| Fast / Normal / Slow | substeps 7/4/1 | GaoTimeSpeed | PASS |
| Clear time | time=0 only | clearSimulationTime | PASS |
| Reset All | model.reset | KratosResetAllButton | PASS |
| Scene reset | resetBodies+time | resetActiveScene | PASS |
| Drag body | position only | dragBody* | PASS |
| Drag velocity | Δv / scale | dragVelocity* | PASS |
| Zoom 0.5–1.3 | ZOOM_RANGE | ZoomControl | PASS |
| Path trail from model | Body.path | GaoPathPainter | PASS |
| PEFRL gravity | ModelState | ModelState.dart | PASS (unit+orbit tests) |

## Webpage spot-check notes

- Default: Model screen, Star+Planet, paused, gravity on, vectors off  
- Matches user screenshots provided at task start  
- If latest HTML diverges from 1.7.0-dev.7 literals, **keep local source**

## Physics cross-check

Same initial Model Sun–Earth → PEFRL steps → planet remains bound (orbit_regression 2000 frames PASS).  
Numerical x/y dump vs browser PhET-iO not automated in this pass; recommended follow-up: PhET-iO state export compare.
