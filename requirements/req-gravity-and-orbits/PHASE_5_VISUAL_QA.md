# PHASE 5 — Visual QA

## Infrastructure

Reuse KARTOSLAB capture/diff under `requirements/req-gravity-and-orbits/visual-qa/`:

```
visual-qa/
  ORIGINAL/
  FLUTTER/
  DIFF/
  manifest.json
```

## Matrix (minimum)

| # | State |
|---|---|
| 01 | Model / starPlanet / initial paused |
| 02 | running ~few seconds |
| 03 | paused mid-orbit |
| 04 | starPlanetMoon |
| 05 | planetMoon |
| 06 | planetSatellite |
| 07 | force vectors on |
| 08 | velocity vectors on |
| 09 | path on |
| 10 | mass changed |
| 11 | gravity off |
| 12 | To Scale + measuring tape |
| 13 | reset all |

## Diff attribution

- **A** = KARTOSLAB global shell (tab bar chrome) — known, do not fix  
- **B** = GAO content — clear P1

## Current status

- Layout baseline documented in `VISUAL_LAYOUT_BASELINE.md`  
- Assets: Substituted = 0 (`ASSET_MAP.md`)  
- Automated pixel diff capture scripts: scaffolded; full ORIGINAL↔FLUTTER batch pending device capture session  
- Visual judgment: `[原版资源一致]` for bodies/icons; `[布局已对齐]` major regions; `[动态绘制已对齐]` PEFRL path/vectors from model

## P0 / P1 / P2

| Level | Count | Notes |
|---|---|---|
| P0 | 0 | |
| P1 | 0 | Measuring tape upgraded from stub; explosion polish = P2 |
| P2 | several | panel padding, explosion spikes, velocity snap&lt;10 |
