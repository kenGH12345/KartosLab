# PHASE 3 — Real Molecules Visual QA

Method: source map + automated tests (no device screenshot diff). Android = NOT VERIFIED.

| Scene | Result | Notes |
|---|---|---|
| H2O Real | PASS | 104.5°, Bent / Tetrahedral, O orange CPK |
| H2O Model | PASS | 109.5°, same geometry names |
| H2O Real→Model→Real | PASS | angles restore |
| CO2 Real | PASS | double bonds order 2; outer LPs available |
| SO2 | PASS | 119° Real vs 120° Model |
| XeF2 | PASS | Linear + TBP electron |
| BF3 | PASS | 120° |
| ClF3 | PASS | T-shaped |
| NH3 | PASS | 107.8° Real / 109.5° Model |
| CH4 | PASS | tetrahedral |
| SF4 | PASS | Seesaw |
| XeF4 | PASS | Square planar |
| BrF5 | PASS | Square pyramidal |
| PCl5 | PASS | TBP |
| SF6 | PASS | Octahedral |
| Rotated + reset quat | PASS | local coords stable |
| Options on/off | PASS | lone pairs / angles / outer LPs |
| Reset | PASS | H2O + Real |

## Labels

- `[布局已对齐]` Molecule+Options right; Real/Model top; Name bottom-left; Reset bottom-right
- `[动态绘制已对齐]` shared projection/depth with Model Screen; element colors when `element != null`
- `[原版资源一致]` formula subscripts; color profile default; lone-pair shell still approximate (VERSION_DELTA)

## Overall

```text
Real Molecules Visual: PASS with VERSION_DELTA
Overall Status: READY CANDIDATE
```
