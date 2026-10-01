# PHASE 4 — GOLDEN MATRIX · Resistance in a Wire

> Implementation regression goldens · seed `0x52494157`  
> **NOT** official pixel-perfect truth  
> Official Gold Standard remains user-provided default screenshot (composition check)

| Matrix ID | State (ρ, L, A) | R display | PNG file | Notes |
|-----------|-----------------|-----------|----------|-------|
| G01 | 0.50, 10, 7.5 | 0.667 | `g01_initial.png` | Initial / defaults |
| G02 | alias G01 | 0.667 | `g01_initial.png` | Normal formula |
| G03 | 0.01, 0.1, 15 | 0.0001 | `g03_small_r.png` | Small R |
| G04 | 1, 20, 0.01 | 2000 | `g04_large_r.png` | Large R / uncapped scale |
| G05 | 0.01, 10, 7.5 | — | `g05_rho_low.png` | Small ρ |
| G06 | 1, 10, 7.5 | — | `g06_rho_high.png` | Large ρ |
| G07 | 0.5, 0.1, 7.5 | — | `g07_l_low.png` | Small L |
| G08 | 0.5, 20, 7.5 | — | `g08_l_high.png` | Large L |
| G09 | 0.5, 10, 0.01 | — | `g09_a_low.png` | Small A |
| G10 | 0.5, 10, 15 | — | `g10_a_high.png` | Large A |
| G11 | alias G03 | 0.0001 | `g03_small_r.png` | Low R readout |
| G12 | alias G01 | 0.667 | `g01_initial.png` | Mid R readout |
| G13 | 1, 20, 1 | **20.0** | `g13_r_20.png` | 10≤R<100 band |
| G_precision | 1, 20, 15 | **1.33** | `g13b_r_1_33.png` | 1≤R<10 → 2 dp |
| G14 | alias G07 | — | `g07_l_low.png` | Min length |
| G15 | alias G01 | — | `g01_initial.png` | Default length |
| G16 | alias G08 | — | `g08_l_high.png` | Max length |
| G17 | alias G09 | — | `g09_a_low.png` | Min area |
| G18 | alias G01 | — | `g01_initial.png` | Default area |
| G19 | alias G10 | — | `g10_a_high.png` | Max area |
| G20 | alias G05 | — | `g05_rho_low.png` | Min ρ |
| G21 | alias G01 | — | `g01_initial.png` | Default ρ |
| G22 | alias G06 | — | `g06_rho_high.png` | Max ρ |
| G23 | 0.01, 0.1, 0.01 | — | `g23_combo_lll.png` | Combined LLL |
| G24 | 0.01, 20, 15 | — | `g24_combo_lhh.png` | Combined LHH |
| G25 | 1, 0.1, 15 | — | `g25_combo_hlh.png` | Combined HLH |
| G26 | alias G04 | 2000 | `g04_large_r.png` | ρH L H A L |
| G27 | alias G04 | 2000 | `g04_large_r.png` | Extreme max R |
| G28 | alias G03 | 0.0001 | `g03_small_r.png` | Extreme min R |
| G29 | reset → defaults | 0.667 | `g29_reset.png` | Reset |
| G30 | reset from extreme | 0.667 | `g30_reset_extreme.png` | Reset extreme |

## Phase 2 continuity files (same visuals, legacy names)

| Legacy PNG | Equivalent |
|------------|------------|
| `g02_rho_low.png` | G05 |
| `g03_rho_high.png` | G06 |
| `g04_l_low.png` | G07 |
| `g05_l_high.png` | G08 |
| `g06_a_low.png` | G09 |
| `g07_a_high.png` | G10 |
| `g08_low_r.png` | G03 |
| `g09_mid_r.png` | G01 |
| `g10_high_r.png` | G04 |
| `g11_combined.png` | mid combined (0.8,18,1) |
| `g12_reset.png` | G29/G30 class |

**Distinct PNG count:** 27  
**Matrix coverage G01–G30:** 30 / 30 (aliases included)
