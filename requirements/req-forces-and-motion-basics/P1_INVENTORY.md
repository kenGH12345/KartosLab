# CURRENT P1 INVENTORY — Visual QA Phase

Updated: 2026-09-24  
Source of truth: `FINAL_MIGRATION_REPORT.md` + gold screenshots + code review  
Model: **FROZEN** (no physics changes this phase)

## CURRENT P1 INVENTORY

### P1-01
**Net Force / all screens: no signed-off Flutter screenshots vs PhET gold**
Pixel Visual QA never completed; cannot claim Visual PASS without actual captures.

### P1-02
**Net Force: puller / cart / rope scale & placement vs gold**
Toolbox figures may be wrong size/facing; Go/Return chrome (fill, border, Return color) may not match PhET; Reset All position under panel.

### P1-03
**Motion / Friction / Acceleration: Object stack geometry**
Stack uses approximate fixed heights, not image intrinsic bounds → floating / gap / overlap risk.

### P1-04
**Motion×3: Pusher applied-force interaction incomplete for Visual**
Applied force mainly via slider; PhET pusher lean frames + contact offset must match gold when force ≠ 0 (drag-to-force is interaction; lean frames are Visual).

### P1-05
**Acceleration: Bucket of Water visual**
Bucket asset present; slosh / water surface response to acceleration not ported — fails Acceleration gold when moving.

### P1-06
**Friction / Acceleration: surface & force-arrow chrome**
Brick/gravel surface, friction arrow placement, control panel density vs gold not verified.

### P1-07 *(downgraded candidate → keep as P1 until verified)*
**SVG CSS-inlined via BaSvgPicture** — previously open; need screenshot proof that fridge/crate/cart colors match gold (not black silhouettes).

---

## Deferred to P2 (not blocking this Visual pass if gold screenshots don't require them)

- Puller purple/orange preference (gold shots are blue/red)
- Keyboard a11y
- Region cultures beyond `usa`
- Ice at μ=0
- Checkbox Material speed icon vs mini gauge
- Legacy unused `netforce_screen.dart` / `motion_screen.dart` stubs

---

## Per-screen Visual QA order

1. Net Force → fix → screenshot → PASS  
2. Motion → …  
3. Friction → …  
4. Acceleration → …  
