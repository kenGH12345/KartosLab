# VISUAL_ASSET_POLICY — Friction

## Priority
```
PhET CoverNode / Magnifier / Thermometer / AtomCanvas geometry
  → Flutter CustomPainter equivalent
  → no Material icons as substitutes
```

## Rules for this sim
1. Books: **must** use CoverNode Path geometry (`book_cover_painter.dart`). No Container+Text fake books.
2. Atoms: shaded spheres matching AtomCanvasNode (cyan top / green bottom).
3. Reset All: **only** `KratosResetAllButton` (radius 22).
4. No PNG book/atom assets exist in PhET Friction — procedural is correct, not a substitution.
5. Sounds: original mp3 files under `assets/simulations/friction/sounds/`.

## Visual QA checklist (vs provided screenshot)
- [ ] White background, 768×504 design coords
- [ ] Magnifier rounded black border (r=30, stroke=5)
- [ ] Blue top / green bottom atom regions with jagged contact
- [ ] White L/R cue arrows when hint visible
- [ ] Thermometer right side, red fluid low at cold start
- [ ] Chemistry (blue) over Physics (green) macro books
- [ ] Dashed zoom lines from target rect to magnifier
- [ ] Orange Reset All bottom-right

## Substituted Assets
**0**
