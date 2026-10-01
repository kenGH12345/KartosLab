# COMPONENT_INVENTORY_PHASE3

| Component | Source | Screen | Reusable | Renderer | Status |
| --------- | ------ | ------ | -------: | -------- | ------ |
| BuoyancyDesignFrame | ScreenView layout | all | yes | layout | PASS |
| BuoyancyCameraConfig | DensityBuoyancyScreenView | all | yes | camera | PASS |
| BuoyancyThreeTransform | THREEModelViewTransform | all | yes | adapter | PASS |
| BuoyancyScenePainter | THREE scene | all | yes | CustomPainter mesh | PASS |
| Pool / fluid surface | Pool.ts | all | yes | painter | PASS |
| CubeMassView (procedural cube) | CuboidView | Compare/Explore/Lab | yes | mesh | PASS |
| DuckSourceMesh | DuckData.ts | Shapes | no | mesh | PASS |
| BoatSourceMesh | BoatDesign.getPrimaryGeometry | Applications | no | mesh | PASS |
| BottleSourceMesh | Bottle.ts profile | Applications | no | mesh | PASS |
| Force arrows | ForceDiagramNode | Lab | yes | overlay on scene | PASS |
| KratosResetAllButton | scenery-phet ResetAll | all | yes | L0 widget | PASS |
| CompareComposer | BuoyancyCompareScreenView | Compare | no | compose | PASS |
| ExploreComposer | BuoyancyExploreScreenView | Explore | no | compose | PASS |
| LabComposer | BuoyancyLabScreenView | Lab | no | compose | PASS |
| ShapesComposer | BuoyancyShapesScreenView | Shapes | no | compose | PASS |
| ApplicationsComposer | BuoyancyApplicationsScreenView | Applications | no | compose | PASS |
| BuoyancyPointerAdapter | BackgroundEventTargetListener | all | yes | ray/plane | PASS |
| BuoyancyTextureAsset | images/*.ts | all | yes | Image.asset | PASS |
| BuoyancyPlayArea | ScreenView stack | all | yes | Widget | PASS |
| BuoyancySimHost | — | five screens | no | Widget | PASS |
