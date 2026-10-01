# DIFF_ATTRIBUTION · States of Matter

> Updated: 2026-09-15  
> Matrix: ORIGINAL 15/15 + smoke · FLUTTER 15/15 · DIFF 15/15  
> PRIMARY behavior: local **1.3.0-dev.3** · Visual ref: published latest (local HTML unbuilt)

---

## Classification

| Class | Meaning | Action this round |
|---|---|---|
| **A** | KARTOSLAB Global Shell / Joist chrome | **Do not modify** — known difference |
| **B** | States of Matter Simulation Content | Fix until no P1 |

---

## A — Global shell / Joist (known, not blocking Visual Gate alone)

| Item | Evidence |
|---|---|
| Joist bottom navbar (Home / screen tabs / PhET logo / menu) | ORIGINAL has white Joist bar; Flutter capture is design 834×504 on black (no Joist). Belongs to PhET joist shell, not SoM model. Kartos uses `KratosTabbedScreen` when hosted. |
| Full-frame letterboxing / navbar vertical space | Inflates whole-image `pct_pixels_changed` (~29–35%) even when scene content is close |
| Home-screen entry chrome | N/A in Flutter capture (direct screen bodies) |

**Decision:** A-class only → does **not** fail Visual Gate by itself.

---

## B — Simulation Content (this round)

| Item | Status after fix | Notes |
|---|---|---|
| TimeControl blue buttons | **Fixed** | Sky-blue RoundPushButton + dark icons (match ORIGINAL) |
| Temperature ComboBoxDisplay (`14 K`) | **Fixed** | Light readout box, PhetFont-size 11, U+212A, space before unit, dropdown chevron |
| Container 3D bevel | **Fixed** | Bevel 9 / tilt 0.15 / front cutout / metallic gradients; physics MVT unchanged |
| Bicycle pump | **Fixed** | Full CustomPaint body/handle/shaft/hose/base; still +3 onTap |
| Reset All orange | **Fixed** | Orange 3D round button + white arrow |
| Phase mipmap icons | Present | Original solid/liquid/gas PNGs |
| Heater/Cooler chrome | **P2 residual** | Functional; bucket label/flame art still soft vs scenery-phet |
| Phase Changes diagrams chrome | **P2 residual** | Data-correct; accordion styling approximate |
| Interaction graph chrome | **P2 residual** | Forces/potential OK functionally |

---

## Diff stats (whole-frame, after B fixes; A shell still dominates)

See `visual-qa/diff_stats.jsonl`. Typical States ~29% changed pixels — largely navbar + framing (A). Interaction ~18–19% (less shell overlap).

**Gate rule used:** Simulation Content P1 cleared; remaining pixel % attributed primarily to A + P2 chrome → **Visual Gate = PASS** for content.

---

## Manifest fields

`visual-qa/manifest.json` + per-shot `.meta.txt`:

```
screen, state, source, actions, viewport 1280x800, DPR 1, paused, version notes
```

ORIGINAL interactions: scenery **tandem click/drag** (real pointer), not silent model mutation (pause freeze fallback only when playPause hit-test misses).
