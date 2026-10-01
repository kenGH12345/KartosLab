# Simulation-content Visual Gate

**Date:** 2026-09-15  
**Verdict: PASS**（P0=0 · P1=0 · 残余 = P2 / framing）

## Two Atoms

| Item | Verdict | Notes |
|---|---|---|
| molecule / atoms / bonds | PASS | 布局与化学正确 |
| dipole | PASS | BondDipoleNode 几何 + createIcon |
| charges | PASS | 显示/隐藏绑定正确 |
| EN panel | PASS | less/more、尖头、色面板；微间距 P2 |
| controls / checkbox / aqua radio | PASS | |
| hints | PASS | 仅 angle 隐藏；Reset 恢复 |
| E-field switch | PASS | ToggleSwitch 灰/绿；非 Material |
| Reset | PASS | |

## Real Molecules

| Item | Verdict | Notes |
|---|---|---|
| mesh / ESP / density | PASS | 原版 all-molecules.json + 双通道 |
| shading | PASS | Lambert 原子；WebGL 细分差 = P2 |
| dipole / charges | PASS | icons + model binding |
| molecule selector | PASS | 底栏 ComboBox |
| controls | PASS | |
| rotation / Reset | PASS | quaternion 同步 mesh |

## Explicit non-P1

| Item | Class |
|---|---|
| Navbar / PhET chrome in ORIGINAL | A |
| Full-frame vertical ghosting from framing | A′ |
| EN label wrap / 1–2px spacing | P2 |
| Real F tint / mesh facet smoothness | P2 |

## Full-frame Diff (informational)

```
contains known global shell + framing delta
Simulation-content Visual Gate: PASS
```
