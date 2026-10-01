# Layout Alignment — Make + Mix View Polish

> Status: **DONE** · Date: 2026-09-18  
> Scope: Phase 7 之后的布局对齐（对照已发布 PhET 截图）  
> Viewport: **768 × 464** · Model **未改**

本轮只改 View 布局与 chrome，不改 Count / Drag / Nature / Average 规则。

---

## 做了什么

### 标题栏（两屏共用）

`IsotopesAndAtomicMassHome` 去掉大标题 + 双层 Tab，改成单行 **44px**：

```text
返回 | [icon] Isotopes    [icon] Mixtures
```

白字 + 白色下划线，避免深青底上深字看不清。

### Mix 右侧

按 `MixturesScreenView` 串联：

```text
Periodic Table (scale 0.55, FittedBox 真实占位)
  +15
Percent Composition
  +10
Average Atomic Mass
  +10
Isotope Mixture
```

- 饼图 `scale(0.6)`
- 手风琴默认展开；按钮为橙圈 −/+
- 桶标签 `Hydrogen-1`；大球标质量数
- Slider 以 model Y=−238 居中
- 模式图标为桶 / 滑条缩略图（不再用 Material Icon）

### Make 右侧

按 `IsotopesScreenView`：

```text
Periodic Table (scale 0.65, FittedBox)
  +10
Symbol
  +10
Abundance in Nature
```

面板宽度与周期表视觉宽度对齐，去掉 `Transform.scale` 造成的虚缝。

### Make 天平

`scaleBottomOffset`：PhET 经验值 **13** → **36**（整体上移约 23px），减少「My Isotope」上方空白。原子仍贴在天平面上（`atomBottomOnScaleOffset = 15`）。

### 折叠不推下面板

PhET `AccordionBox` 的兄弟节点 `top` 在构造时按**展开高度**写死。折叠后只缩短自身，下方留空，位置不变。

Flutter 改为 `Stack` + 固定 `top`（不再用 `Column` 回流）：

| 屏 | 固定间距依据 |
|---|---|
| Make | `makeSymbolExpandedH` 之后才放 Abundance |
| Mix | `mixCompositionExpandedH` 之后放 Average，再之后放 Isotope Mixture |

折叠效果与原版图三一致：上方变矮，下方留白，不跟着上移。

---

## 未改

```text
MixturesModel / MakeIsotopesModel
drag / drop / Nature / average / percent 计算
Reset 按钮（仍是 KratosResetAllButton）
```

---

## 已知差异

1. 天平底边偏移是为观感上移，不是 PhET `bottom - 13` 原值。
2. 手风琴展开高度是常量估算，不是运行时测量节点高度。
3. 饼图标签碰撞、橡皮 SVG、模式按钮完整 Node 仍是简化绘制。
4. V2 截图矩阵未在设备上补齐（离线 `toImage` 对 Nature 过慢）。

---

## 验证

布局改动后已跑过：

```text
dart analyze lib/chemistry/isotopes_and_atomic_mass/screens
→ 0 issues

flutter test
  test/isotopes_and_atomic_mass/make_isotopes_view/
  test/isotopes_and_atomic_mass/mix_view/mix_isotopes_view_test.dart
→ PASS
```

Phase 7 全套基线仍是 **108 PASS**（本轮未重跑整包）。

---

## 停止

本轮布局对齐结束。

下一阶段仍是：

```text
PHASE 8
双 Screen Integration / Final Visual QA
```

本报告不替代 Phase 8。
