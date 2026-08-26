# How-To：向一个 sim 屏接入做中学探究抽屉（InquiryDrawer）

> 来源: 从 [kratos-java-simulations/shared-abstraction-plan.md](../../kratos-java-simulations/shared-abstraction-plan.md) 候选 8「接入模式」抽取 + req-single-bulb-inquiry（single_bulb 屏）最新实证整理 | 创建时间: 2026-08-19
> 实证屏: circuit / color_vision-rgb_bulbs / optics / forces / sound / radio_waves / wave_interference（req-inquiry-extend · 7 sim）+ color_vision-single_bulb（req-single-bulb-inquiry · 第 8 屏）
> 参照屏: `lib/color_vision/screens/rgb_bulbs_screen.dart`（接入最完整）· `lib/color_vision/screens/single_bulb_screen.dart`（最新 1:1 复刻实证）

## 前置条件

- 该 sim 的场景 JSON 有（或计划新增）顶层 `inquiryTask` 字段（question / steps / referenceConclusion / snapshotColumns / predictions 可选）。
- 确认 model 的 `fromJson` 解析 `inquiryTask` **不按 screen 类型分支**（如 `ColorVisionScenario.fromJson` `color_vision_scenario.dart:211-213` 与 screen 解析完全独立）——若 model 尚无 `inquiryTask?` 可空字段，先按「model 加字段 + fromJson 判空」补齐（向后兼容，缺失时 sim 传统模式运行）。
- 已读组件族规划与契约：[shared-abstraction-plan.md](../../kratos-java-simulations/shared-abstraction-plan.md) 候选 8 + §8.1（SnapshotChart 快照列选轴语义，**单一源**）。

## 通用模式（7+1 屏固化的三步接线）

```
① model：加 inquiryTask? 可空字段 + fromJson 判空（缺失 = 纯观察场景，向后兼容）
② screen：Stack 外包 + 入口按钮 + InquiryDrawer 四参数接线
③ JSON：补 inquiryTask 字段 + manifest 注册
④ 连带检查：场景可达性 + 回归测试计数断言（易漏，见易错点）
```

## 步骤

### 1. State 初始化（默认展开 + 回退安全）

```dart
bool _inquiryOpen = false;                       // 模式同 rgb_bulbs_screen.dart:58

@override
void initState() {
  super.initState();
  _inquiryOpen = widget.scenario?.inquiryTask != null;  // 有 task 默认展开
}
```

### 2. build 外包 Stack（InquiryDrawer 浮层不挤占九宫格）

```dart
// 原本 build 直接返回 NineGridLayout(...)，改为：
return Stack(children: [
  NineGridLayout(...),          // 原主布局不动
  InquiryDrawer(                // Stack 第二子节点（rgb_bulbs_screen.dart:311-375 同构）
    task: _inquiryTask,
    columns: _inquiryColumns(task),
    snapshotProvider: _snapshot,
    open: _inquiryOpen,
  ),
]);
```

四参数签名跨 8 屏一致：`task / columns / snapshotProvider / open`。`InquiryDrawer` 内部 `Offstage` 常驻四组件保 State + `Align(centerRight)` + 固定宽 280 浮层（`inquiry_drawer.dart:56-64`），满足九宫格主图 ≥70% 约束（L0-4）。**Stack 无定位子 = 铺满同尺寸，单子节点时布局行为与不包 Stack 等价**——纯观察场景渲染结果与改动前一致。

### 3. 入口按钮（空闲边格 + 已实证样式）

- 先盘点该屏 NineGridLayout 各边格占位，选**空闲格**（如 single_bulb 的 topRight/midLeft/bottomLeft 空闲，选 topRight；`技术方案.md` §1 T2 有占位盘点先例）。若该屏有场景菜单（ScenarioMenuButton）注意避让。
- 样式照抄已实证模式（`rgb_bulbs_screen.dart:377-389`）：`Center` + `IconButton.filledTonal` + `VisualDensity.compact` + `Icons.science_outlined, size 20`。
- `task == null` 时入口按钮返回 `SizedBox.shrink()`（`rgb_bulbs_screen.dart:379-380` 同模式）。

### 4. snapshotProvider 与 columns（key 一致性是硬约束）

```dart
Map<String, dynamic> _snapshot() => {
  // key 必须与场景 JSON snapshotColumns[].key 逐项一致（ExperimentLogger 契约，
  // experiment_logger.dart:3-5）——AC 断言按 Set 比较
};

List<ColumnDef> _inquiryColumns(task) {
  // task.snapshotColumns 非空 → 映射 ColumnDef(key, label, isParam: source == 'param')
  // 空 → 给同 key 集默认列兜底（rgb_bulbs_screen.dart:422-440 同模式）
}
```

- snapshot 值尽量**复用 screen 内既有取值逻辑**（零新算法）。
- 列设计注意 §8.1 契约：第 1 个 param 列 × 第 1 个 reading 列构成有意义的"参数×读数"关系对；全文本列设计 → 默认关系图无点显示空态文案，**是组件契约行为非 bug**（`snapshot_chart.dart:76-86` 双分支）。

### 5. JSON + manifest + 连带检查（最易漏的一步）

- 场景 JSON 补 `inquiryTask`（steps ≥ 2 · referenceConclusion · snapshotColumns ≥ 2 且含 param + reading）；**无 `predictions` 字段 → 进度条自动 2 节点**（记录→归纳，`inquiry_drawer.dart:41-49`，零开发）。
- manifest 注册新场景。
- **可达性检查**：追「谁加载它」的调用链到 home/菜单层——manifest 注册 ≠ 用户可达（见 [../notes.md](../notes.md) 踩坑「场景可达性陷阱」；home 场景 ID 硬编码时需双 findById fallback，先例 `color_vision_home.dart:37-39`）。
- **回归测试计数断言**：全局搜该 sim 回归测试中硬编码的场景数断言（如 `test/color_vision_l9_regression_test.dart` 10→11），同步 +1。

## 易错点

- ⚠️ **snapshot key 与 JSON snapshotColumns 逐项一致**是 ExperimentLogger 硬契约——key 拼错/遗漏不会报错，只会记录表列异常。
- ⚠️ **值的中英文来源要分清**：screen 自己映射的列（如 `_ftLabel` 滤光片）返回中文，而 `ColorModel.colorName` 返回**英文**（如 Red）——测试断言写中文会挂，注释写中文会误导（req-single-bulb-inquiry Nit n-1 实证：断言 `Red` 正确，注释「红色」误导）。
- ⚠️ **纯观察场景回退安全**靠四重保护（`_inquiryOpen` 初始 false + initState 判空 + 入口按钮 shrink + 组件内建 shrink），缺一不可，测试建议正负双例（有 task 默认展开 / 无 task 按钮隐藏且内容不渲染）。
- 入口按钮 tap 测试用 `byTooltip` 定位（先例 single_bulb `:152,188-199`）。
- `testWidgets` × N 视口循环 = 1 处定义 N 次执行——**汇报测试计数前先 `grep -c "testWidgets\|test("` 数一遍**，别凭印象报数（req-single-bulb-inquiry Minor m-1 实证）。

## 验证方法（req-single-bulb-inquiry AC 清单可复用）

1. widget test 正负双例：含 task 场景 → InquiryDrawer 存在且 `Offstage.offstage == false`；无 task 场景（任一纯观察场景）→ 树中无 InquiryDrawer 内容、无入口按钮。
2. `byTooltip` tap 入口按钮 → offstage 翻转；再 tap 恢复。
3. snapshotProvider 断言 keys == JSON snapshotColumns 的 key 集合（Set 比较）；记录 1 行后值正确。
4. 进度条节点数（IXD Spec v1.0 五阶段：猜/任/操/记/归）：无 predictions → 仅「任/操/记/归」4 节点 + 「0/4 已完成」计数，无「猜」节点；有 predictions → 5 节点。
5. 状态机链路（guided 默认模式）：初始仅猜测卡 Active、后续 Locked（任务内容/记录按钮不可见）→ 验证全部预测题（验证后 1.5s 自动下一题）→ 任务卡 Active 出现「我已了解任务，开始实验」→ 确认后操作卡 Active（记录按钮可用）→ 记录 1 行后记录/归纳卡解锁（表格 + 关系图 + 「去写结论」）→ 提交结论触发 Celebration。测试中 tap 记录按钮前需 pump 足够时长（ensureVisible 滚动动画进行中 tap 会被滚动手势劫持）。
5. 三视口（320×480 / 1024×768 / 1920×1080）抽屉展开态无 overflow。
6. 关开抽屉后已记录行与结论 State 保持（Offstage 保 State）。
7. `flutter analyze` 改动文件 0 新增 issue。
8. **测试证据落盘**：iteration 收工时即把 `flutter test` 输出重定向到 `test-report/integration-test.log` + 写 `ac-verification.md`（AC→test:line 引用表格式，先例需求已沉淀该惯例）——零成本避免 closing 被评审以证据链缺失打回（req-single-bulb-inquiry B-1 实证）。

## 与其他文档关系

- **组件族规划与 SnapshotChart 契约（单一源）**：[kratos-java-simulations/shared-abstraction-plan.md](../../kratos-java-simulations/shared-abstraction-plan.md) 候选 8 + §8.1。
- 布局约束（九宫格 / L0-4）：[../frontend/ui-framework.md](../frontend/ui-framework.md) 第三节 + [../notes.md](../notes.md) 9 宫格决策。
- 场景可达性与 manifest knock-on 踩坑（单一源）：[../notes.md](../notes.md)。

## 维护钩子

- 本约定由 `managing-knowledge` Skill 在日常维护中回写：任何屏新接入 InquiryDrawer 或组件族 API 变化时，同步更新本文件。
- 本文件已登记于 [INDEX.md](../INDEX.md) 与 [conventions/INDEX.md](INDEX.md)。
