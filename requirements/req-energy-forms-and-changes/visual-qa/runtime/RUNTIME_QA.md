# Runtime Screenshot QA — Energy Forms and Changes

> Original Runtime **UNBLOCKED** · 2026-09-10  
> Evidence: Original Runtime > Flutter Runtime > Overlay > source constants  
> Marketing banners are **not** primary evidence.

## Directory

```text
visual-qa/runtime/
├── original/           ← Original Runtime baselines (cropped → 1024×618)
├── flutter/            ← Design-space Flutter captures @ 1024×618
│   └── live_shell/     ← Live Home → shell viewport captures
├── overlay/            ← 50/50 blend (design-space)
├── diff/               ← absdiff heatmaps
└── COORDINATE_SHELL.md ← Stage A shell mapping
```

## Dual QA paths

| Path | Entry | Validates |
|---|---|---|
| **Design-space** | `IntroScreenBody` / `SystemsScreenBody` @ 1024×618 | object coords, Scene Graph, internal geometry |
| **Live-shell** | `EnergyFormsAndChangesHome` @ 1280×800 | AppBar/TabBar → full viewport → PhET layout() → scene |

Live-shell **must not** bypass Home or force the body to 1024×618.

See also: `COORDINATE_SHELL.md` (Stage A), `STAGE_B.md` (object alignment).
## Correspondence

| # | State | Original | Flutter |
|---|---|---|---|
| 1 | Intro Initial | `original/intro_initial.png` | `flutter/intro_initial.png` |
| 2 | Intro Heater Active / Link Heaters | `original/intro_heater_active.png` | `flutter/intro_heater_active.png` |
| 3 | Systems Initial | `original/systems_initial.png` | `flutter/systems_initial.png` |
| 4 | Systems Bike Active | `original/systems_bike_active.png` | `flutter/systems_bike_active.png` |

See `original/ORIGINAL_MANIFEST.md` for source asset + state notes.

## Known state caveats (Original assets)

| Pair | Caveat |
|---|---|
| Intro Initial | Original screen1 has Energy Symbols + partial heating (not pure reset) |
| Systems Initial | Original is faucet→generator→beaker; Flutter default is bike→beaker |
| Systems Bike Active | Original uses bulb user; Flutter screenshot now selects bulb to match |

## Overlay metrics (post re-shoot)

Recomputed by `_register_originals.py` after Flutter scenario fix.

## P0 from Overlay (active)

1. Intro Heater Active — beaker-on-burner + Link Heaters + dual flame (screenshot scenario fixed)
2. Intro TimeControl — circular play/step (style closer to TimeControlNode)
3. Systems Belt / wheel centers — already Belt.ts geometry; overlay validates
4. Systems selectors / bulb path — bike_active now selects incandescent
5. Remaining geometry deltas await next overlay pass

## Blocked

- HeaterCooler flame/ice/FaucetNode pixel fidelity: `[BLOCKED D]` (assets present, not pixel-sealed)
- Pure Intro reset Original capture: optional follow-up if user provides exact reset shot
