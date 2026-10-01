# PHASE 3 — Real Molecules Screen Report

## Status

```text
Real Molecules Screen: PASS
Overall: READY CANDIDATE
(not READY — Phase 4 Final Visual QA + Home Integration still open)
```

## Delivery

| Item | Path |
|---|---|
| Screen | `lib/molecule_shapes/view/real_molecules_screen.dart` |
| Shared painter (element colors + outer LPs) | `molecule_painter.dart` |
| Formula subscript / element colors | `element_colors.dart` |
| Model (unchanged semantics) | `RealMoleculesModel` |
| Source map | `PHASE_3_REAL_VIEW_SOURCE_MAP.md` |
| Matrix | `REAL_MOLECULE_MATRIX.md` (Phase 0, still authoritative) |

## Behavior

- 13 molecules in `TAB_2` order; start **H2O** + **Real**
- Real / Model radios rebuild molecule; **selected shape unchanged**
- H2O Real **104.5°** / Model **109.5°** (regression test)
- ComboBox formulas use subscripts (`H₂O`)
- Options: Show Lone Pairs, Show Bond Angles, Show Outer Lone Pairs (preference; reset does not clear preference)
- Name panel: geometry **labels** only
- Background drag rotates quaternion; **local coordinates unchanged**
- No bonding edit controls (source has none)
- Separate instance from Model Screen — no shared molecule state
- Shared `MoleculeCamera` + depth-sorted `MoleculePainter`

## Tests / Analyze

```text
flutter test test/molecule_shapes/
42 tests, All tests passed  (was 29; Phase 1–2 still green)

dart analyze lib/molecule_shapes test/molecule_shapes
No issues found
```

## P0 / P1 / P2

| Level | Count | Notes |
|---|---|---|
| P0 | 0 | Launch, select, Real/Model, rotate, reset |
| P1 | 0 | Data order, angles, geometries, independence |
| P2 / VERSION_DELTA | inherited | Lone-pair shell approximate; Model bonding thumbnails 2D; Real↔Model toggle does not run source’s Attractor orientation match (angles/coords correct; view may jump) |

## Not done

- Phase 4 full visual QA matrix with screenshots
- Home integration / lifecycle
- Balloon OBJ lone-pair mesh

## Absolute rules kept

- No Home
- No other simulation edits
- No Phase 1 VSEPR semantic changes
- Real angles not overwritten by ideal
