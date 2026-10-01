# RESET_SEMANTICS — Quantum Measurement

> PHASE 1 · Do not conflate Reset / Erase / Reprepare / New Coin / Hide

## Coins

| Action | Affects | Does NOT |
|---|---|---|
| **Reset All** (screen) | Both scenes + mode→Classical; bias 0.5; initial heads/up; coin measurement states | — |
| **New Coin** (`preparingExperiment=true`) | Re-enter prep; `prepareNow` on coins; classical may auto-reveal | Does not reset bias / numberOfCoins unless also Reset |
| **Start Measurement** | Leave prep; set immediate measurement values from initial state | Does not change bias |
| **Hide** | `revealed` → `measuredAndHidden` | Does not re-sample |
| **Reveal / Observe** | Show values; quantum samples if was `readyToBeMeasured` | Does not change bias |
| **Flip / Reprepare** | Enter preparing→prepareNow; classical samples+hides; quantum → ready (no sample) | Not full screen reset |
| **Flip and Reveal / Reprepare and Observe** | prepare then reveal | Not Reset All |
| Histogram erase (view) | Clear display counts if present | Not coin state |

## Photons

| Action | Affects | Does NOT |
|---|---|---|
| **Reset All** | Both scenes: polarization default 45°, classical behavior, clear photons/counts, playing, speed | — |
| Polarization change (single mode) | Clear counts + photons | Does not reset behavior mode |
| Behavior Classical↔Quantum | Clear photon collection | Does not reset polarization |
| Pause | Stops stepping | Does not clear counts |

## Spin

| Action | Affects | Does NOT |
|---|---|---|
| **Reset All** | Exp1, α²=1, +Z, single mode, SG orientations, counts | — |
| Change experiment | Apply SG chain; reset counts; restore blocker map | May not reset α² |
| Block mode change | Path blocking; reset downstream counts | Does not reprepare spin direction alone |
| SG orientation change | `prepare()` path; reset counts | |

## Bloch Sphere

| Action | Affects | Does NOT |
|---|---|---|
| **Reset All** | Prep +X, B off, axis Z, single mode, counts 0, PREPARED | — |
| **Erase** | `up/downMeasurementCount` only | Angles, B-field, axis, mode |
| **Reprepare** | Copy prep→measurement spheres; PREPARED; time=0 | Counts (counts cleared separately on angle/B/axis change) |
| Angle / B / axis change | Often `resetCounts` + reprepare | Not full Reset All |
| **Observe** | Sample + collapse + OBSERVED | Does not clear historical counts (accumulates) |

## Preference note

Classical “start hidden” preference affects classical initial `initiallyHidden` / measurement state — separate from Reset All defaults in Flutter until preferences ported.
