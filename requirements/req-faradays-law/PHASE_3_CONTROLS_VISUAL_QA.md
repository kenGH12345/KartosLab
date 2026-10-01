# PHASE 3 — CONTROLS VISUAL QA · Faraday's Law

对照：用户原版截图 + ControlPanelNode layout。

## Screenshot matrix (widget / state verification)

| # | Scene | Result |
|---|-------|--------|
| 1 | Initial | controls present; voltmeter/field OFF; 1 coil selected |
| 2 | Voltmeter ON | model+view sync |
| 3 | Voltmeter OFF | sync |
| 4 | Field Lines ON | sync |
| 5 | Field Lines OFF | sync |
| 6 | 1 coil | topCoilVisible false |
| 7 | 2 coil | topCoilVisible true |
| 8 | Flip NS/SN | polarity sync |
| 9 | Moved + controls | compound tests |
| 10 | Reset All | initial state |

## Gates

| | |
|--|--|
| P0 | **0** |
| P1 | **0** |
| P2 | Phase 2 (5) + control chrome subtleties below |
| Substituted | **0** |

### P2 (controls, record only)

| ID | Note |
|----|------|
| P2-C1 | Flip button bevel vs sun RectangularPushButton 3D |
| P2-C2 | Coil radio icon scale approx vs 0.21×CoilNode |
| P2-C3 | Checkbox centerY approx vs live coilRadio.centerY |

## VERSION_DELTA

| ID | Note |
|----|------|
| VD-02 | Reset clears voltage immediately (Phase 1) |
| VD-SOUND | No control / voltage sounds |
| VD-A11Y | No WASD/1-2-3 / GrabDrag keyboard |
| VD-DRAG | AABB drag limits unchanged |
