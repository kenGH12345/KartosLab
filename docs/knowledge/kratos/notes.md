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

### 2026-08-11 · CanvasProjection 与 SceneProjection 投影原点不一致 → 拖放错位（含缩放教训）

- **现象**：电路屏拖放元件后位置错位、点选不中（`req-ui-interaction-polish`，Major-1）。
- **根因**：`DropCanvas` 放置用 `CanvasProjection`（origin=(W/2, H×0.55)），而电路渲染/hitTest 用 `SceneProjection`（origin=(W/2, H/2)）——**两套投影原点不同**；且 `_onComponentDrop` 转换硬编码 `zoom:1`，渲染/命中却用 `_state.zoom`（0.6~2.0 可调）。
- **解决**：`_onComponentDrop` 中把 `CanvasProjection` 的 world 转回 screenLocal，再用**当前 `_state.zoom`** 构造 `SceneProjection` 转 world（`circuit_screen.dart:179-183`）。
- **教训（重要）**：涉及投影/命中坐标换算时，**缩放系数必须从组件内部状态读取，不可用默认值硬编码**。
- **同类风险检查**：其他接 `DropCanvas` 的 sim（optics 等）需核查是否也存在"放置用 CanvasProjection、渲染/hitTest 用 SceneProjection"的原点不一致问题。

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

---

## 参考链接

- 权威源入口：[INDEX.md](INDEX.md)
- 配置化条款：[architecture/design-patterns.md · §配置化项目硬约束](architecture/design-patterns.md)
- AI 生成完整评估：[architecture/ai-generation-readiness.md](architecture/ai-generation-readiness.md)
- 外部资产：
  - `C:\workspace\kratos\docs\prompts\{circuit,forces,optics}_scenario.md`
  - `C:\workspace\kratos\schemas\{circuit,forces,optics}_scenario.schema.json`
  - `C:\workspace\kratos\assets\scenarios\` （optics 3 + circuit 7 + forces 5 = 15 samples）
