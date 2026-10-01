# SPIN_TRAJECTORY_SPEC_PHASE5

## Model coordinates (meters)

| Segment | Source Coordinates | View (×180, Y-inv) + measurement origin | Experiment Dependency | Status |
| --- | --- | --- | --- | --- |
| Source → SG0 entrance | exit (−0.2,0) → entrance(0.8,0)≈(0.4125,0) | MVT | all | PASS |
| SG0 top exit → ∞ / SG1 | topExit + HORIZONTAL_ENDPOINT or SG1 entrance | MVT | single vs multi | PASS |
| SG0 bottom → ∞ / SG2 | bottomExit → SG2 | MVT | multi | PASS |
| SG1/SG2 through + exit | entrance→exit + HORIZONTAL_ENDPOINT | MVT | multi stage 1–2 | PASS |

## Speed / lifetime

| Constant | Value |
| --- | --- |
| speed | 1 model unit / s |
| max lifetime | 4 s |
| reach threshold | 0.03 |

## Outcome → branch

Model `fireSingleParticle()` decides up/down (and counts) **before** animation path selection. Animation only interpolates along the selected branch.
