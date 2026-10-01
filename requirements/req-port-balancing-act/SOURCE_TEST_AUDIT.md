# Balancing Act — Source Test Audit

> Phase 0 · 2026-09-23

---

## Verdict

```
NOT APPLICABLE — no test files in local balancing-act checkout
```

在以下路径搜索结果为空：
- `*_tests.ts` / `*.tests.ts`
- `tests/` 目录
- `qunit` / `mocha` / `karma` 配置
- 文件名含 `test` / `Test` 的源文件（除无关匹配）

---

## Metrics

| Metric | Value |
|--------|------:|
| Test file count | **0** |
| Covered Model | — |
| Covered interaction | — |
| Covered physics | — |
| Covered reset | — |
| Covered edge cases | — |

---

## Implication for Flutter

PhET 本仓库**不提供**可移植单元测试作为“金标准”。

后续 Flutter 测试必须以 **源码行为** 为 oracle，优先覆盖：

| Priority | Behavior | Source oracle |
|----------|----------|---------------|
| P0 | Torque sign & tip direction | `getTorqueDueToMasses` + Game tip |
| P0 | `isBalanced` with COMPARISON_TOLERANCE 1e-6 | `Plank.isBalanced` |
| P0 | Snap grid 0.25 m / center forbidden | `getOpenMassDroppedPosition` |
| P0 | ColumnState DOUBLE locks θ=0 | `forceToLevelAndStill` |
| P0 | Intro seed masses & reset | `BAIntroModel` |
| P1 | ω/α integration quirks (no dt on ω; ×0.91) | `Plank.step` |
| P1 | Lab miss → animated remove | `BalanceLabModel` |
| P1 | Game scoring / 6 challenges × 4 levels | `BalanceGameModel` |

---

## P1 note

缺少上游测试 → 记入 `SOURCE_AUDIT_REPORT` P1 #2；不阻断 Phase 0 PASS。
