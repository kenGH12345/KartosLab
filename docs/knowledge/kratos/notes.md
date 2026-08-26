# kratos 项目级 notes

> 用途：项目级"决策 / 踩坑 / 参考链接" 沉淀（对应 `45-state-sync-protocol.mdc` §四件套 中的 `notes.md`）。
> 与需求级 notes 的区别：本文件跨需求、跨 session 保留，只写"未来 agent 需要知道"的项目级知识；与 `INDEX.md` 的区别：INDEX 是索引，本文件是"经验 / 决策"。

---

## 决策记录

### 2026-07-20 · 配置化升为项目硬约束（§C1-§C4）

- **授权**：用户拍板 Q1=A · Q2=B · Q3=C · Q4=C
- **落地**：`architecture/design-patterns.md` §配置化项目硬约束 + `architecture/ai-generation-readiness.md` status=adopted-framework-standard
- **影响**：所有模块必须走 ScenarioManager + JSON 驱动 + AI 工具链（prompt + schema + ≥3 samples）；新模块加入按同标准立项。

### 2026-07-21 · 三模块 §C1-§C3 全合规达成

三个模块在同一天完成配置化 + AI 工具链补齐：

| 模块 | ScenarioManager | JSON 场景数 | AI Prompt | JSON Schema |
|---|---|---|---|---|
| optics | ✅ `lib/optics/config/scenario_manager.dart` | 3 | ✅ `docs/prompts/optics_scenario.md` | ✅ `schemas/optics_scenario.schema.json` |
| circuit | ✅ `lib/circuit/config/scenario_manager.dart` | 7 | ✅ `docs/prompts/circuit_scenario.md` | ✅ `schemas/circuit_scenario.schema.json` |
| forces | ✅ `lib/forces/config/forces_scenario_manager.dart` | 5 | ✅ `docs/prompts/forces_scenario.md` | ✅ `schemas/forces_scenario.schema.json` |

**关键顺序**：先 circuit → forces → 最后补 optics AI 工具链（其配置化本身早已存在，仅缺 AI 生成配套）。

### 2026-07-21 · 光学元件拖动体验修复（相对位移 vs 绝对跳跃）

- **问题**：场景初始化的元件"很难拖动"——需要两次手势操作（先点击选中再按住）。
- **根因 A**：`onTapUp` 与 `onScaleStart` 互斥，导致必须先点击。
- **根因 B**：`onScaleUpdate` 直接把元件中心跳到手指绝对位置，用户按边缘拖时视觉跳格。
- **修法**：`_OpticsScene` 改 StatefulWidget，用 `_dragId + _dragElementStart + _dragPointerStart` 三锚点记录初始位移；`newPos = _dragElementStart + (currentPointer - _dragPointerStart)`。
- **教训**：Flutter 手势系统里，`onScaleStart` 天然承担"按下"职责，不要期待 `onTapDown` + `onScaleUpdate` 组合能覆盖所有场景。

### 2026-07-21 · 电路导线折线功能补齐

- **状态断层**：数据模型（`WireSegment.controlPoints` + `addControlPoint/moveControlPoint/removeControlPoint/buildPath`）+ 渲染层完整，但 UI 无双击入口——"能显示、能拖、但不能创建"。
- **修法**：`GestureDetector.onDoubleTap` + `_doubleTapWorld` 缓存 + `_onDoubleTap` 分派：
  - 双击拐点手柄 12px 内 → 删除
  - 双击导线空白段 → 在最近线段插入
  - 双击元件/画布 → 无效果（防误触）
- **相邻功能兼容**：双击元件已用于开关切换，本次逻辑靠"最近命中优先"分派避免冲突。

### 2026-07-21 · 光学求解器 6 处修复（#1-#6）

关键修法（详细见 commit 历史）：

| # | 问题 | 修法 |
|---|---|---|
| 1 | `ImageInfo.focalLength` 字段返回物距 | 引入 `lastFocalLength` 变量正确赋值 |
| 2 | 透镜公式在 3 处独立实现 | 统一调用 `OpticsMath.imageDistance` |
| 3 | `_extendFrom` 双份 | 旧求解器改调 `OpticsMath.extendFrom` |
| 4 | 镜面反射仅平面 | 新增球面反射逻辑 + 小曲率半径回退 |
| 5 | 光屏检测仅左→右单向 | 用叉积判同侧支持双向 |
| 6 | 新旧 `SolvedOptics` / `RayPath` 混淆 | 旧求解器头部加 🗑️ legacy 注释 |

### 2026-08-07 · 9宫格强制屏幕适配方案（NineGridLayout）

- **授权**：用户拍板"公共通用方案 · 所有 sim 都要支持 · 强制要遵守" + "全部立即迁移"
- **落地**：`lib/common/widgets/nine_grid_layout.dart`（L0 通用组件）+ `.codebuddy/rules/80-kratos-sim-checklist.mdc` §七 L0-4（阻塞级）+ `shared-abstraction-plan.md` 候选 7
- **核心规则**：屏幕划为 3×3 九宫格 · 中间格**面积 ≥ 70%** 屏幕（宽高各 `sqrt(0.7)`≈0.837 屏 · 边条各≈8%）· `centerAreaRatio` 下限 0.7 强制 clamp · 周边 8 格贴边放"信息展示 + 交互控件混合" · 无 `Positioned` / 无硬编码像素
- **迁移共性**：7 sim 9 主屏已全部迁移（`req-nine-grid-layout`）· 长文本知识卡改弹窗 · 横排 chips 改 `Wrap` · 每格 `SingleChildScrollView` 兜底防溢出（L0-2 合规）· 拖拽工作区类（optics/circuit）整体入中间格
- **教训**："占 N% 屏幕"必须先澄清含义（面积 vs 宽高）——本需求曾两次误解（先等分、后宽高各 70%），最终用户确认为面积 ≥70%

### 2026-08-11 · 操作面板统一底部横排（NineGridLayout.footer）+ ExperimentIntroPanel 上抽

- **授权**：用户 S1——操作面板统一放**底部横排**，先 molarity 试点，验收通过后推广其余 9 屏（独立迭代，避免一次性大改造成回归面失控）；overflow 存桩合并入本需求仅做验证。
- **落地**（`req-ui-interaction-polish`）：
  - `lib/common/widgets/nine_grid_layout.dart` 新增 **footer 参数**：横跨整行的底部控件条（操作面板底部横排的基础）。**高 = `min(96, 屏高×0.16)`**；Major-2 修复：`centerH` 显式扣除 `footerH`（`nine_grid_layout.dart:91-97`），否则 footer(0.16H)+center(0.837H) 合计占 ~99.7% 屏高，320×480 下边格被压到 ~0.6px 不可见。
  - `lib/common/widgets/experiment_intro_panel.dart`：通用实验引导组件（解决"进入 sim 不知道要干嘛"）——description 常驻一行 + 点击弹 Dialog 复用 `InquiryTaskPanel`；desc/task 均空不渲染；**10 屏接入**。已登记 `shared-abstraction-plan.md` L1 候选第 7。
  - `lib/common/controls/kratos_slider.dart` 新增 **compact 参数**：隐藏 label 行的紧凑滑块，用于顶部/底部窄条控件栏（如 circuit 选中工具条）。
- **窄视口降级**：320px 用 `FittedBox scaleDown` + 横向滚动降级，保证功能可达（AC-5.4）。
- **教训（布局比例分配）**：新增横向/底部占用块时，**必须从主体容器高度显式扣除**（见下"踩坑·footer 高度未扣"），否则按比例分配会挤压到不可用。
- **遗留（独立迭代）**：其余 9 屏底部迁移 + circuit 顶部行布局空间不足（~51px 放不下 compact Slider ~60px，3 个工具条测试暂 skip）。

### 2026-08-12 · 操作面板底部横排迁移完成（9 屏试点 → 8 屏实施）+ footer 迁移模式定型

- **授权**：用户确认"按完整生产方案执行"（S1 试点推广）。`req-panel-bottom-migrate`。
- **实际迁移 8 屏**（非 9 屏）：sound / wave_interference / radio_waves / rgb_bulbs / single_bulb / motion / netforce / circuit；**optics 保留原位**（`_RightPanel` 是只读文本教学目标/约束条件面板，与 footer 横排交互控件条设计初衷不符）。分批按面板相似度（低复杂度优先：声学波动 → 力学 → 色觉 → 电路），每批独立验收。
- **footer 迁移模式（10 屏统一范式，`lib/common/widgets/nine_grid_layout.dart`）**：
  - `NineGridLayout.footer` + `SingleChildScrollView(horizontal)` + `Row` 横排
  - 每控件用 `Wrap` 包 `SizedBox` **限宽**（FittedBox 的 `scaleDown` 在**无界宽**约束下让 `Wrap` 无限展开——FittedBox 会给子节点无界约束，横向滚动容器内不能用 FittedBox 包 Wrap/Slider）
  - **不用 FittedBox 包 Slider 类**（无界约束会爆炸）
  - 矮视口降级：边格 <48px 时压缩 center（保边格控件权衡），320×480 下 center 面积可 <70%（正常视口不变）
- **落点**：`lib/common/widgets/nine_grid_layout.dart` footer + `SingleChildScrollView(horizontal)` + `Row` + `Wrap` 组合。
- **遗留（独立方案）**：circuit AppBar 11 按钮在 320 屏 21px 溢出（ComboBox 响应式隐藏 + FittedBox 均无法消除，AppBar 布局深层问题）→ 待底部工具条/按钮合并独立方案。

---

## 踩坑

### 2026-07-21 · 知识库权威源同步失责

- **现象**：多轮任务里我（AI）修完代码只顺手改 `INDEX.md`，漏改 `architecture/design-patterns.md` §各模块合规现状表（权威源），导致索引层比源头更新。
- **根因**：违反 `20-verify-before-act.mdc` §知识库优先——每次动手前应先读权威源，动手后应回写权威源，我把权威源当"最后才读的文档"。
- **补救**：本次审查一并修 `design-patterns.md` §合规表 + `ai-generation-readiness.md` migration_status + `module-index.md` 文件数 + `optics-module.md` §C3 引用 + 新建本 `notes.md`。
- **提醒未来的 agent**：修 §C1-§C3 相关代码后必须回头核对**四份权威文档**：
  1. `architecture/design-patterns.md` §各模块合规现状
  2. `architecture/ai-generation-readiness.md` migration_status + artifacts
  3. `systems/module-index.md` §设计原则对照总表
  4. `systems/<module>-module.md` §场景配置系统

### 2026-07-21 · `module-index.md` 文件数漂移

- **现象**：文档写 "55 个 .dart"，磁盘实际 54 个。
- **根因**：批量加 `lib/circuit/config/` 5 个文件时按算数加，但同期可能有别处删除未同步。
- **保底手段**：每次改文件数前跑 `Get-ChildItem lib -Recurse -Filter '*.dart' | Measure-Object`；不要凭"上次 + 增量"心算。

### 2026-08-11 · CanvasProjection 与 SceneProjection 投影原点不一致 → 拖放错位（含缩放教训）· 2026-08-24 已根治

- **现象**：电路屏拖放元件后位置错位、点选不中（`req-ui-interaction-polish`，Major-1）。
- **根因**：`DropCanvas` 放置用 `CanvasProjection`（origin=(W/2, H×0.55)），而电路渲染/hitTest 用 `SceneProjection`（origin=(W/2, H/2)）——**两套投影原点不同**；且 `_onComponentDrop` 转换硬编码 `zoom:1`，渲染/命中却用 `_state.zoom`（0.6~2.0 可调）。
- **当时的解决（治标 · 已删除）**：`_onComponentDrop` 中把 `CanvasProjection` 的 world 转回 screenLocal，再用当前 `_state.zoom` 构造 `SceneProjection` 转 world。
- **根治（`req-unify-projection-layer` · 2026-08-24）**：两套投影合并为公共层唯一 `SceneProjection`（`lib/common/geometry/projection.dart`）；`DropCanvas` 增加 `projectionFactory`，circuit 注入后拖放落点与渲染/hitTest **共用同一投影实例**，转换 workaround 整体删除。接线契约由 `test/common/geometry/projection_wiring_test.dart` 锁定（防回退）。
- **教训（重要）**：涉及投影/命中坐标换算时，**缩放系数必须从组件内部状态读取，不可用默认值硬编码**；更根本的是——**同一画面不要存在两套坐标投影**，平行实现迟早混用。
- **同类风险检查**：新 sim 接 `DropCanvas` 一律用 `SceneProjection` + `projectionFactory`（详见 `shared-abstraction-plan.md` 候选 10），**禁止再建平行投影类**。

### 2026-08-11 · GestureDetector 含 onDoubleTap 时 onTapUp 延迟

- **现象**：集成测试 tap 后立即断言失败。
- **根因**：`onDoubleTap` 使 `GestureDetector` 等待双击判定，`onTapUp` 触发被延迟。
- **解决**：测试 tap 后需 `pump` 350ms（double-tap 超时窗口）才能触发 `onTapUp`。

### 2026-08-11 · footer 高度未从 centerH 扣除 → 边格被压近 0

- **现象**：molarity 固定高度合计占 maxHeight ~99.7%（center 0.837 + footer 0.16），320×480 下边格各 ~0.6px，控件不可见。
- **解决**：`centerH = (maxHeight - footerH) * side`（Major-2，`nine_grid_layout.dart:91-97`）。
- **教训**：布局中新增横向占用块时，**必须从主体容器高度中显式扣除**，否则按比例分配会挤压到不可用；footer 默认 null 不波及其他屏。

### 2026-08-11 · SingleChildScrollView 包裹 Expanded → 布局崩溃 → 全局 hit test 失败

- **现象**：optics 屏返回键失效，实为布局崩溃导致整个屏 hit test 全局失败。
- **根因**：`Expanded` 在无界约束（滚动视图内）下崩溃。
- **解决**：移除 midRight 的 `SingleChildScrollView` 包裹（`optics_screen.dart:202`）。

### 2026-08-11 · 测试名实不符（tap 退化为存在性断言）

- **现象**：place 测试改 tap 后退化为托盘存在性断言，放置回归覆盖被移除。
- **解决**：Major-3 改为"拖放成功"验证（`DropCanvas` 内元件存在 + 无异常），恢复启用 place/select；delete/toggle/rotate 仍 skip（设计空间限制，见决策段遗留）。

### 2026-08-12 · 固定宽 Slider / 渐变条在窄格溢出 → 改 Expanded 自适应（重要通用规律）

- **现象**：`req-panel-bottom-migrate` 中 AppliedForceSlider（`SizedBox(200)` 固定宽，motion）与 sound SphericalLegend（固定宽渐变条）在窄格/窄视口溢出，两个真实 bug **同根因**。
- **依据**：app 链路测试（`forces_home_test` ForcesHome→运动 tab）实证 real 溢出 255px；独立 pump 异常值 200161px 是 `scenario:null` 导致的值异常（见坑 7）。
- **解决**：改 `Expanded` 自适应（宽度由外部约束定），而非硬编码宽度。
- **教训（推广 footer 方案时必查）**：footer 横排容器宽度随视口变化，**固定宽子控件（`SizedBox(width:)` / `Container(width:)` / 固定宽渐变条）在 320px 下必溢出**——新迁移/推广前先扫一遍该屏固定宽子控件。

### 2026-08-12 · AppBar 大量 actions 在窄屏溢出 → FittedBox 无法兜底（需布局层方案）

- **现象**：circuit AppBar 11 按钮在 320 屏 21px 溢出；ComboBox 响应式隐藏（<600px）+ FittedBox 双保险均无法消除。
- **根因**：`FittedBox scaleDown` 只对**单一可缩放根节点**有效；AppBar 多按钮是深层布局（多子节点），非样式层能解决。
- **教训**：按钮数量过多的 AppBar（>8）在 320px 下需**布局层方案**（底部工具条 / 按钮合并），不是样式层（FittedBox/隐藏）能兜底。修复前先判断是否单一可缩放根节点。

### 2026-08-12 · 独立 pump 屏测试需包 Scaffold（否则布局崩坏误判）

- **现象**：SingleBulbScreen 无 Scaffold 时独立 pump 布局崩坏 199931px（color_vision_test 先例 L54）。
- **教训**：写 widget 测试前先确认 Screen 是否自带 Scaffold，缺则手动包 `MaterialApp` + `Scaffold`，否则溢出值是假的。

### 2026-08-12 · 独立 pump 的 scenario:null 会掩盖真实布局（值异常 ≠ 真实溢出）

- **现象**：motion 独立 pump 200161px 是 `scenario:null` 导致的值异常；真实链路（app tab 导航）实证 255px 是窄格溢出——**两个不同问题，不能混为一谈**。
- **教训**：独立 pump 暴露的大数溢出值**不要直接判定为"测试方法误判"或"真实 bug"**，需先用真实 app 链路（tab 导航）验证后再下结论。**app 链路测试是独立 pump 的必要补充**。

### 2026-08-19 · 新增 sim 场景两个连带坑：入口硬编码可达性 + 回归测试计数断言

- **现象**（req-single-bulb-inquiry）：新增 `single-inquiry-subtractive.json` 并注册 manifest 后，滤光镜 Tab 仍加载旧观察场景——新场景 App 内**不可达**（死资产），AC 端到端路径断裂；同时 `test/color_vision_l9_regression_test.dart` 场景数断言写死 10，新增第 11 场景后回归立刻红。
- **根因 1（可达性）**：`lib/color_vision/screens/color_vision_home.dart:37` 场景 ID 硬编码（`findById('single-white-red-filter')`），single_bulb 屏又无场景菜单——**manifest 注册 ≠ 用户可达**，必须追「谁加载它」的调用链到 home/菜单层。
- **根因 2（knock-on）**：回归测试硬编码场景计数断言，与 manifest 场景数联动。
- **解决**：① home 默认场景双 findById fallback（`findById('single-inquiry-subtractive') ?? findById('single-white-red-filter')`，1 行，JSON 缺失回退现状不 crash · D-1 用户拍板）；② l9 断言 10→11。
- **教训（新增场景检查清单）**：新增场景 = JSON + manifest 注册 + **可达性接线**（home/菜单默认场景或场景列表）+ **全局搜回归测试的计数断言**（本工程至少 color_vision 的 l9_regression 有）。方案阶段发现"spec 未覆盖的不可达"比收尾发现死资产便宜一个数量级。
- **接入 InquiryDrawer 的新屏操作步骤**（单一源）：[conventions/add-inquiry-screen.md](conventions/add-inquiry-screen.md)。

### 2026-08-19 · PowerShell Get-Content 读无 BOM UTF-8 在中文 Windows 下按 ANSI 解析 → 正则静默失配

- **现象**：`check-before-done.ps1`（done 门禁脚本）首跑报 2 项异常（closer 日志未识别 + checkbox<3），但目标文件内容实际合规。
- **根因**：`Get-Content` 无 `-Encoding` 参数时，中文 Windows（系统 ANSI 代码页）下读**无 BOM 的 UTF-8** 文件按 ANSI 解析，中文变乱码 → 正则匹配中文关键词失配（python 实证：文件 BOM=False 且内容可 regex 匹配，即文件本身合规、编码读取错了）。
- **解决**：脚本两处 `Get-Content` 显式加 `-Encoding UTF8`（已修，复跑 All passed）。
- **教训**：Windows 中文环境下任何 PowerShell 脚本读仓库内 UTF-8 文本（日志 / 报告 / markdown）必须显式 `-Encoding UTF8`——症状指向"内容不合规"，根因在编码，**静默乱码极难排查**。写 UTF-8 文件时 `Out-File` / `Set-Content` 同理需显式编码。

### 2026-08-20 · InquiryDrawer 五阶段状态机改造（IXD Spec v1.0）三个实证坑

按交互设计文档把探究抽屉从"全部展开"改为五阶段状态机（猜测→任务→操作→记录→归纳），过程中三个可复用教训：

- **全高侧边浮层会静默遮挡九宫格边格交互**：Drawer 改为全高（Column+Expanded(ListView)）后，进度条区域挡住了 topRight 的探究入口按钮——hit-test 命中 Drawer 内无手势的 `TextSpan`（RenderParagraph 会消费 hit 但不响应 tap），**Stack 下层按钮永远收不到事件**，用户无法关闭抽屉。修复：`ConstrainedBox(maxHeight: 视口*0.8)` + `Column(min) + Flexible(ListView(shrinkWrap))`（内容少收缩 / 多滚动 / 进度条常驻）。**教训：Stack 浮层高度设计必须同时考虑"挡住谁的下层交互"**——视觉上透明 ≠ hit-test 穿透。
- **卡片折叠时子面板 State 保留需要显式 `Visibility(maintainState: true)`**：AnimatedSize 内直接条件切换 `content : SizedBox` 会销毁子树 State（已验证的预测选择、已写的结论在折叠再展开后丢失）。`Visibility(visible, maintainState, maintainAnimation)` 用 Offstage 实现，折叠时高度归零（AnimatedSize 动画正常）且 State 存活；同一组件的 active 版与 review 版须用**相同 ValueKey** 才能在切换时复用 State。
- **测试中 `tester.ensureVisible` 后立即 tap 会被滚动手势劫持**：ensureVisible 启动 100ms 滚动动画，动画进行中 tap 的 down/up 之间内容位移 → Scrollable 的 drag 手势在竞技场胜出、tap 被取消。修复：ensureVisible 后补 `pump(≥100ms)` 再 tap。另外 Stateful 组件里的无限循环动画（进度条脉冲）导致 **`pumpAndSettle` 永不返回**，必须用固定时长 pump。
- **组件 API 兼容模式**：`InquiryTaskPanel` 加 `onConfirm`/`confirmed`（null = 只读旧行为，ExperimentIntroPanel 弹窗共用不受影响）；`ExperimentLogger` 加受控模式（`rows`/`onRecord`/`onDeleteAt`/`onClear` 非 null 时外部持有状态）+ `enabled` 禁用参数（TASK-002：任务确认前记录按钮禁用）。两个组件的 8 屏调用方**零改动**。
- 测试基线：改动前全量 295 通过 / 1 skip / 5 失败（forces netforce-tug 超时为预先存在的环境问题，与本次无关）；改动后 299 通过 / 1 skip / 1 失败（同一 forces 超时）。

### 2026-08-20 · molarity 沉淀物"看不见"——Stack alignment:center 会把非定位子全部居中（含 Align 包裹的子）

- **现象**：过饱和时烧杯看不到沉淀（用户反馈）。model 计算正确（`numberOfParticles` 150 个）、painter 正常执行，但粒子画在了烧杯中部。
- **根因**：`molarity_screen.dart` 烧杯 Stack 的 `alignment: Alignment.center` 会把**所有非定位子**（含沉淀容器）垂直居中。沉淀容器高 0.4×beakerH 居中后，painter 内部"底部 25%"换算到烧杯坐标是 60%~70% 高度——粒子悬浮在溶液中部而非烧杯底；深色溶液（如 KMnO₄）中同色系粒子更不可见。
- **修复**：改 `Positioned(left: beakerW*0.07, bottom: 0, ...)` 精确贴底（Stack 尺寸 = 烧杯容器，Positioned 不受 alignment 影响）。
- **踩坑 1**：先试了 `Align(bottomCenter)` 包裹——无效！Align 在 loose Stack 里 shrink-wrap 到子尺寸，随后 Align 自身仍被 Stack 居中，内部对齐无空隙可用。**结论：Stack 内要贴边必须用 Positioned，Align 只在"Align 占满父"时才有对齐意义**。
- **踩坑 2（与 2026-08-20 InquiryDrawer 同族）**：Stack 的 alignment 与非定位子尺寸是布局组合陷阱——视觉子元素"应该在底部"不等于"会被放在底部"；每个 CustomPaint 容器的**坐标系换算**（容器在 Stack 里的位置 + painter 内部区域）必须显式验证，本次新增回归测试直接断言沉淀容器 bottom ≈ 烧杯容器 bottom（容差 6%）。
- **回归测试**：`test/chemistry/molarity/molarity_screen_test.dart` "过饱和 → 沉淀粒子堆积在烧杯底部"——换 K₂Cr₂O₇（饱和 0.50）+ 拉满溶质 → 断言 `Saturated!` 指示 + 两个 painter 容器的几何位置关系。

### 2026-08-20 · 代码审查实证：条件包裹层会销毁子树 State（相同 key 也救不回）

对 InquiryDrawer 五阶段改造做审查时，实测发现两个测试未覆盖的缺陷，根因同属"Widget 树结构随状态变化"这一类：

- **缺陷 1（功能失效）**：Completed 阶段展开回顾，显示的是「1 题未验证」而非学生真实作答——CON-007（session 级持久化）实际失效。根因：`InquiryStageCard` 里写成
  ```dart
  final body = isCompleted ? IgnorePointer(child: reviewContent) : content;
  ```
  状态切换时该位置的 widget 从 `PredictionPanel` 变成 `IgnorePointer` → **runtimeType 不匹配 → element 卸载重建 → State 丢失**。即使 active 版与 review 版特意用了相同 `ValueKey` 也无效：**key 只在同一位置 + 同 runtimeType 时才参与复用判定**，中间插入一层就断了。
  修法：包裹层固定存在，只切内部属性——`IgnorePointer(ignoring: isCompleted, child: body)`。
  **通用规则：想保留子树 State，包裹层的"有无"不能随状态变，只能变它的参数。**
- **缺陷 2（误操作）**：点击 Completed 卡片的回顾内容区会意外折叠卡片。根因：`InkWell` 包了整个 Column（Header + 内容 + Footer），而内容被 `IgnorePointer` 设为不消费事件 → 点击穿透到 InkWell → 触发折叠。修法：InkWell 只包 Header（Locked 态因内容为空，额外让 Footer 也可点）。**IgnorePointer 让子树"不消费事件"，事件会继续向上冒泡命中祖先手势——不等于"点击无效"。**
- **测试盲区反思**：改造后 105 个测试全绿，但这两个缺陷都没被发现——因为测试只覆盖了"状态机推导"（纯逻辑）与"Active 态交互"，没有覆盖"**状态切换后的历史数据是否还在**"。补 `test/common/inquiry_stage_review_test.dart` 3 个用例锁定。**教训：状态机类改造的测试必须包含"回头看"路径，不能只测"往前走"。**

### 2026-08-20 · AI 场景生成工具链审计：5 处需同步点两两错位，生成物静默进死目录

审计"配置化 / AI 可生成化"两条原则的落地情况，发现工具链的**同步点分散在 5 处**且互不校验，导致多处错位：

| 同步点 | 位置 | 审计前状态 |
|---|---|---|
| Dart 加载路径 | `lib/<sim>/config/*scenario_manager.dart` 的 `manifestPath` | 权威源 |
| 生成写入路径 | `generate.py` `--write`（原用 sim key 拼接） | **4/8 错位** |
| JSON Schema | `schemas/<sim>_scenario.schema.json` | inquiryTask **1/8 覆盖** |
| AI Prompt | `docs/prompts/<sim>_scenario.md` | inquiryTask **1/8 覆盖**（且那 1 个漏 predictions） |
| 打包声明 | `pubspec.yaml` `assets:` | 与 Dart 一致 |

- **最严重（生成物会静默丢失）**：目录命名风格分裂——Dart 侧用连字符（`color-vision/` `radio-waves/` `wave-interference/`）、optics 更是平铺在 `assets/scenarios/` 根目录，而 `generate.py --write` 直接用 sim key（下划线）拼路径。任何 `--write --sim color_vision` 都会写进 app 永不加载的目录，**且不报错**（pubspec 未声明该目录 → 不打包 / 不加载 / 无异常）。修法：引入 `SCENARIO_DIR_MAP`（以 Dart `manifestPath` 为权威源）+ `scenario_dir()`。
- **孤儿目录 `assets/scenarios/color_vision/` 的来源（git 查证后修正初判）**：最初推断是 generate.py 写错路径的产物，**该推断错误**。`git log --diff-filter=A` 显示它与 `color-vision/` 在**同一 commit `e180529`（资产进库）中一起进来**，属一次性重复拷贝；此后下划线版**仅 1 次提交、再未改动**（冻结在初始态：manifest 只登记 1/11 场景、rgb-default 缺 `challenge` 块），而连字符版有 3 次提交持续维护。两件事分开看：孤儿目录是历史遗留，generate.py 路径 bug 是独立隐患（不修则未来 `--write` 会往死目录追加内容使问题恶化）。**教训：判断"文件为何存在"要查 git 历史，不能从代码行为反推来源。** 处置：2026-08-21 经用户确认删除（逐字段比对确认无独有内容，可从 `e180529` 恢复），守卫第 6 例转绿。
- **次严重（新功能对 AI 不可见）**：探究抽屉的 `inquiryTask` 已在 8 个 sim 的 model 与 11 个场景 JSON 中使用，但只有 molarity 的 schema/prompt 定义了它，且**连 molarity 也漏了 `predictions`**。因为无 schema 用顶层 `additionalProperties: false`，多余字段**静默漏检**（不报错），缺陷长期隐藏。后果：AI 生成的新场景不含探究任务 → 五阶段抽屉直接不显示。
- **单一源取舍**：8 份 schema 内联 inquiryTask 定义（JSON Schema 外部 `$ref` 需 resolver，而 `Draft202012Validator` 未配 → 不可用）；但 prompt 侧改为**共享附录 + generate.py 拼接**（`docs/prompts/_shared/inquiry_task.md`），避免 8 份文档副本漂移。
- **防漂移机制**：新增 `test/tooling/ai_scenario_gen_consistency_test.dart` 6 个用例，把 5 处同步点两两钉死（路径一致 / sim 覆盖一致 / schema 含 inquiryTask 全字段 / 共享附录被拼接且未被复制 / pubspec 声明齐备 / 无孤儿目录）。**该测试立即捕获了 `color_vision` 孤儿目录——负向验证了守卫非空转。**
- **教训**：跨语言工具链（Dart app + Python 生成器 + JSON schema + markdown prompt）的一致性**无法靠注释维持**。凡"同一事实写在 N 处"，必须有一个自动化断言把它们两两比对，否则错位只会在用户使用时才暴露，且**表现为静默失败而非报错**。

### 2026-08-21 · schema 严格校验：从"漏检"到"拦截"，以及第二例"新功能对 AI 不可见"

承接上条审计，补齐 `additionalProperties: false`。过程中的关键点：

- **上条记录的"25 个场景"数字有误，实际 45 个**。原因：审计脚本用 `assets/scenarios/{sim}/` 拼路径，漏掉了连字符目录（radio-waves / wave-interference）。修法：脚本直接 `import generate as g` 复用 `SCENARIO_DIR_MAP`，**审计工具与被审计工具共用同一份路径映射**，避免审计本身出现盲区。
- **第二例"新功能对 AI 不可见"**：递归比对 45 个场景 vs schema，发现唯一未定义字段是 color_vision 的 `challenge`（挑战模式配置）。它在 `lib/color_vision/config/color_vision_scenario.dart` 的 `CVChallengeConfig` 中**真实解析并使用**（targets / timeLimit / accuracyThreshold / randomTargets），2 个场景在用，但 schema 与 prompt 都没有它——prompt 里的 "challenge" 仅是某个示例的 scenarioId。与 inquiryTask 同构：**功能落地了，但对 AI 不可见**。
- **严格校验的施加范围**：只加在「有 `properties` 且未显式声明 `additionalProperties`」的 object 节点（8 个 schema 共 108 处）。显式写了 `additionalProperties: {...}` 的节点是 map 语义（如 circuit 的 `availableComponents`）、没有 `properties` 的 object 是自由结构（如 `successCriteria.params` 随 type 变化）—— 这两类都必须跳过，否则误伤。
- **正负双向验证（缺一不可）**：正向 45/45 场景通过（证明无误伤）；负向注入 21 个拼错字段用例 21/21 被拦截（证明真生效）。用户举的例子 `initialParams.soluteAmount → soluteAmmount` 在 6 个 sim 上均被捕获。**只做正向验证会漏掉"规则写了但没生效"的情况。**
- **防漂移最后一环**：守卫测试增至 9 例，新增最实用的一条——**用 Dart 递归比对所有场景 JSON 与 schema 的字段**（含 `$ref` / `items` / `oneOf` 解析）。它同时守两个方向：场景多字段而 schema 未定义会失败；schema 加严格校验误伤现有场景也会失败。负向验证：临时注入 `soluteAmmount` → 守卫失败并精确报出字段名，还原后转绿。
- **教训**：`additionalProperties` 缺省值是"允许任意字段"，这个默认对 AI 生成场景**极不友好**——AI 拼错字段名不会报错，只会静默变默认值，表现为"场景加载成功但行为不对"。凡是给 AI 消费的 schema，都应显式收紧。

### 2026-08-21 · testWidgets 里直接 await rootBundle 会污染 asset 缓存，让后续用例挂到超时

`test/forces/forces_scenario_test.dart` 的 `netforce-tug scenario has valid pullers` 长期卡 10 分钟超时（此前三次被我标注"预先存在、与本次改动无关"而未深究）。真实根因与"forces 逻辑"完全无关：

- **现象反常点**：同文件前一个用例 `all 5 scenarios parse`（同样 `await mgr.loadScenarios()`，且已成功解析全部 5 个场景，含 netforce-tug）**通过**，紧接着的用例却挂死。`loadScenario()` 是纯同步的 `firstWhere` + 恒等函数，不可能挂起——所以挂点必在 `loadScenarios()`，但它在前一个用例明明成功了。
- **隔离实验定位**（5 个变体，每个 12s 超时）：

  | 变体 | 结果 |
  |---|---|
  | A · 进程内**首次** `await loadScenarios()` | 通过 |
  | B · 第二个 testWidgets 再次加载 | 挂起 |
  | C · 用 `tester.runAsync` 包裹 | **仍挂起** |
  | D · 同一用例内连续两次 | 挂起（第一次就没走完） |
  | E · 纯 `test()` 直接读 rootBundle | 挂起 |

  → 与 FakeAsync / runAsync **无关**，规律是"进程内首次成功，之后全挂"。
- **根因**：`rootBundle` 是 `CachingAssetBundle`，`loadString` 内部 `_stringCache.putIfAbsent(key, () => super.loadString(key))`。在 `testWidgets` 中直接 await，这个 Future 会被存入缓存并**绑定到该用例的 FakeAsync zone**；用例结束、zone 销毁后，缓存项变成**永久 pending**。后续任何读同一 asset 的用例（无论是否用 runAsync、是否 testWidgets）都拿到这个坏 Future。
- **修法**：所有读 asset 的用例**一律**用 `await tester.runAsync(() => mgr.loadScenarios())`。验证实验：3 个连续 runAsync 用例全部通过（`netforce-tug` pullers=8）。
- **顺带排掉一颗定时炸弹**：全项目扫描发现 `test/circuit/scenario_manager_test.dart:414` 同样是 testWidgets 直接 await。它当时"侥幸通过"只因恰好是该文件首个读 asset 的用例——一旦后面再加一个读 asset 的用例就会挂。已预防性改为 runAsync。
- **纯 `test()` 是否安全**：安全，前提是**同文件内没有 testWidgets 先污染缓存**（flutter test 为每个文件起独立 isolate，所以污染不跨文件）。项目里 `color_vision_l9_regression_test.dart` 等 4 处纯 test 直接 await 均无问题。
- **教训 1**：报错指向的用例**不是**污染源。debug 时若发现"前一个同类用例通过、后一个挂死"，要怀疑**共享缓存被前者污染**，而不是纠结后者的业务逻辑。
- **教训 2**：`--timeout` 参数对 `testWidgets` 无效（10 分钟由 flutter_test 内部控制），排查时应在代码里写 `timeout: Timeout(Duration(seconds: 12))` 才能快速迭代——这一步把单轮验证从 10 分钟压到 12 秒。
- 成效：全量测试从 313 通过/1 失败（耗时 10+ 分钟）变为 **313 通过 / 1 skip / 0 失败，耗时 6 秒**。

---

## 参考链接

- 权威源入口：[INDEX.md](INDEX.md)
- 配置化条款：[architecture/design-patterns.md · §配置化项目硬约束](architecture/design-patterns.md)
- AI 生成完整评估：[architecture/ai-generation-readiness.md](architecture/ai-generation-readiness.md)
- 外部资产：
  - `C:\workspace\kratos\docs\prompts\{circuit,forces,optics}_scenario.md`
  - `C:\workspace\kratos\schemas\{circuit,forces,optics}_scenario.schema.json`
  - `C:\workspace\kratos\assets\scenarios\` （optics 3 + circuit 7 + forces 5 = 15 samples）
