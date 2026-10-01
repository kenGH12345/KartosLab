# PHASE 5 — FINAL ASSET AUDIT

## Bitmap inventory

| Source `images/` | Flutter `assets/simulations/wave_on_a_string/` | Used By | Status |
| ---------------- | ---------------------------------------------- | ------- | ------ |
| wrench.png | wrench.png | Manual StartNode | Original |
| clamp.png | clamp.png | Fixed End | Original |
| ringBack.png | ringBack.png | Loose End | Original |
| ringFront.png | ringFront.png | Loose End | Original |
| windowBack.png | windowBack.png | No End (behind string) | Original |
| windowFront.png | windowFront.png | No End (above string) | Original |

Byte sizes match source checkout copies (Phase 2 migration).

## Source-generated (not substitution)

| Visual | Flutter |
| ------ | ------- |
| Red / cyan beads | `WoasStringPainter` circles |
| String path | polyline stroke `#F00` |
| Center dash | `WoasCenterLine` |
| Reference line | `ReferenceLinePainter` |
| Loose post | LinearGradient |
| Oscillate wheel | CustomPainter StartNode |
| NumberControl track | custom Path chrome |
| Restart glyph | Path approx of RestartUndoButton |
| Reset All | L0 `KratosResetAllButton` |

## Forbidden replacements — not used

- Material Icons for wrench / clamp / rings / windows / Reset
- Emoji / network / AI images

## Final

```text
Substituted assets = 0
```
