# DEFAULT_STATE_SPEC_PHASE1B

Source snapshot = LOCAL `0c835c64`. Values from Model constructors / optionize defaults — not screenshots.

| Screen | Object | Material | Mass (kg) | Volume (m³) | Fluid | Gravity | Initial Position (m) | Visibility / Notes |
| ------ | ------ | -------- | --------: | ----------: | ----- | ------: | -------------------- | ------------------ |
| Compare | blockA (SAME_MASS) | brick (ρ=2000) | 4 | 0.002 | water | 9.8 | left of pool, y=halfH | visible (default mode) |
| Compare | blockB (SAME_MASS) | wood (ρ=400) | 4 | 0.01 | water | 9.8 | right of pool, y=halfH | visible |
| Compare | SAME_VOLUME A/B | brick / wood | 10 / 2 | 0.005 / 0.005 | water | 9.8 | left / right | hidden until mode |
| Compare | SAME_DENSITY A/B | wood / wood | 2 / 4 | 0.005 / 0.01 | water | 9.8 | left / right | hidden until mode |
| Compare | controls | — | sameMass=4; sameVolume=0.005; sameDensity=400 | — | — | — | — | ranges [1,10], [0.001,0.01], [100,3000] |
| Explore | blockA | wood | 2 | 2/400 | water | 9.8 | (−0.2, 0.2) | visible; ONE_BLOCK |
| Explore | blockB | aluminum | 13.5 | 13.5/2700 | water | 9.8 | (0.05, 0.35) | hidden |
| Lab | block | wood | 2 | 2/400 | water | 9.8 | (−0.2, 0.2) | visible; force flags true |
| Shapes | objectA | wood | dens×vol | ratios 0.25×0.75 block | water | 9.8 | (−0.225, 0) center | visible; ONE_BLOCK |
| Shapes | objectB | wood | dens×vol | ratios 0.25×0.75 block | water | 9.8 | (0.075, 0) | hidden |
| Applications | bottle | composite | (0.1+1000×0.004)/0.01 dens | 0.01 | water | 9.8 | (0, 0) | visible; interior water 0.004 |
| Applications | boat | boatHull | dens×hullVol | hull≈0.001111; displace max 0.01 | water | 9.8 | (0.08, −0.1) | hidden; basin 0 |
| Applications | block | brick | dens×0.001 | 0.001 | water | 9.8 | (−0.5, 0.3) | hidden until boat mode |

## Default-state reference snapshots (for later Layout/Visual)

- Compare: `comparisonMode=sameMass`, both visible, masses 4 kg, densities 2000 vs 400
- Explore: ONE_BLOCK, A wood 2 kg at (−0.2,0.2)
- Lab: wood 2 kg, earth, water, forces visible flags true
- Shapes: A block ratios 0.25/0.75 wood at (−0.225,0)
- Applications: bottle mode, interior 0.004 m³ water
