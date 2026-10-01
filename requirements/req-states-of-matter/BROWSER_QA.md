# Browser QA — States of Matter

**Updated:** 2026-09-16  
**Visual:** ORIGINAL / FLUTTER / DIFF 15/15 (post–Major Geometry) · A=shell allowed  
**Behavior source:** local PhET **1.3.0-dev.3** + Flutter widget / model tests  
**Browser QA harness:** `test/states_of_matter/browser_qa_interaction_test.dart`  
**Home lifecycle:** `test/chemistry/states_of_matter/som_home_nav_test.dart`

| Action | Original | Flutter | Match | Evidence |
|---|---|---|---|---|
| States: default Neon solid | Neon lattice, ~14 K | Neon solid / atoms | YES | ORIGINAL `01` + smoke |
| Change particle Neon→Argon→O₂→Water | Radio rebuild | `setSubstance` + engines | YES | Browser QA tap Argon + engine tests |
| Solid / Liquid / Gas | Phase buttons | `setPhase` + snapshots | YES | Browser QA Liquid + ORIGINAL `01–03` |
| Heat / Cool | Heater slider | `heatingCoolingAmount` | YES | Browser QA + MPM heat test |
| Pause / Resume / Step | TimeControl | `setPlaying` / `stepOnce` | YES | Browser QA TimeControl + home nav |
| Reset All (States) | ResetAllButton | `resetAll` → Neon solid | YES | Browser QA Reset |
| Phase Changes initial | Pump/lid/diagrams | layout + model | YES | ORIGINAL `10` + geometry checklist |
| Piston / lid compress | Pointing hand drag | `targetContainerHeight` | YES | Browser QA height shrink + ORIGINAL `11` |
| Pump + molecules | Bicycle pump | `injectMoleculesFromPump(3)` | YES | Pump tap + model inject test |
| Adjustable Attraction | Radio + ε | `adjustableAtom` + epsilon | YES | ORIGINAL `12` + model |
| Interaction Neon initial | Dual atoms + hand/pin | MVT + assets | YES | ORIGINAL/FLUTTER `13` |
| Force Total + drag atom | Total + drag | `forcesDisplayMode` + drag | YES | Browser QA drag/force |
| Normal / Slow | Speed radios | `InteractionTimeSpeed` | YES | Browser QA slow |
| Interaction Reset | ResetAll | `resetAll` + hint restore | YES | Browser QA reset |
| Tab / Home open-back-reopen | Joist screens | `StatesOfMatterHome` | YES* | `som_home_nav_test` |

\* Screen chrome vs Joist = **A** (allowed). Content models Match.

## Manual checklist (re-verified 2026-09-16)

1. [x] 四档物质 / phase  
2. [x] 加热 + pause  
3. [x] Phase Changes 压盖 + pump UI  
4. [x] Interaction 拖开 + Total 力 + Slow  
5. [x] 各屏 Reset  
6. [x] Home → SoM → tabs → back → reopen  

**Browser QA = PASS**（行为 Match；像素壳层差异见 A-class；P2 chrome 未开）。
