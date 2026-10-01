# MODEL_SOURCE_EVIDENCE_PHASE1B

> Source snapshot = **LOCAL** density-buoyancy-common HEAD `0c835c64`  
> PINNED lockfile SHA `0295f8f6` — PROVENANCE MISMATCH OPEN P1 (no checkout)  
> Buoyancy package: 1.3.0-dev.2

| Screen | Feature | Source File | Class | Handler / Method | Model Effect | Evidence |
| ------ | ------- | ----------- | ----- | ---------------- | ------------ | -------- |
| Compare | block sets | `common/model/BlockSet.ts` | `BlockSet` | SAME_MASS / SAME_VOLUME / SAME_DENSITY | `comparisonMode` | enum 3 values |
| Compare | defaults | `buoyancy/model/BuoyancyCompareModel.ts` | `BuoyancyCompareModel` | constructor options | sameMass=4, sameDensity=WOOD.density, cubesData volumes/masses | L28–75 |
| Compare | shared controls | `common/model/CompareBlockSetModel.ts` | `CompareBlockSetModel` | massProperty / volumeProperty / densityProperty | `setSameMass/Volume/Density` | L113–229 |
| Compare | create masses | `CompareBlockSetModel.ts` | `createMasses` | per-blockSet cubes | 6 cubes, visibility by mode | L141–211 |
| Compare | reset | `CompareBlockSetModel.ts` + `BlockSetModel.ts` | `reset` | reset props + all masses + reposition | `BuoyancyCompareModel.reset` | CBS L232–237, BSM L109–124 |
| Compare | positions | `DensityBuoyancyModel.ts` | `positionMassesLeft/Right` | pool edge placement | `_positionPair` | L413–439 |
| Explore | defaults | `BuoyancyExploreModel.ts` | constructor | A wood 2kg (−0.2,0.2); B Al 13.5kg (0.05,0.35) hidden | blockA/B | L56–80 |
| Explore | two-block | `BuoyancyExploreModel.ts` | `modeProperty` | TWO_BLOCKS → B visible | `setMode` | L43–84 |
| Explore | materials | `BuoyancyExploreModel.ts` | availableMassMaterials | SIMPLE + CUSTOM + R/S | `availableMaterials` | L48–53 |
| Explore | reset | `BuoyancyExploreModel.ts` | `reset` | mode + super | `reset()` | L108–112 |
| Lab | defaults | `BuoyancyLabModel.ts` | constructor | wood 2kg (−0.2,0.2); gravity instrumented | block | L46–55 |
| Lab | gravity | `Gravity.ts` + Lab options | `gravityProperty` | moon 1.6 / earth 9.8 / jupiter 24.8 / planetX 19.6 + custom | `setSelectedGravityPreset` | Gravity.ts L77–97 |
| Lab | fluid | `DensityBuoyancyModel` fluidSelectionType `all` | pool | fluid materials + custom density | `setFluidPreset` / `setFluidDensity` | Lab L32–34 |
| Lab | displaced vol | `BuoyancyLabModel.ts` | `fluidDisplacedVolumeProperty` | %submerged × volume × 1000 L | `fluidDisplacedVolumeLiters` | L68–79 |
| Lab | force display | `BuoyancyLabScreenView.ts` | `forcesInitiallyDisplayed: true` | view DisplayProperties | model visibility flags (values only) | View L44 |
| Lab | reset | `BuoyancyLabModel.ts` | `reset` | super + block.reset | `reset()` | L85–89 |
| Shapes | catalog | `MassShape.ts` | enumeration | block→ellipsoid→vCyl→hCyl→cone→invCone→duck | `kShapesCatalog` | L15–42 |
| Shapes | object model | `BuoyancyShapeModel.ts` | shape cache + ratios | shape switch keeps bottom | `ShapesObjectSlot` | L55–119 |
| Shapes | defaults | `BuoyancyShapesModel.ts` | objectA/B | ratios 0.25/0.75; positions (−0.225,0)/(0.075,0); B hidden | constructors | L88–97, L174–177 |
| Shapes | material | `BuoyancyShapesModel.ts` | `materialProperty` WOOD | propagates to all shapes | `setMaterial` | L65–73, L165–167 |
| Shapes | duck | `Duck.ts` | extends Ellipsoid | physics = ellipsoid | `MassShapeKind.duck` | Phase 1A |
| Shapes | reset | `BuoyancyShapesModel.ts` | `reset` | objects + mode + material + positions | `reset()` | L182–195 |
| Applications | mode | `BuoyancyApplicationsModel.ts` | `applicationModeProperty` | bottle \| boat | `setApplicationMode` | L60–64 |
| Applications | bottle | `Bottle.ts` | volume 0.01, mass 0.1, interior water 0.004 | interior → composite density | bottle APIs | L169–178, L301–302 |
| Applications | bottle tables | `Bottle.ts` | TEN_LITER_DISPLACED_* | piecewise displacement | `ApplicationDisplacementTables` | L164–165 |
| Applications | boat | `Boat.ts` + `BoatDesign.ts` | hull + basin + stepMultiplier=(V/0.001)^(1/3) | boat geometry + basin volume | boat APIs | Boat L157–195 |
| Applications | boat tables | `BoatDesign.ts` | ONE_LITER_DISPLACED_* | scaled by m²/m³ | tables extracted | static arrays |
| Applications | updateFluid | `BuoyancyApplicationsModel.ts` | override updateFluid / getPoolFluidVolume | boat basin transfer | `updateBoatBasinTransfer` STRUCTURAL | L194–285 |
| Applications | reset boat pos | `BuoyancyApplicationsModel.ts` | `resetBoatAndBlockPosition` | clear basin, reset positions | same API | L150–170 |
| Applications | reset | `BuoyancyApplicationsModel.ts` | `reset` | bottle/block/boat + mode | `reset()` | L175–188 |
