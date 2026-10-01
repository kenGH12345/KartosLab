# PROVENANCE_PHASE6.md

## PROVENANCE: **VERIFIED**

| Item | Value |
|------|-------|
| Buoyancy package | `1.3.0-dev.2` (`package.json`) |
| Lockfile pin (`dependencies.json`) | `0295f8f62bff7f345185fbf11a9e42c08206e4c5` |
| Local common HEAD | `0c835c642c0603531c3b9f0844fcb8b196abe003` |
| Fetch | `git fetch origin 0295f8f6…` succeeded (object now present) |
| Commits pin→HEAD | **1** (`0c835c64 sync-to-poly: Update copyright dates…`) |
| PhysicsEngine / DensityBuoyancyModel / Boat / BoatBasin / ApplicationsModel diff | copyright year + remove `densityBuoyancyCommon.register` only — **no physics formula changes** |

## Conclusion

LOCAL HEAD is functionally equivalent to the pinned lockfile SHA for Buoyancy model/physics used by this port. SHA mismatch is **no longer OPEN P1**.

Working tree intentionally tracks LOCAL HEAD `0c835c64` with pin documented as ancestor.
