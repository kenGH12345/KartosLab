# Molecule Shapes Final Acceptance Report

## Status

```text
FINAL STATUS: READY
```

Sim: **Molecule Shapes**（full · `isBasicsVersion = false`）  
SoT: local `phet sourses/molecule-shapes-main/molecule-shapes-main`  
Home: `化学 → 分子形状 → Molecule Shapes`

---

## Phase Summary

| Phase | Scope | Result |
|---|---|---|
| 0 | Source audit | PASS |
| 1 | Model / VSEPR | PASS |
| 2 | Model Screen | PASS |
| 3 | Real Molecules Screen | PASS |
| 4 | Final behavioral + visual QA | PASS |
| Home | Entry / Back / re-entry / lifecycle | PASS |
| P2 close-out | Balloon / thumbs / Attractor / bond audit | PASS |
| Visual polish | Bonding thumbs + HIGH_DETAIL balloon + shading | PASS |

---

## Screens

| Screen | Status |
|---|---|
| Model | PASS |
| Real Molecules | PASS |

## Real Molecules

```text
13 / 13  (TAB_2 order)
```

## Critical Geometry

```text
H₂O Real  = 104.5°
H₂O Model = 109.5°
```

Real ↔ Model Attractor orientation match: PASS（坐标不合并）

## Controls

| Control | Status |
|---|---|
| Bonding（单/双/三） | PASS |
| Lone Pair | PASS |
| Remove All | PASS |
| Options | PASS |
| Name（几何名称） | PASS |
| Rotation | PASS |
| Reset（`KratosResetAllButton`） | PASS |

## Home

| Item | Value |
|---|---|
| Category | 化学 → **分子形状** |
| Card | Molecule Shapes |
| Entry | `MoleculeShapesHome`（Model \| Real Molecules） |
| Back | AppBar → Home |
| Re-entry | fresh instance PASS |

## Lifecycle

Model / Real tickers dispose · cross-screen isolation · Home leave stops updates — PASS

---

## Tests

```text
flutter test test/molecule_shapes/
→ 66 PASS

dart analyze lib/molecule_shapes test/molecule_shapes
→ No issues found
```

## Defects

| Level | Count |
|---|---|
| P0 | 0 |
| P1 | 0 |
| P2 | 0 |

## Assets

| Item | Status |
|---|---|
| Original balloon mesh（`balloon2.obj`） | used |
| CPK / CustomPainter / L0 Reset | used |
| **Substituted** | **0** |

## Platform

| Platform | Status |
|---|---|
| Web / Windows（widget tests） | PASS |
| Android | **NOT VERIFIED** |

## Global Suite

```text
+2549 ~1 -56
```

Unrelated: SoM / Gas / Pendulum / Projectile / Forces  
**未修改任何其他 simulation。**

---

## Remaining VERSION_DELTA（negligible）

1. Balloon：CustomPainter 近似 Lambert vs three.js `MeshLambertMaterial`
2. Bonding 缩略图：专用 ortho-style painter vs WebGL `toDataURL` 快照
3. 场景键：着色描边 vs Mesh 圆柱几何
4. Kartos Home 顶栏 Tab chrome（工程壳，非 PhET joist 原样）

---

## Delivery Map

| Artifact | Path |
|---|---|
| Model | `lib/molecule_shapes/model/` |
| Views | `lib/molecule_shapes/view/` |
| Home shell | `lib/molecule_shapes/screens/molecule_shapes_home.dart` |
| Home card | `lib/screens/home_screen.dart` |
| Tests | `test/molecule_shapes/` |
| Phase docs | `requirements/req-molecule-shapes/` |

---

## Absolute Rules Kept

- 非 Molecules and Light / Basics / Greenhouse
- 未改其他 simulation
- VSEPR：每键级 1 domain · 最多 6 · 拖动改角不改名
- Real / Model 状态分离

```text
MOLECULE SHAPES — CLOSED · READY
```
