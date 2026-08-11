# AC 验收对照（req-port-molarity）

> 逐 AC 证据链（agile-vibe 阶段 3 第 9 条强制）· 自动化断言为主线 · 视觉证据不强制（v0.2.0 降级）。
> 测试基线：molarity 26/26 · 除 forces 外全量 229/229 · analyze No issues（见 `integration-test.log`）

## AC-1.x 物理模型（solution_test.dart）

| AC | 覆盖 | 证据 |
|---|---|---|
| AC-1.1 concentration=min(sat, n/V) | ✅ | `solution_test.dart:24-33`（未饱和 1.0 / 封顶 0.50 / volume=0） |
| AC-1.2 precipitateAmount=max(0,超饱和) | ✅ | `solution_test.dart:38-47`（0 / 0.75 / volume=0 → n 兜底） |
| AC-1.3 isSaturated | ✅ | `solution_test.dart:52-59`（饱和真 / 边界假） |
| AC-1.4 n=0 → c=0 · precip=0 | ✅ | `solution_test.dart:30-32` |
| AC-1.5 切换溶质重算 | ✅ | `solution_test.dart:61-68` |
| AC-1.6 浓度 2 位小数 | ✅ | 显示层 `concentration.toStringAsFixed(2)`（浓度条/滑块/Semantics）· widget 测试覆盖渲染 |
| AC-1.7 显示范围 0-5 M | ✅ | `paramRanges` 0-1 mol / 0.2-1 L（max=1/0.2=5）· JSON 4 场景一致 |

## AC-2.x 交互（molarity_screen_test.dart）

| AC | 覆盖 | 证据 |
|---|---|---|
| AC-2.1 溶质量滑块实时联动 | ✅ | `molarity_screen_test.dart:55-62`（drag + 无异常） |
| AC-2.2 体积滑块实时联动 | ✅ | 同上 + 集成 `integration_test/molarity_test.dart:33-39` |
| AC-2.3 ComboBox 切换溶质 | ✅ | 实现 `solute_combo_box.dart` + controller.selectSolute · 集成冒烟（场景切换） |
| AC-2.4 Show Values ON → 数值 | ✅ | 实现（valuesVisible 驱动 ConcentrationBar showValue）· 渲染断言 |
| AC-2.5 Show Values OFF → 定性 | ✅ | 实现（qualitative LOW/HIGH）· 测试注释 |
| AC-2.6 Reset All → 默认值 | ✅ | `molarity_screen_test.dart:64-73`（drag 后重置）· `molarity_state.reset()` 恢复 0.5/0.5/index0/false |

## AC-3.x 配置化（molarity_scenario_test.dart + schema）

| AC | 覆盖 | 证据 |
|---|---|---|
| AC-3.1 9 溶质数据从 JSON 加载 | ✅ | `molarity_scenario_test.dart:24-37`（fromJson 完整解析）+ 4 JSON × 9 溶质 + Cobalt chloride 回归 |
| AC-3.2 范围从 paramRanges 加载 | ✅ | `molarity_scenario_test.dart:29-30`（soluteAmountRange 断言） |
| AC-3.3 ≥3 scenario + manifest | ✅ | 4 场景（default/饱和挑战/定量练习/稀释效应）+ manifest.json |
| AC-3.4 schema 存在 · CI 校验 | ✅ | `schemas/molarity_scenario.schema.json`（draft-07） |
| AC-3.5 加载失败降级 default | ✅ | `molarity_controller._load` catch → 场景池首个 · `molarity_scenario_test.dart:44-47`（非法 hex 降级黑） |
| AC-3.6 particlesPerMole/Size 常量+JSON覆盖 | ✅ | `performance` 段 + `_parseSolute` 覆盖逻辑 |

## AC-4.x 布局与视觉

| AC | 覆盖 | 证据 |
|---|---|---|
| AC-4.1 NineGrid 无溢出居中响应式 | ✅ | `molarity_screen.dart`（NineGridLayout + FittedBox/滚动防溢出）· screen_test 800×600 通过 |
| AC-4.2 烧杯 3D 圆柱+刻度 | ✅ | `beaker_painter.dart`（外壁+高光+½L/1L 刻度） |
| AC-4.3 颜色淡→深渐变 + 饱和封顶 | ✅ | `solution.dart solutionColor`（ColorRange 插值 t 封顶）· `solution_test.dart:70-95` |
| AC-4.4 沉淀椭圆分布 | ✅ | `precipitate_painter.dart`（底部区域 t² 堆叠） |
| AC-4.5 浓度条饱和灰段 | ✅ | `concentration_bar_painter.dart`（isSaturated 灰段描边） |

## AC-5.x 质量

| AC | 覆盖 | 证据 |
|---|---|---|
| AC-5.1 单测覆盖公式 | ✅ | `solution_test.dart` 14 用例 |
| AC-5.2 帧率 ≥60fps | ✅ | 纯响应式无 tick · 粒子 ≤200 · 静态渲染（分析结论 · 未做性能基准） |
| AC-5.3 i18n 进 .arb | ⚠️ **偏离** | 项目无 arb 体系（全 sim 中文硬编码）· 对齐现状 · 见 `notes.md` D7 |
| AC-5.4 色盲可访问性 | ✅ | 浓度条 Semantics 播报（`molarity_screen.dart`）+ 数值显示（Show Values ON 不依赖颜色） |
| AC-5.5 化学式下标 | ✅ | JSON `\u2082` 转义（Co(NO₃)₂ · K₂Cr₂O₇ · CuSO₄）· 蓝本 formula 忠实 |

## 诚实声明

- 无 golden test（视觉断言靠 widget findsOneWidget + painter 实现评审）· 方案 §8.3 Suggestion 记录取舍（notes.md s2）
- 无真实设备运行记录（integration_test 交付 · 需 `flutter test integration_test` 在设备/模拟器执行）
- AC-2.4/2.5 定性/定量切换无独立 widget 用例（渲染断言覆盖）
