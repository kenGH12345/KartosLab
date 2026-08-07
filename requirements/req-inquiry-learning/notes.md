# notes.md — req-inquiry-learning

## 已确认发现

1. **数据层vs 交互层断裂**：scenario JSON 的 objectives/successCriteria/hints 已定义完善，但 7 sim 零消费——这意味着通用层（ScenarioManagerBase）的 `checkObjectives`/`validateConstraints` 方法已就绪可直接复用，只需在 screen 层接入调用（S3, S9）

2. **knowledge_panel 不应改造**：该组件承担的是"知识展示"功能，与"探究引导"是并行关系（不是替代关系）。探究任务卡+结论归纳是新增组件，不应试图"升级" knowledge_panel（用户决策隐含此意）

3. **color_vision 挑战模式有完整业务逻辑可复用**：`_calcAccuracy()` /得分算法 / celebration_dialog 调用 / level递进逻辑已完整（S10），迁移 JSON 驱动只需将硬编码参数替换为 JSON 读取，核心算法不变

4. **ExperimentLogger 的通用化关键在 snapshotProvider 回调**：每个 sim 的"参数+读数"结构不同，通用组件不应知道 sim 内部 model——通过回调解耦是唯一可行路径

5. **JSON schema 扩展的snapshotColumns 字段可简化 sim 接入**：如果表头定义也放在 JSON 里，sim 代码只需提供 Map<String,dynamic>，通用组件自动匹配 key→label渲染表格

## 风险备注

- A1 假设（session 级存储）如后续需改为持久化，需要引入本地数据库层（如Hive/SharedPreferences），架构影响面较大——但本轮明确不做
- 三组件在九宫格中的精确位置需要视觉验证（T4），建议 tech-leader阶段做简单 mock 验证布局空间是否充裕

---

## 收尾沉淀（closer · 2026-08-07 · phase 4.closing）

### 决策记录（执行期补充 · 相对技术方案）

- **D6' 布局方案重大修正**：技术方案原定 color_vision 三组件入 `midLeft` 边条，实测窄视口 midLeft 仅 ~41px 放不下三组件。改为新增**通用 `InquiryDrawer`**（`Offstage` 常驻保 State + 右侧 280px 固定抽屉）+ 两 sim midLeft 只放入口按钮。`Offstage` 方案的关键价值：抽屉开合不销毁 ExperimentLogger 记录行与 ConclusionPanel 两阶段状态。教训：**"边条能放得下"不能只靠估算，需 mock/实测验证视口最窄宽度**（技术方案 §10 风险 R1 已预判"空间不足改底部抽屉"，执行落到了 InquiryDrawer 变体）。
- **D8 场景菜单迁移 topRight**：color_vision 场景菜单从 SCSV（滚动容器）移 topRight 独立格——`PopupMenuButton` 在滚动容器内定位错乱。教训：**PopupMenu 定位依赖非滚动祖先上下文**，放滚动容器会弹层错位。
- **D9 AC-4.4 测试绕开 rootBundle IO**：`manager.loadScenarios` 走 rootBundle 真实 IO，在 `fakeAsync`/widget test 下挂起。改为**内联构造场景**。教训：**涉及 asset 加载的测试不要走真实 rootBundle IO，内联构造数据更可控**（规避 Flutter asset 在测试环境加载的不确定性）。
- **Blocker 触发链路修复**：`MagicLabScreen` 自行构造 state 绕过 manager → `_currentScenario` 恒 null → `checkObjectives` 恒 false。修复为 manager 持有 currentScenario 并同步。教训：**state 构造必须走统一入口（manager），screen 自行 new state 会破坏 manager 的状态一致性**。

### 踩坑经验

- **Button 未定义 / TextButton visualDensity / ExpansionTile 默认折叠**：三组件首版测试 2 轮修复（Button→TextButton、加 visualDensity、`initiallyExpanded: true`）。教训：Flutter Material 组件在测试中需注意默认样式与无 Material ancestor 的报错。
- **PopupMenu 在滚动容器定位错乱**：见 D8。
- **rootBundle 加载在测试挂起**：见 D9。

### 遗留项（后续迭代候选 · 全部非阻塞）

1. **M3（已接受取舍）**：`rgb-challenge-basic` 的 `successCriteria` 只覆盖第 1 关（黄色）。产品取舍：黄色达成即整体达成。如需每关可评估需扩展配置（多目标 criterion 或逐关 successCriteria）。
2. **S1（体验优化）**：circuit `_maybeNotifyObjectiveMet` 提示时机过早风险（探究未完成即提示达成）。非 bug。
3. **S2（非 bug）**：`_applyScenario` 里 `_timerTicker?.stop()` 可改 `dispose()` 语义更清晰。
4. **forces 基线超时（独立任务）**：`forces_scenario_test.dart` netforce-tug 10 分钟死循环超时，forces 零改动。建议独立排查 `flutter_test` 二次 rootBundle 加载。
5. **docs/knowledge/phet-common/ 历史 analyze error（独立任务）**：`property_control_panel.dart` 参考文档 8 个 error（历史提交 e180529，非运行代码）。
6. **git 工作区杂项（commit 时排除）**：`lib/circuit/models/circuit_solver.dart` / `circuit_state.dart` / `test/circuit/circuit_solver_mna_test.dart`（MNA solver 历史未提交工作）+ `.codebuddy.backup-20260729/` + `scripts/`。已由 `req-nine-grid-layout` 最终需求交叉证实为会话前遗留，非本需求。

### 对后续需求的提示

- **推广其余 5 sim（Q1 验收后）**：三组件 + InquiryDrawer 已在 common，后续 sim 接入只需 ① scenario JSON 补 `inquiryTask`/`challenge` ② screen 接 InquiryDrawer + snapshotProvider。`snapshotColumns` 的 key 与 snapshotProvider 返回 Map key 必须一一对应（AC-2.4 是常见坑）。
- **challenge 迁移**：其他 sim 若要挑战模式，参照 color_vision 的 JSON `challenge` 配置 + `CVCriterionConfig.check` 模式（当前 criterion 仅 colorMatch 型，其他型需扩展）。
- **InquiryDrawer 复用**：新增通用抽屉已登记 L1 候选，任何 sim 需要"右侧探究抽屉"可直接复用；若未来出现 ≥2 sim 使用相同探究布局，按 3-Time Rule 评估上抽 `InquiryWorkflow` 容器。
