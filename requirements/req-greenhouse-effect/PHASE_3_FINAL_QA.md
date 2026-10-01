# PHASE_3_FINAL_QA · Greenhouse Effect

> Date: 2026-09-21

## Verdict

```text
Overall Status: READY CANDIDATE
P0 = 0
P1 = 0
P2 > 0 (chrome / typography only)
Home: NOT INTEGRATED (by design for this phase)
```

## Checklist

| Item | Result |
|---|---|
| Gap Matrix written | PASS |
| Wave attenuation from model | PASS |
| Flux Meter panel + altitude + zoom | PASS |
| Energy Legend (wave vs photon) | PASS |
| Energy Balance In/Out/Net | PASS |
| Time Period / Concentration UI | PASS |
| Landscape switches by date | PASS |
| Temperature units K/C/F | PASS |
| Layer Model 0–3 + absorbance + solar + albedo | PASS |
| More Photons display-only | PASS |
| Original assets, Substituted=0 | PASS |
| `flutter test test/greenhouse_effect/` | **38 PASS** |
| `dart analyze …` | **No issues found** |
| Home Integration | **OUT OF SCOPE** |

## P2 backlog (non-blocking)

1. Scenery-phet Panel fill / stroke / shadow parity  
2. Flux Meter full vector arrows + drag on observation window (slider surrogate OK)  
3. Thermometer graphic (currently formatted text)  
4. Separate PhET Screen shells instead of in-app tabs  
5. Exact Energy Balance bamboo plot styling  

## Assets audit

```text
Original assets used: iceAge / agricultural / fifties / twentyTwenties (bg+fg), visiblePhoton, infraredPhoton, unadornedLandscape
Custom drawn: waves, cloud oval, atmosphere lines, panel chrome
Substituted: 0
```

## Gate for READY

Only after:

```text
HOME INTEGRATION
+ FINAL QA (product)
```

Until then keep status:

```text
READY CANDIDATE — do not claim READY
```
