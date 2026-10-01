# req-build-a-nucleus · 实施记录

> 分析文档：`BUILD_A_NUCLEUS_ANALYSIS.md`
> 本文件按阶段记录决策、证据与工时。诚实标记：[已确认] / [推测] / [待确认]

---

## Phase 1A · 数据层（2026-08-28 完成）

### 范围

Decay Screen MVP 所需数据层：核素稳定性 / 半衰期 / 衰变模式 / 元素符号与名称 / 电子云半径。
不含 UI、拖拽、动画。

### 目录决策

**最终目录：`lib/chemistry/build_a_nucleus/`**，子目录采用扁平约定
（`data/`、`model/`、`screens/`、`painters/`、`widgets/`、`config/`）。

依据 [已确认]：
- 8 个已有 sim 中 7 个（sound / circuit / optics / forces / color_vision / radio_waves /
  wave_interference）使用扁平结构；`lib/chemistry/molarity/` 的 `controller/model/view/config`
  嵌套是少数派（19 文件实测）。
- Decay MVP 无独立 Controller（Screen 兼任输入处理，与 sound/circuit 主流一致），
  不需要 molarity 式 MVC 嵌套。
- 归属 `chemistry/`：HomeScreen 按学科分组，本 sim 属化学/原子核主题，且用户已暂定认可。

### 数据方案决策

**原始数据 → JSON → Schema → Dart Model / Repository** [已确认落地]：

| 层 | 文件 | 说明 |
|---|---|---|
| 原始数据 | `requirements/req-build-a-nucleus/reference/AtomData.ts`、`AtomNameUtils.ts` | PhET shred 仓库 main 分支快照（Relational ENSDF 2022，GPL-3.0），留存作转换依据 |
| 提取脚本 | `scripts/extract_nuclide_data.mjs` | Node 一次运行，内置 11 项锚点自检（C-14、Pu-240、Be-6 等） |
| JSON | `assets/data/nuclide_table.json` | 101.5KB 紧凑格式；119 元素、244 稳定条目、2807 半衰期条目 |
| Schema | `schemas/nuclide_table.schema.json` | draft 2020-12，文档级（工程无运行时校验先例） |
| Dart Model | `lib/chemistry/build_a_nucleus/data/nuclide_table.dart` | `NuclideTable` / `ElementInfo` + fromJson |
| Lookup | `lib/chemistry/build_a_nucleus/data/nuclide_repository.dart` | `NuclideRepository`，逐函数对标 shred `AtomInfoUtils` |
| 衰变类型 | `lib/chemistry/build_a_nucleus/data/decay_type.dart` | `NucleusDecayType` 5 值 + ENSDF 键映射（忽略键返回 null） |
| 加载器 | `lib/chemistry/build_a_nucleus/data/nuclide_data_loader.dart` | rootBundle 加载，可注入 AssetBundle |

### 关键保真决策（均有原项目源码依据）

1. **数据范围**：只提取 Decay 屏用到的 4 张表（stableElementTable / HalfLifeConstants /
   DECAYS_INFO_TABLE / mapElectronCountToRadius）+ 元素符号名表。
   `ISOTOPE_INFO_TABLE`（同位素质量/丰度）、`standardMassTable` 等未被 Build a Nucleus
   任何代码引用，不提取。[已确认：AtomInfoUtils 全部调用点排查]
2. **ENSDF 衰变键保持原样**（'B-'、'EC+B+'、'A'、'2P' …），映射逻辑在 Dart 侧，
   逐行对照 `AtomInfoUtils.getAvailableDecaysAndPercents` 的 switch。[已确认]
3. **半衰期三态**忠实保留：无条目 / 条目为 null（未知）/ 有秒数
   （`HalfLifeInfo{hasEntry, seconds}`）。[已确认]
4. **衰变排序用稳定排序**：JS `Array.prototype.sort` 稳定、Dart `List.sort` 不稳定，
   并列分支比（如 Be-6 的 2P:100 + A:100）需保持表内顺序，用下标 tie-break 复现。[已确认]
5. **0p0n 空核**：数据层 `doesExist(0,0) = false`（与原项目一致）；
   「0p0n 是可接受的空态」属于视图层特例，留到 Phase 1B/1C。[已确认 BANScreenView.step]
6. **元素名**用首字母大写英文名（`englishNameTable` 大写化）；中文本地化方案 [待确认]。

### 新约定（工程首例，需用户知晓）

- `assets/data/` 目录为本 sim 新建（此前 assets 只有 images/sounds/scenarios），
  已在 pubspec.yaml 声明。原分析文档中该项为 [待确认]，现已落地 → 若不接受可回退。

### 验证结果

- `flutter analyze lib/chemistry/build_a_nucleus test/chemistry/build_a_nucleus` → No issues found
- `flutter test test/chemistry/build_a_nucleus` → 17/17 通过
  （迷你表逻辑 12 项 + 真实数据锚点 5 项：H-3/C-14/自由中子/Be-6/Pu-240 半衰期、
  稳定性、存在性、衰变分支、元素表/电子云半径）
- 全量 `flutter test` 回归：除 `test/forces/forces_scenario_test.dart` 外 **276/276 通过**
  （1 个 skip 为既有）。该 forces 测试文件**单独运行也会挂起**（90 秒无输出），
  属既有问题，与本阶段改动无关（本阶段未触碰 forces 任何代码）→ 建议单独立项排查。
- 副作用：`flutter pub get` 将部分依赖小版本升级（audioplayers 6.7.1→6.8.1 等），
  pubspec.lock 有变动；pubspec.yaml 本身仅新增一行 assets 声明。

### 工时

| 项 | 理论（分析文档 §21） | 实际 |
|---|---|---|
| 数据表提取转换 + 校验 + 锚定测试 | 8h（探索任务） | ≈0.5h（2026-08-28 11:44–11:55，AI 辅助单次会话） |

### 下一阶段入口（Phase 1B 提示）

- `NuclideRepository` 已提供 Phase 1B 所需全部查询：isStable / doesExist / halfLife /
  availableDecays / 6 个邻位判定 / elementSymbol / elementName / electronCloudRadius。
- DecayModel 的 halfLifeNumberProperty 语义（稳定→10^24、不存在→0、null→0）属于
  Model 层，不在数据层实现。

---

## Phase 1B · Model / State（2026-08-28 完成）

### 交付文件

| 文件 | 职责 |
|---|---|
| `lib/chemistry/build_a_nucleus/ban_constants.dart` | 常量（94/146 上限、捕获半径 100、1 秒纠正、1e24 稳定显示值、-1 未知半衰期），逐项标注原项目出处 |
| `lib/chemistry/build_a_nucleus/model/nucleon.dart` | `Nucleon`（id/type/x/y，纯 Dart）、`NucleonType`、`EmittedParticleType` |
| `lib/chemistry/build_a_nucleus/model/build_a_nucleus_state.dart` | `BuildANucleusState` 可变模型：核内核子列表、衰变产物、undo 快照、无效核素回退；派生量全部委托 `NuclideRepository`（State 与 Data 职责分离） |
| `test/chemistry/build_a_nucleus/build_a_nucleus_state_test.dart` | 23 项纯 Dart 测试（真实数据驱动） |

### 已实现的的状态转换（均 [已确认] 有原项目源码依据）

- 核子增减 + 箭头 enable 规则（逐条对标 `NucleonCreatorsNode.createArrowEnabledProperty`，
  含「上箭头允许越界 1 个」「下箭头 (1,0)/(1,1) 特例」「不存在核素禁用全部按钮」）
- 拖拽进出核：捕获半径 100 判定 + 「移除会造成不存在核素则强制收回」（`dragEndedListener`）
- 五种衰变的状态变更：n/p 发射取离中心最近者、α 取 2p+2n、β 衰变原位转换核子类型并发射电子/正电子
- Undo：恢复衰变前计数 + 清空发射产物；任何后续核变化使 undo 失效（对标 hideUndoButtonEmitter）
- 无效核素回退：`stepInvalidNuclideRollback(dt)` 累计 1 秒后回退到上一个有效核素；
  0p0n 空核不触发（p0n0Case 特例）
- Reset：恢复到 0p0n 空核（DEFAULT_INITIAL_* = 0）

### 与原项目的已知差异（[推测] / 留待后续阶段）

- 本阶段添加/移除立即生效；原项目粒子需动画飞入核后才计数（incoming/userControlled
  数组留待 Phase 1E 拖拽阶段）。
- `_removeNucleon` 取「离中心最远」核子；原项目取「离生成器节点最近」（生成器坐标属视图层，
  核子同类型不可区分，对计数无影响）。
- α 衰变产物在 outgoing 中合并为一条 `alpha` 记录（原项目为 4 个核子 + AlphaParticle 对象；
  undo 不依赖其内容，行为等价）。
- Be-6 α Hollywood 特例已在 Phase 1F-2B-2 落地（见该节）。

### 事故记录：协议标记污染

- 1B 首轮生成时，测试文件混入 24 处字面 `<|sep|>` 标记、`nucleon.dart` 注释混入 2 处
  （模型生成侧协议 token 泄漏，非工具/工程问题）。
- 修复：仅改动测试文件——15 行按行号定点恢复标识符（依据：state 文件字节级验证过的
  真实 API），未改任何业务代码。
- 遗留：`nucleon.dart` 注释中 2 处标记（不影响编译与测试；按当时任务边界未清理，
  建议 Phase 1C 前顺手清理）。
- 教训：生成含特定词干的代码后，先跑 `scripts/_diag_ident.mjs` 扫描再 analyze。

### 排障：唯一失败测试的根因

「invalid 累计 1 秒回退」首次运行失败（Expected 1, Actual 0）。根因 [已确认]：
原项目在**每一帧** step 中记录上一个有效核素（BANScreenView.step 362-381）；
测试未在有效态推进帧，快照仍是初始 (0,0)。修复方式是测试侧补一次帧推进
（`stepInvalidNuclideRollback(0.016)`），断言标准未降低。

### 验证结果

- `flutter analyze`（lib + test 的 build_a_nucleus 范围）→ No issues found
- `flutter test test/chemistry/build_a_nucleus` → **40/40 通过**（1A 17 项 + 1B 23 项）
- 测试文件字节级扫描：无任何 `<|...|>` 协议标记

### 工时

| 项 | 理论（分析文档 §21） | 实际 |
|---|---|---|
| Model + State（1B） | 8h + 3h（State 接入） | ≈1h（含排障；12:24–13:05 会话，含中断） |

---

## Phase 1C · Controller + 交互闭环（2026-08-28 完成）

### 交付文件

| 文件 | 职责 |
|---|---|
| `lib/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart` | `BuildANucleusController extends ChangeNotifier`：用户命令（增减/成对/衰变/撤销/重置）、拖拽闭环（dropFromTray / beginDrag / moveDragged / endDrop）、`tick(dt)` 时间推进入口。对齐 molarity 显式 Controller 模式；通知机制参照 molarity `Solution` 的 ChangeNotifier 先例 [推测：范式选择依据] |
| `lib/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart` | 最小可运行壳（占位视觉）：NineGridLayout + DropCanvas(center) + DragTray(footer) + 增减箭头 + 衰变按钮 + 撤销 + 重置 + 读数面板。**未注册进 HomeScreen**（正式入口待 UI 阶段） |
| `test/.../build_a_nucleus_controller_test.dart` | 12 项 Controller 测试（命令/通知/拖拽/衰变/撤销/重置/tick 回退） |
| `test/.../build_a_nucleus_screen_test.dart` | 5 项 Widget 测试（初始渲染/箭头/拖入/拖出/衰变+撤销+重置） |

### State 层新增（1C 必需）

- `BuildANucleusState.createFreeNucleon(type, {x, y})`：创建不入核的自由核子，
  对标原项目 createParticleFromStack 创建后、到达核之前的形态。id 由状态统一分配。

### 复用确认（未新造拖拽框架）

- `DragTray<NucleonType>` + `DropCanvas<NucleonType>` + `CanvasProjection` 直接复用；
  Draggable 静态列表天然满足「生成器无限供应」语义 [已确认 drag_drop_workspace.dart:56]。
- `CanvasProjection.origin = (w/2, h*0.55)` 与原项目
  `SCREEN_VIEW_ATOM_CENTER_Y = height * 0.55` 一致 [已确认 两处源码]。
- `SimulationClock(fps:60)` 驱动 `controller.tick(dt)`（无效核素 1 秒回退）。
- `NineGridLayout.footer` 承载生成器条。

### 排障记录（均为本阶段壳代码问题，未改业务逻辑）

1. `_NucleusCanvas` 用 `dynamic` 持有 state 导致 spread 类型错误 → 改为强类型字段。
2. 九宫格边格几何实测：边格宽 ≈65px、顶/底行高 ≈44px → 衰变按钮改紧凑符号按钮
   （α/β-/β+/p/n，符号 [已确认] BANDecayType.decaySymbol），读数/衰变面板加滚动，
   生成器条从 bottomCenter 移至 footer。
3. Widget 测试不能用 pumpAndSettle（时钟常开），用 pump（color_vision 既有教训）。

### 验证结果

- `flutter analyze`（BAN 范围）→ No issues found
- `flutter test test/chemistry/build_a_nucleus` → **57/57 通过**
  （1A 17 + 1B 23 + 1C controller 12 + 1C widget 5）
- 标记扫描：lib/test 下 0 残留（notes.md 中 2 处为事故记录的有意引用）

### 工时

| 项 | 理论（分析文档 §21） | 实际 |
|---|---|---|
| Controller（1C） | 0.5h | ≈0.7h（含 widget 壳与排障；14:17–14:40 会话） |

### 下一阶段建议（Phase 1D 渲染）

- 正式 `NucleusPainter`：核子径向渐变球 + 同心层排布 + 电子云
  （半径查 `electronCloudRadii`）；壳占位视觉整体替换。
- 半衰期对数数轴、符号面板（^A_ZX 上下标）、does-not-form 文案样式。
- 壳中 `_NucleusCanvas` / `_ArrowControls` 等占位件届时替换或提升为正式 widgets。

---

## Phase 1D · Nucleus 基础渲染（2026-08-28 完成）

### 关键取证（原 [待确认] 项已解密）

**`reconfigureNucleus` 排布算法** [已确认，shred ParticleAtom.ts 540-659 行全文]：

1. 先按 `neutronsPerProton` 比例累积器把质子/中子**交错**成单一序列
   （如 2p1n → [p,n,p]；2p2n → [n,p,n,p]）
2. 按总数分情形（核中心为原点，nucleonRadius = 10 [已确认 ShredConstants]）：
   - 1 个：居中
   - 2 个：并排，距中心 r，角度 0.4π（原项目任意选定）
   - 3 个：互切三角，距中心 r×1.155，角度起点 1.4π，间隔 120°
   - 4 个：菱形——0/2 位 ±r（z=1），1/3 位垂直方向 ∓r（z=2）
   - ≥5 个：螺旋层——首核居中；每层 `radius += r×scaleFactor/level`、
     容量 `floor(radius×π/r)`、角度步进 `0.4π + level×π`（观感任意值）；
     `scaleFactor = LinearFunction(3,10, 2.4, 1.35, clamp)`，r=10 → **1.35**
3. 原版写入 destinationProperty，粒子以 300 px/s 匀速归位（Particle.step）；
   zLayer 大者靠后，拖拽中为 0

**核子视觉** [已确认 ParticleNode.ts + PARTICLE_COLORS]：
- 径向渐变：中心 (-0.4r, -0.4r)、半径 1.6r、白 → 基色；描边 = 基色
- 质子 #D14600；中子 = gray×0.9 ≈ #737373；电子蓝；正电子 rgb(53,182,74)
- β 衰变有 0.5s 颜色渐变动画（changeNucleonType，留 1F）

### 交付文件

| 文件 | 职责 |
|---|---|
| `model/nucleus_layout.dart` | `NucleusLayout.reconfigure` 逐行移植（交错 + 5 种情形 + clamp 线性映射） |
| `painters/nucleus_painter.dart` | `NucleusPainter`：zLayer 排序 + 径向渐变球 + 基色描边 |
| `ban_constants.dart` | +nucleonRadius=10、质子/中子基色 |
| `model/nucleon.dart` | +zLayer 字段（渲染相关模型态，原版即在模型中） |

### Render 接口缺口报告（按要求先报告再最小修改）

- **缺口**：核子位置是模型状态（原版 positionProperty/destinationProperty 在 Particle 中），
  1B 的 State 只有 x/y 默认值，Painter 无位可绘。
- **最小修改**：`_onNucleusChanged` 中按「质量数变化才重排」调用 `NucleusLayout.reconfigure`
  （对标 BANModel 的 massNumberProperty.link；β 衰变质量数不变不重排，
  与原项目 defer 行为一致，有测试锁定）；`beginNucleonDrag` 置 zLayer=0。
- 未改动任何 1B 已有行为与 API。

### 与原项目的已知差异

- 排布直接落位（无 300px/s 归位动画）→ Phase 1F 补。[已确认差异来源]
- 电子云未渲染（1D 范围外，用户明确暂缓）。
- 壳中捕获区提示圆已随占位渲染移除（原版无此视觉）。

### 测试与验证

- 新增 `nucleus_layout_test.dart` 11 项：1/2/3/4/≥5 布局精确坐标（closeTo 1e-9）、
  240 核子边界不发散、State 集成（添加后落位、β 不重排、α 重排、拖拽 zLayer、reset）
- 排障：3 核子用例的交错顺序预期写错（[n,p,p] → 实为 [p,n,p]），测试侧修正
- `flutter test test/chemistry/build_a_nucleus` → **68/68 通过**
- `flutter analyze`（BAN 范围）→ No issues found
- 工程无 golden/截图测试先例 → 未新建视觉测试框架（遵守约束 §8）

### 工时

| 项 | 理论（分析文档 §21） | 实际 |
|---|---|---|
| Painter（1D，含排布取证） | 8h（探索任务） | ≈0.7h（14:32–15:05 会话） |

---

## Phase 1E-1 · 核内核子直接拖动（2026-08-28 完成）

### 取证结论（shred ParticleView.ts 全文已读）

| 行为 | 原版实现 | 标记 |
|---|---|---|
| 命中区域 | ParticleNode 圆本身（r=10 屏 px）；1.5r 圆仅为无障碍焦点高亮 | [已确认] |
| 拖拽偏移 | `applyOffset: false` → 拖动时核子**中心对齐指针**（无抓取点补偿） | [已确认] |
| 拖拽阈值 | scenery DragListener 默认值（数值未取证）；本实现按下命中即生效 | [待确认]（差异微小） |
| 拖动开始 | 取消进行中的动画；isDragging=true → 从 particleAtom 移除、zLayer=0 | [已确认] |
| 拖动中 | destination 跟随指针 + moveImmediatelyToDestination（位置即时更新） | [已确认] |
| 拖动中核素状态 | 核内计数立即变化 → 读数/稳定性实时更新 | [已确认]（有 widget 测试锁定） |
| 生成器规则 | 用「有效计数 = 核内 + incoming + 拖拽中」判存在性/邻位/范围；下箭头零检查用核内计数 | [已确认] NucleonCreatorsNode |
| 无效回退 | 拖拽中暂停触发（计时照常累计） | [已确认] BANScreenView.step 388-389 |
| 松手 | 捕获区内 → 入核；区外 → 返回生成器；移除会造成不存在核素 → 强制收回 | [已确认]（1B 已实现，本次接入真实指针） |

### 变更

- `model/build_a_nucleus_state.dart`：+`_draggedNucleons`（对标 userControlled 数组）；
  `_creatorEnabled` 改用有效计数；`stepInvalidNuclideRollback` 触发条件加「无拖拽中粒子」；
  beginDrag/endDrop 维护拖拽列表
- `controller`：+`hitTestNucleon(worldX, worldY)`（圆命中 + zLayer 最小者优先）
- `painters/nucleus_painter.dart`：补画拖拽中核子（最前层）
- `screens`：画布内容包 `Listener`（translucent，不影响 DragTarget 外部拖入），
  pointer down 命中 → beginDrag；move → moveDragged；up/cancel → endDrop
- 排障：`_NucleusCanvas` 的 `Positioned.fill` 在 Listener 包裹下脱离 Stack → 改 `SizedBox.expand`

### 测试（新增 8 项，`build_a_nucleus_drag_test.dart`）

有效计数规则 / 拖拽中回退暂停 + 强制收回 / zLayer 恢复 / 命中半径边界 / 重叠取最前 /
widget 端到端：拖中子出核（He-4→He-3，含拖动中读数实时更新）、区内松手保留、空白点按无操作。

### 验证

- `flutter test test/chemistry/build_a_nucleus` → **76/76 通过**
- `flutter analyze`（BAN 范围）→ No issues found

### 工时

| 项 | 理论（分析文档 §21 Interaction 8h 之一部） | 实际 |
|---|---|---|
| 1E-1 核内拖拽 | —（子项未单列） | ≈0.5h（14:53–15:20 会话） |

---

## Phase 1E-2 · 生成器拖出 + 归位动画（2026-08-28 完成）

### 取证结论（此前已读源码，本阶段落定）

| 行为 | 原版实现 | 标记 |
|---|---|---|
| 创建时机 | 生成器 pointer down 即创建粒子并 `startSyntheticDrag`（立即拖拽态） | [已确认] NucleonCreatorNode→addAndDragParticle |
| 初始位置 | 生成器中心（creatorNodeModelCenter，世界坐标） | [已确认] |
| 跟随方式 | 中心对齐指针（applyOffset: false），桌面端无偏移 | [已确认] ParticleView；触屏 touchOffset 值 [待确认] |
| 拖拽阈值 | scenery DragListener 默认值（未取证）；本实现按下即生效 | [待确认] |
| 无限供应 | 生成器不消耗，可连续/多指拖出（userControlled 数组复数语义） | [已确认] |
| 成功 drop | 捕获区（r<100）内 → 入核，reconfigure 设 destination，从落点动画归位 | [已确认] |
| 失败 drop | `animateAndRemoveParticle`：300px/s 匀速飞回生成器中心，到达后销毁 | [已确认] |
| 归位速度 | `PARTICLE_ANIMATION_SPEED = 300`（CSS px/s）；`Particle.step` 匀速直线，恰好相等也算到达（issue#198） | [已确认] |
| 拖动中生成器规则 | 有效计数含拖拽中粒子（1E-1 已接入） | [已确认] |
| 取消拖拽 | pointer cancel 与松手同路径（dragEndedListener） | [推测]（scenery cancel 即 drag end；依拖拽监听器语义） |

### 架构决策（重要）

- **DragTray/Draggable 弃用于生成器**：common 拖拽组件是「drop 时才入世界」的
  离散元件语义，与原版「按下即创建活粒子并实时跟随」冲突。不改造 common
  （G1：避免影响 circuit/optics），生成器用 1E-1 同款 Listener 指针机制在 sim 内
  实现（L2 域特化）；`CanvasProjection` 继续复用。`DropCanvas` 随之不再使用
  （其 DragTarget 覆盖层「释放以放置元件」也非原版视觉，一并去除 → 更接近原版）。
- **运动模型入 Nucleon**：destX/destY + `stepMotion(dt, speed)` 逐行对标
  `Particle.step`；布局改写 destination（1D 起即为 destination 语义铺路）。

### 变更

| 文件 | 内容 |
|---|---|
| `model/nucleon.dart` | +destX/destY、isAnimating、setPositionImmediate、setDestination、stepMotion |
| `model/nucleus_layout.dart` | `_place` 改写 destination（原版即写 destination） |
| `model/build_a_nucleus_state.dart` | +`_returningNucleons`、beginFreeDrag、endNucleonDrop(returnX/Y)、stepMotion、moveAllNucleonsToDestination；beginNucleonDrag 取消进行中动画；**reset 补清拖拽/归位列表（1E-1 遗漏修复，有测试锁定）** |
| `controller` | +startTrayDrag；endDrop 支持归位坐标；tick 同时驱动运动与回退 |
| `painters/nucleus_painter.dart` | 补画归位中核子 |
| `screens` | 画布改 LayoutBuilder+Listener（KeyedSubtree 'ban_canvas' + GlobalKey 坐标桥）；footer 改 `_CreatorNode` 生成器（渐变球 + 标签）；多指会话 Map |

### 测试（新增 11 项 `build_a_nucleus_tray_drag_test.dart`）

归位匀速性（0.5s→150px）、归位完成移除、成功落点→卡位动画、无限供应、
拖动中有效计数规则、拖拽开始取消动画、reset 清场、widget 端到端：
按下即创建/实时跟随/入核、区外松手归位消失、多指同拖、cancel 按松手处理。

### 排障

1. GlobalKey 未挂载（Listener 上用了 ValueKey 而非 _canvasKey）→ 坐标换算回退零值；
   改 KeyedSubtree（测试用）+ GlobalKey（换算用）双层。
2. SimulationClock 每帧固定 dt=1/60（不看真实流逝）→ widget 测试按帧数推进。

### 验证

- `flutter test test/chemistry/build_a_nucleus` → **87/87 通过**（76 + 新增 11）
- `flutter analyze`（BAN 范围）→ No issues found
- 1D 布局测试同步迁移到 destination 语义（行为更贴近原版：落位有动画）

### 工时

| 项 | 理论 | 实际 |
|---|---|---|
| 1E-2 生成器拖出 + 归位动画 | —（Interaction 8h 之一部） | ≈0.7h（15:02–15:40 会话） |

---

## Phase 1F-1 · 箭头按钮飞入动画（2026-08-28 完成）

### 源码再确认（本阶段关键问题）

> **「原版是否在粒子真正到达 nucleus 后才增加核内计数？」——是。**
> [已确认] BANScreenView.createParticleFromStack（255-291 行）：粒子在生成器中心创建，
> `setAnimationDestination(核中心)` 飞行中入 incomingProtons/Neutrons（不计数、
> inputEnabled=false），`animationEndedEmitter` 到达回调里才 `particleAtom.addParticle`
> （此刻计数）→ reconfigureNucleus 设卡位 destination 继续归位。

### 变更

| 文件 | 内容 |
|---|---|
| `model/build_a_nucleus_state.dart` | +`_incomingProtons/_incomingNeutrons`、`_launchIncoming`（生成器→核中心）、`_processArrivals`（到达才入核）、`settleAll()` 测试辅助；`addProton/addNeutron/addPair` 改飞入签名（fromX/fromY，由视图层给生成器坐标）；有效计数含 incoming；`isDecayEnabled` 加 `!hasIncomingParticles`；reset 清 incoming |
| `controller` | +`creatorHomeResolver`（视图注入生成器世界坐标；命令保持零参） |
| `painters/nucleus_painter.dart` | 补画飞行中核子 |
| `screens` | 注入 creatorHomeResolver |

### 行为连锁确认（均有测试锁定）

- 飞行中：读数/核素身份不变（atom 计数）；衰变按钮禁用；生成器规则用有效计数；
  undo 隐藏（_onNucleusChanged 清快照，对标 multilink 含 incoming.lengthProperty）
- 下箭头零检查用核内计数 → 飞行中不可删（对标 issue#74 分支）
- 下箭头移除仍走立即移除；原版的「移除核子飞回生成器」动画与飞入同机制，
  留作后续小项 [待确认排期]
- undo/rollback 的 `_restoreCount` 走立即入核 —— 对标原版
  `addNucleonImmediatelyToAtom`（undo 本来就不用飞入动画）[已确认]

### 测试（新增 8 项 `build_a_nucleus_flyin_test.dart`）

创建于生成器位置/目的地核中心、300px/s 匀速到达才计数、到达后重排卡位 destination、
多飞行共存各自到达、飞行中衰变禁用、飞行中有效计数、reset 清空、widget 端到端
（点击→读数不变→泵帧→更新）。

### 存量测试迁移

37 处依赖「点击即计数」旧时序的断言迁移：buildUp 每步 settleAll、widget 测试加
pumpFlight 辅助（SimulationClock 固定 dt=1/60/帧）。迁移中发现的 3 个测试侧错误
（大步长同帧完成归位导致时序断言失效 / 大步长同帧触发 1 秒回退 / 误判 H-4 可 β-
——ENSDF 数据 H-4 仅中子发射），均为测试修正，业务行为未动。

### 验证

- `flutter test test/chemistry/build_a_nucleus` → **95/95 通过**
- `flutter analyze`（BAN 范围）→ No issues found

### 工时

| 项 | 理论（§21 Animation 6h 之一部） | 实际 |
|---|---|---|
| 1F-1 飞入动画 | —（子项未单列） | ≈0.6h（15:30–16:10 会话） |

---

## Phase 1F-2A · 衰变动画基础框架（2026-08-28 完成）

### ⚠️ 证据冲突修正（按诚实机制报告并落实）

`BANParticle.setAnimationDestination`（1F-2A 取证时全读）推翻了 1E-2/1F-1 的速度假设：

| 路径 | 旧实现 | 源码证据 | 现实现 |
|---|---|---|---|
| 箭头飞入 | 300 px/s 定速 | `consistentTime: true` → **固定 0.6s**（speed=dist/0.6） | 已修正 |
| 失败归位 | 300 px/s | `consistentTime: false` → 300 px/s | 不变 ✓ |
| 衰变发射 | —（本阶段新增） | 同上 → 300 px/s（AlphaParticle: duration=dist/300 恒速等价） | 300 px/s |
| 卡位归位 | 300 px/s | BANParticle 不覆盖 shred 默认 → **200 px/s** | 已修正（MovingParticle.speed 默认 200） |

分析文档 §7 交互表已同步回写。影响面：速度字段入 `MovingParticle`（每粒子自持），
1F-1 飞入测试改写为定时语义（含「距离 10 倍同为 0.6s」证明用例）。

### 衰变行为 13 问（取证结论，全部 [已确认]）

1. 触发条件：按钮 enabled = `!hasIncomingParticles && availableDecays.contains(type)`；decayAtom assert 核素存在
2. 核素状态变更时点：**点击即变**（extractParticle/changeNucleonType 同步改计数）
3. 发射粒子创建时点：点击即创建
4. 初始位置：n/p 发射=被取核子原位置；β 发射=换型核子位置且 zLayer+1（在其后）；α=核中心组装
5. destination：屏外随机点（可见区外扩 200px 排除 + 300px 目标环，均匀随机）
6. 速度：300 px/s 恒定（α 为等时长恒速直线）
7. 到达后：从模型移除（dispose）
8. daughter nuclide：点击即建立（读数立即更新）
9. 重排时机：质量数变化 → reconfigure（β 质量数不变不重排）
10. reset：清空 outgoingParticles + particleAnimations
11. 多动画并存：支持（数组语义）
12. 衰变期间按钮：按新计数立即重新派生
13. 互斥：仅 incoming 禁用衰变；**拖拽中无互斥**（decayEnabled 依赖不含 userControlled）

### 架构决策

- **不建状态机枚举**（idle/animating…）：原版无显式状态机，衰变 = 点击即变计数 +
  发射粒子飞行 + 数组跟踪。以原版为准（用户规则）。
- `EmittedParticle` 升级为运动粒子（与 Nucleon 共用 `MovingParticle` 基类，
  未复制第二套定速算法）。
- `DecayEvent`（type + parent/daughter 计数）替代散字段快照，undo 依赖之；
  核变化即失效（对标 hideUndoButtonEmitter 时机）。
- State 保持确定性：逃逸点由 Controller 计算注入（Random 可注入，测试确定性）。
- α 渲染复用 `NucleusLayout` 四核子菱形（AlphaParticle 内部即同一排布算法）。

### 变更文件

- `model/moving_particle.dart`（新）：共享匀速运动基类
- `model/nucleon.dart`：Nucleon/EmittedParticle 继承运动基类；+DecayEvent
- `model/build_a_nucleus_state.dart`：applyDecay 重写（发射粒子真实飞出）+ stepMotion
  驱动 outgoing + lastDecay/undo 重构 + 飞入 0.6s + 归位 300 + 卡位 200
- `controller`：+`_randomEscapePosition`（port getRandomEscapePosition）+ Random/Size 注入
- `painters`：outgoing 按类型绘制（电子 r8 蓝 / 正电子 r8 绿 / α 菱形簇 / 核子球），
  与核内核子按 zLayer 混排
- `screens`：注入 visibleSizeProvider

### 测试（新增 12 项 `build_a_nucleus_decay_animation_test.dart`）

五种发射的生命周期（点击即变/位置/速度/到达移除）、β 发射定位与 zLayer+1、
多动画并存、DecayEvent 记录/失效/undo 清空、逃逸点在排除区外、reset 清空、
widget 端到端（点击 → 读数即变 He-3 → 电子飞出消失）。

### 验证

- `flutter test test/chemistry/build_a_nucleus` → **107/107 通过**
- `flutter analyze`（BAN 范围）→ No issues found

### 未覆盖（后续阶段）

- 衰变按钮的 undo 按钮定位/面板正式 UI → UI 阶段

### 工时

| 项 | 理论（§21 Animation 6h） | 实际 |
|---|---|---|
| 1F-2A 衰变动画框架 | —（子项未单列） | ≈0.7h（15:51–16:35 会话） |

---

## Phase 1F-2B-1 · β 衰变 0.5s 换色动画（2026-08-28 完成）

### 取证结论（changeNucleonType 全文已于 1D 阶段读取，本阶段复核确认）

| 问题 | 原版行为 | 标记 |
|---|---|---|
| 换型核子 | 离中心最近者 | [已确认] |
| 状态时间点 | 计数点击即变（数组同步迁移 + massNumber defer 不重排） | [已确认] |
| 颜色开始/时长/曲线 | 点击即开始；0.5s；Easing.LINEAR | [已确认] |
| 起止颜色 | 旧类型色 → 新型色（base color 逐通道线性插值） | [已确认] |
| 渐变 | 随基色同步（ParticleNode 由基色重建填充） | [已确认] |
| zLayer | 不变 | [已确认] |
| 电子/正电子创建时机 | 点击即创建（置于换型核子位置、zLayer+1），**但 0.5s 换色完成后才飞出**（onChangeComplete 回调） | [已确认] |
| 换色中拖拽 | 禁止（inputEnabled=false，issue#115） | [已确认] |
| undo/reset 时 | clearAnimations 停掉换色动画，**颜色定格在中间值**（既不完结也不恢复；原版此处为已知粗糙边缘，见 issue#115 band-aid） | [已确认] |

### ⚠️ 冲突修正

1F-2A 中发射粒子「点击即飞」与源码不符 → 已修正为「创建即存在、滞留 0.5s、
换色完成后起飞」（`EmittedParticle.holdTime`）。

### 实现

- `Nucleon`：`colorAnimatingFrom / colorProgress / colorAnimationRunning`
  （render-only 三字段，无状态机）；冻结语义 = 停止推进但保留混合上下文
- `NucleusPainter.baseColorFor(nucleon)`：静态纯函数解析当前基色
  （`Color.lerp` 与原版 `Color.interpolateRGBA` 同为逐通道线性 [已确认等价]）
- 偏差说明：原版被 clearAnimations 停掉的核子 inputEnabled 不再恢复（已知缺陷），
  本实现冻结核子**恢复可拖**（不复制缺陷）[推测：属有意偏差]

### 测试（新增 8 项 `build_a_nucleus_beta_color_test.dart`）

β-/β+ 换型即变 + 0s/0.25s/0.5s 颜色插值精确值、zLayer 不变、换色中禁拖/完成恢复、
电子/正电子滞留 0.5s 后飞出、reset 清空、undo 冻结半途混合色（progress 不再推进）。

### 验证

- `flutter test test/chemistry/build_a_nucleus` → **115/115 通过**
- `flutter analyze`（BAN 范围）→ No issues found
- 标记扫描：0（notes.md 中 2 处为事故记录的有意引用）

### 工时

| 项 | 理论 | 实际 |
|---|---|---|
| 1F-2B-1 β 换色动画 | —（Animation 6h 之一部） | ≈0.5h（16:20–16:50 会话） |

### 下一阶段候选（1F-2B-2）→ 已完成，见下节

---

## Phase 1F-2B-2 · Be-6 α Hollywood 特例（2026-08-28 完成）

### 取证 12 问（源码：`DecayScreenView.emitAlphaParticle` override + `BANScreenView.emitAlphaParticle` + `doc/model.md` Hollywood）

| # | 问题 | 结论 | 标记 |
|---|---|---|---|
| 1 | 是否走普通 α 之外的特殊路径 | **是，但不是另一种衰变。** 先跑完整普通 α（`super.emitAlphaParticle()`），再在 override 里附加分支 | [已确认] |
| 2 | 触发条件 | α **之后**剩余恰好 `(protonCount==2 && neutronCount==0)`。表内唯 Be-6(4p,2n) 满足（α 取走 2p2n）。**不是** `if (Be-6)` | [已确认] |
| 3 | 哪些核子被移除 | 与普通 α 相同：离中心最近 2p+2n 组成 α；1s 行程后再 `emitNucleon(PROTON)×2` 取走剩余 2 质子 | [已确认] |
| 4 | α 创建位置 | `new AlphaParticle()` 后把取出的 4 核子 `addParticle` + `moveAllParticlesToDestination`；α 本体在核中心 | [已确认] |
| 5 | α 运动起点 | α 当前 `positionProperty`（核中心）→ 随机屏外点 | [已确认] |
| 6 | daughter nuclide | 点击瞬间：Be-6 → **2p0n（He-2，不存在）**；再过 300px 行程 → **0p0n 空核** | [已确认] |
| 7 | 2p0n → ? 的实际状态变化 | 两步：4p2n → 2p0n（点击）→ 0p0n（α 飞满 `TIME_TO_SHOW_DOES_NOT_EXIST × velocity`） | [已确认] |
| 8 | 是否立即改变状态 | **是**（与普通 α 相同，extract 同步改计数）。强制射出 2 质子**不**在点击时发生 | [已确认] |
| 9 | 是否重新排布 | 点击后质量数 6→2，走普通 `reconfigureNucleus`（2 质子并排）。强制射出后 2→0，空核无需排布 | [已确认] |
| 10 | animation end 后是否还有额外操作 | α **dispose** 时：`correctingNonexistentNuclide = true`。2 质子射出发生在飞行**途中**（距离判定），不是 finish 回调 | [已确认] |
| 11 | Reset / Undo | Reset：`correctingNonexistentNuclide=true` + 清空粒子。Undo（射出前）：恢复 (4,2) 并清 outgoing。射出后 massNumber 2→0 触发 `hideUndoButtonEmitter` | [已确认] |
| 12 | 与普通 α 的差异 | 见下表。普通路径完全复用；差异全部在 override 附加分支 | [已确认] |

### 与普通 α（例：Be-8 → He-4）对照

| 行为 | 普通 α（Be-8） | Be-6 特例 |
|---|---|---|
| 衰变类型 / 按钮 | `ALPHA_DECAY` | 同一个 |
| extract 2p2n、α 从核中心以 300px/s 飞出 | 是 | 是（先跑 `super`） |
| 点击后 daughter | He-4 (2p2n) 存在、稳定 | **2p0n 不存在**（"does not form"） |
| `correctingNonexistentNuclide` | 保持 true | **置 false**（挂起 1s 自动回退，否则会把 2p0n 拉回 Be-6） |
| 剩余核子可拖 | 是 | **剩余 2 质子 `inputEnabled=false`** |
| α 飞满 1s×300px/s | 无附加动作 | **`emitNucleon(PROTON)×2`**，从质子当时位置飞向各自随机屏外点 |
| α dispose | 移除 α | 额外把 `correctingNonexistentNuclide` 恢复 true |
| 终态 | He-4 留在核内 | **0p0n 空核** |
| Undo | 恢复 Be-8 | 射出前可恢复 Be-6；射出后按钮隐藏 |

实现上**明确保留该附加分支**（条件是剩余 (2,0)，不是硬编码核素名），不把强制射出折进普通 α。

### 实现

- 复用既有 `MovingParticle` / `EmittedParticle` / `stepMotion` / `DecayEvent`
- 触发：普通 α extract 之后 `protonCount==2 && neutronCount==0`
- 距离判定：`distanceTraveled >= TIME_TO_SHOW_DOES_NOT_EXIST * 300`（=300px）
- Controller 为 α 预计算 2 个 extraEscapes（普通 α 忽略）
- Painter 无新视觉：α 簇与质子球沿用 1F-2A

### 测试（新增 10 项 `build_a_nucleus_be6_alpha_test.dart`）

触发/即时 2p0n、α 起点与 destination、剩余质子锁定、300px 前不射出且不回退、300px 后 2 质子从核内位置飞出到 extraEscapes、α 到达关闭窗口、undo/reset、Be-8 对照。

### 验证

- `flutter test test/chemistry/build_a_nucleus` → **125/125 通过**（原 115 + 本阶段 10）
- `flutter analyze`（BAN 范围）→ No issues found
- 标记扫描：0（notes.md 中 2 处为事故记录的有意引用）

### 下一阶段（停止于此，不进入 1G）

- 半衰期数轴 / 符号面板 / 电子云 / Chart Intro / InquiryDrawer / HomeScreen 注册

---

## Phase 1G-1 · Reset / Undo 最终对齐（2026-08-28 完成）

### 取证：Reset 与 Undo 不是同一套逻辑

**Reset** [已确认] `BANModel.reset` + `BANScreenView.reset` + `DecayScreenView.reset`：

1. `particleAnimations.clear()`（先停动画，避免 endedEmitter 打到已销毁粒子）
2. `particleAtom.clear()` + `particles/incoming/outgoing/userControlled.clear()`（**销毁**粒子）
3. `previousProton/Neutron=0`、`timeSinceCountdown=0`、`correctingNonexistentNuclide=true`
4. `populateDefaultAtom(0,0)` 放最后

**Undo** [已确认] `BANScreenView.undoDecay` **只**：

- `restorePreviousNucleonNumber`（立即补/退）
- 移除 outgoing + `particleAnimations.clear()`
- `particleAtom.clearAnimations()`（换色**定格**，不销毁核子）

明确不做：不清 incoming / userControlled / returning；不重置 invalid 计时；不回到 0p0n。

**hideUndoButtonEmitter** [已确认] 监听 `massNumber` + incoming 长度 + userControlled 长度。飞入/核内拖出会藏按钮。衰变 listener 在这些 emit **之后**把按钮设回 visible，因此「拖着生成器粒子点衰变」后仍可 Undo，且 Undo 保留那枚拖拽粒子。

### 发现并修复的缺口

拖拽中 Reset 后松手：`endNucleonDrop` 会把已清空的核子重新入核/归位。原版粒子已 dispose、DragListener 拆除。[已确认] 修复：

- State：`endNucleonDrop` 若核子不在 dragged 列表则忽略
- Screen：Reset 同步 `_dragSessions.clear()`

### 有意偏差

- Undo 后一律 `lastDecay=null`（按钮隐藏）。原版 β Undo 质量数不变，multilink 可能不藏按钮。[推测：不复制该粗糙边缘]
- Reset 销毁换色核子（无冻结残留），对齐 `particleAtom.clear()`，与 Undo 冻结不同。[已确认]

### 测试（新增 `build_a_nucleus_reset_undo_test.dart`）

Reset：空核 / incoming+tick / 拖拽松手 / 多指 / returning / β outgoing / invalid 计时 / Be-6 射出前 / Be-6 射出后。
Undo：无衰变 / outgoing 飞行 / 飞入后失效 / 核内拖出后失效 / 拖生成器时衰变保留拖拽 / 改核子数失效 / Be-6 射出前恢复 / 射出后不可 Undo。
Widget：拖入途中点 Reset，松手不再入核。

### 验证

- `flutter test test/chemistry/build_a_nucleus` → **143/143 通过**（原 125 + 本阶段 18）
- `flutter analyze`（BAN 范围）→ No issues found
- 标记扫描：0（notes.md 中 2 处为事故记录的有意引用）

### 下一阶段

- 1G-2：核素信息 / 状态显示 UI（不含半衰期数轴）

---

## Phase 1G-2 · 核素信息 / 状态显示 UI（2026-08-28 完成）

本阶段只补 **Decay 屏与当前核素状态直接相关的可见 UI**。未进入半衰期数轴、电子云、Chart Intro。未改 State / Controller / 衰变 / 拖拽 / undo / reset 业务逻辑。

### 取证：原版 UI → 当前实现 → 本阶段落地

| 原版控件 | 源码 | 1G-1 末状态 | 1G-2 |
|---|---|---|---|
| 元素名 `ElementNameText` | `js/common/view/ElementNameText.ts` + `nameMassPattern` 等 | 占位读数（旧格式） | **落地** |
| 稳定性 `StabilityIndicatorText` | `js/decay/view/StabilityIndicatorText.ts` | 无 | **落地** |
| 质子/中子计数 `NucleonNumberPanel` | `js/common/view/NucleonNumberPanel.ts` | 合并一行占位 | **落地**（无 0.1s 淡入） |
| 符号 `SymbolNode` in AccordionBox | `DecayScreenView.ts` scale 0.3、无 charge | 无 | **落地**（无折叠） |
| 半衰期文字 `halfLifeDisplayNode` | `HalfLifeNumberLineNode.ts` | 无 | **文字落地**（无数轴） |
| 半衰期对数数轴 | `HalfLifeInformationNode.ts` | 无 | **不做**（1G-4） |
| 电子云 Checkbox | `ShowElectronCloudCheckbox` | 无 | **不做** |
| Available Decays / Undo / Reset | 已有 1C–1G-1 | 已有 | 只读，不改逻辑 |

### 新增 UI 与数据来源

全部只读 `BuildANucleusState` 已有派生量（`elementName` / `elementSymbol` / `protonCount` / `neutronCount` / `massNumber` / `nuclideExists` / `isStable` / `halfLifeNumber`），查表仍走 `NuclideRepository`。无第二份核素数据。

NineGrid 落位（遵守现有布局，不新建框架）：

- `topLeft`：计数 + 半衰期文字
- `topCenter`：元素名 + 稳定性
- `topRight`：Symbol 盒（A 左上、Z 左下质子色、符号居中）
- `midRight`：已有衰变面板（未改 enable 规则）

### 文案对照与诚实标记

| 项 | 落地 | 标记 |
|---|---|---|
| 存在且 Z>0：`"{{name}} - {{mass}}"`（如 `Hydrogen - 1`） | `NuclideStatusText.elementCaption` | [已确认] `nameMassPattern` |
| 不存在且 Z>0：`"Helium - 2 does not form"` | 同上 | [已确认] `elementDoesNotFormPattern` |
| 不存在且 Z=0：`"2 neutrons does not form"` | 同上 | [已确认] `zeroParticlesDoesNotFormPattern` |
| 0p1n 存在：`"1 neutron"` | 同上（doesNotForm 空串） | [已确认] |
| 0p N>1 且存在：`"Cluster of N neutrons"` | 同上 | [已确认] `clusterOfNeutronsPattern` |
| 0p0n：空串（不是「空核」） | 同上 | [已确认] ElementNameText |
| 元素名 fill 纯红 `#FF0000` | `ElementAndStabilityReadout` | [已确认] `Color.RED` |
| Stable / Unstable；`visible = nuclideExists` | `stabilityCaption` | [已确认] StabilityIndicatorText |
| 「Half-life:」标签始终可见 | `halfLifeCaption` | [已确认] 标签未随存在性隐藏 |
| 不存在/空核：只留标签，无数值 | 同上 | [已确认] `halfLifeNumber === 0` 分支 |
| 稳定：∞ 代替 InfinityNode | 同上 | [推测：无穷符节点未画] |
| 未知：`Unknown` | 同上 | [已确认] strings.unknown |
| 已知：科学计数 + `s` | `toStringAsExponential(2)` | [已确认 单位 s]；位数格式 [推测：非 ScientificNotationNode] |
| Symbol 标题、无电荷、A/Z | `NuclideSymbolReadout` | [已确认] DecayScreenView 未传 charge；Accordion 折叠 [待确认 / 本阶段不做] |
| 计数标签「质子/中子」 | 与 footer 生成器一致 | [推测：原版 `Protons:` / `Neutrons:`；中文本地化仍待确认] |
| 计数 0.1s 淡入替换 | 未做 | [已确认 原版有；本阶段有意省略] |
| 边格宽 ~57px，计数 FittedBox 缩小 | 适配 NineGrid | [视觉待确认] |
| 符号盒像素/折叠/字号 | 紧凑盒 | [视觉待确认] |

### Reset / Undo

UI 只订阅 Controller/`state`。incoming / dragging / outgoing / β 换色 / invalid / Be-6 的按钮可见性仍由 1G-1 已确认规则驱动，本阶段未改。

### 测试

新增 `test/chemistry/build_a_nucleus/nuclide_status_test.dart`：

- 纯函数：空核 / H-1 / H-3 / H-4 Unknown / 自由中子 / (0,2) invalid / Be-6 后 2p0n
- Widget：初始、稳定、不稳定、无效、Be-6 可见、计数变化、Reset、Undo、H-4 Unknown

### 验证

- `flutter analyze lib/chemistry/build_a_nucleus test/chemistry/build_a_nucleus` → No issues found
- `flutter test test/chemistry/build_a_nucleus` → **159/159 通过**（原 143 + 本阶段 16）
- 标记扫描：源码 0；notes.md 2 处为 1B 事故记录的有意引用

### 工时

| 项 | 理论 | 实际 |
|---|---|---|
| 核素信息 / 符号 / 读数（从 §21 Widget/UI 12h 中拆出，不含数轴） | ≈3h | ≈1.5h（2026-08-28 单次会话） |

### 下一阶段（未开始）

- 1G-3A：半衰期数轴数据与映射（不含绘制）

---

## Phase 1G-3A · Half-Life Number Line 数据与映射（2026-08-28 完成）

只做数据 / 特殊值 / 数值映射。无 Painter、无 tick UI、无电子云。未改 State / Controller。

### 原版证据

| 项 | 值 / 行为 | 标记 |
|---|---|---|
| 轴范围 | 指数 -24 … +24（秒） | [已确认] `HALF_LIFE_NUMBER_LINE_START/END_EXPONENT` |
| 是否 log | 是，**log10**（`Utils.log10`） | [已确认] `logScaleNumberToLinearScaleNumber` |
| 模型坐标 | `ChartTransform.modelXRange = [-24, 24]` | [已确认] |
| tick | `tickXSpacing = 3` → -24,-21,…,24 | [已确认 spacing]；bamboo 是否从 min 起画两端 [推测：±24 可被 3 整除] |
| 0 处标签 | `"1"`，其余 `10^n` 上标 | [已确认] `createExponentialLabel`；上标绘制属 1G-3B |
| 单位 | `"seconds"` | [已确认] strings.seconds |
| 映射公式 | `halfLife===0 → 0`；否则 `log10(seconds)` | [已确认] |
| 右端 clamp | `> 10^24` 时指针钉在 10^24，**读数仍用真值** | [已确认] |
| 左端 clamp | **无** | [已确认 源码无此分支] |
| Stable | `isStable` 优先；读数 InfinityNode；指针 +24 向右 | [已确认] |
| Unknown | `halfLifeNumber === -1`；文案 Unknown；指针 `moveHalfLifePointerSet(0)` 且隐藏 | [已确认] |
| Nonexistent | `halfLifeNumber === 0`；无数；指针同样到指数 0 且隐藏 | [已确认] |
| 更新 | DerivedProperty + `.link` 立即重算；指针 0.7s 动画属视觉层 | [已确认 数据即时；动画 1G-3B] |

哨兵 vs 物理值：

- `stableHalfLifeDisplay = 1e24`：**DecayModel 写入数轴的显示哨兵**，不是表内半衰期 [已确认]
- `unknownHalfLife = -1`：表内有条目但 null [已确认]
- `nonexistentHalfLife = 0`：不存在 / `getNuclideHalfLife === null` 的 graceful 回退 [已确认]

### 数据模型

`HalfLifeNumberLine` / `HalfLifeNumberLineReading`（`model/half_life_number_line.dart`）

输入：`State.halfLifeNumber` + `State.isStable`（原版 NumberLine 同时听这两个 Property；**不重算、不复制核素表**）。

输出：`readoutKind`、真值秒数、`pointerExponent`、箭头可见/向右、`normalizedPosition = (exp+24)/48`。

Dart 注意：`math.pow(10, 24)` 走整数幂会溢出 int64；必须 `pow(10.0, 24)` 才对齐 JS `Math.pow`。[已确认]

log10 与 JS 逐 bit 是否相同：[待确认] 测试用 `closeTo(1e-12)`。

### 测试

新增 `half_life_number_line_test.dart`：正常 H-3、极短 Be-6、较长 C-14/Pu-240、Stable、Unknown、Nonexistent、左右边界、单调性、核素切换。

### 验证

- analyze：No issues found
- `flutter test test/chemistry/build_a_nucleus` → **175/175**（159 + 16）
- 源码 marker：0

### 工时

| 项 | 理论 | 实际 |
|---|---|---|
| 数轴数据/映射（从 Widget/UI 12h 拆出，不含绘制） | ≈2h | ≈0.7h |

### 剩余视觉工作（1G-3B，未开始）

tick 线与上标、箭头旋转/0.7s 动画、Half-life 读数条定位、less/more stable、info dialog、像素级 ChartTransform。

### 下一阶段

- 1G-3B-1：数轴基础视觉（轴 / 刻度 / 上标 / 静态指针）

---

## Phase 1G-3B-1 · 数轴基础视觉（2026-08-28 完成）

只做：轴 + 刻度 + 上标 + 静态指针。未接 Screen。无 0.7s 动画、less/more stable、info、读数条。

### 原版视觉 / 坐标依据

| 项 | 值 | 标记 |
|---|---|---|
| model→view X | `linear(-24, 24, 0, viewWidth, exp)` identity transform | [已确认] ChartTransform.modelToView |
| 原版 viewWidth | 550 | [已确认] HalfLifeInformationNode；Flutter 用容器宽 |
| tick 间距 / 数量 | 3 → 17 个（origin 0, clipping strict） | [已确认] TickMarkSet |
| tick 高 | extent 18，关于轴线对称 | [已确认] |
| tick 线宽 | 2 | [已确认] |
| 0 标签 | `"1"`；其余 `10` + 上标（supScale 0.6） | [已确认] createExponentialLabel |
| 指针向下 | 尾在轴上 L=30，尖在轴上 | [已确认] ArrowNode(0,0,0,L) |
| 指针向右（stable） | 旋转 -π/2 后水平，在轴上方 | [已确认 旋转；箭头轮廓 [视觉待确认] |
| 指针色 | magenta #FF00FF | [已确认] halfLifeColorProperty |
| 轴线 y 在画布中下移 L | 为在正坐标里画出向下箭头 | [推测：相对几何平移] |
| ArrowNode headHeight | BAN 未覆盖 | [待确认] 用 10 |
| 不使用 CanvasProjection | 数轴不是核世界坐标 | [已确认] |

Painter **只读** `HalfLifeNumberLineReading`，不判断 -1 / 0 / isStable。

### 测试

`half_life_number_line_view_test.dart`：公式精确点 -24/-21/-3/0/3/21/24；17 tick；Stable / Unknown / Nonexistent 指针；1s 在中点。像素断言相对容器宽，不用伪造 550 上的经验坐标。

### 验证

- analyze：No issues found
- **183/183**（175 + 8）
- 源码 marker：0

### 工时

| 项 | 理论 | 实际 |
|---|---|---|
| 轴/刻度/静态指针（不含动画与读数条） | ≈2h | ≈0.6h |

### 下一阶段（未开始）

- 1G-3B-2：指针动画（不含读数条 / Screen）

---

## Phase 1G-3B-2 · Half-Life Pointer Animation（2026-08-28 完成）

只做 pointer 运动。未接 Screen，无 readout / less-more-stable / info。

### 原版动画（均 [已确认]）

| 项 | 证据 |
|---|---|
| 时长 X | `arrowXPositionAnimationDuration = 0.7` |
| 时长旋转 | `0.1` |
| easing | `Easing.QUADRATIC_IN_OUT` = `polynomialEaseInOut(2)`：t≤0.5 → `2t²`，否则 `1-2(1-t)²`。**不是线性** |
| 动画对象 | **model X**：`arrowXPositionProperty`（log10 指数）。viewX = ChartTransform.modelToViewX(x) |
| from | 未传 `from` → `getValue()` = **当前** property |
| 连续变更 | `stop()` 旧动画（不触发 finish/then）+ 从当前值新建。不是 queue / jump-to-end |
| Unknown / Nonexistent | visible 立即 false；仍 `moveHalfLifePointerSet(0)`，X 动画到指数 0 |
| Stable / 钉右 | `halfLife === 10^24`：**先 X 0.7s，再转 -π/2**；否则 **先转回 0，再 X 0.7s** |
| hidden | 动画仍跑（property 在动），箭头 `visible=false` |
| Reset | 无数轴专用 reset；halfLife 变 0 走同一套 stop+restart |
| 终点 | tween `to` = Reading.pointerExponent / 目标旋转 |

### 分层

`Reading.setTarget` → `HalfLifePointerAnimator`（render-only）→ Painter 的 `displayExponent` / `displayRotation`。不查表。

### 新增 / 修改

- 新增 `model/half_life_pointer_animator.dart`
- 新增 `test/.../half_life_pointer_animator_test.dart`
- 修改 Painter（插值旋转）、View（Stateful + Ticker）、1G-3B-1 Stable 测试改为 settle 0.8s

### 验证

- analyze：No issues found
- **193/193**（183 + 10）

### 工时

| 项 | 理论 | 实际 |
|---|---|---|
| 指针动画 | ≈1.5h | ≈0.5h |

### 下一阶段（未开始）

- 1G-3B-3：读数条（不含 less/more stable / info / Screen）

---

## Phase 1G-3B-3 · Half-Life Readout（2026-08-28 完成）

只做数轴上方的 half-life 数值显示。未接 Screen，无 less/more stable、info、电子云、Chart Intro。

### 原版证据（`HalfLifeNumberLineNode.ts` + `ScientificNotationNode.ts`）

| 项 | 结论 | 标记 |
|---|---|---|
| 标签 | `halfLifeColon` = `"Half-life:"`，始终在 tree 且可见 | [已确认] |
| 单位 | 读数用 `"s"`；轴下方单位仍是 `"seconds"`（本阶段不改轴） | [已确认] |
| Stable | `infinityNode.visible = true`；InfinityNode 是 **Path** 不是字符 | [已确认]；本阶段用 `∞` 占位 [推测 visual] |
| Unknown | `halfLifeUnknownText` = `"Unknown"` | [已确认] |
| Nonexistent / 空核 | `halfLifeNumber === 0`：Unknown 与科学计数均隐藏，只留标签 | [已确认] |
| 正常值 | `ScientificNotationNode` + `"s"`；`mantissaDecimalPlaces: 1` | [已确认] |
| 科学计数 | `value.toExponential(1)` → `M x 10^E`；指数 0 只显示 M（`showZeroExponent: false`） | [已确认] |
| 超右端 | 指针钉 10^24，**读数仍用真值** | [已确认] |
| 切换动画 | readout **无动画**；`halfLifeNumberProperty.link` 立即改 visible / 数值 | [已确认] |
| 与 pointer | 读数绑 `halfLifeNumberProperty`，不绑 `arrowXPositionProperty` | [已确认] |
| 层级 | `VBox halfLifeDisplayNode` → `HBox sentenceHBox`：Colon 始终 + 三选一（Unknown / Infinity / 科学计数+s） | [已确认] |
| 始终显示 | 标签始终显示；数值区按 kind 互斥 | [已确认] |

### 格式规则

- 尾数 1 位小数（不是 1G-2 的 `toStringAsExponential(2)`）
- `timesTen` 文案为 `'x 10'`（字母 x）
- 指数去 `+` 号；上标 `exponentScale: 0.75`

### 分层

`Reading` → `HalfLifeReadoutContent.fromReading` → Widget。不查表、不重判哨兵。

NineGrid 边格 `HalfLifeReadout` 改走同一 formatter（仍是占位单行，非数轴上的 HBox）。

### 新增 / 修改

- 新增 `model/half_life_readout.dart`
- 新增 `widgets/half_life_number_line_readout.dart`
- 新增 `test/.../half_life_readout_test.dart`
- 修改 `HalfLifeNumberLineView`（Column：读数条 + 轴）
- 修改 `nuclide_status.dart` 的 `halfLifeCaption` 复用 formatter

未接 Screen。未做 less/more stable / info。

### 验证

- analyze：No issues found
- **210/210**（193 + 17）

### 工时

| 项 | 理论 | 实际 |
|---|---|---|
| 读数条 | ≈1.5h | ≈0.6h |

### 下一阶段（未开始）

- 1G-3B-4：less / more stable、info dialog（不含电子云 / Screen）

---

## Phase 1G-3B-4 · Half-Life 辅助信息 UI（2026-08-28 完成）

less/more stable + info 按钮 + Half-Life Timescale dialog。未接 Screen，无电子云、Chart Intro。

### 原版依据

| 项 | 结论 | 标记 |
|---|---|---|
| less/more 文案 | `"less stable"` / `"more stable"` | [已确认] strings |
| 是否随半衰期变化 | **否**。无 Property 绑定，构造时加入后一直在 | [已确认] |
| 位置 | 数轴底部 `preferredWidth = numberLine.width` 的 HBox，左箭头+文案 / 文案+右箭头 | [已确认] |
| info 按钮 | 始终存在，无三态 visible | [已确认] |
| 位置 | `left = numberLine.left + 124`，`centerY = halfLifeDisplayNode.centerY` | [已确认] |
| 缩进 | 读数 `left = 124 + 30 + 10` | [已确认] |
| 点击 | `halfLifeInfoDialog.show()`；Dialog 构造一次，重复 show | [已确认] |
| 关闭 | 右上 CloseButton；点 barrier 也 hide（Joist modal stack） | [已确认] |
| 标题 | `"Half-Life Timescale"` | [已确认] |
| 内容 | 左 A–E / 右 F–J 图例 + 第二条数轴 + A–J 标记 | [已确认] |
| 背景 | rgb(255,254,244)；按钮底 rgb(255,153,255)；iconFill black | [已确认] |
| Reset | **不关** dialog；内容随 halfLifeNumber 更新 | [已确认] |
| 三态 | less/more / info 行为相同；读数/指针仍走 Reading | [已确认] |

### less/more 规则

纯视觉常量。不读 Reading，不计算半衰期。左 = 更不稳定方向，右 = 更稳定方向。

### 新增 / 修改

- 新增 `model/ban_timescale_points.dart`
- 新增 `widgets/half_life_stability_legend.dart`
- 新增 `widgets/half_life_info_dialog.dart`
- 新增 `widgets/half_life_information_view.dart`
- 新增 `test/.../half_life_information_view_test.dart`
- 修改 `ban_constants.dart`、`HalfLifeNumberLineView.readoutLeftInset`

未接 Screen。Dialog 内元素名不跟指针平移 [推测：原版 `isHalfLifeLabelFixed: false`]；A–J 现为字母标记，未画蓝色短箭头 [推测 visual]。

### 验证

- analyze：No issues found
- **218/218**（210 + 8）

### 工时

| 项 | 理论 | 实际 |
|---|---|---|
| 辅助信息 UI | ≈2.5h | ≈0.8h |

### 下一阶段（未开始）

- 1G-3B-5：Half-Life UI 接入 Decay Screen

---

## Phase 1G-3B-5 · Half-Life UI Integration（2026-08-28 完成）

把已完成的 `HalfLifeInformationView` 挂到 Decay Screen。无新半衰期功能，无电子云。

### 布局证据 vs NineGrid

原版 `DecayScreenView`：`halfLifeInformationNode.left = minX + 15 + 30`，`y = minY + 15 + 80`，数轴宽 550，在**屏顶**。[已确认]

KARTOSLAB NineGrid 顶行高度约 48–80px，数轴+legend 约 124px，**放不进 topCenter/topLeft**。[已确认 几何冲突]

本阶段把信息区放在**中间格顶部、核画布之上**（中间格是唯一够宽够高的格子）。不改 NineGrid 组件。[推测 映射；像素级与原版绝对坐标不对齐]

边格 1G-2 的 `HalfLifeReadout` 占位已撤，避免两套 “Half-life:”。计数仍在 topLeft。

### 数据流

`State` → `HalfLifeNumberLine.fromState` → `Reading` → `HalfLifeInformationView`。Screen 不查 Repository。元素名用已有 `NuclideStatusText.elementCaption`。

### 生命周期

沿用 InformationView：Reset 不关 dialog；Screen dispose / 页面退出 pop overlay。

### 新增 / 修改

- 修改 `screens/build_a_nucleus_screen.dart`
- 新增 `test/.../build_a_nucleus_half_life_screen_test.dart`
- 修改 `nuclide_status_test.dart`（结构化读数断言）

未改 Painter / State / Repository / decay / common。

### 验证

- analyze：No issues found
- **226/226**（218 + 8）

### 工时

| 项 | 理论 | 实际 |
|---|---|---|
| Screen 接入 | ≈1h | ≈0.4h |

### 下一阶段（已开始 → 1G-3B-6）

- 电子云（本文件下节）
- Chart Intro（仍未开始）

---

## Phase 1G-3B-6 · 电子云取证与实现（2026-08-28 完成）

本阶段只处理 Decay Screen 电子云/电子层视觉。未做 Chart Intro、未做整体视觉对齐、未改 Half-Life 布局、未改 decay/drag、未建电子物理模型。

### 层判断：[已确认] 只是视觉

Decay 屏 **不是** Bohr 电子层，也不是 shred `ElectronCloudView` / `ElectronShellView`（那两套属于 Build an Atom：离散电子粒子 + 虚线壳层环）。

BAN 用 shred `ParticleAtomNode` 的 **单个径向渐变 Circle**。

数据流：

`State.protonCount` + `State.electronCloudAtomicRadius`（只读查表）
→ `ElectronCloudReading.fromState`
→ `NucleusPainter` / `ShowElectronCloudCheckbox`

Checkbox 是视图层 `BooleanProperty`，不进 State。

### 13 问（均有源码依据）

| # | 结论 | 标记 / 出处 |
|---|---|---|
| 1 电子数量来源 | `protonCountProperty`；查 `AtomInfoUtils.getAtomicRadius(n)` = `mapElectronCountToRadius[n]` | [已确认] |
| 2 是否 = proton | **是**（中性假设）。`doc/model.md` + `updateCloudSize` 注释 | [已确认] |
| 3 离子 | **无离子模型**。Decay `SymbolNode` 未传 charge。β 电子/正电子是衰变动画粒子，不是云 | [已确认] |
| 4 电子层数量 | **无离散层**。只有一个 Circle | [已确认] `ParticleAtomNode` |
| 5 每层容量 | 不适用（不是 2/8/18） | [已确认] |
| 6 位置算法 | 圆心 = `atomCenter`；半径见下 | [已确认] |
| 7 固定圆轨道 | 单个填充圆，不是轨道上的点 | [已确认] |
| 8 动画 | 云本身无动画。Checkbox 只切 `visible` | [已确认] |
| 9 随机 | 无 | [已确认] |
| 10 元素切换 | `protonCount` 变 → 立即 `updateCloudSize` | [已确认] `BANScreenView` link |
| 11 Reset | proton=0 → 半径 1E-5、fill transparent；Checkbox `reset()` 恢复 true | [已确认] `DecayScreenView.reset` |
| 12 与 nucleus | 纯视觉；不改 ParticleAtom。z：emptyAtomCircle → electronCloud → nucleonLayers | [已确认] |
| 13 可交互 | 云不可点。只有 Checkbox | [已确认] |

### 半径公式 [已确认]

```
BANScreenView: updateCloudSize(protonNumber, 0.27, 10, 20)
protonNumberRange = Range(CHART_MIN=0, DECAY_MAX=94)

protonNumber === 0:
  radius = 1E-5; fill = transparent

else:
  atomicRadius = mapElectronCountToRadius[protonNumber]
  compressedDiameter = LinearFunction(1, 94, 10, 20).evaluate(atomicRadius)
    // LinearFunction 默认不 clamp
  radius = (atomCenter.x - compressedDiameter/2) * 0.27
  fill = ELECTRON_CLOUD_FILL_GRADIENT(radius)
```

`atomCenter.x` 原版 = `LAYOUT_BOUNDS.width/3`（`DEFAULT_LAYOUT_BOUNDS` 宽 1024）。
Flutter [推测] 映射为 `CanvasProjection.origin.dx`。像素级与原版屏坐标 **未对齐**。

### 视觉参数

| 项 | 落地 | 标记 |
|---|---|---|
| 电子色 | `#0000FF`（scenery `Color.BLUE`） | [已确认] PARTICLE_COLORS.electron |
| 渐变 | 径向 中心→r，stop 0 alpha 1、stop 0.9 alpha 0 | [已确认] ELECTRON_CLOUD_FILL_GRADIENT |
| 无离散电子大小 | 不适用 | [已确认] |
| 空核虚线圆 | radius = nucleonRadius-1、GRAY、dash [2,2]、仅 massNumber==0 | [已确认] emptyAtomCircle |
| Checkbox 文案 | `Electron Cloud` | [已确认] strings |
| Checkbox 默认 true | 是 | [已确认] |
| 图标半径 = 文字高×0.82 | 现用 16px 图标 | [视觉待确认] |
| REGULAR_FONT 20 | 现用 14px 以适配画布叠放 | [视觉待确认] |
| Checkbox 落位 | 原版 left=衰变面板、bottom=Reset；NineGrid 边格 ~65px 放不下 → 叠在画布右下 | [推测 NineGrid] |
| 淡入淡出 | 无（原版亦无） | [已确认] |

### State 缺口与处理

State 原先没有电子云半径字段。本阶段只加只读 getter `electronCloudAtomicRadius` → `repository.electronCloudRadius(protonCount)`，与 `elementName` 同类派生，**不改业务状态**。Painter 不持有 Repository。

### 新增 / 修改

- 新增 `model/electron_cloud.dart`（`ElectronCloudReading`）
- 新增 `widgets/show_electron_cloud_checkbox.dart`
- 新增 `test/.../electron_cloud_test.dart`
- 修改 `ban_constants.dart`、`build_a_nucleus_state.dart`、`nucleus_painter.dart`、`build_a_nucleus_screen.dart`

未改 decay / drag / Half-Life 布局 / common / Chart Intro。

### 验证

- `flutter analyze`（BAN lib+test）→ No issues found
- `flutter test test/chemistry/build_a_nucleus` → **241/241**（226 + 15）

### 下一阶段（已开始 → FINAL-1）

- 最终视觉对齐（本文件下节）
- Chart Intro（仍未开始）

---

## FINAL-1 · Decay Screen 最终对照（2026-08-28 完成）

未改 Model / State / Controller / Repository / decay / drag / Undo / Reset 业务逻辑。

### UI 最小修正（能准确复刻的控件结构）

- 生成器改为原版 HBox 顺序：`[↑↓p][p][双箭][n][↑↓n]`，露出已有 `addPair`/`removePair`
- 衰变面板标题 `Available Decays`；启用色 `#FBB240`
- footer `FittedBox` 防窄横屏溢出

其余 NineGrid / Material 皮肤 / 中文标签 / ∞ 字符等保持 **[有意差异]**，见 `BUILD_A_NUCLEUS_FINAL_REPORT.md`。

### 验证

- analyze：No issues found
- **244/244**（241 + 视口/生命周期/双箭头 3）
- 未跑全仓 `flutter test`（forces 既有挂起）

### 工时

| 项 | 理论 | 实际 |
|---|---|---|
| Integration / 最终对照（§21 Integration 4h） | ≈4h | ≈1.2h |

Chart Intro 未开始。

---

## Phase 2I-1 · Chart Intro 最终视觉与布局对齐（2026-08-31）

不新增功能。未改 State / Controller / Repository / Decay / Home 业务 / NineGrid / common。

### 精确修正（源码参数）

- 方程符号：150/100 × 0.15；V 距 15×0.15；H 距 20×0.15；行距 10；加号 9×2；箭头 DECAY_ARROW_OPTIONS
- 计数面板：Panel 铬、字号 18、球 r=7、行距按 `MIN_VERTICAL_SPACING`
- 元素名：20 / `#FF0000`
- 手风琴：白底、标题 Partial Nuclide Chart、图例接入（14 / 80 / 5）
- Dialog：top 40 / bottom 60；矮屏减 inset，内容可滚
- footer FittedBox，避免 640×360 溢出

### 有意差异（记录于 `CHART_INTRO_ANALYSIS.md` §21）

NineGrid 映射、无 Energy/虚线/壳层标题、无 Magic、Radio 文字、中文计数、Tab 关 Dialog。

### 验证目标

- `flutter analyze`（BAN lib+test）：No issues found
- `flutter test test/chemistry/build_a_nucleus`：**404/404**（400 + 视口 / Dialog dispose / Tab 4）
- 四视口 Partial+Zoom 无 overflow；Dialog 可关；卸树关 Dialog 且不改 `selectedChart`

下一阶段只做 **Phase 2I-2：最终回归与完成报告**。

---

## Phase 2I-2 · 最终回归与完成报告（2026-08-31）

不新增功能。未改 State / Controller / Decay / Home / NineGrid / common。

### 回归

- BAN **405/405**（404 + Chart Intro 进/出 ×5）
- `flutter analyze`：No issues found
- Android debug APK：**成功**
- Android release：**失败**（`integration_test` 进 GeneratedPluginRegistrant）→ [已有工程问题]，未改工程配置
- 排除 `forces_scenario_test`：664 passed + 1 skipped
- `forces_scenario_test`：仍挂起（90s 后终止），未改 Forces

### Marker

- `lib/` / `test/`：`<|sep|>` 等协议标记 **0**
- `requirements/`：仅 `notes.md` 1B 事故记录 1 处（有意）

### 产物

`requirements/req-build-a-nucleus/BUILD_A_NUCLEUS_COMPLETION_REPORT.md`

### 工时

| 项 | 理论 | 实际 |
|---|---|---|
| 2I-2 回归 + 报告 | 含在 Chart Intro「生命周期 / 回归 / 测试」3+8h 内 | ≈1.5h |

**停止 Build a Nucleus 一期开发。**








