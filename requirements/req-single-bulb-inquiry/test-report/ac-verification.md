# AC 验证报告 · req-single-bulb-inquiry

> 生成时间：2026-08-19 15:30（closing 阶段 · 补 code-reviewer B-1）
> 验证执行者：主会话（iteration 15:04 首跑 + 本文件落盘复跑 15:30）；code-reviewer 15:25 独立复跑
> 测试日志：`test-report/integration-test.log`（flutter test 88/88 全绿 · 2026-08-19 15:30 落盘）

## 一、执行命令与结果

| 命令 | 结果 |
|---|---|
| `flutter test test/color_vision test/color_vision_model_test.dart test/color_vision_l9_regression_test.dart test/rgb_bulbs_layout_test.dart test/single_bulb_layout_test.dart` | **88/88 All tests passed**（含本需求新增 10 用例） |
| `flutter analyze lib/color_vision test/color_vision test/color_vision_l9_regression_test.dart test/single_bulb_layout_test.dart` | 改动文件 **0 新增 issue**（仅 2 个既有 info：rgb_bulbs_screen.dart:259 / magic_lab_ac44_test.dart:2，均不在本需求改动文件内） |

## 二、AC → 测试用例引用表

| AC | 验证方式 | 测试用例（test/color_vision/single_bulb_inquiry_test.dart） | 结果 |
|---|---|---|---|
| AC-1 抽屉接入（有 task 展开/无 task 隐藏） | widget test | :108「含 inquiryTask → 抽屉默认展开 + 入口按钮存在」· :121「无 inquiryTask → 入口按钮隐藏 · 抽屉不渲染内容（回退安全）」 | ✅ |
| AC-2 入口按钮切换 | widget test | :108（按钮存在 · tooltip 定位）· :130「点击入口按钮切换抽屉开合」 | ✅ |
| AC-3 snapshotProvider 数据正确 | widget test + unit test | :154「白光+红滤光片记录一次 → 行数据正确」（白光/—/红色/Red + 实验记录（1/20））· :75（key 与 JSON snapshotColumns 逐项一致断言） | ✅ |
| AC-4 场景 JSON 有效可加载 | unit test（真实 manifest+JSON） | :75「single-inquiry-subtractive 已注册且字段完整」（screen==singleBulb · 3 steps · 4 snapshotColumns · predictions 空） | ✅ |
| AC-5 进度条 2 节点 | widget test | :143「无预测题 → 进度条 2 节点（记录/归纳），无「猜测」」 | ✅ |
| AC-6 布局合规 + State 保持 | widget test | :177「记录后关闭再打开抽屉 → 记录 State 保持」· :201-206 三视口无 overflow（320×480 / 1024×768 / 1920×1080，抽屉展开态） | ✅ |

## 三、诚实声明

- [x] 全部 AC 均有自动化测试覆盖并真实执行（88/88 全绿 · integration-test.log 落盘）
- [x] 已知未执行项如实列出（见下方 1-4 条，含 AC-4 端到端手动抽验待用户执行）
- [x] 用例计数勘误已声明（iteration 日志"9 用例"为口误，实际 10 个用例）

1. **用例计数勘误**：iteration 日志与首次汇报写"9 用例"为口误，实际 **10 个用例**（1 unit + 9 widget，testWidgets×3 视口循环计 1 处定义 3 次执行）——以本报告为准。
2. **未执行项**：
   - 全仓库测试套件未跑（含 forces 基线已知超时项 netforce-tug，属既有独立任务，非本需求范围）
   - AC-4 端到端手动抽验（启动 App → 色彩视觉 → 滤光镜 Tab → 抽屉默认展开）**未执行**，属用户抽验点；自动化等价证据为 :75 真实 manifest 加载断言 + home fallback 代码（color_vision_home.dart:37-39）
   - SnapshotChart 对本场景列设计（3 文本 + 1 条件数值列）显示空态文案"有效数值数据不足 2 组"——**组件契约行为非 bug**（design §5.2 R1 已声明）
3. **已知回归联动**：test/color_vision_l9_regression_test.dart 场景数断言 10→11 为本需求连带修改（manifest 新增场景），已含在 88 用例全绿内。
4. **测试环境**：flutter test（Windows · fake async · 内联场景 JSON）；integration_test 真机/桌面 harness 未运行。

## 四、评审联动

- code-reviewer 结论：passed_with_suggestions · verdict=tweak（design/代码评审.md）
- B-1（本文件 + integration-test.log）即 tweak 的修复动作；代码层无返工项
- M-1（commit 切分）：closer 执行 commit 时须切分——本需求仅含 7 处改动文件，工作区另有 C7 拖拽相关 4 文件（radio_waves/wave_interference/wave_radio_layout_test/docs 汇总）不得混入同一 commit
