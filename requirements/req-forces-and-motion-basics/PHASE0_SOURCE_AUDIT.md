# PHASE 0 SOURCE AUDIT — Forces and Motion: Basics

**Source version:** `forces-and-motion-basics` **2.7.0-dev.0** (`package.json`)  
**Local path:** `phet sourses/forces-and-motion-basics-main/forces-and-motion-basics-main`  
**Layout bounds:** 981 × 604 (`ForcesAndMotionBasicsLayoutBounds`)  
**Visual gold standard:** user-provided PhET screenshots (Net Force / Motion / Friction / Acceleration)

> **Note:** Screenshot #4 is **Acceleration** (checkbox “Acceleration” + water bucket).  
> Screenshot #3 is **Friction** (Stopwatch + trash can, no Acceleration meter).

---

## Screens

| # | Screen | Entry | Model | View |
|---|--------|-------|-------|------|
| 1 | Net Force | `forces-and-motion-basics-main.ts` | `js/netforce/model/NetForceModel.ts` | `NetForceScreenView.ts` |
| 2 | Motion | `MotionScreen('motion')` | shared `MotionModel` | shared `MotionScreenView` |
| 3 | Friction | `MotionScreen('friction')` | same | same (μ slider, gravel) |
| 4 | Acceleration | `MotionScreen('acceleration')` | same | same (accelerometer, bucket) |

Motion / Friction / Acceleration share `js/motion/` — differentiated by `screen` style flags.

**NOT the same as** KartosLab `lib/friction/` (PhET Friction books/atoms sim).

---

## Models

### Net Force (tug of war)

| Quantity | PhET behavior | Source |
|----------|---------------|--------|
| Puller force S/M/L | **50 / 100 / 150 N** | `Puller.ts` |
| Left force | −Σ(attached blue) | `NetForceModel` |
| Right force | +Σ(attached red) | |
| Net force | left + right | |
| Cart mass | **none** (implicit in coeff) | |
| Velocity update | `v += F_net * dt * 0.003` | L449 |
| Position update | `x += v * dt * 60` | L453 |
| Win threshold | `\|x\| ≥ 458 − 55 = **403**` | `GAME_LENGTH`, `Cart.widthToWheel` |
| Pullers | 4 left (1L+1M+2S), 4 right (2S+1M+1L) | |
| Knots | 8 (4+4), spacing 80, y=285 | |
| Colors | `blueRed` (default) or `purpleOrange` preference | |
| Go / Pause | `isRunningProperty` | |
| Return | reset cart/knots/speed; **keep pullers attached** | |
| Reset All | full reset including pullers home | |
| Control toggles | Sum of Forces, Values, Speed | defaults false |
| Sound | `golfClap` on completed | |

### Motion / Friction / Acceleration (shared)

| Quantity | Value | Source |
|----------|-------|--------|
| Applied force | −500…500 N, default 0 | `MotionModel` |
| μ range | 0…**0.5** (`MAX_FRICTION`) | `MotionConstants` |
| μ default Motion | **0** | |
| μ default Friction/Accel | **0.25** | |
| g | **9.8** | |
| Static friction | oppose applied; cap at μmg | `getFrictionForce` |
| Kinetic friction | `−sign(v) * μmg * **0.75**` | L473 |
| a = ΣF / m | yes | |
| Velocity reverse clamp | if v would reverse from friction → 0 | |
| MAX_SPEED | **40 m/s** → pusher falls | |
| Manual step dt | **1/60** | |
| Max stack | **3** (4th splices bottom) | |
| Initial stack | crate1 (50 kg) | |
| Pusher home | −16 m | |
| POSITION_SCALE | 10 | |

---

## Objects (masses — authoritative)

| id | mass (kg) | Motion | Friction | Acceleration |
|----|-----------|--------|----------|--------------|
| fridge | 200 | ✓ | ✓ | ✓ |
| crate1 | 50 | ✓ (initial on stack) | ✓ | ✓ |
| crate2 | 50 | ✓ | ✓ | ✓ |
| girl | 40 | ✓ | ✓ | ✓ |
| man | 80 | ✓ | ✓ | ✓ |
| trash | 100 | ✓ | ✓ | ✗ |
| mystery | 50 | ✓ | ✓ | ✓ |
| bucket | 100 | ✗ | ✗ | ✓ |

---

## Views / Controls per screen

| UI | Net Force | Motion | Friction | Acceleration |
|----|-----------|--------|----------|--------------|
| Sum of Forces | ✓ | ✗ | ✓ | ✓ |
| Force(s) | — | Force | Forces | Forces |
| Values | ✓ | ✓ | ✓ | ✓ |
| Masses | — | ✓ | ✓ | ✓ |
| Speed | ✓ | ✓ | ✓ | ✓ |
| Stopwatch | — | ✓ | ✓ | ✗ |
| Acceleration meter | — | ✗ | ✗ | ✓ |
| Friction slider | — | ✗ | ✓ | ✓ |
| Go / Return | ✓ | — | — | — |
| Play / Pause / Step | — | ✓ | ✓ | ✓ |
| Reset All | ✓ (r=23) | ✓ | ✓ | ✓ |
| Skateboard | — | ✓ | ✗ | ✗ |
| Water bucket | — | ✗ | ✗ | ✓ |

Panel fill ≈ `#e3e980`. Reset All → Flutter `KratosResetAllButton` (L0).

---

## Assets inventory (PhET local)

### Motion objects / scene
- `images/skateboard.svg`, `fridge.svg`, `crate.svg`, `trashCan.svg`, `mysteryObject01.svg`, `waterBucket.svg`
- `images/mountains.svg`, `cloud1.svg`, `brickTile.png`, `icicle.png`, `grass.png`
- `images/{usa,africa,asia,latinAmerica,oceania}/*Girl*|Man*{Standing,Sitting,Holding}.svg`
- `images/pushPullFigures/pusher_0.png` … `pusher_30.png`, `pusher_straight_on.png`, `pusher_fall_down.png`

### Net Force
- `images/cart.svg`, `rope.png`
- `pull_figure_{BLUE|RED|PURPLE|ORANGE}_{0|3}.png` (+ `_lrg_`, `_small_`)
- `tugIconBlueRed.png`, `tugIconPurpleOrange.png`

### Sounds
- `sounds/golfClap_mp3.js` (+ license) — only Net Force completion clap

### Flutter today
- **No** PhET image assets under `assets/` for this sim
- `pubspec.yaml` only lists `assets/scenarios/forces/`
- UI uses **Material Icons** — **blocked** by `85-phet-original-assets`

---

## Sounds

| Sound | When |
|-------|------|
| golfClap | Net Force `state === 'completed'` |
| (none other sim-specific) | drag uses shared listeners in HTML |

---

## Keyboard / Accessibility

**Net Force hotkeys:** Alt+G Go, Alt+P Pause, Alt+C Return; puller ←/→ A/D, Enter/Space grab, Esc cancel, Delete home.

**Motion:** object / pusher keyboard navigation help sections exist in source.

**a11y:** Interactive Description, Voicing strings — P2 for Flutter unless already patterned in other sims.

---

## Shared systems (Flutter target)

```
Force / Mass / Velocity / Acceleration / Position
Object + Stack (max 3)
Friction (μ, static/kinetic 0.75)
SimulationClock (lib/common/simulation_clock.dart — reuse)
NetForceModel (separate, no cart mass)
MotionModel (style: motion|friction|acceleration)
Force arrows, Speedometer, Accelerometer, Stopwatch
KratosResetAllButton
```

---

## Existing KartosLab `lib/forces` gap analysis

| Area | Current stub | PhET / required |
|------|--------------|-----------------|
| Kinetic friction | **0.8** | **0.75** |
| Net Force win | gameLength **400** (scenario) | **403** |
| Net Force v coeff | scenario cartStep | **0.003** fixed |
| Objects | Material `Icons.*` | Original SVG/PNG |
| Pullers | `Icons.directions_run` | pull_figure PNGs |
| Pusher | missing / simplified | 31-frame push + fall |
| Assets in pubspec | scenarios only | must copy images/sounds |
| Home | already wired | keep; fix after PASS |
| Tests | scenario JSON only | need physics + interaction |
| Independent `lib/friction` | books/atoms | **do not modify** |

---

## Known risks

1. **Asset volume** — 100+ puller/pusher PNGs + region SVGs; must copy and map carefully.
2. **Net Force integration coeffs** — easy to “fix” with F=ma; must keep 0.003 / 60.
3. **Return vs Reset** — Return keeps pullers; Reset clears — stub may conflate.
4. **Stack geometry** — heights from image bounds, not `index * fixedHeight`.
5. **Pusher fall / stand-up timing** — 2 s, speed gate 40 m/s.
6. **Bucket water slosh** — Acceleration-only, tied to acceleration.
7. **Do not touch** completed sims or `lib/friction` (different product).
8. **doc/model.md** omits 0.003/60 and misstates win length — **code wins**.

---

## Phase gate

- [x] Phase 0 Source Audit
- [ ] Phase 1 Shared Model + unit tests (P0=0, P1=0 on model)
- [ ] Phase 2 Net Force
- [ ] Phase 3 Motion
- [ ] Phase 4 Friction
- [ ] Phase 5 Acceleration
- [ ] Phase 6 Cross-Screen Regression
- [ ] Phase 7 Visual QA
- [ ] Phase 8 Home Integration / Regression
- [ ] Final Gate
