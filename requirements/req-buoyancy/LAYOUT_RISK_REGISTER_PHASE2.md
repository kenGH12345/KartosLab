# LAYOUT_RISK_REGISTER_PHASE2.md

| Risk | Severity | Evidence | Impact on Composer | Status |
| ---- | -------- | -------- | ------------------ | ------ |
| R1 Design bounds unknown | P0 | Found 1024×618 | — | CLOSED |
| R2 MVT unknown | P1 | THREE API known; matrix needs mobius | Approximate projection | OPEN |
| R3 Global shell mismatch | P1 | Screens differ panels | Per-screen composers | MITIGATED |
| R4 Compare object geometry | P1 | Must use MVT not pixels | Dynamic pose | OPEN Composer |
| R5 Explore dynamic object area | P1 | B visibility semantics | Keep controls | MITIGATED |
| R6 Lab force visual mapping | P1 | ×20 documented | View mapping | DOCUMENTED |
| R7 Shapes mesh geometry | P1 | Per-shape views | Use source meshes | OPEN Phase 3 |
| R8 Duck visual/physics | P1 | Documented | Separate bounds | DOCUMENTED |
| R9 Boat mesh | P1 | BoatDesign | Not cube | DOCUMENTED |
| R10 Bottle cavity | P1 | BottleView clip | Not cylinder | DOCUMENTED |
| R11 Boat cabin basin | P1 | Coupling DEFERRED | Geometry only | DEFERRED |
| R12 Waterline dynamic | P1 | fluidY | Never fixed Y | DOCUMENTED |
| R13 Texture mapping | P2 | Materials textures | Phase 3 wiring | OPEN |
| R14 Pointer conversion | P1 | ray / modelToView | Boundary contract | OPEN Composer |
| R15 Responsive scaling | P1 | Joist uniform | Shared helper OK | DOCUMENTED |
| R16 Z-order | P2 | sky→THREE→overlay→panels→popup | Per composer | DOCUMENTED |
| R17 Typography baseline | P2 | PhetFont sizes | Shared primitives | DOCUMENTED |
| R18 Material control geometry | P2 | Panel stacks | Per screen | DOCUMENTED |
| R19 Density code contamination | P0 | Must not reuse Density spring layout | Separate lib/buoyancy/layout | MITIGATED |
| P1 physics frozen | P1 | p2 APPROXIMATE; provenance | Do not “close” via layout | FROZEN OPEN |
