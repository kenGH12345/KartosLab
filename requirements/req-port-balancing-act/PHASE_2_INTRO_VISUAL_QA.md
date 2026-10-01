# Balancing Act — Phase 2 Intro Visual QA

> Structural visual QA vs user screenshots + PhET source.  
> **Pixel baseline: NOT AVAILABLE**

| # | Reference | Implementation | Difference | Source Evidence | Status |
|---|-----------|----------------|------------|-----------------|--------|
| 1 | Viewport aspect ~ PhET stage | Fixed 768×504 FittedBox contain | Letterboxing depends on parent | BASharedConstants.LAYOUT_BOUNDS | PASS |
| 2 | Sky gradient blue | SkyNode colors (1,172,228)→(208,236,251) | — | SkyNode.ts | PASS |
| 3 | Ground green band | GroundNode (144,199,86)→(103,162,87) | — | GroundNode.ts | PASS |
| 4 | Yellow A-frame fulcrum | Procedural Fulcrum path fill rgb(240,240,0) | Micro geometry tweak factors | Fulcrum.ts / FulcrumNode | PASS |
| 5 | Tan plank + ticks | rgb(243,203,127) + bold/normal ticks | — | PlankNode.ts | PASS |
| 6 | Grey support columns | Gradient stops from LevelSupportColumnNode | Cap/base flange simplified | LevelSupportColumnNode.ts | PASS (approx) |
| 7 | Two extinguishers + trash can | Original SVGs; labels 5 kg / 10 kg | SVG style warning harmless | BAIntroModel + images/objects | PASS |
| 8 | Show panel top-right | Show + 3 checkboxes; fill rgb(240,240,240) | Flutter Checkbox chrome | BasicBalanceScreenView | PASS |
| 9 | Position panel | None/Rulers/Marks radios | Custom radio dots | PositionIndicatorControlPanel | PASS |
| 10 | Column toggle bottom-center | AB icons + thumb; model (0,−0.5) | Icon is simplified procedural | ColumnOnOffController | PASS |
| 11 | Orange Reset All | KratosResetAllButton ×0.96 | — | ResetAllButton + L0 rule | PASS |
| 12 | Mass labels above objects | PhetFont 12 | — | ImageMassNode | PASS |

**Overall structural Intro visual: PASS** with noted approximations (column flanges, rulers). No substituted assets.
