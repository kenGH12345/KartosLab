# PHOTON_TRAJECTORY_SPEC_PHASE4

## Units

All path geometry is in **meters** (model space). View conversion:

```
x_v = origin.x + x_m * 640
y_v = origin.y - y_m * 640
```

## Waypoints (meters)

| Point | Coordinates | Role |
| --- | --- | --- |
| Laser | (−0.15, 0) | emission |
| PBS | (0, 0) | measure / split |
| Mirror | (0.11, 0) | reflect downward |
| Vertical detector | (0, 0.20) | absorb vertical |
| Horizontal detector | (0.11, −0.09) | absorb horizontal |

## Segments

| Segment | Physics | Classical | Quantum |
| --- | --- | --- | --- |
| Laser → PBS | RIGHT @ 0.3 m/s | always | always |
| PBS → Vertical | UP | if reflect (Malus) | always as state A |
| PBS → Mirror | RIGHT | if transmit | always as state B |
| Mirror → Horizontal | DOWN | after transmit | after split RIGHT |

## Speed / timing

| Constant | Value | Source |
| --- | --- | --- |
| PHOTON_SPEED | 0.3 m/s | Photon.ts |
| Slow scale | 0.4 | TimeSpeed.SLOW |
| Step forward button | 2/60 s | PhotonsExperimentSceneView |

## Branch selection

- **Classical:** at PBS surface, `nextDouble() ≤ sin²(θ)` → UP; else continue RIGHT (no split states).
- **Quantum:** always SPLIT into UP (pReflect) + RIGHT (1−pReflect); collapse at detector by probability.

## Implementation

`PhotonTrajectorySpec` documents waypoints; live motion is Euler step of `PhotonMotionState` with interaction tests (PBS / Mirror / Detector) matching `PhotonsExperimentSceneModel.stepForwardInTime`.
