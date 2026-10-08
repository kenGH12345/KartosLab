# PHASE3_LAYOUT_IMPACT

| Simulation | Component | Before | After | Issue | Severity | Fix |
|---|---|---|---|---|---|---|
| buoyancy | Forces panel (156px) | English short labels | 力数值 / 矢量缩放 longer | Possible wrap at narrow width | P2 | Keep existing width; ellipsis / fontSize 12; no Positioned magic |
| buoyancy | Tab bar (5 tabs) | enum English short | 比较/探索/实验室/形状/应用 | 「实验室」「应用」稍长 | P2 | fontSize 11 + ellipsis already present |
| gas-properties | Hold Constant radios | Volume (V) | 体积 (V) | Similar length | — | OK |
| gas-properties | Particles Heavy/Light | Heavy/Light | 重粒子/轻粒子 | Wider | P2 | Existing panel constraints |
| under-pressure | Tools panel 140px | Atmosphere On/Off | 大气 开/关 | Shorter — OK | — | OK |
| density | Material dropdown | Wood/Aluminum | 木材/铝 | Similar or shorter | — | OK |
| membrane | Protein panel titles | Voltage-Gated Channels | 电压门控通道 | Longer | P2 | Intrinsic column; monitor overflow |
| diffusion | Slider labels | Number of Particles | 粒子数 | Shorter — OK | — | OK |

## Rules applied

- No page-level magic `Positioned` for Chinese.
- No physics / LayoutSpec geometry rewrite for localization.
- Typography: Phase 1 font fallback retained.

## Golden

- EN baselines preserved under existing sim golden dirs.
- ZH placeholder: `test/goldens/zh/phase3/` (capture pending → blocks VERIFIED).
