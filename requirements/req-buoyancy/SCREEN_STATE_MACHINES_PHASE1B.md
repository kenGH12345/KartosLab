# SCREEN_STATE_MACHINES_PHASE1B

Source snapshot = LOCAL `0c835c64`.

Shared lifecycle enum: `ScreenModelLifecycle`  
`initial → idle ↔ physicsRunning ↔ dragging ↔ paused → disposed`  
(+ settling when near-equilibrium after drag — reserved)

## Compare

```
initial
  → idle (after ctor / reset)
idle
  → dragging (startDrag on visible block)
  → physicsRunning (step)
  → resetting (reset → idle)
dragging
  → idle (endDrag)
physicsRunning
  → idle
paused
  → idle (resume) | disposed
```

Mode switch (`setComparisonMode`) stays in idle; visibility swap only.

## Explore

```
initial → idle
idle ↔ physicsRunning (step)
idle → dragging → idle
idle → modeChange (ONE/TWO block visibility) → idle
idle → reset → idle
paused / disposed as shared
```

Hidden B does not participate in `world.step` force loop (`visible=false`).

## Lab

```
initial → idle
idle ↔ physicsRunning
idle → dragging → idle
idle → measurementRead (fluidDisplacedVolumeLiters derived; no separate state)
idle → forceDisplayToggle (flags only)
idle → reset → idle
```

## Shapes

```
initial → idle
idle → shapeSwitch (geometry change, bottom preserved) → idle
idle → ratioChange → idle
idle → materialChange → idle
idle → modeChange (show B) → idle
idle ↔ physicsRunning / dragging
idle → reset → idle
```

## Applications

```
initial → bottleIdle
bottleIdle ↔ physicsRunning / dragging
bottleIdle → modeBoat → boatIdle
boatIdle → basinTransfer (updateBoatBasinTransfer each step) → boatIdle
boatIdle → resetBoatAndBlockPosition → boatIdle
* → reset → bottleIdle
```

Boat basin fill/spill animation flags: `spillingFluidOutOfBoat` (boolean, not a full FSM state).
