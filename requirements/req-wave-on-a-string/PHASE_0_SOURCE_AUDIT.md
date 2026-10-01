# PHASE 0 — SOURCE AUDIT · Wave on a String

> **Status:** COMPLETE  
> **Local source:** `phet sourses/wave-on-a-string-main/wave-on-a-string-main`  
> **Official runtime:** https://phet.colorado.edu/sims/html/wave-on-a-string/latest/wave-on-a-string_all.html  
> **GitHub:** https://github.com/phetsims/wave-on-a-string  
> **Screenshot:** user-provided initial Manual / Fixed End state  
> **No Flutter code written in this phase.**

---

## Overview

Wave on a String is a **single-screen** PhET HTML5 simulation. The core is **not** an analytic traveling sine wave. The string is a **1D chain of 61 beads** with three time buffers (`yLast`, `yNow`, `yNext`) updated by an **explicit central-difference damped wave scheme** with Courant number **α = 1**, plus prescribed left-end drive (Manual / Oscillate / Pulse) and discrete right-end boundary conditions (Fixed / Loose / No End).

Tension does **not** change α; it changes how often `evolve()` runs relative to wall-clock via `minDt`. Damping enters as β in the update rule. Rendering uses `yDraw` interpolated between physics steps; beads are Circle→toDataURL images plus a stroked Path.

---

## Local Source Version

| Field | Value |
| ----- | ----- |
| `package.json` name | `wave-on-a-string` |
| **version** | **`1.3.0-dev.0`** |
| license | GPL-3.0 |
| supportedBrands | phet, phet-io, adapted-from-phet |
| simulation | true |
| supportsOutputJS | true |
| supportsDynamicLocale | true |
| **supportsInteractiveDescription** | **true** |
| **supportsSound** | **true** |
| runnable | true |
| published | true |
| requirejsNamespace | WAVE_ON_A_STRING |

Evidence: local `package.json` (not assumed from GitHub alone; matches reported GitHub `main` tag `1.3.0-dev.0`).

Root inventory (present): `package.json`, `dependencies.json`, `tsconfig.json`, `js/`, `images/`, `assets/`, `doc/`, strings JSON. Entry is TypeScript `js/wave-on-a-string-main.ts` (not an HTML filename assumption).

---

## Screen Structure

| Item | Source fact |
| ---- | ----------- |
| Screen count | **1** |
| Registration | `wave-on-a-string-main.ts` → `new Sim(..., [ new WOASScreen(...) ])` |
| Screen class | `WOASScreen` |
| Model factory | `() => new WOASModel(...)` |
| View factory | `model => new WOASScreenView(model, ...)` |
| Default / only screen | the single `WOASScreen` |
| Keyboard help | `WOASKeyboardHelpContent` |
| Background | `WOASColors.backgroundColorProperty` (`#FFFFB7`) |

```text
Screens = 1
Screen = WOASScreen
Model = WOASModel
ScreenView = WOASScreenView
```

---

## Main Entry

```text
js/wave-on-a-string-main.ts
  → simLauncher.launch
  → new Sim(title, [ new WOASScreen(Tandem...) ], credits)
  → .start()
```

Related:

- `js/waveOnAString.ts` — namespace module
- `js/WaveOnAStringFluent.ts` / `WaveOnAStringStrings.ts` — i18n
- `doc/model.md` — conceptual equations (aligned with code; code is SoT)

---

## Model Architecture

**Class:** `js/wave-on-a-string/model/WOASModel.ts`

### Discrete string

```text
point0 — point1 — ... — point60
i = 0 ... NUMBER_OF_BEADS-1 = 60
LAST_INDEX = 60
NEXT_TO_LAST_INDEX = 59
```

| Constant | Value | File |
| -------- | ----- | ---- |
| `NUMBER_OF_BEADS` | 61 | `WOASConstants.ts` |
| `MODEL_UNITS_PER_GAP` | 10 | same |
| `MODEL_UNITS_PER_CM` | 80 | same |
| `FRAMES_PER_SECOND` | 50 | same |
| `FRAME_DURATION` | 1/50 = 0.02 s | same |
| `MAX_START_AMPLITUDE_CM` | 1.3 | same |

### State buffers (vertical displacement only)

| Buffer | Role |
| ------ | ---- |
| `yLast[i]` | displacement at previous physics step |
| `yNow[i]` | displacement at current physics step |
| `yNext[i]` | computed next step (then arrays rotate) |
| `yDraw[i]` | view interpolation target |

**No separate velocity/acceleration arrays.** Velocity is implicit in `yNow - yLast`. Mass is not an explicit parameter.

### Control / mode properties

| Property | Default | Range / values |
| -------- | ------- | -------------- |
| `waveModeProperty` | `WOASMode.MANUAL` | MANUAL, OSCILLATE, PULSE |
| `stringEndTypeProperty` | `WOASEndType.FIXED_END` | FIXED_END, LOOSE_END, NO_END |
| `isPlayingProperty` | `true` | boolean |
| `timeSpeedProperty` | `TimeSpeed.NORMAL` | NORMAL, SLOW |
| `tensionProperty` | `0.8` | 0.2 … 0.8 (unitless ratio) |
| `dampingProperty` | `0.2` | 0 … 1 (unitless; UI×100 → %) |
| `frequencyProperty` | `1.50` Hz | 0 … 3 |
| `pulseWidthProperty` | `0.5` s | 0.2 … 1 |
| `amplitudeProperty` | `0.75` cm | 0 … 1.3 |
| tools visibility | rulers/ref line false; stopwatch via `Stopwatch` | |
| `angleProperty` | 0 | oscillator/pulse phase |
| pulse flags | pending/active/sign | internal |

---

## String/Wave Representation

- **Model:** 61 scalar displacements; horizontal spacing fixed (`MODEL_UNITS_PER_GAP`).
- **View (`StringNode`):** Path stroke through bead centers + bead Images (every 10th bead is “reference” cyan; others red; bead 0 scaled 1.2×).
- Beads are **not** independent physics nodes; they display `yDraw[i]` (bead 0 uses `nextLeftYProperty` for live manual).
- String Path color `#F00`; bead fills from `WOASColors`.

---

## Wave Propagation Algorithm

### Clock path

```text
Joist animation → WOASModel.step(dt)
  → (if isPlaying) accumulate stepDt
  → when stepDt >= FRAME_DURATION → manualStep(stepDt)
  → manualStep loops in FRAME_DURATION slices
  → when timeElapsed >= minDt → evolve()
  → yNowChangedEmitter → StringNode dirty
WOASScreenView.step(dt) → frameEmitter only (redraw)
```

**maxDT:** not source-defined as a named constant. `step()` **soft-limits** frame dt: if `|dt - lastDt| > 0.3 * lastDt`, dt is clamped toward lastDt by at most 30%. Default `lastDtProperty = 0.03`.

### Tension → evolve rate (source fact)

```text
tensionFactor = linear(
  sqrt(0.2), sqrt(0.8),
  0.2, 1,
  sqrt(tension)
)
minDt = 1 / (FRAMES_PER_SECOND * tensionFactor * speedMultiplier)
speedMultiplier = NORMAL ? 1 : 0.25
```

Higher tension → larger `tensionFactor` → smaller `minDt` → more frequent `evolve()` → **faster apparent wave travel**. α inside `evolve` stays 1; wave speed is **not** changed by altering α.

### `evolve()` interior update (source)

Conceptual PDE (from `doc/model.md`, matching code):

```text
y_tt = v^2 y_xx - 2 γ y_t
```

Code (`WOASModel.evolve`):

```text
dt = 1; v = 1; dx = dt * v;   // α = v*dt/dx = 1 always
b = dampingProperty * 0.2
beta = b * dt / 2
alpha = 1
a = 1 / (beta + 1)
c = 2 * (1 - alpha^2)         // = 0 when α=1
yNext[0] = yNow[0]            // left Dirichlet held
for i = 1 .. LAST_INDEX-1:
  yNext[i] = a * (
    (beta - 1) * yLast[i]
    + c * yNow[i]
    + alpha^2 * (yNow[i+1] + yNow[i-1])
  )
rotate: yLast←yNow←yNext←old yLast
then re-apply right boundary on LAST_INDEX
```

With α=1 this is a **damped neighbor average** plus previous-step term — **not** `y = A sin(kx − ωt)` for the bulk string.

### Integration character

- Fixed conceptual physics step inside `evolve` (normalized dt=1).
- Wall clock subdivided into `FRAME_DURATION` (1/50 s) slices.
- Multiple `FRAME_DURATION` iterations per browser frame when dt is large.
- Between evolves, `yDraw[i]` linearly interpolates `yLast`→`yNow` using `timeElapsed/minDt`.
- Manual left end: `yNow[0]` ramps by `perStepDelta` across those slices toward `nextLeftYProperty`.

---

## Boundary Conditions

Right end index = `LAST_INDEX` (60).

| Mode | Pre-update | Post-rotate | Reflection semantics (emergent) |
| ---- | ---------- | ----------- | ------------------------------- |
| **FIXED_END** | `yNow[LAST]=0` | `yLast[LAST]=yNow[LAST]=0` | Dirichlet node; inverted reflection |
| **LOOSE_END** | `yNow[LAST]=yNow[NEXT_TO_LAST]` | `yNow[LAST]=yNow[NEXT_TO_LAST]` | zero slope; non-inverted |
| **NO_END** | `yNow[LAST]=yLast[NEXT_TO_LAST]` | `yNow[LAST]=yLast[NEXT_TO_LAST]` | 1st-order absorbing approx.; residual reflections possible |

**Boundary switch:**

- Switching **to** `FIXED_END` calls `zeroOutEndPoint()` (sets `yNow`/`yDraw` last index to 0 only — does **not** clear whole string).
- Switching to Loose/No End does **not** clear the string.
- Mode (Manual/Oscillate/Pulse) switch → `manualRestart()` (clears **entire** string + pulse/angle state).

**HISTORICAL:** Flash-era comments remain in NO_END branch; current HTML5 code uses the `yLast[NEXT_TO_LAST]` form. Extra-vibration issues on boundary switch are **HISTORICAL** unless reconfirmed; current source only special-cases Fixed via `zeroOutEndPoint`.

---

## Manual Mode

- Selected via `waveModeProperty = MANUAL` (radio in `modePanel`).
- User drags **`WrenchNode`** (PNG wrench + up/down arrows), **not** arbitrary mid-string beads.
- Drag maps pointer Y → `nextLeftYProperty`, clamped to `± MAX_START_AMPLITUDE_CM * MODEL_UNITS_PER_CM` (±104 model units).
- Drag start forces `isPlayingProperty = true`.
- On release: arrows stay hidden (`wrenchArrowsVisibleProperty = false`); left end **stays** at last Y (no snap to zero); wave continues to propagate from that Dirichlet left value.
- Manual mode UI shows only Damping + Tension (no Amplitude/Frequency).
- Amplitude property exists but is **not used** for Manual drive.

---

## Oscillate Mode

```text
angle += 2π * frequency * FRAME_DURATION * speedMultiplier  (mod 2π)
yNow[0] = yDraw[0] = amplitude * MODEL_UNITS_PER_CM * sin(-angle)
```

- Continuous sinusoidal Dirichlet drive at left end.
- Switching into Oscillate → `manualRestart()` (string cleared, angle reset).
- Changing amplitude/frequency **immediately** affects subsequent `yNow[0]` writes; existing interior wave **continues** under the same evolve rule (not wiped by slider change).

---

## Pulse Mode

**Pulse = PRESENT IN CURRENT SOURCE** (`WOASMode.PULSE`, `PulseButton`, `manualPulse()`).

| Aspect | Source behavior |
| ------ | --------------- |
| Fire | `PulseButton` → `model.manualPulse()` |
| Shape | Triangular in time: angle rises to π/2 then falls; `y = A*MODEL_UNITS_PER_CM * (-angle/(π/2))` |
| Width | `pulseWidthProperty` (seconds) controls `da = π * FRAME_DURATION * speedMultiplier / pulseWidth` |
| Amplitude | `amplitudeProperty` |
| Repeat | one pulse per button press; `isPulseActive` / `pulsePending` |
| UI | Amplitude + Pulse Width + Damping + Tension |

---

## Amplitude

| | |
| -- | -- |
| Model | `amplitudeProperty` cm, default **0.75**, range **0 … 1.3** |
| Role | **Oscillator/Pulse left-end drive only** — not “current max string displacement” |
| Manual | unused for drive |
| Live change | updates next drive samples; does not clear string |

---

## Frequency

| | |
| -- | -- |
| Model | `frequencyProperty` Hz, default **1.50**, range **0 … 3** |
| Mapping | `Δangle = 2π f Δt_eff` with `Δt_eff = FRAME_DURATION * speedMultiplier` |
| Display | 2 decimal places |
| Visible | Oscillate mode only |

Not a free-standing `sin(kx−ωt)` field; frequency only drives **left boundary**.

---

## Damping

| | |
| -- | -- |
| Model | `dampingProperty` default **0.2**, range **0 … 1** |
| UI | ×100 → **0% … 100%**, default displayed **20%** |
| Mapping | `b = damping * 0.2`; `beta = b * dt / 2` with evolve `dt=1` → `beta = damping * 0.1` |
| Effect | enters `(beta−1)*yLast` and `a=1/(beta+1)`; attenuates step-by-step (velocity-like damping in discrete PDE) |
| Boundary | no separate damping region; uniform on interior points |
| Live | yes — next `evolve()` uses new beta |

---

## Tension

| | |
| -- | -- |
| Model | `tensionProperty` default **0.8**, range **0.2 … 0.8** |
| UI | ×100 → **20% … 80%**, default **80%** |
| Effect | via `tensionFactor` → `minDt` (see above); **higher tension → faster propagation** (source fact) |
| Does not | change α inside evolve; α remains 1 |
| Live | yes |

---

## Clock

| Item | Source |
| ---- | ------ |
| Type | Joist model `step(dt)` + fixed `FRAME_DURATION` subdivision |
| FRAME_DURATION | 0.02 s (50 Hz conceptual) |
| maxDT named | **not source-defined** |
| Soft dt limit | ±30% vs `lastDtProperty` |
| Pause | `isPlayingProperty === false` skips `manualStep` accumulation |
| Slow | `speedMultiplier = 0.25` on angle, pulse, stopwatch, and `minDt` |
| View step | `frameEmitter` redraw only |

---

## Pause / Play

- Default: **playing** (`isPlayingProperty = true`). Screenshot shows Pause glyph → consistent with running.
- Control: `TimeControlNode` (Play/Pause + Step).
- While paused: physics/`evolve`/`stopwatch.step` do not advance via `step()`; Step button calls `manualStep()` once.
- Manual drag while paused: drag sets `isPlaying = true` (auto-resume).
- Timer: only advances inside `manualStep` → **pauses with sim**.

---

## Slow Motion

| Values | Default | Impact |
| ------ | ------- | ------ |
| NORMAL (1), SLOW (0.25) | NORMAL | scales oscillator/pulse phase advance, stopwatch, and `minDt` denominator |

Affects **simulation clock semantics**, not CSS animation alone.

---

## Ruler

- Two `RulerNode`s (horizontal 0–10 cm, vertical 0–5 cm), units `cm`.
- Default visibility: **false** (`rulersVisibleProperty`).
- Draggable (pointer + keyboard Sound*DragListener); positions in model properties; clamped to keep ≥120 px visible.
- Reset restores default positions + visibility false.
- Scale tied to `MODEL_UNITS_PER_CM` via MVT.

---

## Timer

- `scenery-phet` `Stopwatch` + `StopwatchNode`.
- Visibility: `stopwatch.isVisibleProperty` (checkbox “Stopwatch”), default hidden.
- Time range: `Stopwatch.ZERO_TO_ALMOST_SIXTY`.
- Steps with `FRAME_DURATION * speedMultiplier` inside `manualStep` → respects pause & slow.
- Draggable; position default `(774, 414)`.
- Reset: `stopwatch.reset()`.

---

## Reset

| Action | Method | Clears |
| ------ | ------ | ------ |
| **Restart** (blue button) | `manualRestart()` | angle, timeElapsed, pulse flags, **all y buffers → 0**; keeps modes/sliders/tools |
| **Reset All** (orange) | `reset()` | all properties to defaults + `manualRestart()` + stopwatch/rulers/ref line |

Do **not** conflate Restart with Reset All.

---

## Keyboard / Touch

- Wrench: SoundDragListener + SoundKeyboardDragListener (up/down).
- Rulers / reference line: Sound drag + keyboard.
- NumberControls: keyboard steps defined per control.
- `WOASKeyboardHelpContent` for help dialog.
- Touch areas dilated (`dilatedTouchArea = 10`, reference line 20).

---

## Sound

- `supportsSound: true` in package metadata.
- **No local `sounds/` directory** in this repo checkout.
- Interaction sounds via shared `SoundDragListener` / `SoundKeyboardDragListener` (scenery-phet grab/release), not sim-local mp3 inventory.
- **VERSION_DELTA candidate:** Flutter may defer shared PhET drag sounds (`VD-SOUND`).

---

## Accessibility

- `supportsInteractiveDescription: true`.
- Screen summary: `WOASScreenSummaryContent`.
- PDOM order for play/control areas; accessible names/help on radios, wrench, rulers, controls.
- Parallel DOM / voicing patterns from Joist/Scenery (standard PhET).
- Flutter a11y scope: audit only in Phase 0; migration decision later.

---

## Initial State

| Item | Value |
| ---- | ----- |
| mode | Manual |
| boundary | Fixed End |
| amplitude | 0.75 cm |
| frequency | 1.50 Hz |
| pulseWidth | 0.5 s |
| damping | 0.2 (UI 20%) |
| tension | 0.8 (UI 80%) |
| isPlaying | true |
| timeSpeed | NORMAL |
| rulers | hidden |
| stopwatch | hidden |
| reference line | hidden |
| pulse | inactive |
| string y* | all 0 |
| wrench arrows | visible |
| center dashed line | always drawn (not a checkbox) |

Matches user screenshot (Manual, Fixed, Damping 20%, Tension 80%, Pause icon, tools unchecked).

---

## Interaction Map

```text
User
 ├─ Mode radios → waveModeProperty → (lazyLink) manualRestart → y*=0
 ├─ End radios → stringEndTypeProperty → (if FIXED) zeroOutEndPoint
 ├─ Wrench drag → nextLeftYProperty → (playing) yNow[0] interpolate → evolve chain
 ├─ Pulse button → manualPulse → triangular yNow[0] drive
 ├─ Amplitude/Freq/PulseWidth → drive formulas in manualStep
 ├─ Damping/Tension → beta / minDt in evolve path
 ├─ Play/Pause/Step → isPlayingProperty / manualStep
 ├─ Normal/Slow → timeSpeedProperty → speedMultiplier
 ├─ Rulers/Stopwatch/RefLine checkboxes → visibility + drag positions
 ├─ Restart → manualRestart
 └─ Reset All → reset
        ↓
   yLast/yNow/yNext/yDraw
        ↓
   StringNode / StartNode / EndNode
```

---

## Asset Summary

See `ASSET_MAP.md`. Local bitmaps: wrench, clamp, ringFront/Back, windowFront/Back. Beads/string/center line/posts are **source-generated**. Shared: ResetAllButton, TimeControlNode, RulerNode, StopwatchNode, ArrowNode, Panel, radio groups.

Target: **Substituted assets = 0**.

---

## Viewport

| Item | Source |
| ---- | ------ |
| ScreenView | default Joist `layoutBounds` (standard ~1024×618; not overridden in WOASScreenView ctor) |
| MVT | `createSinglePointScaleMapping(ZERO → (VIEW_ORIGIN_X, VIEW_ORIGIN_Y), SCALE_FROM_ORIGINAL=1.25)` |
| VIEW_ORIGIN | (150, 265) |
| VIEW_END_X | originX + 1.25 * 60 * 10 = 900 |
| Controls | AlignBox margins 10; bottom panel right of Reset All; time/restart at y≈ height−175 |

Model Y positive mapping: view uses MVT; wrench clamp uses parent Y with sign convention via `leftMostBeadYProperty` map `-y/MODEL_UNITS_PER_CM`.

---

## Z-order

`WOASScreenView` children order (back → front):

```text
a11y stubs → rulersNode → modePanel → restart → endTypePanel
→ waveGenerationParagraphs → timeControl → resetAll → bottomControlPanel
→ stopwatch → centerLine → endNode.windowNode → referenceLine
→ endNode → stringNode → startNode → windowImage (front of no-end)
```

Notable:

- Center dashed line **behind** string.
- `windowImage` (front) above string for No End clipping sandwich with `endNode.windowNode` behind.
- StartNode (wrench) above string; EndNode around string with window split.
- Rulers under most play graphics but above a11y-only nodes; stopwatch above bottom panel region in tree (drawn after panels).

---

## Known VERSION_DELTA Candidates

| ID | Topic | Notes |
| -- | ----- | ----- |
| VD-SOUND | Shared drag sounds | No local sound assets; scenery-phet dependency |
| VD-A11Y | Interactive description / PDOM | Full parity optional for Flutter MVP |
| VD-PHETIO | PhET-iO instrumentation | Not required for KartosLab unless specified |
| VD-LOCALE | Dynamic locale / Fluent | Flutter i18n strategy TBD |
| VD-BEAD-CACHE | Circle→toDataURL beads | Flutter may use CustomPainter/cached images but must match look — not substitute third-party icons |

No screenshot-vs-source conflict found for initial Manual/Fixed/20%/80% state (`VERSION_DELTA` visual = none for that frame).

---

## Future Test Strategy

| Category | Should verify |
| -------- | ------------- |
| Model Unit | evolve formula, α=1, β from damping, tension→minDt, boundaries, pulse triangle, oscillate sin, manualRestart vs reset |
| View Widget | control sync, mode-dependent slider visibility, checkbox tools |
| Interaction | wrench drag clamp, mode switch clears string, Fixed switch zeros end only |
| Dynamic | reflection Fixed vs Loose, No End absorption, damping decay, tension speed, slow 0.25, pause/step |
| Visual | bead count/spacing/colors, clamp/ring/window assets, center dash, panel colors |
| Lifecycle | clock dispose, step while paused, Reset All |
| Home | later phases only |

**Tests this phase = 0.**

---

## Gate Checklist

| Gate | Status |
| ---- | ------ |
| Screen structure | known (1 × WOASScreen) |
| Model structure | known (WOASModel buffers) |
| Wave algorithm | known (evolve + minDt) |
| Boundary behavior | known |
| Manual/Oscillate/Pulse | known (Pulse present) |
| Control ranges | known |
| Initial state | known |
| Clock | known |
| Reset | known (Restart ≠ ResetAll) |
| Viewport | known |
| Z-order | known |
| Assets | inventoried |
| Screenshot | audited |
| VERSION_DELTA | identified candidates |

```text
Phase 0 = COMPLETE
Overall = NOT READY
Home = NOT STARTED
Android = NOT VERIFIED
```
