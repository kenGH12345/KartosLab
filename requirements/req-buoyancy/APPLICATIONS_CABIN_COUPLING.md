# APPLICATIONS_CABIN_COUPLING.md

## Answers (source)

| # | Question | Answer |
|---|----------|--------|
| A | cabin basin 是否随船运动？ | **YES** — `Boat.updateStepInformation` sets `basin.stepTop/Bottom` from boat matrix + `stepMultiplier` |
| B | cabin 内水体是否独立？ | **YES** — `BoatBasin.fluidVolumeProperty` separate from pool; transfer via `getPoolFluidVolume` |
| C | 船体浸没是否影响 cabin fluid？ | **YES** — spill when boat top high above pool; fill animation when partially filled; fully submerged special submerged volume |
| D | cabin waterline 是否动态？ | **YES** — `Basin.computeY` root-find |
| E | piecewise fluid update？ | **YES** — `ONE_LITER_INTERNAL_AREAS/VOLUMES` |
| F | 哪些状态变化？ | empty↔fill↔full spill; scene leave pours cabin→pool; reset clears |

## Mapping

| SOURCE_FACT | MODEL_STATE | VISUAL_STATE | FLUID_STATE |
|-------------|-------------|--------------|-------------|
| `Boat.basin` | `BoatBasin` on `BuoyancyApplicationsModel` | cabin plane from `cabinFluidY` | `boatBasin.fluidVolume` / `fluidY` |
| `pool.childBasin = boat.basin` | transfer in `_updateFluidCoupling` before forces | pool waterline from `pool.fluidY` | volumes conserved on transfer |
| `getPoolFluidVolume` fill/spill | same thresholds 0.3 / 0.9 / 0.01 | Painter draws cabin after pool | spill drains cabin→pool |
| `containedMassProperty` | `boat.containedMass = ρ * cabinV` | mass affects gravity | — |
| `isMassInside` | Y+X proximity stand-in (no kite Shape) | block buoyed by cabin fluid when inside | `basinContextFor` |

## Status

**Cabin Basin: RESOLVED**

Not painter-only. Chain: Boat pose → basin extents → transfer → `computeY` → Composer `cabinFluidY` → Painter.
