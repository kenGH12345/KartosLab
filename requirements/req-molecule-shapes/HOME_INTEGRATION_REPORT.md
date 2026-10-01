# Molecule Shapes — Home Integration Report

## Status

```text
HOME INTEGRATION: PASS
```

## Wiring

| Item | Value |
|---|---|
| Discipline | 化学 / Chemistry |
| Subject group | **分子形状**（新建二级组，未改一级学科） |
| Card title | `Molecule Shapes` |
| Subtitle | `Model · Real Molecules · VSEPR` |
| Icon | `Icons.hub_outlined`（沿用 Home Material icon 规范） |
| Accent | `#9F66DA`（central-atom purple） |
| Builder | `_buildMoleculeShapes` → `MoleculeShapesHome` |
| Navigation | `Navigator.push(MaterialPageRoute)`（无新路由体系） |

## Entry

```text
Home → 化学 → 分子形状 → Molecule Shapes → MoleculeShapesHome
```

`MoleculeShapesHome` 使用 `KratosTabbedScreen`：

| Tab | Child |
|---|---|
| Model | `ModelMoleculesScreen`（独立 `ModelMoleculesModel` + ticker） |
| Real Molecules | `RealMoleculesScreen`（独立 `RealMoleculesModel` + ticker） |

- 正式入口，无 demo/QA hub
- 非活动 Tab：`TickerMode(enabled: false)`（`KratosTabSwitcher`）
- AppBar Back → `Navigator.pop` → Home

## Defaults on entry

| Screen | Default |
|---|---|
| Model | 2× single bond，options 默认，quat identity |
| Real Molecules | H₂O + Real，104.5° |

## Lifecycle

| Event | Behavior |
|---|---|
| Leave Home route | both screens dispose → tickers disposed |
| Re-entry | brand-new `MoleculeShapesHome` instance |
| Cross-tab | separate models；无状态串联 |

## Files touched

| File | Change |
|---|---|
| `lib/molecule_shapes/screens/molecule_shapes_home.dart` | **new** Home shell |
| `lib/screens/home_screen.dart` | import + 分子形状 group + builder |
| `test/molecule_shapes/home/home_lifecycle_test.dart` | **new** Home/lifecycle tests |

**No Phase 1–4 core model/view/renderer edits.**

## Tests

```text
flutter test test/molecule_shapes/
→ 65 PASS (was 58; +7 Home lifecycle)
```

## Global suite

```text
flutter test → +2548 ~1 -56
```

UNRELATED GLOBAL TEST FAILURE only（SoM / Gas / Pendulum / Projectile / Forces）. Molecule Shapes pass count contributed to the +7 vs prior `+2541`.

## Known issues

P2 VERSION_DELTA only（unchanged from Phase 4）:

1. Lone-pair shell approximate
2. Bonding thumbnails 2D
3. Real↔Model orientation attractor match
4. Bond color not A/B split
