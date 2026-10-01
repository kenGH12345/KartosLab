# LAYOUT_RISK_REGISTER

| ID | Risk | Severity | Evidence | Impact on Composer |
|---|---|---|---|---|
| R1 | 1024×618 root mismatch | P0 if wrong | joist HIGH | Breaks all anchors |
| R2 | Coins Classical/Quantum as side-by-side | P0 | Source: two scenes visibility | Wrong structure |
| R3 | Wrong Coins divider ratios | P1 | 0.38 / 0.2 HIGH | Prep/measure squeeze |
| R4 | Photons absolute offsets without MVT | P0 | scale 640 HIGH | Trajectory wrong |
| R5 | Spin Exp 1–6 as 7 layouts | P1 | shared nodes HIGH | Maintainability / drift |
| R6 | Bloch invented 3D projection | P0/P1 | Must port BlochSphereNode | Visual fail |
| R7 | 10k as Widgets | P0 perf | Canvas HIGH | Must use painter |
| R8 | Photon trajectory wrong path lengths | P1 | model distances HIGH | Timing/opacity |
| R9 | Asset intrinsic ignore | P1 | SVG/PNG | Scale/crop errors |
| R10 | Font baseline drift | P2 | PhetFont vs Flutter | Tiny shifts |
| R11 | QCT layout reused as QM Coins | P1 | QCT ≠ QM chrome | Forbidden |
| R12 | Overlay parent wrong (ComboBox) | P1 | parentNode=ScreenView | Clipped menus |
| R13 | Responsive Flex reflow vs scale | P1 | ScreenView matrix | Distorts design |
| R14 | Magic-number drift (+12/−8) | P1 process | Spec forbids | Breaks determinism |
| R15 | BlochMeasurementArea XY | RESOLVED (PHASE 6) | HIGH root+relations; Observe absolute = CONTENT_DRIVEN | Composer uses relations, not invented pixel XY |
| R16 | sceneTranslation Y content-driven | P2 | radio height | Small vertical shift |

**P0 open:** 0 (documented)  
**Critical P1 open for Composer:** R15 (complete MeasurementArea scan at implementation start)
