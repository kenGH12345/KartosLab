# PHASE3_TERM_CONSISTENCY

Cross-simulation scan for PHASE 3 domain terms.

| Concept | Canonical ZH | density | buoyancy | under-pressure | gases-intro | gas-properties | diffusion | membrane |
|---|---|---|---|---|---|---|---|---|
| Density | 密度 | ✓ | ✓ | ✓ (流体密度) | — | — | — | — |
| Pressure | 压强 | — | — | ✓ | ✓ | ✓ | — | — |
| Volume | 体积 | ✓ | ✓ | — | ✓ (V) | ✓ (V) | — | — |
| Mass | 质量 | ✓ | ✓ | — | — | ✓ | ✓ (AMU) | — |
| Temperature | 温度 | — | — | — | ✓ (T) | ✓ | ✓ (K) | — |
| Fluid | 流体 | — | ✓ | ✓ | — | — | — | — |
| Liquid | 液体 | — | — | title 液体压强 | — | — | — | — |
| Gas | 气体 | — | — | — | title | title | — | — |
| Buoyancy | 浮力 | — | ✓ | — | — | — | — | — |
| Gravity | 重力 | — | ✓ | ✓ | — | — | — | — |
| Material wood | 木材 | ✓ | ✓ | — | — | — | — | — |
| Reset All | 全部重置 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Normal / Slow | 正常 / 慢速 | — | — | — | — | ✓ | ✓ | ✓ |
| Outside / Inside | 外侧 / 内侧 | — | — | — | — | — | — | ✓ |

## Conflicts found & resolved

1. Fluid ≠ Liquid — keys separated in `fluids_l10n`.
2. Wood unified to 木材 (not 木头/木板).
3. Pressure remains 压强 (not 压力).
4. Mass never translated as 重量 in this batch.
