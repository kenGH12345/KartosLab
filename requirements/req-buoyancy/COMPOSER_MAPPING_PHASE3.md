# COMPOSER_MAPPING_PHASE3

| Screen | LayoutSpec | Camera | Transform | Components | Status |
| ------ | ---------- | ------ | --------- | ---------- | ------ |
| Compare | BuoyancyCompareLayoutSpec | BuoyancyCameraConfig.compare | BuoyancyThreeTransform | cubes A/B, pool, fluid, mode radios, slider, ResetAll | PASS |
| Explore | BuoyancyExploreLayoutSpec | buoyancyDefault | same | A (+B if visible), material dropdown, mode radios | PASS |
| Lab | BuoyancyLabLayoutSpec | buoyancyDefault | same | block, forces, gravity radios, V_disp readout | PASS |
| Shapes | BuoyancyShapesLayoutSpec | buoyancyDefault | same | catalog chips, object A/B, duck mesh | PASS |
| Applications | BuoyancyApplicationsLayoutSpec | buoyancyDefault | same | bottle/boat/brick, icons, interior slider; cabin DEFERRED | PARTIAL |
