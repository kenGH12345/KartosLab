# COMPLETION_REPORT — req-curve-fitting

## Verdict

**移植成功 · 功能/数学/交互可封板。**

PhET Curve Fitting（本地 `1.1.0-dev.0`）已迁移至 KARTOSLAB Flutter，可从 Home 进入运行。  
后续若有原版 runtime 截图，可继续做像素级 Visual QA，**不阻塞本次封板**。

| 维度 | 状态 |
|---|---|
| 源码版本 | [已确认] `1.1.0-dev.0` |
| Screen | [已确认：单 Screen] |
| 数学一致 | [数学一致] 加权 WLS |
| 统计一致 | [统计一致] r² + reduced χ² |
| 行为一致 | [行为一致] Best/Adjustable、Bucket/Graph 拖点、Reset、Lifecycle |
| 布局 / 控件默认 | [源码一致] 三列 + Curve off 时隐藏 Order/Fit |
| 视觉 | [视觉已对齐目标]；[视觉近似] 方程 KaTeX / bumpOut；[待确认：缺原版截图] |
| Home | 物理 → 力学（未改 taxonomy） |
| Analyze | **0 issues** |
| Tests | **38 passed** |
| Build | debug APK ✅ · release APK ✅ |

---

## Acceptance Criteria

| AC | 结果 |
|---|---|
| AC-1 进入 / 返回 / 再进入 | ✅ |
| AC-2 Linear / Quadratic / Cubic + Best / Adjustable | ✅ |
| AC-3 Residuals / r² / reduced χ² | ✅ |
| AC-4 Data point drag / delta / bucket / reset | ✅（含 hit-test 回归修复） |
| AC-5 Graph MVT inverted-Y 集中在 transform | ✅ |
| AC-6 analyze 0 + 专项测试 | ✅ |

---

## 本地源码锚点

| 项 | 值 |
|---|---|
| Path | `phet sourses/curve-fitting-main/curve-fitting-main` |
| Version | `1.1.0-dev.0` |
| dependencies.json sha | `cb6f00b03721427040808eaca67575dafb6ad13e` |
| 策略 | 本地源码为唯一第一事实来源 |

---

## 交付物

### 代码
- `lib/curve_fitting/` — model / solver / transform / render / painters / widgets / screens
- Home：`lib/screens/home_screen.dart` → 物理 → 力学 → Curve Fitting
- 测试：`test/curve_fitting/`（38）

### 需求文档（`requirements/req-curve-fitting/`）
- `PROJECT_DISCOVERY.md`
- `SOURCE_ANALYSIS.md`
- `STATISTICS_VALIDATION.md`
- `ARCHITECTURE_PLAN.md`
- `FUNCTIONAL_GAP_CLOSURE.md`
- `visual-qa/BASELINE.md`
- `visual-qa/ASSET_MAPPING.md`
- `visual-qa/GEOMETRY_CALIBRATION.md`
- `visual-qa/DEFAULT_SCREEN_CALIBRATION.md`
- `COMPLETION_REPORT.md`（本文件）
- `meta.yaml` · `process.txt`

---

## 核心公式（已按 Curve.js 移植）

- \(y = \sum a_i x^i\)，系数升序 `[a0…a3]`（UI：d,c,b,a）
- Best Fit：\(w=1/\delta^2\)；矩阵 \(X_{ij}=\sum x^{i+j}/\delta^2\)；`|det|≤1e-30` → 零系数
- reduced χ²（属性名 `chiSquared`）：`|RSS / max(n−order−1, 1)|`
- r²：加权；坏拟合→0；零方差→NaN
- Residual 竖线：`(x, yObs) → (x, yFit)`

---

## 过程中修复的迁移问题

| 问题 | 分类 | 结果 |
|---|---|---|
| Deviations 气压计不全 | [迁移 UI 缺口] | 已修 |
| Graph 被侧栏挤压 | [迁移布局问题] | 已修 |
| Order/Fit 默认可见 | [已确认源码后修复] | 默认隐藏 |
| Bucket 视觉 | [资源/视觉迁移缺口] | 几何+渐变 |
| 拖点失效 | **[迁移引入：DataPoint Drag / Hit-Test Regression]** | 已修 |

---

## 有意差异 / 待确认

1. Equation bumpOut 用固定矩形 — [视觉近似]
2. snapToGrid 默认 false（与源码 query 一致）
3. 无原版截图像素 overlay — [待确认]
4. 未改 common API / 其他 simulation / Home taxonomy

---

## 如何运行

**Home → 物理 → 力学 → Curve Fitting**

默认：仅 Curve / Residuals / Values；勾选 Curve 后出现 Linear/Quadratic/Cubic 与 Best/Adjustable。
