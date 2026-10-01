# Stage B — Object Alignment / Intro Runtime Convergence

> Shell (Stage A) ✅ · Stage B geometry ✅ · Intro dynamic z-order ✅ (do not reopen)
> Evidence order: PhET source → Original Runtime → Flutter Runtime → Overlay

## This round (Intro convergence)

### Fixes landed

1. **Iron/Brick anchor** — `BlockNodeWidget.localOriginFromTopLeft` now includes PhET `blockFaceOffset` (Y), matching `BlockNode.ts` front-face bottom at `translation`.
2. **HeaterCooler layer split** — `HeaterCoolerPaintLayer.back` (opening+flame/ice) in backLayer; `.front` (body Path + slider) in heaterCoolerFrontLayer — matches `EFACIntroScreenView` / scenery-phet split. Flame/ice still `[BLOCKED D]` fidelity.

### Overlay metrics (design-space)

| Pair | meanΔ | hot>30% |
|---|---|---|
| intro_initial | 27.9 | 29.7% |
| intro_heater_active | 39.1 | 31.9% |

meanΔ is auxiliary; remaining gaps are largely **state mismatch** on `intro_initial` Original (EC on / heating / objects on stands) and UI chrome / TimeControl, not only geometry.

## Report

```text
Intro:
- P0: Block MVT anchor (faceOffset); HeaterCooler back/front layer split + body Path
- P1: (open) Beaker meniscus/liquid height; Thermometer tip; Shelf vertical vs objects; bottom TimeControl; heater_active fixture state completeness
- meanΔ: initial 27.9 / heater 39.1
- hot>30%: initial 29.7% / heater 31.9%

Systems:
- Original runtime: systems_initial bike-reset BLOCKED (faucet archived)
- Status: no forged overlay; code work may continue separately

Tests:
- Intro screenshots PASS; prior EFAC suite PASS this session

Analyze:
- changed Intro heater/block files: No issues found

Blocked:
- flame/ice/Faucet pixel fidelity [BLOCKED D]
- systems_initial same-state Original bike-reset
- intro_initial Original ≠ pure reset (manifest caveat)
```

## Forbidden

- Re-open z-order
- NineGrid / shell changes
- Fake systems_initial overlay
- Screenshot-only offsets without source
