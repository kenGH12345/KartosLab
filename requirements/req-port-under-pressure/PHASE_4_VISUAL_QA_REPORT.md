# PHASE 4 — FULL VISUAL RECONSTRUCTION / GOLDEN QA REPORT

**Sim:** PhET Under Pressure → Flutter  
**Req id:** `req-port-under-pressure`  
**Source:** `fluid-pressure-and-flow-main` + scenery-phet FaucetNode originals  
**Model:** Phase 1–3 LOCKED (no physics changes)

---

## PHASE 4 STATUS: PASS

判定：

- Accordion chrome / custom HSlider（非 Material Slider）收口
- Cement Pattern 使用原版 `cementTextureDark.jpg` ImageShader stroke
- Faucet 使用 scenery-phet 原版 PNG 合成（非截图、非第三方）
- Mystery ComboBox 完整下拉（open list + highlightFill）
- 12 scene/control goldens PASS
- Behavior regression：71 既有 + 15 新增 = **86 PASS**
- Analyze clean；P0/P1 = 0
- Home：**NOT TOUCHED**

```text
Flutter UI: visual reconstruction PASS
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
```

---

## Viewport / MVT

```text
Viewport: 768 × 504
MVT: 70 px/m · inverted Y · origin (0,245)
```

（未为修视觉改 MVT。）

---

## SQUARE

| | |
|--|--|
| Scene / Pool / Fluid / Sensor / Ruler / Grid / Controls | PASS |
| Visual | PASS（golden `square_initial`） |

---

## TRAPEZOID

| | |
|--|--|
| Geometry / Fluid / Sensor / Ruler / Grid | PASS |
| Visual | PASS（golden `trapezoid_initial`） |

---

## CHAMBER

| | |
|--|--|
| Geometry / Mass / Displacement / Fluid / Sensor | PASS |
| Visual | PASS（`chamber_initial` + `chamber_mass_placed`） |

---

## MYSTERY

| | |
|--|--|
| Geometry / Mystery dataset / Fluid / Sensor | PASS |
| Dropdown | PASS（open list + Fluid A/B/C） |
| Visual | PASS（`mystery_initial` + `mystery_dropdown_open`） |

---

## FAUCET

| | |
|--|--|
| Body / Spout / Pipe / Track / Knob / Flange | PASS — scenery-phet PNGs |
| Outline | PASS — original assets |
| Handle / Shooter | PASS — drag maps to flowRate |
| Stream | PASS — `FaucetFluidNode` static rect |
| States | closed / open / filling / draining via Model |
| Visual | PASS（`faucet_open_square`） |

---

## ACCORDION

| | |
|--|--|
| Closed / Open | PASS |
| Chrome | PASS — `#f2fa6a` / gray stroke / r=4 / +− button 12×12 |
| Visual | PASS（`accordion_density_collapsed` + `control_slider_density`） |

---

## CEMENT PATTERN

| | |
|--|--|
| Pattern | original `cementTextureDark.jpg` |
| Scale / Opacity | ImageShader tile · strokeWidth 4 |
| Visual | PASS（Square / Trapezoid / Chamber borders） |

---

## CONTROLS

| Control | Status |
|---------|--------|
| Density / Gravity | PASS — custom thumb 12×25, track 115×6 |
| Atmosphere | PASS — golden `atmosphere_off` |
| Units | PASS — golden `units_english` |
| Scene Selector | PASS |
| Reset | PASS（KratosResetAllButton r=18） |

---

## TYPOGRAPHY

PASS — title 13 / value 12 / tick 9.5 / mystery 12（对齐 ControlSlider / MysteryPoolView）

---

## GOLDENS

```text
Count: 12
PASS: 12
FAIL: 0
```

| Golden | Purpose |
|--------|---------|
| square_initial | Square baseline |
| trapezoid_initial | Trapezoid baseline |
| chamber_initial | Chamber baseline |
| mystery_initial | Mystery baseline |
| atmosphere_off | Black sky |
| ruler_grid_on | Tools |
| units_english | Units + ft grid |
| accordion_density_collapsed | Accordion closed |
| faucet_open_square | Faucet + stream |
| chamber_mass_placed | Mass displacement |
| mystery_dropdown_open | Combo open |
| control_slider_density | Accordion/slider chrome |

Environment: 768×504 · DPR 1 · textScale 1 · no production golden hacks.

---

## Behavior Regression

```text
PASS — Oracle A–H + Phase 2/3 suites unchanged
```

---

## Assets

```text
FPAF Required: 7
FPAF Found: 7
Missing: 0
Substituted: 0

scenery-phet faucet PNGs (original PhET, not third-party):
  faucetBody / Spout / HorizontalPipe / VerticalPipe /
  Track / Knob(+Disabled) / Shaft / Flange(+Disabled) / Stop
```

---

## Tests

```text
Previous: 71
Added: 15
Final: 86
```

---

## Analyze

```text
No issues found!
```

---

## P0 / P1 / P2

| | |
|--|--|
| P0 | 0 |
| P1 | 0 |
| P2 | 极细 shadow / font baseline / faucet shooter 像素装配微差（相对 scenery-phet 复合叠层） |

---

## Phase 3 P2 关闭

| Item | Status |
|------|--------|
| accordion chrome | **CLOSED** |
| cement Pattern | **CLOSED** |
| faucet scenery-phet outline | **CLOSED**（原版 PNG） |
| mystery dropdown | **CLOSED** |

---

## Home / Runtime

```text
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
```

---

## Report

`requirements/req-port-under-pressure/PHASE_4_VISUAL_QA_REPORT.md`
