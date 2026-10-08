# PHASE3_SCOPE — Fluids / Density / Buoyancy / Gases

> Source: `LOCALIZATION_INVENTORY.md` § Batch 4 + module ownership.
> Ambiguous non-fluid modules are **excluded**.

| Simulation | Domain | Included | Reason |
|---|---|---|---|
| `density` | density / fluids | **YES** | Density / material / mass–volume |
| `buoyancy` | buoyancy / fluids | **YES** | Buoyant force / fluid density / submersion (READY sim — loc only) |
| `under-pressure` | fluid pressure | **YES** | Hydrostatic pressure / atmosphere / pools |
| `gases-intro` | gases | **YES** | Ideal gas intro / hold-constant |
| `gas-properties` | gases | **YES** | Ideal / Explore / Energy / Diffusion tabs |
| `diffusion` | gases / transport | **YES** | Particle diffusion / divider / flow rate |
| `membrane-transport` | fluids-adjacent / bio-transport | **YES** | Inventory Batch 4; membrane + solutes / diffusion |
| `concentration` / `beers-law` | chemistry solution | **NO** | Chemistry batch (PHASE 7+) |
| `states-of-matter` | chemistry / phase | **NO** | Chemistry batch |
| mechanics / EM / optics / quantum | other | **NO** | Out of PHASE 3 |

### Ambiguous membership notes

| Simulation | Primary Domain | Secondary Domain | PHASE 3? |
|---|---|---|---|
| `membrane-transport` | biology / membrane | diffusion / fluids | **YES** (inventory Batch 4) |
| `diffusion` | gases / kinetic theory | transport | **YES** |
| `buoyancy` | buoyancy | density-common materials | **YES** — localization only; no physics rewrite |

**Simulation count (included): 7**
