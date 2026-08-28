# 需求笔记 · req-drag-lesson-editor

## 已确认发现

### 1. 数据契约完全锁定（无需协商）
- `schemas/lesson.schema.json` 已存在且完整（6.65KB），定义了全部字段类型、enum、条件树结构
- 编辑器只需"忠实还原"该 schema 的可视化编辑能力，无需发明新数据结构
- 运行时消费端（LessonRuntime）已 done 且 58 AC 全覆盖——编辑器产出只要通过 schema 校验就可直接运行

### 2. DragDropWorkspace 复用需适配
- 现有 DragDropWorkspace<T> 设计为"元件库 → 拖入画布"模式（电路/光学），泛型 T 为元件数据类型
- 剧本编辑器需要"节点图/流程图"模式：节点间有连线、需要连线交互、需要路由可视化
- 这是主要的技术适配点——需 tech-leader 评估是否扩展 DragDropWorkspace 还是在其上封装新画布层

### 3. 节点布局位置不在 schema 中
- lesson.schema.json 不含任何 UI 布局信息（x/y 坐标），这是纯运行时数据契约
- 编辑器需要持久化画布上的节点位置，否则每次导入都需要重新自动布局
- 解决方案选项：a) schema 扩展 metadata（影响运行时兼容）b) 外置 .layout.json c) 纯自动布局
- 建议 tech-leader 评估选项 b（外置布局文件，运行时忽略）

### 4. 场景引用封闭集当前为试点范围
- scenarioRef.sim enum 当前限定 `["circuit", "color_vision"]`——这是 req-lesson-runtime 试点约束
- 编辑器应考虑未来扩展性：从 manifest 动态读取可选 sim 列表，而非硬编码 enum
- [待技术确认] 是否需要同步扩展 schema enum

### 5. 两条创作路径的 UX 差异
- "从零新建"路径：用户从空白画布开始，核心操作是拖入节点→配置属性→连线
- "导入编辑"路径：用户选择已有 JSON 文件，画布自动生成节点图布局（依赖自动布局算法）
- 两条路径最终汇合到同一编辑态，只是初始状态不同

## 决策记录

| 日期 | 决策 | 决策人 | 依据 |
|------|------|--------|------|
| 2026-08-26 | 承载形态为 App 内作者模式，非独立工具 | 用户 | Q1 答复 A |
| 2026-08-26 | 编辑范围限定为现有 schema 结构，不扩展原语 | 用户 | Q2 答复 A |
| 2026-08-26 | 面向两类用户（UI 友好 + 高级 JSON 模式并存） | 用户 | Q4 答复 C |
| 2026-08-26 | 支持导入+从零创建两条路径 | 用户 | Q5 答复 |
| 2026-08-26 | T2 方案 A（注册表驱动）：运行时侧保持手工接线，不重构为自动发现 | 用户 | 追问"新增 sim 会自动加进来吗"→ 拍板 A |
| 2026-08-26 | 编辑器场景选择器**必须动态刷新**：进入编辑器重新加载 + 手动刷新按钮，新增 sim 接线后无需重启即可选到 | 用户 | "A 新增了 sim 编辑的时候要能刷新出来" |
| 2026-08-26 | 新增 F14 上下游 sim 冲突检测：维度=教学语义+数据传递 · 拦截=警告可保存 · 规则=配置化 JSON 表 · 不破坏 circuit↔color_vision 已验收组合 | 用户 | AskUserQuestion 澄清：Q1=C,D / Q2=B / Q3=B / Q4=A |

### 6. sim 冲突规则表设计要点

- 冲突判定分两类：① sim→sim 组合的教学语义（规则表标记）；② 条件树叶子跨 sim 引用节点（数据传递，运行时求值已 fail-safe）
- 规则表结构：`allowedCombos`（白名单，默认含 circuit↔color_vision）+ `warnCombos`（from/to/reason）
- 未知组合保守放行（不报错），提示可在规则表显式声明
- 规则表失败降级：仅保留数据传递冲突检查（不 crash）

## 7. 代码评审 r3 修复记录（2026-08-27）

评审报告 `design/代码评审.md` 结论：❌ 不通过（3 Blocker + 3 Major + 4 Minor + 2 Nit）。用户拍板方案1，按 **B1→B2→M3→B3→M1→M2** 顺序修复，六项已全部完成：

| 项 | 修复内容 | 关键文件 | 回归测试 |
|---|---|---|---|
| B1（AC-4） | 节点属性面板"标题"由只读 Text 改为可编辑 TextField（key `title-<id>`），`_onTitleChanged` → `model.updateNode(copyWith(title:))` | `screens/lesson_editor_screen.dart` | `node_property_panel_test.dart:49-64` |
| B2（AC-16） | "剧本设置"区新增 version/description TextField（key `meta-version`/`meta-description`），`_onMetaChanged` 签名扩展 | `screens/lesson_editor_screen.dart` | `node_property_panel_test.dart:66-90` |
| M3（AC-7） | `_withFallbackInvariant()`：routes 删末项后强制新末项 `when=null`（D7 兜底不变量自愈）；`_RouteRow` 删除按钮补 key `route-remove-<i>` | `panels/advance_editor.dart` | `advance_editor_test.dart:15-63` |
| B3 | 补齐 `test-report/ac-verification.md`（逐 21 AC）+ `test-report/unit-test.log` | `test-report/` | 见 ac-verification.md |
| M1（AC-10） | 新建 `canvas/lesson_auto_layout.dart`（entry 起 BFS 分层）；导入缺失/部分缺失布局时兜底填充，已保存坐标优先 | `canvas/lesson_auto_layout.dart` + `validation/lesson_importer.dart` | `lesson_auto_layout_test.dart` + `lesson_importer_test.dart:74-110` |
| M2（AC-19） | dataFlow 类冲突可视化：`LessonNodeCard` 新增 `isConflict` ⚠ 角标；`ConditionTreeEditor` 全链新增 `nodeSims`/`ownerSim`，叶子跨 sim 引用渲染行内 ⚠ | `canvas/lesson_node_card.dart` + `panels/condition_tree_editor.dart` + `canvas/lesson_canvas_view.dart` + `screens/lesson_editor_screen.dart` | `lesson_node_card_test.dart` + `advance_editor_test.dart:65-140` + `node_property_panel_test.dart:92-133` |

验证：`flutter analyze` 0 error；`flutter test` 全量 514 passed / 1 skipped（本轮新增 18 个测试，含 m4 回归测试）。

### Minor / Nit 处理决策（本轮暂不处理，登记理由）

- **m1（方案文件未拆分）**：M1 修复已创建评审指出缺失的 `canvas/lesson_auto_layout.dart`（m1 的一部分已消解）。`node_property_panel.dart`/`lesson_meta_panel.dart` 仍内联在 `lesson_editor_screen.dart`，本轮**不拆分**——理由：内联实现功能完整，拆分属纯结构调整无功能收益，遵循"最小化方案优于过度设计"（`00-engineering-principles.mdc` 第4条）；待出现第二处复用需求再抽取。
- **m2（导入限定 manifest 的 MVP 妥协）**：本轮维持"从 manifest 选择已注册剧本"方式，未引入 `file_picker`——理由：与 AI 生成链路共用 `assets/lessons` + manifest 数据契约，任意外部路径导入为后续增强项（对应需求 F9 字面差距已在此登记）。
- **m3（`LessonValidationResult.warnings` 死字段）/ Nit 两项**：登记为技术债，待后续迭代处理，本轮不动（均非阻塞、无功能缺陷）。

### 追加修复：m4（2026-08-27 · 复审通过后用户追加）

复审结论为"通过（带建议）"，用户选择"顺带修 m4 再收尾"。m4 由此从"推迟技术债"转为**已修复**：

- **问题**：`NodePropertyPanel` 的 5 处 TextField（meta-lessonId/name/version/description + title）每次 `build` 都 `TextEditingController(text: ...)` 重建（未 dispose）；输入过程中若因 `_conflictWarnings` 刷新等触发 `setState` 重建，光标/焦点会跳位。
- **修复**：新建受控 `_ControlledTextField`（StatefulWidget · `screens/lesson_editor_screen.dart`）——initState 建一次 controller，`didUpdateWidget` 仅当外部 value 与当前文本不一致（切换节点/导入剧本等外部来源）才同步并把光标收敛到末尾；用户输入时（value==text）不打断光标。5 处 TextField 全部改用，key 保留在外层（测试 `enterText` 向下查找后代 EditableText，兼容）。
- **回归测试**：`node_property_panel_test.dart` 新增"m4 · 外部 rebuild（value 未变）时受控输入框保持光标位置"——断言外部 `setState` rebuild 后光标 offset 保持不变（老实现会重建 controller 使光标跳末尾）。
- **验证**：`flutter analyze` 0 error（lib/lesson_editor + test/lesson_editor `No issues found!`）；`flutter test` 全量 514 passed / 1 skipped。

## 8. 收尾结晶（closer · 2026-08-27）

最终态快照见 `spec/最终需求.md`（含决策 D1~D11、21 AC 覆盖矩阵、遗留技术债表、变更时间线骨架）。以下为对后续需求可复用的经验沉淀：

### 可复用经验

1. **复用 L0 画布承载异构编排场景（T1 决策 D7）**：`DragDropWorkspace` 原为"元件→电路"场景设计，当需要"节点图/流程图"编排时，正确姿势是**在其上封装新连线层（`LessonCanvasView` + `LessonEdgePainter`）而非改动本体**——既复用了拖拽/画布基建，又不污染既有画布语义。后续遇到"复用既有组件承载新交互范式"时可参照。

2. **UI 隐藏字段必须保证数据层不变量自愈（M3 踩坑）**：routes 末项 UI 上隐藏条件编辑器（`isLast` 不渲染），但删末项使倒数第二条"被动晋升"为新末项时，其旧 `when` 未清空 → 触发运行时校验失败且**用户在 UI 上无入口修复**。教训：凡"某状态下 UI 隐藏某字段编辑入口"，删除/切换操作必须在**数据层强制维持不变量**（`_withFallbackInvariant()`），不能依赖用户手动操作。这是"UI 可达性 = 数据合法性前提"的实证。

3. **降级路径 = 核心场景时不可空转（M1 踩坑）**：导入布局缺失的降级路径正对应 AC-10"含 AI 生成产物"这一**核心场景**（AI 产物天然无 `.layout.json`），却被实现为"返回空 Map 致节点堆叠 (40,40)"。教训：识别"降级路径是否实际是主路径"，若是，降级算法（BFS 自动布局）必须真实实现而非占位。

4. **TextEditingController 生命周期（m4 · 有先例仍复发）**：`process.txt` T9 阶段 `_RouteRow` 已因"每次 build 重建 controller 丢焦点"改过 StatefulWidget，但 `NodePropertyPanel` 未吸取教训重蹈覆辙。教训：**Flutter 表单输入框凡随 `setState` 频繁重建的场景，一律用受控 StatefulWidget（initState 建一次 + didUpdateWidget 仅外部 value 变化才同步 + dispose）**，可沉淀为项目级 checklist 项。

5. **自测证据缺口与缺陷强相关（B1/B2/B3 实证闭环）**：本需求首轮 3 Blocker 中 2 个（title/version+description 不可编辑）正是"缺乏 UI 交互 widget 断言"的直接后果——若有"选中节点→属性面板输入→断言模型更新"最基础的 widget test，缺陷在自测阶段即应暴露。教训：交互类 AC 至少应有 widget 级断言覆盖"字段可编辑→回调触发→模型更新"链路，不能仅靠手动运行。

### 对后续需求的提示

- 涉及 `lesson.schema.json` 编辑/生成时：schema 是**纯运行时数据契约不含 UI 坐标**，任何布局/编辑器元数据走外置文件（`.layout.json`），运行时忽略（决策 D8）。
- 涉及场景引用时：走 `loadSceneCatalog()` 注册表驱动（新增 sim 接线 4 处后自动出现），编辑器侧需支持动态刷新（决策 D5）。
- 冲突规则为配置化 JSON（`assets/editor/sim_conflict_rules.json`），`allowedCombos` 白名单默认含 circuit↔color_vision，改规则时勿破坏 AC-58 混合剧本（决策 D6/D9-C9）。
