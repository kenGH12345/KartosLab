# Official runtime capture

Date: 2026-09-18

## URL

`https://phet-dev.colorado.edu/html/bending-light/1.2.5/phet/bending-light_en_phet.html`

`https://phet.colorado.edu/sims/html/bending-light/` directory listing returned Forbidden in the earlier lookup. This capture is **not** website `latest`.

## Published version

| Field | Value |
|---|---|
| `phet.joist.sim.version` | **1.2.5** |
| `phet.chipper.version` | **1.2.5** |
| `phet.chipper.buildTimestamp` | **2026-06-24 06:06:49 UTC** |
| phet-dev directory date | **2026-06-24** |
| brand | `phet` |
| locale | `en` |

No `1.3.0` directory is listed on `https://phet-dev.colorado.edu/html/bending-light/`. Newest published HTML there is **1.2.5**.

## Local source

| Field | Value |
|---|---|
| package version | **1.3.0-dev.0** (`package.json`) |
| SHA recorded in `SOURCE_AUDIT.md` | `a85e95079c52a2abc8386e637e49ea75526f8327` |
| This folder | not a git checkout (`git rev-parse` failed). SHA was **not** re-read from git in this session. |

## Version verdict

`LATEST VERSION MISMATCH`

`OFFICIAL VERSION MATCH = NOT VERIFIED`

1.2.5 screenshots are the nearest published HTML runtime. They are **not** a pixel truth for local `1.3.0-dev.0`.

## Browser

| Field | Value |
|---|---|
| browser | Cursor embedded Chromium (Chrome/148, Electron/42) |
| user agent | `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ... Cursor/3.20.21 Chrome/148.0.7778.280` |
| viewport | **1024 × 618** CSS pixels (`Emulation.setDeviceMetricsOverride`) |
| `devicePixelRatio` | **1.0000000298023224** (override `deviceScaleFactor: 1`) |
| `visualViewport.scale` | 1 |
| zoom | 100% (no extra browser zoom) |
| scrollbar | sim root `overflow: hidden`; no page scrollbar in the capture |
| fullscreen | no |
| canvas | two scenery canvases, CSS 1024×618. After reload under the override, backing store was 1025×619 and 1024×618 |

The user target 1024×618 is the **browser** viewport. PhET layout bounds are **834×504**, then scaled into the area above the joist navbar (navbar starts at y=569 in this capture). Flutter design canvas is the same 834×504 inside `BendingLightSceneShell`, under a demo `AppBar` (56px). Those two stages are not the same rectangle inside 1024×618.

## Capture method

1. Load the 1.2.5 HTML runtime.
2. Set viewport 1024×618, DPR 1, then reload so scenery builds the canvas at that size. A first capture before reload used a 1536×927 backing store and was discarded.
3. `Page.captureScreenshot` PNG, no browser chrome (the page is the sim document).
4. Screen changes via `phet.joist.sim.selectedScreenProperty` (Home=0, Intro=1, Prisms=2, More Tools=3).
5. White light / graph / sensors: model properties on the live sim, not a marketing image.

## Runtime state

| File | State |
|---|---|
| `OFFICIAL_INTRO.png` | Intro default. Air / Water. Ray selected. Normal on. Laser body visible. Tools in the toolbox. |
| `OFFICIAL_MORE_TOOLS.png` | More Tools default. Top n≈1.000, bottom n=1.5 (glass). Ray. Sensors `enabled=false` (in toolbox). Laser off. |
| `OFFICIAL_PRISMS.png` | Prisms default. `manyRays=1`, `colorMode=SINGLE_COLOR`, wavelength 650 nm, `prisms.length=0`, laser off. |
| `OFFICIAL_WHITE_LIGHT.png` | Same screen, then `colorMode=WHITE`, `manyRays=1`, laser **on**, still no prism. Environment went black (play-area black fraction ≈ 0.83). Radio button adapter was **not** updated, only the model. |
| `OFFICIAL_GRAPH.png` | More Tools, `laserView=WAVE`, laser on, wave sensor enabled, then paused at `t=5.375e-13`. |
| `OFFICIAL_SENSORS.png` | More Tools, view `RAY`, laser on, intensity and velocity `enabled=true` at the model's stored positions (not hand-dragged onto the beam). |

Flutter captures are the debug web demo, same browser, viewport **1024×618**, `devicePixelRatio` ≈ 1, zoom 100%, not fullscreen, no page scrollbar. Canvas backing store **1024×618**, read from `flt-glass-pane` via `drawImage` + `toDataURL`. `Page.captureScreenshot` of that canvas is blank and was not used.

`VIEWPORT MISMATCH`: both windows are 1024×618, but the official frame includes the joist navbar (content ends at y=569) and the Flutter frame includes a 56px Material AppBar plus the debug banner. Comparison crops those chromes and scales both stages to 834×504. Raw 1024×618 frames are not directly comparable.

| Flutter file | State |
|---|---|
| `FLUTTER_INTRO.png` | Intro default. Air/Water, Ray, Normal on, tools in toolbox, laser off. |
| `FLUTTER_MORE_TOOLS.png` | More Tools default. Air over glass, Ray, sensors in toolbox, laser off. |
| `FLUTTER_PRISMS.png` | Prisms default. Single color, 650 nm, no prism, laser off. |
| `FLUTTER_WHITE_LIGHT.png` | `?qa=white`. `colorMode=white`, `manyRays=1`, laser on, no prism. Play-area sample black fraction **0.825**. |
| `FLUTTER_GRAPH.png` | `?qa=graph`. Wave view, laser on, wave sensor enabled, paused after stepping to `t=5.375e-13`. Chart pixels are only a 25×99 sliver (design box is 126×93), so most of the chart is clipped or covered. |
| `FLUTTER_SENSORS.png` | `?qa=sensors`. Ray view, laser on, intensity and velocity `enabled=true` at constructor positions. Not dragged onto the beam. |

The `?qa=` values are a demo-only launch hook in `lib/bending_light/qa_launch.dart`. They do not change Home. Official white-light radio was **not** updated when that frame was captured (model only). Flutter did select the white-light icon. That control difference is part of the white-light overlay, not a claim that the beam matches.
