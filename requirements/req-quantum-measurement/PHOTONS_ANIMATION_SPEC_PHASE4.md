# PHOTONS_ANIMATION_SPEC_PHASE4

| Event | Duration / Rate | Easing | Source Evidence | Status |
| --- | --- | --- | --- | --- |
| Photon translation | continuous @ 0.3 m/s | **linear** (Euler `position += dir * speed * dt`) | PhotonMotionState.step | PASS |
| Single emit | instantaneous spawn | n/a | Laser.emitAPhoton | PASS |
| Continuous emit | `rate * dt` (+ fractional accumulator) | n/a | Laser.step | PASS |
| Max rate | 200 photons/s | n/a | MAX_PHOTON_EMISSION_RATE | PASS |
| Slow motion | dt × 0.4 | n/a | TimeSpeed.SLOW | PASS |
| Step button | 2/60 s | n/a | STEP_FORWARD_TIME | PASS |
| PBS / mirror / detect | within same dt slice | piecewise linear to intersection then remainder | stepForwardInTime | PASS |
| Sprite update | every view step | n/a | PhotonSprites.update after model step | PASS |

## Architecture

```
Ticker (Flutter)
  → PhotonAnimationController
  → PhotonsSpatialSimulation.step(dt)
  → setState / onTick
  → PhotonRenderer (positions from motion states)
```

Animation does **not** sample Malus; model/simulation does.

## Lifecycle

| Action | Behavior |
| --- | --- |
| dispose Screen | `PhotonAnimationController.dispose` stops ticker |
| Reset All | clear photons, emissionRate=0, scene.reset |
| Classical↔Quantum | clear photons (source link) |
| Single↔Many | IndexedStack keeps both sims; ticker rebinds active sim |
| Leave Photons | dispose cancels ticker — no leaked emission |

## Concurrency

Source allows many simultaneous photons (especially many-photons mode). Flutter keeps `List<PhotonParticle>`; each may have 1–2 motion states (quantum split). No artificial `maxConcurrent=1`.
