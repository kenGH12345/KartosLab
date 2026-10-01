# POST-RELEASE FIX REPORT — Balancing Chemical Equations

> **req-id**: `req-port-balancing-chemical-equations`  
> **Date**: 2026-09-23  
> **Type**: Visual hotfix after Phase 7 READY  
> **Scope**: Particles molecule rendering only

---

## 1. Summary

```text
STATUS: FIXED
FINAL STATUS: READY (unchanged)
```

用户反馈：原版 Particles 框内显示分子球模型；移植版显示整盒蓝色色块。

根因已修复；回归 117 PASS。

---

## 2. Symptom

| 侧 | 表现 |
|----|------|
| 原版 PhET | Reactants / Products 白框内显示 CPK 分子球（如 NH₃：蓝 N + 白 H） |
| 移植版（修前） | 框内整块蓝色填充，几乎看不出分子结构 |

复现：Intro → Make Ammonia → View=Particles → 系数非 0。

---

## 3. Root Cause

`BceAtomLayout.diameter`（`lib/balancing_chemical_equations/views/bce_molecule_node.dart`）相对 nitroglycerin `AtomNode` / RPL `MoleculeIcon` **多乘了 `* 100`**：

```dart
// 错误（修前）
return 2 * modelToView * adjusted * 100;

// 正确（nitroglycerin / RPL）
return 2 * modelToView * adjusted;
```

后果：N 原子直径约 **18px → ~1800px**，经 `PARTICLES_SCALE_FACTOR (0.74)` 后仍远超 285×145 粒子框，被 clip 成整盒蓝色色块。

---

## 4. Fix

| 文件 | 变更 |
|------|------|
| `lib/.../views/bce_molecule_node.dart` | 去掉 diameter 的 `* 100`，对齐 RPL |
| `test/.../visual/visual_qa_test.dart` | 增加 N 直径 / NH₃ layoutSize 上限断言，防回归 |

未改 Model、Game、Home、布局架构。

---

## 5. Verification

```text
flutter test test/balancing_chemical_equations/
→ 117 PASS

dart analyze (touched files)
→ No issues found!
```

视觉预期：Particles 框内为独立分子球模型，不再整盒色块。

---

## 6. Release Impact

| Gate | Result |
|------|--------|
| Phase 7 FINAL STATUS | **READY**（保持） |
| P0 / P1 | **0 / 0** |
| P2 | **8**（未变） |
| Assets substituted | **0** |
| Home | 未改 |

---

## 7. Remaining Issues

Phase 5–7 已记录的 P2（音频 mp3、复杂分子微差、截图基线等）仍保留，不构成本次阻断。

---

## 8. Final Status

```text
HOTFIX: PASS
SIMULATION FINAL STATUS: READY
```

**STOP** — Balancing Chemical Equations 迁移与本 hotfix 收尾完成。
