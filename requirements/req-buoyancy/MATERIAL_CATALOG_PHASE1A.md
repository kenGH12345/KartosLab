# Material Catalog — PHASE 1A

Source: `Material.ts` @ LOCAL SNAPSHOT `0c835c64`. Units kg/m³, Pa·s.

## Solids

| id | density | viscosity | notes |
| --- | ---: | ---: | --- |
| styrofoam | 150 | 1e-3 | SIMPLE |
| wood | 400 | 1e-3 | SIMPLE default |
| ice | 919 | 1e-3 | SIMPLE |
| pvc | 1440 | 1e-3 | SIMPLE |
| brick | 2000 | 1e-3 | SIMPLE |
| aluminum | 2700 | 1e-3 | SIMPLE |
| boatHull | 2700 | 1e-3 | name only |
| concrete | 3150 | 1e-3 | |
| copper | 8960 | 1e-3 | |
| gold | 19320 | 1e-3 | |
| platinum | 21450 | 1e-3 | |
| pyrite | 5010 | 1e-3 | |
| sand | 1442 | 0.03 | |
| silver | 10490 | 1e-3 | |
| steel | 7800 | 1e-3 | |
| tantalum | 16650 | 1e-3 | |
| diamond | 3510 | 1e-3 | mystery U |
| human | 950 | 1e-3 | mystery T |
| titanium | 4500 | 1e-3 | mystery X |
| lead | 11342 | 1e-3 | mystery W |
| materialR–Y | see OBJECT_CATALOG | | hidden |
| custom | editable | 1e-3 | range 0.8–27000 |

## Fluids

| id | density | viscosity |
| --- | ---: | ---: |
| gasoline | 680 | 6e-4 |
| oil | 920 | 0.02 |
| water | 1000 | 8.9e-4 |
| seawater | 1029 | 1.88e-3 |
| honey | 1440 | 0.03 |
| mercury | 13593 | 1.53e-3 |
| fluidA–F | 3100/790/490/2890/1260/6440 | 1e-3 |
| customFluid | 500–15000 | 1e-3 |
| air | 1.2 | 0 |

Flutter: `BuoyancyMaterial` in `lib/buoyancy/domain/material/buoyancy_material.dart`.
