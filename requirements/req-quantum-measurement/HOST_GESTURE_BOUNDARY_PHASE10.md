# HOST_GESTURE_BOUNDARY_PHASE10

## Host gestures (Home / Shell)

| Gesture | Where | Conflict with QM? |
|---|---|---|
| Vertical scroll | Home `SingleChildScrollView` | No — only on Home route |
| Card tap | `_SimCard` InkWell | No — opens route |
| AppBar Back | `KratosTabbedScreen` AppBar | Exits Simulation |
| System Back | Navigator pop | Exits Simulation |
| Tab bar tap | QM internal `TabBar` | Simulation-internal only |
| PageView swipe on Home | **None** | N/A |
| Dismissible route | **None** | N/A |

## Simulation gestures (QM runtime)

| Gesture | Screen | Notes |
|---|---|---|
| Slider drag | Coins / Photons / Bloch | Inside design frame |
| Button / chip tap | all | |
| Dropdown / menu | Spin / Bloch | |
| Source fire InkWell | Photons / Spin | |

## Priority / interception

```text
Home route active
  → Host scroll + card taps

QM route active
  → Simulation gestures inside body
  → TabBar switches screens (TickerMode only on active tab)
  → AppBar / system Back → pop route (Host Exit)
```

`KratosTabSwitcher` uses `NeverScrollableScrollPhysics`-equivalent behavior (tap tabs only; no swipe between screens) via TabBar + disabled inactive `IgnorePointer`.

## Verdict

| Claim | Status |
|---|---|
| No Host PageView vs QM drag conflict observed | **PASS** (Home has no PageView) |
| Gesture isolation fully VERIFIED for all future shells | **NOT FULLY VERIFIED** — only current Home + QM |
| Back exits Simulation (not tab stack) | **PASS** |
