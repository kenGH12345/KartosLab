# 决策与踩坑记录

## 需求命名纠偏

- 用户首条消息误称"PM2.5"→ 搜索 lib/requirements/知识库确认无此模块 → 用户自我纠正为通用屏幕适配
- 教训：用户口误时先搜索确认，不要假设存在某模块

## 20-verify-before-act 违规（本需求实证）

- 第 2 轮实现把"至少占 70% 屏幕"理解为"宽、高各占 70%"直接动手，未确认"占屏幕大小"指面积
- 用户质询"为什么没有跟我确认" → 核心参数含义信心 <70% 时必须先 AskQuestion，不能边做边猜
- 修正后面积 70% 方案：宽高各 sqrt(0.7)，边条各 ≈8%（比宽高各 70% 的边条 15% 更窄，周边格只能放紧凑内容）

## 边条容量的现实约束

- 面积 70% → 边条 ≈8% 宽/高：手机竖屏（375 宽）边条仅 ≈31px，放不下标准滑块/长文本
- 迁移应对：周边格用 `SingleChildScrollView` 兜底防溢出；长文本知识卡一律改弹窗；横排 chips 改 `Wrap`
- 桌面（1920）边条 ≈157px，竖排紧凑控件可用

## 技术踩坑

- `rgb_bulbs_screen.dart` 挑战模式 `LinearProgressIndicator` 的 `Expanded(->SizedBox->ClipRRect->LinearProgressIndicator->AlwaysStoppedAnimation)` 链少 1 个闭合括号（重写时引入），`flutter analyze` 定位后修复；连带删除失去引用的 `_subtitle`
- 重写大文件（430 行）比逐段 replace 更可控；replace 长 old_str 失败时改用 write_to_file 整体重写
- PowerShell 下 `flutter analyze`/`test` 输出被 CLIXML 污染（stderr 对象序列化），`cmd /c` + 重定向到文件可读纯文本

## 中间格内容边界修正（Change-1 · 2026-08-07 用户截图纠正）

- **实证**：用户截图指出 optics 的"教学目标/约束条件"（DragDropWorkspace.rightPanel）与底部托盘出现在中间格内——违反"中间格只给实验本身展示 · UI 都要按适配要求靠边"
- **根因**：迁移 optics/circuit 时把 `DragDropWorkspace` 整体（画布+托盘+面板）塞入中间格，把"工作区容器"误当"实验画面"
- **修正**：`_Card`/`_tray`/`_DropCanvas` 提升为公共组件 `DragItemCard`/`DragTray`/`DropCanvas`；`DragDropWorkspace` 原 API 复用（零行为变化）；optics/circuit 拆为 center=DropCanvas + 边格=DragTray/面板
- **教训**："中间格只放实验画面本身"是硬约束——工作区类容器（含面板/托盘）必须拆分，不能整体入中间格

## code-reviewer Minor 精简理由（2026-08-07 · 评审通过后补记）

评审报告：`design/代码评审.md`。3 处 Minor 均为 UI 文案/交互精简，理由如下：

| Minor | 精简动作 | 理由 |
|---|---|---|
| sound | 删除控件级 hint 教学文案（如"频率↑=弧/波变密…"） | 9 宫格边条（≈8% 屏宽）容纳不下长 hint · 删除以保 L0-2 无溢出 |
| rgb_bulbs | 删除 Header 模式副标题（`_subtitle`） | topCenter 格高仅 ≈8% 屏 · 容纳不下标题+副标题+3 模式按钮 · 副标题信息可由 Tab 标题/模式按钮承载 |
| motion | 图表从行内展开改为弹窗 | 图表需较大区域保证趋势可读性 · 8% 边条无法承载 · 弹窗保留完整功能（`_showChartDialog`） |

## 遗留（非本需求范围）

- `test/forces/forces_scenario_test.dart` netforce-tug testWidgets 超时（10 分钟）· 依赖链未动 · 单独运行稳定复现 → 既有环境问题，建议另立诊断需求排查 `flutter_test` 二次 rootBundle 加载
- git 工作区存在非本需求的未提交改动：`lib/circuit/models/circuit_solver.dart`、`circuit_state.dart`、`test/circuit/circuit_solver_mna_test.dart`（会话中出现的其他来源改动，与本需求无关，注意不要误纳入本需求 commit）

## 知识沉淀（closer 收尾追加 · 2026-08-07）

### 对"回溯建档"需求的收尾要点
- 本需求为回溯建档（需求已实现完成后再补 spec/process），前置校验（代码评审 / 测试豁免 / AC 覆盖 / 用户确认）全部走用户提供的留底证据，无强 dev/test 阶段产物——agile-vibe 收尾从 process.txt + 用户留底取数，不硬性要求 dev agent 返回与 integration_test。

### 可复用经验（建议交 knowledge-maintainer 沉淀）
- **"百分比/比例类参数"必须先澄清含义再动手**：本需求"中间 ≥70%"曾两次被误解（先等分、后"宽高各 70%"），最终澄清为"面积 ≥70%（宽高各 sqrt(0.7)）"。凡涉及"占 N%"均需区分：占宽度 / 占高度 / 占面积 / 占对角线，且对用户用可核验的量化表述（边条各≈8%）。
- **UI 布局迁移的验证策略**：无独立功能断言的 UI 布局，用"组件 widget 测试（面积精确断言/贴边/自适应/下限 clamp）+ 全量 flutter test 回归 + analyze 无 error"作为自动化验证，可豁免 integration_test——这是 test_exempt 的合法合理用法。
- **窄边条（≈8% 屏宽）适配模式**：手机竖屏边条仅 ≈30px，标准滑块/长文本放不下 → 用 `SingleChildScrollView` 兜底防溢出、长文本知识卡一律改弹窗、横排 chips 改 `Wrap`。可作为未来 sim 迁移的标准应对清单。
- **重写大文件比逐段 replace 更可控**：430 行大文件（rgb_bulbs_screen.dart）整体 write_to_file 重写 + flutter analyze 定位括号错误，比长 old_str replace 更稳。
- **PowerShell 下 flutter 输出污染**：`flutter analyze`/`test` 输出被 CLIXML 污染（stderr 对象序列化），用 `cmd /c` + 重定向到文件可读纯文本。

### 对本需求自身 process 的工具环境备注
- 收尾时 `.workflow/scripts/auto-extract-failures.sh` 在 kartosos 工程**不存在**（.workflow 目录不存在）→ 步骤 1.5 / 4.5.1 自动失败提取跳过，此段为人工沉淀替代。
- 项目实际是 git 仓库（非 SVN），收尾的所有 `svn *` 命令改用 `git *`。
