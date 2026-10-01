# PHASE 0 — SCREENSHOT AUDIT · Wave on a String

> Evidence: user-provided official initial-state screenshot (Manual / Fixed End).  
> Screenshots are **visual evidence only** — Model facts come from source.

## Play Area

| Region | Observation | Source cross-check |
| ------ | ----------- | ------------------ |
| Viewport | Pale yellow full playfield | `backgroundColor` `#FFFFB7` |
| String region | Horizontal mid-height bead chain, straight | y*=0 initial |
| Equilibrium / center line | Horizontal dashed brown line through beads | `centerLine` always visible (not checkbox) |
| Beads | Many small **red** beads; larger **light-blue** every ~10th | reference bead i%10==0; bead0 larger |
| Left endpoint | Wrench gray head, red/black handle; leftmost cyan bead in jaws | `wrench.png` + `WrenchNode` |
| Manual affordance | Two **blue** vertical arrows on wrench | `ArrowNode` + `wrenchArrowsVisibleProperty` default true |
| Right endpoint | Black C-clamp, silver screw; rightmost cyan bead clamped | `clamp.png` Fixed End |
| Oscillator | Not shown (Manual selected) | StartNode mode visibility |
| Ruler | Not visible | `rulersVisibleProperty` false |
| Timer / stopwatch | Not visible | stopwatch hidden |
| Reference line (draggable) | Not visible as separate tool | checkbox off; **center dashed ≠ reference line** |
| Help/status | No floating help overlay in frame | a11y is PDOM, not this frame |

## Control Area

| Control | Screenshot | Source |
| ------- | ---------- | ------ |
| Mode panel (top-left) | Light-green; Manual selected; Oscillate; Pulse | `modePanel` + `WOASMode` **Pulse present** |
| End panel (top-right) | Fixed End selected; Loose; No End | `endTypePanel` |
| Bottom-right panel | Damping **20%**, Tension **80%**; checkboxes Rulers/Stopwatch/Reference Line unchecked | Manual mode shows only damping+tension; UI percent mapping |
| Reset All | Large orange circular arrow bottom-right | `ResetAllButton` |
| Restart | Small blue circular counterclockwise near bottom-center-left | `RestartButton` |
| Play/Pause | Large blue circle with **Pause** bars | `isPlaying=true` default |
| Step | Smaller gray step beside play | `TimeControlNode` |
| Speed | Normal selected; Slow available | `TimeSpeed.NORMAL` |

## Typography

| Item | Screenshot note | Source |
| ---- | --------------- | ------ |
| Panel labels | Sans-serif, readable mid size | `NORMAL_FONT` / `HEADER_FONT` PhetFont 16 / bold 16 |
| Units | Damping/Tension as **%** | RangedDynamicProperty ×100, `percentUnit` |
| Amplitude/Frequency | Not visible in Manual | hidden in Manual controlBox |

## Rendering

| Item | Screenshot | Source |
| ---- | ---------- | ------ |
| Bead size | Small red; larger cyan markers | radius ≈ half gap in view; ref beads same radius different fill; [0]×1.2 |
| Bead spacing | Uniform along string | `MODEL_UNITS_PER_GAP=10` × scale 1.25 |
| Line thickness | Thin red connector visible between beads | `stringPath` stroke |
| Colors | Yellow bg; green panels; red string/beads; cyan markers | `WOASColors` |
| Shadows/bevel | Soft 3D on clamp/wrench PNGs | bitmap assets |
| Gradients | Panel flat green; posts not prominent in Fixed | postGradient for Loose |
| Clipping | None obvious at Fixed | No End uses window sandwich |
| Z-order | Wrench above string; clamp at right end; panels on top corners; bottom controls above bg | matches `children` order |

## VERSION_DELTA (screenshot vs source)

| Item | Result |
| ---- | ------ |
| Initial Manual/Fixed/20%/80%/Pulse radios/Pause icon | **Aligned** — no conflict |
| Center dashed line vs “Reference Line” checkbox | Screenshot dashed line = **centerLine** (always on), not the tool Reference Line |
| Pulse control present | **Present** in both screenshot and source |

## Do not infer from screenshot alone

- Discrete evolve algorithm  
- Tension→minDt mapping  
- Pulse triangular formula  
- Mode-switch restart  

Those are source-only facts (documented in `PHASE_0_SOURCE_AUDIT.md`).
