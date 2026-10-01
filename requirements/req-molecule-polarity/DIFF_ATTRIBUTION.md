# Visual Diff Attribution — Molecule Polarity (Final)

**Updated:** 2026-09-15 (Visual Gate 收口)  
**Full-frame:** Two ≈22.5% · Real ≈16.3%（含 shell + 取景）

## Class split

| Class | What | Action |
|---|---|---|
| **A** | PhET bottom navbar / KartosLab shell / utility icons / PhET logo | **Do not modify** |
| **A′ Framing** | ORIGINAL 含 navbar；FLUTTER capture 为无 PhET navbar 的 layoutBounds 缩放进 1280×800 → **整帧系统位移/ghosting** | 记为取景差，不按内容 P1 |
| **B** | Simulation content | 局部 Visual Gate 判定 |

## Why full-frame % stays high

1. **A**：navbar 整条红带  
2. **A′**：内容区高度不同 → 分子/面板/EN 整体错位叠影（看起来像 B，根因是 framing）  
3. **B P2**：EN 文案分行、控件微间距、F 原子色调、Canvas 投影 vs WebGL 平滑度  

**不以整帧 Diff % 作为 Visual Gate 唯一标准。**

## B items previously fixed (source-aligned)

- EN Panel / BondDipole offset / hints state machine  
- Real mesh + initialRotation + shading  
- ComboBox bottom / AquaRadio / Dipole createIcon / ToggleSwitch  
