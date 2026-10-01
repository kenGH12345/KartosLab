# SPIN_SOURCE_EVIDENCE_PHASE5

| Experiment | Shared Nodes | Different Parameters | Visibility Changes | Orientation | Evidence |
| --- | --- | --- | --- | --- | --- |
| 1 | Source, SG0, MD0/1, particles | single apparatus | SG1/SG2 hidden | SG0=Z | SpinExperiment.EXPERIMENT_1; SpinModel multilink |
| 2 | same | single | SG1/SG2 hidden | SG0=X | EXPERIMENT_2 |
| 3 | Source, SG0–2, MD0–2 | multi | SG1/2 unless blocked | SG0=Z, SG1=X, SG2=X | EXPERIMENT_3 |
| 4 | same | multi | same | all Z | EXPERIMENT_4 |
| 5 | same | multi | same | SG0=X, SG1/2=Z | EXPERIMENT_5 |
| 6 | same | multi | same | all X | EXPERIMENT_6 |
| Custom | same | multi; direction controllable | same + custom radios | default X,Z,Z; user can change | CUSTOM; isDirectionControllable |

## Visibility rules (SpinModel.ts table)

| Mode | Single Particle | Continuous |
| --- | --- | --- |
| Single apparatus | MD0, SG0, MD1 | SG0 (+ histogram) |
| Multi apparatus | MD0, SG0, MD1, SG1, SG2, MD2 | SG0 blockable + SG1 if not BLOCK_UP + SG2 if not BLOCK_DOWN |

## Positions (meters, SpinModel)

| Node | Position |
| --- | --- |
| Particle source | (−0.5, 0) tip/exit offset +width/2 |
| SG0 | (0.8, 0) |
| SG1 | (2.0, 0.3) |
| SG2 | (2.0, −0.3) |

## Constants

| Name | Value | File |
| --- | --- | --- |
| MVT scale | 180 | SpinMeasurementArea |
| Divider X | 300 | SpinScreenView |
| Divider top | 70 | SpinScreenView |
| Particle speed | 1 | ParticleWithSpin |
| Max lifetime | 4 s | ParticleCollection |
| Continuous max rate | 5 /s × particleAmount | MultipleParticleCollection |
| Blocker offset | (0.1, 0) from exit | BLOCKER_OFFSET |
| Horizontal endpoint | +10 in X | HORIZONTAL_ENDPOINT |

## Assets

| Asset | Use |
| --- | --- |
| spinScreenIcon.png | Screen/Home icon (272×188) — not apparatus |
| Particles | ShadedSphereNode / canvas — programmatic |
| SG body | Rectangle + Path curves — programmatic |
