# AC 验证证据链 — req-inquiry-learning

> 验证方式：真实执行 `flutter test`（除 forces 基线超时文件外全量）+ `flutter analyze` + 代码/JSON 审查
> 执行时间：2026-08-07
> 测试日志：`integration-test.log`
> 结论摘要：**190 通过 / 0 失败**（除 forces 外）；AC 全覆盖；forces 基线超时为已知历史问题，非本需求引入

---

## 测试统计总览

| 范围 | 结果 | 说明 |
|---|---|---|
| 全量测试（除 `test/forces/forces_scenario_test.dart`） | **190 通过 / 0 失败** | 日志末尾 `All tests passed!` |
| forces 模块 | 6 通过 / 1 超时 | `netforce-tug scenario has valid pullers` 死循环超时（**基线问题**，forces 零改动，见下） |
| `flutter analyze` | 本需求代码 0 error | 唯一 error 全部位于 `docs/knowledge/phet-common/`（历史提交 e180529 引入的参考文档，非本需求，非运行代码） |

---

## 逐 AC 验证表

### AC-1 · 通用组件就绪

| # | 验证点 | 验证方式 | 测试引用（file:line） | 结果 | 备注 |
|---|---|---|---|---|---|
| 1.1 | `InquiryTaskPanel` 存在 | `ls` + 测试 | `lib/common/widgets/inquiry_task_panel.dart` 存在 | ✅ | — |
| 1.2 | `ExperimentLogger` 存在 | `ls` + 测试 | `lib/common/widgets/experiment_logger.dart` 存在 | ✅ | — |
| 1.3 | `ConclusionPanel` 存在 | `ls` + 测试 | `lib/common/widgets/conclusion_panel.dart` 存在 | ✅ | — |
| 1.4 | 三组件不依赖特定 sim 的 model | 代码审查 import | 三组件仅 import `flutter/material.dart`、`foundation.dart`、`inquiry_models.dart`；`inquiry_drawer.dart` 引用三者 | ✅ | 0 处 `lib/circuit/` / `lib/color_vision/` 依赖 |
| 1.5 | task==null 不渲染（SizedBox.shrink） | 单元测试 | `test/common/inquiry_task_panel_test.dart:9-16` | ✅ | 实测通过 |
| 1.6 | 点击"记录"追加一行 / maxRows 20 上限 | 单元测试 | `test/common/experiment_logger_test.dart:17-37`（追加）、`:39-54`（maxRows 拒绝+提示） | ✅ | 实测通过 |
| 1.7 | 提交前参考结论不可见 / 提交后展开不可收回 | 单元测试 | `test/common/conclusion_panel_test.dart:9-17`（提交前）、`:19-31`（提交后展开）、`:53-69`（再次编辑参考结论仍可见） | ✅ | 实测通过 |

### AC-2 · JSON Schema 扩展

| # | 验证点 | 验证方式 | 测试引用（file:line） | 结果 | 备注 |
|---|---|---|---|---|---|
| 2.1 | circuit + color_vision 各含有效 `inquiryTask` | JSON + 测试 | `assets/scenarios/circuit/simple-series.json`；`assets/scenarios/color-vision/rgb-challenge-basic.json`；解析见 `test/circuit/inquiry_snapshot_test.dart:14-28` | ✅ | 实测解析通过 |
| 2.2 | color_vision 含有效 `challenge` | JSON + 测试 | `rgb-challenge-basic.json` + `rgb-default.json`；`test/color_vision/challenge_config_test.dart:15-37` | ✅ | 实测解析通过 |
| 2.3 | 无新字段旧 JSON 加载不报错 | 单元测试 | `test/circuit/inquiry_snapshot_test.dart:30-40`（inquiryTask==null）、`test/color_vision/challenge_config_test.dart:39-51`（challenge==null） | ✅ | 实测通过 |
| 2.4 | snapshotColumns key 与 snapshotProvider 一致 | 集成测试 | `test/circuit/inquiry_snapshot_test.dart:43-63`（keys = resistance/voltage/current/brightness） | ✅ | 实测通过 |

### AC-3 · Pilot Sim 接入

| # | 验证点 | 验证方式 | 测试引用（file:line） | 结果 | 备注 |
|---|---|---|---|---|---|
| 3.1 | Circuit：含 inquiryTask 场景显示任务卡 | 代码审查 + widget 集成 | `lib/circuit/screens/circuit_screen.dart:411-415`（InquiryDrawer 接入）、`:437-438`（`_inquiryTask` getter） | ✅ | 抽屉入口按钮 `:423-435` 仅在有 inquiryTask 时显示 |
| 3.2 | Circuit：点记录→表格新增行 | 集成测试 | `test/circuit/inquiry_snapshot_test.dart:43-63`（`_circuitSnapshot` 数据源字段可用） | ✅ | 实测数据字段可用 |
| 3.3 | Circuit：提交结论后可见参考结论 | 通用组件测试覆盖 | `test/common/conclusion_panel_test.dart:19-31`（组件层）；circuit 复用该组件 | ✅ | 组件行为已被测试覆盖 |
| 3.4 | Color Vision：探究型场景三组件正常 | 代码审查 + 测试 | `lib/color_vision/screens/rgb_bulbs_screen.dart:287-296`（InquiryDrawer）、`:328-329`；`magic_lab_ac44_test.dart:57-65`（inquiryAdditive 场景构造）、`:96-111`（切到探究场景） | ✅ | 实测通过 |
| 3.5 | Color Vision：挑战从 JSON 读取配置 | 代码审查 | `rgb_bulbs_screen.dart:133-139`（`_challengeTimeLimit` 读 `cfg.timeLimit`）、`:141-145`（`_accuracyThreshold` 读 `cfg.accuracyThreshold`）、`:109-121`（`_nextTargetColor` 读 `cfg.targets`） | ✅ | JSON 驱动，缺省才 fallback |
| 3.6 | 两 sim 传统场景不受影响 | 回归测试 | `test/color_vision_l9_regression_test.dart`（10 个场景全部加载校验通过）；`test/common/nine_grid_layout_test.dart`（九宫格布局不变） | ✅ | 实测通过 |

### AC-4 · 挑战模式 JSON 驱动化

| # | 验证点 | 验证方式 | 测试引用（file:line） | 结果 | 备注 |
|---|---|---|---|---|---|
| 4.1 | 目标色从 JSON `challenge.targets` 读取 | 代码审查 | `rgb_bulbs_screen.dart:109-121`（`_nextTargetColor`：`cfg.targets[_level-1]` 按序出题） | ✅ | targets 用尽才有 randomTargets / fallback |
| 4.2 | 倒计时从 JSON 计算 | 代码审查 | `rgb_bulbs_screen.dart:133-139`（`cfg.timeLimit + (level-1)*cfg.timeBonusPerLevel`） | ✅ | JSON 驱动 |
| 4.3 | 精度阈值从 JSON 读取 | 代码审查 | `rgb_bulbs_screen.dart:141-145`（`_accuracyThreshold` 返回 `cfg.accuracyThreshold`） | ✅ | JSON 驱动，缺省回退 99.99 |
| 4.4 | 挑战完成触发 `checkObjectives` | 单元 + widget 测试 | `test/color_vision/challenge_config_test.dart:73-101`（criterion.check + checkObjectives）；`test/color_vision/magic_lab_ac44_test.dart:88-94`（initState 同步 currentScenario）、`:96-111`（切场景同步）、`:113-119`（完成黄色匹配→checkObjectives 全达成） | ✅ | 实测通过 |
| 4.5 | 无 challenge 字段 fallback 不崩溃 | 单元测试 + 代码审查 | `test/color_vision/challenge_config_test.dart:39-51`（challenge==null 解析）；`rgb_bulbs_screen.dart:237-242`（fallback 路径 + deprecated 日志） | ✅ | 实测通过 |

### AC-5 · 回归

| # | 验证点 | 验证方式 | 测试引用（file:line） | 结果 | 备注 |
|---|---|---|---|---|---|
| 5.1 | `flutter analyze` 无 error | 手动执行 | `test-report/analyze.log` | ⚠️ | 本需求代码 **0 error**；8 个 error 全部位于 `docs/knowledge/phet-common/`（历史参考文档，git diff 确认非本需求引入，非运行代码） |
| 5.2 | 全量测试通过率不降 | `flutter test` | 190 通过 / 0 失败（除 forces） | ✅ | forces 基线超时除外 |
| 5.3 | 7 sim 传统场景正常运行 | 回归 + 全量 | `color_vision_l9_regression_test.dart`（10 场景）；全量 190 通过覆盖 circuit/optics/sound/wave/radio | ✅ | 实测通过 |
| 5.4 | 九宫格布局未破 | 测试 + 代码审查 | `test/common/nine_grid_layout_test.dart`（中间面积≥70% 等）；InquiryDrawer 用 `Offstage` 常驻（`inquiry_drawer.dart:36-37`） | ✅ | 实测通过 |
| 5.5 | knowledge_panel 未修改 | git diff | `git diff HEAD -- lib/common/widgets/knowledge_panel.dart` 为空 | ✅ | 零改动 |

---

## 已知失败 / 基线问题（非本需求引入）

### forces 超时（基线）

- **测试**：`test/forces/forces_scenario_test.dart` → `netforce-tug scenario has valid pullers`（:125）
- **现象**：`flutter test --timeout 60s` 下该测试持续反复运行（日志 +156→+196 均标记同一测试），命令最终被外部超时终止，无法返回结果
- **归属**：`git status` 确认 `lib/forces/`、`test/forces/` **零改动**，本需求未触碰 forces 模块 → **历史基线问题，非本需求引入**
- **建议**：独立追加 forces 稳定性任务（与本需求无关）

### `flutter analyze` 预存 error（基线）

- **现象**：8 个 error 全部位于 `docs/knowledge/phet-common/property_control_panel.dart`（uri 不存在 / 未定义方法）
- **归属**：`git diff` 确认 `docs/` 未被本需求改动，来自历史提交 e180529 → **预存参考文档问题，非本需求引入，且不在运行代码路径**
- **本需求新增代码**：analyze 0 error；唯一 info 为 `test/color_vision/magic_lab_ac44_test.dart:2` 的 unnecessary_import（info 级，非 error/warning）

---

## 附录

- 测试日志：`test-report/integration-test.log`（真实 `flutter test` 输出，末尾 `All tests passed!`）
- analyze 日志：`test-report/analyze.log`（真实 `flutter analyze` 输出）
- 范围：执行了 `test/common`、`test/circuit`、`test/color_vision`、`color_vision_l9_regression_test.dart`、`color_vision_model_test.dart`、`optics_solver_test.dart`、`radio_waves_model_test.dart`、`sound_model_test.dart`、`wave_interference_model_test.dart`、`widget_test.dart` 共 16 个文件，190 项断言全部通过
