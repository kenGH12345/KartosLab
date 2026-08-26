# 做中学 · 阶段转换交互设计（Inquiry Workflow Stages）

> 整理日期：2026-08-18
> 范围：做中学（ICAP 框架）探究工作流的阶段划分、组件职责、阶段转换交互、已修复问题
> 相关需求：`req-inquiry-learning`（做中学升级）· `req-predictive-inquiry`（预测题）· `req-inquiry-chart-poc/extend`（记录图表化）
> 修复记录：`docs/reviews/interaction-issues-2026-08.md`（A 类 6 项已全部完成）

---

## 一、阶段模型（学习闭环）

做中学按 ICAP 框架（Chi & Wylie 2014）把探究组织为 5 阶段闭环：

```
① 猜测 → ② 任务 → ③ 操作 → ④ 记录 → ⑤ 归纳
```

| 阶段 | 教学意图 | 载体组件 | 位置 |
|---|---|---|---|
| ① 猜测 | 操作前预测答案，建立认知冲突（"先猜后验"） | `PredictionPanel` | 抽屉顶部（有预测题时） |
| ② 任务 | 明确探究问题与分步指引 | `InquiryTaskPanel` | 抽屉第 2 位 |
| ③ 操作 | 在 sim 画布上动手实验 | 各 sim 画布（不在抽屉内） | 画布 |
| ④ 记录 | 快照当前参数/读数，累积对比 | `ExperimentLogger` + `SnapshotChart` | 抽屉第 3/4 位 |
| ⑤ 归纳 | 先自主写结论，再对照参考结论 | `ConclusionPanel` | 抽屉第 5 位 |

**入口**：`ExperimentIntroPanel`（边格常驻一行说明 + 点击弹窗）→ 弹窗含任务概览 +「去猜一猜」跳转 → 打开 `InquiryDrawer`。

---

## 二、组件职责与阶段转换

### 2.1 抽屉容器 `InquiryDrawer`（`lib/common/widgets/inquiry_drawer.dart`）

- **结构**：`Offstage(offstage: !open)` 常驻 widget 树（关闭再开不丢记录/结论 State）
- **内容顺序**（自上而下 = 学习闭环顺序）：
  1. 阶段进度条 `_ProgressBar`（A3 新增）
  2. 预测题 `PredictionPanel`（有 predictions 时）
  3. 任务卡 `InquiryTaskPanel`（compact）
  4. 记录器 `ExperimentLogger` + 关系图 `SnapshotChart`（columns 非空时）
  5. 结论 `ConclusionPanel`
- **宽度**：固定 280px（项目允许硬编码控件面板宽度）

### 2.2 阶段进度条 `_ProgressBar`（A3 新增）

**节点**：`猜测 → 记录 → 归纳`（3 节点；无预测题时为 `记录 → 归纳` 2 节点）

**点亮规则**（按数据自动，无手动点击）：

| 节点 | 点亮条件 | 数据来源 |
|---|---|---|
| 猜测 | 已验证题数 == 预测题总数 | `PredictionPanel.onVerifiedChanged` |
| 记录 | 记录行数 ≥ 1 | `ExperimentLogger.onRowsChanged` |
| 归纳 | 结论已提交 | `ConclusionPanel.onSubmittedChanged` |

**视觉**：已完节点 = 蓝色实心圆 + check 图标；进行中 = 空心蓝圈；未到 = 灰圈。连线随完成度变蓝。

**设计意图**：解决"学生不知道自己在探究哪个阶段、下一步该做什么"——进度条让闭环进度可见，且**数据驱动**（操作完自然点亮，无强制步骤）。

### 2.3 预测题 `PredictionPanel`（猜测阶段 · 预测→验证）

- **状态**：`_selected`（已选选项）+ `_verified`（已验证题集合），保留在 State
- **交互**：
  - 选择选项 → `onSelect`（选中即**重置验证状态**，A2 修复：改答案后需重新验证）
  - 点「验证我的猜测」→ `onVerify` → 显示对错 + 解析
  - 已验证 → 展示"猜对了/猜错了 + 正确答案 + 原因"
- **回调**：`onVerifiedChanged(int)` 通知已验证题数（供进度条）
- **向后兼容**：回调为 null 时不通知（旧调用方不受影响）

### 2.4 任务卡 `InquiryTaskPanel`（任务阶段）

- 只读展示 question + 分步指引（steps + hints）
- `ExpansionTile` 默认展开；`task == null` 不渲染
- **A6 解决**：预测题不再内嵌于 `ExperimentIntroPanel` 弹窗，弹窗仅留任务概览（compact）+ 跳转入口

### 2.5 记录器 `ExperimentLogger`（记录阶段）

- 手动快照：点「记录本次实验」→ 插入一行（时间戳 + 参数/读数）
- `maxRows=20`，满额提示；支持删除单行 / 清空
- `onRowsChanged` 通知行数变化（供进度条 + SnapshotChart）

### 2.6 结论 `ConclusionPanel`（归纳阶段 · 两阶段状态机）

| 状态 | 行为 |
|---|---|
| 未提交 | 文本框 +「提交我的结论」；参考结论**不可见**（"结论先消失"防抄）；空文本提交有 SnackBar 提示 |
| 已提交 | 展示"你的结论" +「参考结论」对照；参考结论展开后**不可收回** |
| 编辑中 | 点「修改结论」→ 重新编辑；**编辑时参考结论隐藏**（A5 修复：杜绝"边抄边改"）；取消/更新按钮 |

- 回调：`onSubmittedChanged(bool)` 通知提交状态（供进度条）

### 2.7 入口 `ExperimentIntroPanel`（引导入口）

- 常驻一行展示 `description`（回答"这是什么实验"），点击弹窗
- 弹窗内容：description + 任务概览（`InquiryTaskPanel` compact）+ **预测题跳转入口**（A1 修复）
- 跳转入口：含预测题时显示"去猜一猜"按钮 → 关闭弹窗 → `onOpenInquiry` 打开抽屉
- 各 sim 接入 `onOpenInquiry: () => setState(() => _inquiryOpen = true)`

---

## 三、抽屉默认开合策略（A4 统一）

**统一规则**：`_inquiryOpen = scenario.inquiryTask != null`（有探究任务即默认展开，进入即见任务/预测题；无任务时抽屉不渲染，无副作用）。

已统一 8 个 sim（`circuit / optics / forces(netforce+motion) / color_vision(rgb+single) / sound / radio_waves / wave_interference / molarity`）：

| sim | 现状（统一后） |
|---|---|
| circuit / molarity | 有预测题 → 进入即展开（先猜） |
| 其余 6 sim | 有 inquiryTask → 进入即展开（先看任务） |

场景切换时按新场景的 `inquiryTask` 重新决定（`_applyScenario` 内同步）。

---

## 四、阶段转换的完整用户路径

```
进入 sim（有 inquiryTask）
  → 抽屉默认展开，进度条显示：○猜测 ○记录 ○归纳
  → ① 预测题：选答案 → 验证 → 进度条"猜测"点亮 ✓
  → ② 任务卡：读问题 + 步骤
  → ③ 画布操作（SimulationClock 驱动的 sim 有 play/pause/step）
  → ④ 点「记录本次实验」≥1 次 → 进度条"记录"点亮 ✓ → 关系图出现
  → ⑤ 写结论 → 提交 → 进度条"归纳"点亮 ✓ → 对照参考结论
  → 全部点亮 = 探究闭环完成
```

---

## 五、已修复问题对照（A 类 6 项 · 全部完成）

| # | 问题 | 修复 | Commit |
|---|---|---|---|
| A1 | 预测题状态不共享（弹窗 vs 抽屉双实例） | 弹窗移除内嵌预测题，改「去猜一猜」跳转，单一入口 | `d1d4c4c` |
| A2 | 验证后改答案判定结果不更新 | `onSelect` 重置 `_verified`，强制重新验证 | `9a43c8e` |
| A3 | 阶段切换无进度指示 | 抽屉顶部 3 节点进度条（数据驱动自动点亮） | `644923c` |
| A4 | `_inquiryOpen` 默认值割裂（6 sim 无入口感知） | 统一"有 inquiryTask 即默认展开" | `2788522` |
| A5 | 结论"修改"绕过防抄 | 编辑态隐藏参考结论 | `2788522` |
| A6 | 任务卡弹窗/抽屉冗余 | A1 方案 B 顺带解决（弹窗只留任务概览） | `d1d4c4c` |

**测试**：common 47 测试全过（含 prediction_panel 6 / conclusion_panel 6 / snapshot_chart 9 / intro_panel 2 / 进度条相关）；molarity 5；wave/radio 布局 7。

---

## 六、后续可优化（非阻塞）

- **导出**：`ExperimentLogger.onExport` 已留接口未实现（可导出 CSV）
- **进度持久化**：当前进度仅内存（session 级），关闭 App 丢失
- **预测题推广**：预测题目前仅 circuit/molarity 试点，其余 6 sim 无 predictions（进度条自动降为 2 节点）

---

*组件源码：`lib/common/widgets/{inquiry_drawer, prediction_panel, inquiry_task_panel, experiment_logger, conclusion_panel, experiment_intro_panel}.dart` + `lib/common/chart/snapshot_chart.dart` + `lib/common/widgets/inquiry_models.dart`*
