# Kratos 仿真实验室 · 交互问题汇总（2026-08）

> 汇总两次交互审查：
> ① 主界面 + 8 sim 交互设计与实现审查（12 个 screen）
> ② "做中学"探究工作流阶段切换交互审查（5 个通用组件 + 引导入口）
> 整理日期：2026-08-18 · 数据来源：`lib/` 源码行号引用

---

## 一、问题总览

| # | 问题 | 级别 | 类别 | 位置 |
|---|---|---|---|---|
| A1 | 预测题状态不共享：弹窗与抽屉是两个独立实例 | **P0** | 做中学 | `experiment_intro_panel.dart:131-134` + `inquiry_drawer.dart:57-58` |
| A2 | 预测验证后改答案，判定结果不更新 | **P0** | 做中学 | `prediction_panel.dart:55-60` |
| A3 | 阶段切换无进度指示，"操作"与探究抽屉零联动 | P1 | 做中学 | `inquiry_drawer.dart` 整体 |
| A4 | `_inquiryOpen` 默认值割裂（circuit/molarity=true，其余 6 sim=false） | P1 | 做中学 | 各 sim screen |
| A5 | 结论"修改"路径绕过"结论先消失"防抄设计 | P2 | 做中学 | `conclusion_panel.dart:159-168` |
| A6 | `InquiryTaskPanel` 在弹窗与抽屉冗余展示 | P2 | 做中学 | `experiment_intro_panel.dart:129` |
| B1 | 主界面无响应式（GridView 固定 3 列，窄屏不降级） | P2 | 主界面 | `home_screen.dart` |
| C1 | `ScenarioSelectionScreen` 死代码（无活跃引用） | **P0** | 场景切换 | `lib/screens/scenario_selection_screen.dart` |
| C2 | rgb_bulbs 探索模式无 RGB 数值滑块，只能拖瓶子 | **P0** | 参数交互 | `rgb_bulbs_screen.dart:684-693` |
| C3 | 场景切换 5 种模式并存（AppBar 菜单/底部快切条/内嵌 Popup/弹窗/topRight 菜单） | P1 | 一致性 | 各 sim screen |
| C4 | single_bulb 垂直滑块违反 footer 底部横排规范 | P1 | 布局规范 | `single_bulb_screen.dart` |
| C5 | circuit footer 无 `FittedBox` 缩放兜底 | P1 | 布局规范 | `circuit_screen.dart` footer |
| C6 | molarity 烧杯无拖拽交互（拖溶质瓶/水龙头），与 PhET 原版差距大 | P1 | 画布手势 | `molarity_screen.dart` |
| C7 | radio_waves / wave_interference 画布无手势（不能拖天线/波源/缝） | P1 | 画布手势 | 对应 screen |
| C8 | circuit `onDoubleTap` 导致 `onTapUp` 约 400ms 延迟 | P2 | 手势冲突 | `circuit_screen.dart` |
| C9 | 知识点入口位置不统一（AppBar / bottomRight / 无） | P2 | 一致性 | 各 sim screen |
| C10 | 返回导航不统一（部分 sim 有 AppBar 返回键，部分无） | P2 | 一致性 | 各 sim screen |

**统计**：P0 × 4 · P1 × 8 · P2 × 6 = **18 项**

---

## 二、做中学探究工作流问题（A 类 · 阶段切换）

### A1 预测题状态不共享（P0）✅ 已修复

预测题同时渲染在两处，`PredictionPanel` 各自持有 `_selected` / `_verified` State（`prediction_panel.dart:19-20`）：

- `ExperimentIntroPanel` 弹窗（`experiment_intro_panel.dart:131-134`）
- `InquiryDrawer` 抽屉（`inquiry_drawer.dart:57-58`）

学生在弹窗答完题 → 关闭弹窗 → 打开抽屉，预测题又是空白，需重答。同一学习任务在两个入口状态不一致，**直接破坏"猜测→验证"阶段的连续性**。

**修复**（2026-08-18 · 方案 B 用户确认）：弹窗移除内嵌 `PredictionPanel`，含预测题时显示"去猜一猜"跳转入口（`_buildPredictionEntry`），点击关闭弹窗并调 `onOpenInquiry` 打开抽屉；预测题统一在抽屉内做（单一入口）。circuit / molarity 已接入 `onOpenInquiry`。新增回归测试 `test/common/experiment_intro_panel_test.dart`。

### A2 验证后改答案，判定结果不更新（P0）✅ 已修复

`prediction_panel.dart:55-60`：`onSelect` 只写 `_selected[id]`，**不从 `_verified` 移除**。学生验证后改答案，"猜对了/猜错了"的判定仍停留在旧答案的验证结果。

**修复**（2026-08-18）：`onSelect` 时同步从 `_verified` 移除该题，强制重新验证。已补回归测试「验证后改答案 → 验证结果重置」。

### A3 阶段切换无进度指示，"操作"与抽屉零联动（P1）

- 无显式阶段进度（猜 ✓ → 记 (3条) → 归纳）——学生不知道自己在哪个阶段。
- `InquiryTaskPanel` 的 steps 是纯静态文本（`inquiry_task_panel.dart:43`），无完成标记。
- 学习闭环的核心"操作 sim"发生在画布（抽屉外），与抽屉组件**零联动**；唯一桥梁是 `ExperimentLogger.snapshotProvider`（`experiment_logger.dart:54`），需学生主动点"记录本次实验"——无"你还没记录"或"基于记录来归纳"的引导。

**修复方向**：抽屉顶部加轻量阶段进度条（按数据自动点亮）；记录 ≥2 条时图表区给引导、≥3 条时结论面板给"可以归纳了"提示。

### A4 `_inquiryOpen` 默认值割裂（P1）

circuit / molarity 为 `true`（有预测题即默认展开），其余 6 sim 为 `false`——学生进入这些 sim 根本不知道右侧有探究工作流。

**修复方向**：全部统一为"有 inquiryTask 即默认展开"（对齐 circuit/molarity 先例）。

### A5 结论"修改"绕过防抄设计（P2）

`conclusion_panel.dart:159-168`：修改结论时参考结论仍可见，学生可边抄边改。"提交后参考结论不可收回"的防抄意图被"修改结论"路径削弱。

**修复方向**：修改时可选择临时隐藏参考结论，或明确此为可接受折衷（允许迭代完善）。

### A6 任务卡冗余展示（P2）

`InquiryTaskPanel` 同时出现在弹窗（`experiment_intro_panel.dart:129`）与抽屉，同一任务两处展示。

---

## 三、主界面问题（B 类）

### B1 主界面无响应式（P2）

`home_screen.dart` 用 `GridView.count(crossAxisCount: 3)` 固定 3 列，窄屏不降级列数。桌面横屏场景可接受，但违背项目 L0-2 响应式原则的普适性。

---

## 四、各 sim 交互问题（C 类）

### C1 ~~`ScenarioSelectionScreen` 死代码~~（更正：非死代码）

**2026-08-18 更正**：初判"死代码"有误。`lib/screens/scenario_selection_screen.dart` 实为 optics 的**活跃**场景切换路径——`optics_screen.dart:213-216` AppBar folder 图标 → `_showScenarioPicker`（421-436 行）→ `Navigator.push` 全屏选择页 → pop 返回场景 id。当前正确描述：这是 optics 的"全屏页面"场景切换模式，与其他 sim 的菜单/弹窗模式不一致，应并入 **C3 一致性问题**（optics 案例），而非删除。

### C2 rgb_bulbs 探索模式无 RGB 数值滑块（P0）✅ 已修复

`rgb_bulbs_screen.dart:684-693`：探索模式 footer 只有色块 + 标签开关，RGB 强度只能 `onPanUpdate` 拖瓶子调，无数值滑块直接输入，发现性差。

**修复**（2026-08-18）：探索模式 footer 复用挑战模式的 `_miniSliderVertical` 补 R/G/B 三个数值滑块（footer 已有横向滚动，无溢出风险）。

### C3 场景切换 5 种模式并存（P1）

| sim | 场景切换方式 |
|---|---|
| circuit / radio_waves / wave_interference | AppBar `ScenarioMenuButton` |
| sound | bottomCenter 场景快切条 |
| molarity | topCenter 内嵌 `PopupMenuButton` |
| optics | 自定义弹窗 |
| rgb_bulbs | topRight `ScenarioMenuButton` |

**修复方向**：统一为 `ScenarioMenuButton`（sound 快切条可保留但样式对齐）。

### C4 single_bulb 垂直滑块违反 footer 规范（P1）

`single_bulb_screen.dart` 用 midRight 垂直 CompactSlider，是"footer 底部横排"规范的唯一例外。

### C5 circuit footer 无 `FittedBox` 缩放兜底（P1）

其他 sim footer 已加 `FittedBox fit: scaleDown`，circuit footer 仅依赖横向滚动，窄视口风险更高。

### C6 molarity 烧杯无拖拽交互（P1）

烧杯纯展示，不能拖溶质瓶倒入/水龙头加水（PhET 原版核心交互），只能 footer 滑块。

### C7 radio_waves / wave_interference 画布无手势（P1）

不能拖天线位置/电子、波源/缝，纯被动观察 + footer 滑块。

### C8 circuit `onDoubleTap` 致 `onTapUp` 延迟（P2）

`circuit_screen.dart` 注册 `onDoubleTap` 后，`onTapUp` 需等双击判定窗口（约 400ms），连接触点响应迟滞（notes 已记录）。

### C9 知识点入口位置不统一（P2）

sound / radio / wave 在 AppBar info；color_vision 在 bottomRight；forces / optics / circuit / molarity 无知识点面板。

### C10 返回导航不统一（P2）

sound / radio / wave / molarity 有 AppBar 自动返回键；forces / color_vision / optics / circuit 无 Scaffold/AppBar（靠 home 导航栈）。

---

## 五、修复优先级建议

| 批次 | 内容 | 涉及问题 | 状态 |
|---|---|---|---|
| **第一批（P0 · 逻辑错误）** | 预测题状态共享（方案 B）+ 验证后改答案重置 + rgb_bulbs 补滑块 + 更正 C1 死代码误判 | A1 A2 C1 C2 | ✅ 已完成（commit `d1d4c4c`/`9a43c8e`） |
| **第二批（P1 · 一致性）** | 场景切换统一 + `_inquiryOpen` 统一 + single_bulb 垂直滑块迁移 + circuit footer 补 FittedBox | A4 C3 C4 C5 | 待做 |
| **第三批（P1 · 交互增强）** | 阶段进度条 + 记录/结论联动引导 + molarity/radio/wave 画布手势 | A3 C6 C7 | 待做 |
| **第四批（P2 · 打磨）** | 结论修改防抄 + 任务卡去重 + 知识点/返回统一 + 主界面响应式 | A5 A6 C9 C10 B1 | 待做 |

## 六、测试基线备注（2026-08-18）

`flutter test test/common/ test/chemistry/molarity/ test/circuit/` 有 **8 个预存在失败**（stash 本轮改动后重跑结果一致，非本批修复引入）：

- **6 个 `nine_grid_layout_test.dart`**：中间格面积断言 `closeTo(0.7)`，实际约 `0.569`（`centerAreaRatio` 计算与测试预期不符）
- **2 个 `molarity_screen_test.dart`**：AC-4.1 `find.textContaining('溶质量')` 期望 1 个实际 5 个；AC-5.5 `science_outlined` 图标歧义 2 个

建议另立任务排查（疑似 `nine_grid_layout.dart` 面积公式与测试断言语义不一致 + molarity 屏幕文本/图标重复），不在本批交互修复范围内。

---

*引用规则：所有行号基于 2026-08-18 工作区源码。修复前请先 Read 确认行号未漂移。*
