# NUMERICAL_MODEL — Quantum Measurement 1.0.4

> PHASE 1 · Source-traced mathematics (not screenshot guesses)  
> Primary sources: `doc/model.md`, `CoinSet.ts`, `PolarizingBeamSplitter.ts`, `SternGerlach.ts`, `ComplexBlochSphere.ts`, `BlochSphereModel.ts`

---

## 0. Shared conventions

| Symbol | Meaning |
|---|---|
| Bias / P(up) | Probability of first valid outcome |
| `seed ∈ (0,1)` | Generates measurement vector; `0`/`1` force all outcomes to index 0/1 |
| Pure Bloch state | Unit vector `r̂` with `|r|=1` (source has no mixed states) |

Layout design space (for later): **1024 × 618**. Not used in this phase.

---

## 1. Coins

### 1.1 State variables

Per `CoinsExperimentSceneModel` (two instances: Classical + Quantum):

| Variable | Classical | Quantum |
|---|---|---|
| `systemType` | CLASSICAL | QUANTUM |
| `preparingExperiment` | prep vs measure area | same |
| `initialCoinState` | `heads` \| `tails` | `up` \| `down` \| `superposition` |
| `upProbability` ∈ [0,1] | P(heads) | P(up) ≡ \|α\|² style bias |
| `downProbability` | `1 - up` | `1 - up` ≡ \|β\|² |
| `singleCoin` / `coinSet` | CoinSet instances | same |
| `numberOfCoins` | ∈ {10,100,10000} | same |
| `measurementState` | see §1.3 | see §1.3 |
| `measuredValues[]` | heads/tails | up/down only |
| `seed` | RNG seed property | same |
| `initiallyHidden` | preference-driven | always true |

**There is no separate complex α,β storage for Coins.** Source uses a single real bias `upProbabilityProperty`. Superposition is encoded as bias ∉ {0,1} plus `initialCoinState = 'superposition'`. Visual opacity uses bias. This matches PhET Coins (not a full qubit amplitude with phase).

### 1.2 Equations

```
P(up)   = upProbability
P(down) = 1 - upProbability
P(up) + P(down) = 1
```

Sampling (per coin i):

```
u ~ Uniform(0,1) from Random(seed)
measuredValues[i] = validValues[ u < bias ? 0 : 1 ]
```

Classical validValues = `[heads, tails]`  
Quantum validValues = `[up, down]` (superposition never a measurement result)

### 1.3 State machine (`ExperimentMeasurementState`)

```
preparingToBeMeasured  --(timeout 1s / prepareNow)-->
    Classical → measuredAndHidden  (+ sampled values)
    Quantum   → readyToBeMeasured  (NO sample yet)

readyToBeMeasured --(reveal/observe)--> revealed  (+ sample now for quantum)

measuredAndHidden --(reveal)--> revealed
revealed --(hide)--> measuredAndHidden
```

### 1.4 Control → transition map

| UI (Classical) | UI (Quantum) | Model |
|---|---|---|
| Reveal / Hide | Observe / Hide | `reveal()` / `hide()` |
| Flip | Reprepare | `prepare()` → after 1s `prepareNow()` |
| Flip and Reveal | Reprepare and Observe | `prepare(revealWhenPrepared=true)` |

**Critical:** Quantum `prepareNow` does **not** sample. Sampling happens on `reveal` when state was `readyToBeMeasured`.

### 1.5 Multiple coins / 10000

- Quantities: `[10, 100, 10000]`, default **100**
- Model: one `measuredValues` array length ≤ 10000; only first `numberOfCoins` active
- View (later): 10000 uses **canvas pixel** representation (`CoinSetPixelRepresentation`), not 10000 Scenery nodes — aggregate state already in model

### 1.6 Time

- Preparation animation duration: `MEASUREMENT_PREPARATION_TIME = 1` second
- No continuous clock on Coins screen beyond this timeout / view animation

### 1.7 Reset

Scene reset: preparing=true, initial state heads/up, bias=0.5, coin reset.  
Screen reset: both scenes + mode→CLASSICAL.

### 1.8 Audio events (semantics only)

- Start Measurement → `collect_mp3`
- Erase / clear histogram → shared `erase`
- (View phase)

---

## 2. Photons

### 2.1 State variables

| Variable | Notes |
|---|---|
| `experimentMode` | SINGLE_PHOTON \| MANY_PHOTONS |
| Per scene: laser polarization preset | vertical, horizontal, fortyFiveDegrees, unpolarized, custom |
| `customPolarizationAngle` | degrees [0, 90] |
| `photonBehaviorMode` | CLASSICAL \| QUANTUM |
| Detector counts / rates | V and H |
| `isPlaying`, `timeSpeed` | NORMAL \| SLOW |
| Photon collection | spatial motion (full sim); PHASE 1 abstracts emit→PBS→detect |

### 2.2 Polarization angles (Laser)

| Preset | Angle (°) |
|---|---|
| horizontal | 0 |
| vertical | 90 |
| fortyFiveDegrees | 45 |
| custom | custom property |
| unpolarized | random ∈ [0,360) per photon |

### 2.3 Malus law at PBS (`PolarizingBeamSplitter.ts`)

```
θ = polarizationAngle in radians
P(reflect) = 1 - cos²(θ) = sin²(θ)   → Vertical detector path
P(transmit) = cos²(θ)                 → Horizontal detector path
```

### 2.4 Classical vs Quantum

| Mode | At PBS |
|---|---|
| Classical | Sample once: reflect OR transmit |
| Quantum | SPLIT into both paths with weights; collapse at detector |

Expectation value (normalized ∈ [-1,1]):

| Preset | Value |
|---|---|
| vertical | +1 |
| horizontal | −1 |
| 45° | 0 |
| unpolarized | null |
| custom | `1 - 2 cos²(θ)` |

Outcome metric: `(N_V - N_H) / (N_V + N_H)` (or rates in many-photon mode).

### 2.5 Time

- `step(dt)` moves photons; emission rate for many-photons up to 200/s
- Pause / Slow / Normal from scenery-phet `TimeSpeed`
- Single-photon: polarization change clears counts + photons

### 2.6 Reset

Laser presets, clear photons, reset detectors, playing=true, speed=NORMAL, behavior=CLASSICAL.

---

## 3. Spin

### 3.1 State representation

Preparation spin as **XZ unit vector** (not full 3D Bloch for SG math):

| Direction | Vector (x,z) |
|---|---|
| +Z | (0, 1) |
| −Z | (0, −1) |
| +X | (1, 0) |
| (null / −X after SGx down) | (−1, 0) |

Custom: `α²` slider → `θ = π(1−α²)`, vector `(sin θ, cos θ)`.

`α² + β² = 1` with `β² = 1 − α²`. `α²` = P(up) for SGz on prepared state.

### 3.2 Stern-Gerlach measurement

```
measurementVector = isZOriented ? (0,1) : (1,0)
P(up) = (incoming · measurement + 1) / 2
isUp = random() < P(up)
```

Outgoing state: ± eigenstate of SG axis.

### 3.3 Experiments (`SpinExperiment.ts`)

| Exp | Chain |
|---|---|
| 1 | [SGz] |
| 2 | [SGx] |
| 3 | [SGz, SGx, SGx] |
| 4 | [SGz, SGz, SGz] |
| 5 | [SGx, SGz, SGz] |
| 6 | [SGx, SGx, SGx] |
| Custom | [SGx, SGz, SGz] default; orientations controllable |

Stages: 0 source→SG0; 1 SG0→SG1/SG2; 2 exit.

### 3.4 Block Up / Down

On SG0 in multi-apparatus continuous mode: wall on top or bottom exit **removes that path** (particles stop). Does not rewrite probabilities of SG; changes which particles continue. Default remembered mode often `BLOCK_UP`.

### 3.5 Single vs Continuous

| Mode | Collection |
|---|---|
| Single | up to 50 particles, manual fire |
| Continuous | stream up to 1250, clock-driven emission |

Not “fast single loop” only — continuous uses rate emission + canvas many-particles view.

### 3.6 Reset

Experiment→1, α²→1, +Z, single mode, clear counts, SG orientations from experiment 1.

---

## 4. Bloch Sphere

### 4.1 State

Angles on pure-state Bloch sphere:

```
θ ∈ [0, π]   polar from +Z
φ ∈ [0, 2π)  azimuthal from +X in XY
```

Cartesian:

```
x = sinθ cosφ
y = sinθ sinφ
z = cosθ
|r| = 1  (pure states only)
```

Z-basis amplitudes:

```
|ψ⟩ = cos(θ/2)|↑_z⟩ + e^{iφ} sin(θ/2)|↓_z⟩
P(↑) = cos²(θ/2),  P(↓) = sin²(θ/2)
```

Presets: ±X ±Y ±Z + Custom (sliders).

### 4.2 Measurement

Along axis `n̂` (X/Y/Z):

```
dot = n̂ · r̂
isUp = (2U − 1) < dot     // U~Uniform(0,1)
⇒ P(up) = (1 + dot) / 2
```

Collapse: state → ± eigenstate of measurement axis. Counts ++.

Modes: ×1 (one sphere) or ×10 (ten independent spheres).

Measurement state machine:

```
PREPARED --initiateObservation-->
  if B-field: TIMING_OBSERVATION --(delay)--> OBSERVED
  else: OBSERVED immediately
Reprepare → copy prep angles → PREPARED
```

### 4.3 Magnetic field

```
MAX_PRECESSION_RATE = π/2 rad/s
dφ/dt = rotatingSpeed * MAX_PRECESSION_RATE
rotatingSpeed = magneticFieldStrength ∈ [-1,1] only while TIMING_OBSERVATION && B enabled
```

Precession about **Z**. Erase clears counts; Reset All resets everything.

### 4.4 Time

`step(dt)` advances precession; timing observation uses `MODEL_TO_VIEW_TIME` scaled elapsed vs `measurementDelay`.

---

## 5. Cross-screen isolation

Four independent top-level models (`CoinsModel`, `PhotonsModel`, `SpinModel`, `BlochSphereModel`). Shared utilities (RNG interface, Bloch math helpers) must not share mutable experiment state.

---

## 6. Flutter package map

| Screen | Dart entry |
|---|---|
| Coins | `lib/quantum_measurement/coins/model/coins_model.dart` |
| Photons | `lib/quantum_measurement/photons/model/photons_model.dart` |
| Spin | `lib/quantum_measurement/spin/model/spin_model.dart` |
| Bloch | `lib/quantum_measurement/bloch_sphere/model/bloch_sphere_model.dart` |
| RNG | `lib/quantum_measurement/common/qm_random.dart` |
