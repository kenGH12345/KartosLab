# POST-READY Hotfix Report — Reactants, Products and Leftovers

日期：2026-09-22  
基线：Phase 7 `Overall=READY`（`PHASE_7_FINAL_ACCEPTANCE_REPORT.md`）  
范围：**仅 CODE CHANGES**（viewport + Game 分子绘制），不改 Model / 关卡逻辑

---

## Summary

| Item | Result |
|---|---|
| Hotfix-1 Game viewport clip | **FIXED** |
| Hotfix-2 Game 分子 FormulaText chip | **FIXED** |
| RPL tests | **119+ PASS**（含全池 iconId → MoleculeIcon） |
| Analyze (`lib/reactants_products_and_leftovers`) | **clean** |
| P0 / P1 | **0 / 0** |
| Substituted bitmap assets | **0** |
| Overall | **READY**（维持） |
| Android | **NOT VERIFIED** |

---

## Hotfix-1 · Game 视口裁切

**现象**：Home TabBar + SafeArea 下 Game 底部（Reset / 计数器）被裁切。

**改动**：
- `game_play_node.dart` — challenge 区 `FittedBox(fit: BoxFit.scaleDown)`
- `game_screen` / sandwiches / molecules — 底部 `SafeArea`
- `game_random_box.dart` — 粒子 inset，避免贴边裁切

**判定**：`[布局已对齐]`

---

## Hotfix-2 · Game 分子球棒图缺失

**现象**：Level 1（如 `1 SO₂ + 2 H₂ → 1 S + 2 H₂O`）中 SO₂ / S 等显示为蓝色 `FormulaText` chip，H₂ / H₂O 正常。

**根因**：`MoleculeIcon` / `fromIconId` 仅覆盖 Molecules 屏七分子；Game 全池（39/21/18）其余走 `SubstanceIcon` → FormulaText 占位（原 Phase 4 VERSION_DELTA #2）。

**改动**：
- `molecule_icon.dart` — 按 nitroglycerin `*Node.ts` 补齐 Game 全分子几何  
  - 元素：H / C / N / O / **S** / F / Cl / P  
  - `RpalMoleculeId`：H2…PCl5（含 SO2 / S / SO3 / H2S / CS2 / C2H* / P* 等）
- `substance_icon.dart` — 已知 `iconId` 一律走 `MoleculeIcon`；未知才 FormulaText
- 测试：全 `ReactionFactory.pools` 的 `iconId` 必须 `fromIconId != null`

**判定**：`[动态绘制已对齐]` · `[原版资源一致]`（无图源码几何，非 Material/Emoji）

**设备验证**：Pixel Tablet Hot Restart 后确认 SO₂ / S 显示球棒模型。

---

## VERSION_DELTA 变更

| 原 Phase 7 P2 | 处置 |
|---|---|
| 非 Molecules 七分子 FormulaText chip | **CLOSED**（本 hotfix） |
| Game RandomBox 布局近似 | 仍 Accepted |
| FaceWithPoints / StatusBar / Level 图标 / confetti | 仍 Accepted |

P2 计数：6 → **5**（Accepted，不阻断 READY）

---

## Files touched（hotfix）

| Path | Role |
|---|---|
| `lib/.../view/widgets/molecule_icon.dart` | 全池几何 |
| `lib/.../view/widgets/substance_icon.dart` | 映射注释 |
| `lib/.../view/widgets/game_play_node.dart` | FittedBox |
| `lib/.../view/widgets/game_random_box.dart` | inset |
| `lib/.../view/game_screen.dart` 等 | SafeArea |
| `test/.../final/molecules_final_test.dart` | iconId 全池断言 |

---

## Gates

```text
Sandwiches = PASS
Molecules  = PASS
Game       = PASS
Home       = PASS

P0 = 0
P1 = 0
Substituted = 0
Overall = READY
Android = NOT VERIFIED
```

## Blockers

**无。**
