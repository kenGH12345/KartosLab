# Molecule Shapes — Final Visual QA

Method: Home catalog + entry shell review + automated Home/lifecycle tests. Device screenshot pixel-diff = NOT RUN.

## Matrix

| Scene | P0 | P1 | P2 | Verdict |
|---|---|---|---|---|
| Home Card（化学 / 分子形状） | — | — | — | PASS |
| Card title / subtitle / icon | — | — | — | PASS |
| Entry → MoleculeShapesHome | — | — | — | PASS |
| Model initial | — | — | VERSION_DELTA thumbnails/LP shell | PASS |
| Model interaction | — | — | — | PASS |
| Real initial H₂O | — | — | — | PASS |
| Real molecule selection | — | — | — | PASS |
| Real / Model angles | — | — | orientation jump | PASS |
| Rotation | — | — | — | PASS |
| Options | — | — | — | PASS |
| Reset | — | — | — | PASS |
| Back → Home | — | — | — | PASS |
| Re-entry fresh | — | — | — | PASS |

## Labels

- `[布局已对齐]` Home card under 化学 → 分子形状；sim AppBar + Model | Real Molecules tabs
- `[动态绘制已对齐]` Phase 4 painter unchanged
- `[原版资源一致]` Substituted = 0；Reset = `KratosResetAllButton`

## Counts

```text
P0 = 0
P1 = 0
P2 = VERSION_DELTA only (4 items)
```

## Platform

| Platform | Status |
|---|---|
| Web / Windows (widget tests) | PASS |
| Android | **NOT VERIFIED** |
