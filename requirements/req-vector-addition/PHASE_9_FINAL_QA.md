# Phase 9 · Final QA — 封板结论

> 完成：2026-09-04 · 源码 `1.3.0-dev.0`  
> 基准：`PHASE_8_VISUAL.md` + 当前代码

---

## 最终结论

**Phase 9 可以封板。**

| 门禁 | 结果 |
|---|---|
| `flutter test test/vector_addition/` | **102 passed** |
| `flutter analyze lib/vector_addition` | **0 issues** |
| `[待实现]` | **已清零**（unsigned dual picker wrap 已落地） |
| 核心数学 / 交互语义 | 未破坏 Phase 6–8 |

---

## A. Unsigned angle 双 picker wrap — 已修复

对齐 PhET `LabelEqualsAnglePicker` + `VectorAdditionUtils`：

| 规则 | 标记 |
|---|---|
| Model / Polar base ground truth = **signed** ° ∈ [−180, 180] | [源码一致] |
| Display unsigned ∈ **[0, 355]** step 5（永不显示 360） | [源码一致] |
| `signed→unsigned`：`≥0 ? s : s+360`，**0→0**（非 360） | [数学一致] |
| `unsigned→signed`：`≤180 ? u : u−360`，0 与 360 → 0 | [数学一致] |
| UI：convention 切换时只显示对应 picker；两端禁用，**不环绕** | [行为一致] |
| Model angle CCW；Flutter sweep = −θ | [源码一致]（未改） |

实现：
- `lib/vector_addition/model/angle_convention_utils.dart`
- `EquationsVector.baseAngleDegreesUnsigned` / `setBaseAngleDegreesUnsigned`
- `_EquationBar` polar θ 双 picker

---

## B. 行为 QA

| 检查项 | 标记 |
|---|---|
| coefficient −5 / 0 / 1 / 5 与 clamp | [行为一致] |
| `xy = base × coefficient`；EquationsResultant ≠ Sum | [源码一致][行为一致] |
| angle 0 / 5 / 90 / 180 / 355；无负角 / 无 360 显示 | [行为一致] |
| Cartesian ↔ Polar 独立 Scene；d/e→f | [源码一致] |
| Lab u/v ≠ Explore a/b/c | [源码一致] |
| Reset 恢复 coeff / equation / angleConvention | [行为一致] |
| Picker ↔ model ↔ render 同步 | [行为一致] |
| Equation 文本随 scene 符号变化 | [行为一致] |

---

## C. 视觉 QA（screen{1..4}_final.png）

对照 `visual-qa/ref/`，**未改**已标「有意差异」的 ChoiceChip 外观。

| 屏 | 结论 |
|---|---|
| Explore 1D | [视觉近似] 结构对齐；无 Angles/Components |
| Explore 2D | [视觉近似] origin / components / toolbox |
| Lab | [视觉近似][行为一致] u/v toolbox |
| Equations | [视觉近似][行为一致] coeff + polar θ pickers |

未发现必须修的文字溢出 / 箭头反向 / eraser Material 回退问题。Eraser 保持自定义几何。

---

## D. AC 核对

| AC | 状态 |
|---|---|
| AC-1 Home 往返重初始化 | [行为一致]（自动化 + reopen） |
| AC-2 Canonical tail+xy | [源码一致] |
| AC-3 Sum / EquationsResultant / components | [源码一致] |
| AC-4 Transform 集中 | [源码一致] |
| AC-5 snap / toolbox / controls | [行为一致] |
| AC-6 test + analyze | **PASS** |

---

## E. 标签汇总

| 标签 | 是否残留 |
|---|---|
| [源码一致] | 核心数学与 Equations / Lab 隔离 |
| [行为一致] | coeff / dual picker / reset / isolation |
| [数学一致] | signed↔unsigned Utils |
| [视觉近似] | 四屏相对 ref（chip 外观有意差异保留） |
| [待实现] | **无** |

---

## 修改文件（Phase 9）

- `lib/vector_addition/model/angle_convention_utils.dart`（新）
- `lib/vector_addition/model/root_vector.dart`
- `lib/vector_addition/model/equations_vector.dart`
- `lib/vector_addition/vector_addition_constants.dart`
- `lib/vector_addition/widgets/va_screen_body.dart`
- `test/vector_addition/phase9_final_qa_test.dart`（新）
- 本文件 / `COMPLETION_REPORT.md` / `meta.yaml` / `process.txt`
