# Rutherford Scattering — Phase 0 Source Analysis

> Local source: `phet sourses/rutherford-scattering-main/rutherford-scattering-main`  
> Official: https://github.com/phetsims/rutherford-scattering  
> Visual reference: https://phet.colorado.edu/sims/html/rutherford-scattering/latest/rutherford-scattering_all.html  
> Analyzed: 2026-09-17

---

## Done

- [x] Screen / Model / View architecture mapped from local TypeScript
- [x] Physics algorithm extracted (`RutherfordAtom.moveParticle`)
- [x] Plum Pudding behavior confirmed (straight-line, no deflection)
- [x] Clock / step / reset / gun firing cadence documented
- [x] Asset inventory completed
- [x] Critical behavioral nuances that contradict naive assumptions documented
- [x] P0 / P1 / P2 prioritization

## Remaining

- Phase 1+ implementation (Model → Physics → View → Interaction → Visual QA → Test/APK)

## P0 / P1 / P2 (from source)

| Priority | Items |
|---|---|
| **P0** | Two screens; Gun ON/OFF; α emission + lifecycle; Rutherford trajectory algorithm; Plum Pudding straight-line; Energy→speed; Protons→charge/D; Neutrons visual-only (physics unchanged); Traces history; Atomic↔Nuclear scene (with particle clear); Pause / Step(1/60) / Reset |
| **P1** | Observation window canvas; Atom shells / nucleus nucleons; Plum pudding PNG+electrons; Gun/foil/beam; Control panels; Scale labels; Layout fidelity |
| **P2** | Projector color profile; a11y/PDOM; bevel/shadow micro chrome; keyboard help |

## Tests / Analyze / Build

N/A at Phase 0 (analysis only).

## Known Differences vs User Brief (source wins)

| Assumption in brief | Actual PhET source |
|---|---|
| Atomic↔Nuclear keeps particles continuous | **`sceneProperty` change calls `removeAllParticles()`** |
| Neutrons must change scattering | **`model.md`: neutrons have no effect on trajectories**; only proton count + energy affect D |
| Plum Pudding has distinct scattering force | **No atoms in space → particles move straight**; visual pudding only |
| Energy changes existing particles | Changing energy/protons/neutrons **clears all particles** (Multilink) |

---

## 1. Screen Architecture

Entry: `js/rutherford-scattering-main.ts`

```
Sim
 ├── RutherfordAtomScreen  → RutherfordAtomModel + RutherfordAtomScreenView
 └── PlumPuddingAtomScreen → PlumPuddingAtomModel + PlumPuddingAtomScreenView
```

Both extend shared `RSBaseScreenView` for gun / foil / observation space / time controls / Reset All.

**Models are independent** — separate screen instances, no shared runtime state between screens.

---

## 2. Model Architecture

```
RSBaseModel
 ├── alphaParticleEnergyProperty  (DEFAULT 80, min 50, max 100)  ← used as SPEED
 ├── protonCountProperty           (DEFAULT 79, 20–100)
 ├── neutronCountProperty          (DEFAULT 118, 20–150)
 ├── runningProperty               (true = playing)
 ├── userInteractionProperty       (slider drag pauses stepping)
 ├── bounds: Bounds2(-255,-255,255,255)  // SPACE_NODE 510/2 = 255 → /4 = ±127.5? Wait: WIDTH/4
 ├── gun: Gun
 ├── particles: AlphaParticle[]
 └── atomSpaces: AtomSpace[]

RutherfordAtomModel extends RSBaseModel
 ├── sceneProperty: 'atom' | 'nucleus'   // Atomic Scale / Nuclear Scale
 ├── atomSpace: RutherfordAtomSpace      // 5 RutherfordAtoms
 └── nucleusSpace: RutherfordNucleusSpace // 1 RutherfordAtom + RutherfordNucleus (shred)

PlumPuddingAtomModel extends RSBaseModel
 └── plumPuddingSpace: PlumPuddingAtomSpace  // ZERO atoms → straight motion only
```

### Model bounds (critical)

```ts
// RSBaseModel
bounds = Bounds2(
  -SPACE_NODE_WIDTH/4, -SPACE_NODE_HEIGHT/4,
  +SPACE_NODE_WIDTH/4, +SPACE_NODE_HEIGHT/4
);
// SPACE_NODE_WIDTH = SPACE_NODE_HEIGHT = 510
// → bounds = [-127.5, -127.5, 127.5, 127.5], width = 255
```

View mapping: `ModelViewTransform2.createRectangleInvertedYMapping(model.bounds, spaceNodeBounds)`  
(+y model up → view down inverted).

### Shared vs screen-specific

| Shared | Rutherford only | Plum Pudding only |
|---|---|---|
| RSBaseModel, Gun, AlphaParticle, AtomSpace empty-space motion | RutherfordAtom trajectory, AtomSpace×5 / NucleusSpace×1, sceneProperty, Protons/Neutrons panels | PlumPuddingAtomSpace (no atoms), plumPudding.png visual |

---

## 3. View Architecture

```
RSBaseScreenView
 ├── LaserPointerNode (gun) + BeamNode + "Alpha Particles" label
 ├── TargetMaterialNode (gold foil trapezoid) + TinyBox + dashed zoom lines
 ├── spaceNode (abstract createSpaceNode)
 ├── ScaleInfoNode
 ├── TimeControlNode (play/pause + step → model.manualStep)
 └── ResetAllButton → showAlphaTraceProperty.reset() + model.reset()

RutherfordAtomScreenView
 ├── scene radio: 'atom' | 'nucleus' (atom.png / nucleus icon)
 ├── AtomSpaceNode (particleStyle: 'particle' = magenta dots)
 ├── NucleusSpaceNode (particleStyle: 'nucleus' = 2p+2n cluster)
 └── Dual control panel stacks (legend differs per scene)

PlumPuddingAtomScreenView
 └── PlumPuddingSpaceNode (pudding image + electrons + nucleus-style α)
```

Observation rendering uses **CanvasNode** (`ParticleSpaceNode`) for particle performance.

---

## 4. Component Inventory

### Model

| File | Role |
|---|---|
| `common/model/RSBaseModel.ts` | Base clock, particles, gun, reset, energy/protons/neutrons |
| `common/model/Gun.ts` | Emission cadence, spawn positions, X0_MIN avoidance |
| `common/model/AlphaParticle.ts` | speed, position, orientation, positions[] traces, bounding box prep |
| `common/model/Atom.ts` | Bounding rect/circle, particle ownership |
| `common/model/AtomSpace.ts` | Empty-space straight motion + atom transition |
| `rutherfordatom/model/RutherfordAtom.ts` | **Core scattering algorithm** |
| `rutherfordatom/model/RutherfordAtomSpace.ts` | 5 atoms, DEFLECTION_WIDTH=30 |
| `rutherfordatom/model/RutherfordNucleusSpace.ts` | 1 centered atom, width=bounds.width |
| `rutherfordatom/model/RutherfordNucleus.ts` | shred ParticleAtom for visual nucleons |
| `plumpuddingatom/model/PlumPuddingAtomSpace.ts` | Empty space (no atoms) |

### View (key)

| File | Role |
|---|---|
| `RSBaseScreenView.ts` | Shared layout |
| `ParticleSpaceNode.ts` | Canvas particles + traces |
| `ParticleNodeFactory.ts` | Procedural proton/neutron/electron/α icons |
| `AlphaParticlePropertiesPanel.ts` | Energy slider + Traces checkbox |
| `AtomPropertiesPanel.ts` | Protons/Neutrons (userInteraction on drag) |
| `TargetMaterialNode.ts` | Procedural foil shape |
| `AtomCollectionNode.ts` | Nuclei + Bohr dashed shells |
| `PlumPuddingAtomNode.ts` | plumPudding.png + 79 electron positions |

---

## 5. Asset Inventory

### Bitmap (must reuse)

| Original | Use |
|---|---|
| `images/plumPudding.png` | Plum pudding positive-charge blob |
| `images/plumPuddingIcon.png` | Legend icon |
| `images/plumPuddingAtomScreenIcon.png` | Screen icon |
| `images/atom.png` | Atomic scale radio button |
| `images/atomProjector.png` | Projector profile (P2) |

### Procedural (CustomPainter / Canvas — NOT bitmaps)

- Proton / Neutron / Electron spheres (radial gradient)
- Magenta α particle (Atomic scale) / 2p+2n α cluster (Nuclear / Plum)
- Nucleus yellow dot + dashed electron energy levels
- Gold foil TargetMaterialNode
- LaserPointer gun body (PhET scenery-phet) → Flutter recreate with RSColors
- Beam, TinyBox, dashed zoom lines
- Traces (paths from `particle.positions`)

### Source assets / AI

- `assets/*.ai`, screenshot PNGs — **not runtime**

**Substituted Assets target: 0** for runtime bitmaps listed above.

---

## 6. Physics / Scattering Algorithm

### Rutherford (`RutherfordAtom.moveParticle`)

Documented assumptions in source comments:

1. Algorithm assumes atom at (0,0) → coordinates adjusted relative to atom.position  
2. Algorithm assumes +y up → model uses that after rotation correction  
3. Particles move bottom → top  
4. Algorithm fails for x≤0 → abs(x), restore sign  
5. Use `atan2(x, -y)` not arctan(-x,y)  
6. Gun keeps min |x| from nucleus (`X0_MIN_FRACTION = 0.04`)

**Interaction strength D:**

```
D = (L / 8) * (p / pd) * (sd² / s0²)

L  = atom boundingRect width
p  = protonCount
pd = DEFAULT_PROTON_COUNT (79)
s0 = particle initial speed (energy when fired)
sd = DEFAULT_ALPHA_ENERGY (80)
s  = current speed
```

Polar update (impact parameter `b`, radius `r`, angle `phi`):

```
b1 = sqrt(x0² + y0²)
b  = 0.5 * (x0 + sqrt(-2*D*b1 - 2*D*y0 + x0²))
r  = sqrt(x² + y²)
phi = atan2(x, -y)
phiNew = phi + (b² * s * dt) / (r * sqrt(b⁴ + r² * t1²))
  where t1 = b*cos(phi) - (D/2)*sin(phi)
rNew = |b² / (b*sin(phiNew) + (D/2)*(cos(phiNew)-1))|
sNew = s0 * sqrt(1 - D/rNew)
xNew = rNew * sin(phiNew)  (± restore)
yNew = -rNew * cos(phiNew)
```

On intermediate failures → remove particle from model (error path).

### Empty space / Plum Pudding

```
dx = cos(orientation) * speed * dt
dy = sin(orientation) * speed * dt
// default orientation = π/2 → straight up (+y model)
```

**No electrostatic force in Plum Pudding.** Concept teaching: pudding predicts undeflected paths.

### Neutrons

Affect `RutherfordNucleus` visual nucleon count only. **Not in D formula.**

---

## 7. Clock / Step Architecture

| Mechanism | Behavior |
|---|---|
| `step(dt)` | If `running && !userInteraction && dt < 1`: gun.step → moveParticles → cull |
| `manualStep()` | Always one frame of `manualStepDt = 1/60` (if !userInteraction) |
| Gun cadence | `dtPerGunFired = (bounds.width / speed) / MAX_PARTICLES` with MAX=20, intensity=1 |
| Cull | Remove particle if outside `model.bounds` |
| Trace | Every position change pushes to `positions[]` (listener on positionProperty) |

Energy is **speed in model units**, not eV conversion.

---

## 8. Reset Lifecycle

`RSBaseModel.reset()`:

1. `gun.reset()` → onProperty = false  
2. `removeAllParticles()`  
3. Reset energy, running, userInteraction, protons, neutrons  

`RutherfordAtomModel.reset()` also resets `sceneProperty` → `'atom'`.

View Reset All also resets `showAlphaTraceProperty` (default false).

**Side effect clears** (Multilink): any change to protons / neutrons / energy / userInteraction → `removeAllParticles()`.

**Scene switch** (Atomic ↔ Nuclear): `removeAllParticles()` + toggle `atomSpace`/`nucleusSpace` visibility.

Gun OFF: stops spawning; existing particles continue until cull.

---

## 9. Interaction List

| Control | Property | Effect |
|---|---|---|
| Alpha Particles gun button | `gun.onProperty` | Start/stop emission |
| Energy slider | `alphaParticleEnergyProperty` | New particle speed; clears particles |
| Traces checkbox | `showAlphaTraceProperty` (view) | Show/hide path history |
| Protons ± / slider | `protonCountProperty` | D, nucleus charge visual; clears particles |
| Neutrons ± / slider | `neutronCountProperty` | Nucleus visual only; clears particles |
| Atomic / Nuclear radio | `sceneProperty` | Space visibility + clear particles |
| Play/Pause | `runningProperty` | Clock on/off |
| Step | `manualStep()` | One 1/60 step while paused |
| Reset All | model + traces | Full initial state |

Slider drag sets `userInteractionProperty=true` → freezes stepping until release.

---

## 10. Constants (`RSConstants`)

```
MIN/MAX/DEFAULT_ALPHA_ENERGY: 50 / 100 / 80
DEFAULT_SHOW_TRACES: false
MIN/MAX/DEFAULT_PROTON_COUNT: 20 / 100 / 79
MIN/MAX/DEFAULT_NEUTRON_COUNT: 20 / 150 / 118
SPACE_NODE_WIDTH/HEIGHT: 510
SPACE_BUFFER: 10
BEAM_SIZE: 40×110
PANEL_MIN/MAX_WIDTH: 230 / 250
TARGET_SPACE_MARGIN: 50
DEFLECTION_WIDTH (atom space): 30
```

Colors: see `RSColors.ts` (black background default profile).

Scale strings:

- Atomic (Rutherford atom scene): `6.0 × 10⁻¹⁰ m (atomic scale)`
- Nuclear: `1.5 × 10⁻¹³ m (nuclear scale)`
- Plum Pudding: `3.0 × 10⁻¹⁰ m (atomic scale)`

---

## 11. Coordinate Systems

```
Model space (square ±127.5)
        ↓ ModelViewTransform2 inverted-Y rectangle mapping
View spaceNodeBounds (~510×510, eroded by SPACE_BUFFER=10 for clip)
        ↓ Flutter layout (prefer PhET layoutBounds ~1024×618)
Device viewport
```

Gun fires at `y = bounds.minY` with random `x ∈ ±width/2`, corrected away from nuclei.

Atom (Atomic Scale) positions (atomWidth = bounds.width/2):

```
(-half, +half), (+half, +half), (0, -half), (-atomWidth, -half), (+atomWidth, -half)
each with DEFLECTION_WIDTH = 30
```

Nuclear Scale: single atom at (0,0) with boundingWidth = bounds.width.

---

## 12. Animation Lifecycle

```
Ticker / Sim step
 → RSBaseModel.step(dt)
   → Gun.step (maybe spawn)
   → AtomSpace.moveParticles
        → transitionParticlesToAtoms / ToSpace
        → empty-space straight update OR RutherfordAtom.moveParticle
   → cull out-of-bounds
 → stepEmitter → Canvas invalidatePaint
 → draw particles + optional traces
```

**No per-particle AnimationController.** Single simulation clock.

Traces: full `positions` history while particle alive; removed with particle; Atomic style fades last 80 segments; Nuclear style single path stroke.

---

## 13. Testable Behaviors

| ID | Behavior |
|---|---|
| T1 | Initial: gun OFF, energy 80, protons 79, neutrons 118, running true, traces false, scene atom |
| T2 | Gun ON emits ≤ ~20 particles across space width/speed |
| T3 | Gun OFF: no new spawn; existing keep moving |
| T4 | Rutherford near nucleus: trajectory bends; D scales with p and 1/s0² |
| T5 | Plum Pudding: orientation π/2 straight lines only |
| T6 | Energy change clears particles; new speed = energy |
| T7 | Proton change clears particles; scattering D changes |
| T8 | Neutron change clears particles; physics D unchanged |
| T9 | Traces toggle view-only; motion continues |
| T10 | Scene switch clears particles; toggles visible space |
| T11 | Pause: no gun/move/cull; Step advances 1/60 |
| T12 | Reset restores all defaults |
| T13 | Out-of-bounds particles removed (no leak) |
| T14 | Algorithm failure path removes particle safely |

---

## Flutter Port Plan (post Phase 0)

```
lib/rutherford_scattering/
  rs_constants.dart / rs_colors.dart / rs_assets.dart / rs_strings.dart
  model/
    alpha_particle.dart
    gun.dart
    atom.dart / atom_space.dart
    rs_base_model.dart
    rutherford_atom.dart / rutherford_atom_space.dart / rutherford_nucleus_space.dart
    rutherford_atom_model.dart
    plum_pudding_atom_space.dart / plum_pudding_atom_model.dart
  screens/
    rutherford_scattering_home.dart  (2 tabs / screens)
    rutherford_atom_screen.dart
    plum_pudding_atom_screen.dart
  painters/ widgets/ transform/
assets/simulations/rutherford_scattering/   ← copy PhET images
test/rutherford_scattering/
requirements/req-rutherford-scattering/     ← this + phase reports
```

Home registration: Chemistry → 原子核 group in `home_screen.dart` (append only).

---

## Phase Gate

**Phase 0 COMPLETE** — proceed to Phase 1 Model (physics-faithful, Widget-free).
