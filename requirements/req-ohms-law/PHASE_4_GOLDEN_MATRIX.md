# PHASE 4 — GOLDEN MATRIX · Ohm's Law

> Source: 1.5.0-dev.6 · Layout 768×504 · Seed `0x4F484D53`  
> Expected type: **implementation regression goldens** (source-geometry driven).  
> Official screenshot = Gold Standard for G01 composition; not every state has an official PNG.

## Distinct raster files

| File | States covered | V | R | Units |
|------|----------------|---|---|-------|
| `g01_initial.png` | G01,G03,G10,G13,G19,G21,G24,G27 | 4.5 | 500 | mA |
| `g09_voltage_min.png` | G09,G23 | 0.1 | 500 | mA |
| `g11_voltage_max.png` | G11,G05,G25 | 9 | 500 | mA |
| `g12_resistance_min.png` | G12,G06,G26 | 4.5 | 10 | mA |
| `g14_resistance_max.png` | G14,G28 | 4.5 | 1000 | mA |
| `g02_low_current.png` | G02,G08,G15,G18,G30 | 0.1 | 1000 | mA |
| `g04_high_current.png` | G04,G07,G17,G20,G31 | 9 | 10 | mA |
| `g29_low_v_low_r.png` | G16,G29 | 0.1 | 10 | mA |
| `g32_high_v_high_r.png` | G32 | 9 | 1000 | mA |
| `g22_units_a.png` | G22,G35,G36 | 4.5 | 500 | A |
| `g37_r_min_units_a.png` | G37 | 4.5 | 10 | A |
| `g38_reset_preserves_units_a.png` | G38 | 4.5* | 500* | A |

\* after `reset()` from dirty V/R with Units held at A.

## Aliases (same visual → no duplicate PNG)

| ID | Alias of |
|----|----------|
| G03,G10,G13,G19,G21,G24,G27 | G01 |
| G23 | G09 |
| G05,G25 | G11 |
| G06,G26 | G12 |
| G28 | G14 |
| G08,G15,G18,G30 | G02 |
| G07,G17,G20,G31 | G04 |
| G16 | G29 |
| G35,G36 | G22 |

## Non-raster contracts (same test file)

- Background `#FFFFE8`
- Equation scale monotonicity
- No multiply glyph positions
- Battery AA count
- Resistor dots ∝ R
- Arrow scale ∝ I; clockwise via π/2 + 0 rotations
- Dot RNG determinism

## Current animation

Source arrows scale with I; **no time-driven particle animation** → Animation Frame: **NOT VERIFIED / N/A**.
