# PHASE_3 — Molecules Visual QA

日期：2026-09-22  
依据：source map + Widget/Model tests（未跑截图对比机）

## Matrix

| State | Equation | Reactants | Products | Leftovers | Controls |
|---|---|---|---|---|---|
| Initial | PASS | PASS (0) | PASS (0) | PASS (0) | PASS |
| Make Water | PASS (H₂/O₂/H₂O) | PASS | PASS | PASS | PASS |
| Make Ammonia | PASS | PASS | PASS | PASS | PASS |
| Combust Methane | PASS | PASS | PASS | PASS | PASS |
| A limiting (H₂) | PASS | PASS | PASS | PASS | — |
| B limiting (O₂ via H₂=6 O₂=2) | PASS* | PASS | PASS | PASS | — |
| Zero quantities | PASS | PASS | PASS | PASS | PASS |
| Reaction switch | PASS | isolated | isolated | isolated | PASS |
| Reset | PASS | PASS | PASS | PASS | PASS |

\* Phase 1/3 tests cover H₂=6 O₂=2 → O₂ limiting.

## Tags

- `[动态绘制已对齐]` nitroglycerin 布局复刻
- `[布局已对齐]` 835×504 + 310×240
- `[原版资源一致]` 无 PNG；几何非替代素材

## Verdict

```text
Molecules Visual QA = PASS (P0=0, P1=0)
Overall Status = NOT READY
```
