# SPIN_ANIMATION_SPEC_PHASE5

| Event | Duration / Rate | Easing | Source Evidence | Status |
| --- | --- | --- | --- | --- |
| Particle motion | speed=1 linear | linear Euler | ParticleWithSpin.step | PASS |
| Continuous emit | particleAmount × 5 /s × dt | n/a | MultipleParticleCollection (rate intent) | PASS |
| Max concurrent | 80 pool cap | n/a | Flutter bound (source uses preallocated pool) | PASS |
| Lifetime cull | >4 s remove | n/a | MAXIMUM_PARTICLE_LIFETIME | PASS |
| Idle ticker | no setState when no particles & not continuous | n/a | lifecycle | PASS |
| Experiment switch | clear particles | n/a | SpinModel prepare/clear | PASS |
| Dispose | stop ticker | n/a | SpinAnimationController.dispose | PASS |

Architecture:

```
Ticker → SpinAnimationController → SpinParticleSimulation.step
       → SpinParticleRenderer (positions via SpinViewTransform)
```
