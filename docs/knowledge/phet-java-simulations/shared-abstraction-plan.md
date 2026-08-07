# Flutter phet 项目 · 通用抽象层规划

> **产出触发**：主对话 2026-07-24 用户拍板 D 方案（Q1=A · Q2=B · Q3=B）
> **核心原则**：通用的抽到 `lib/common/`；特有的不硬塞公共；有 ≥ 2 使用者证据才抽象（§00 §4 最小化 + §10 §5 3-Time Rule）
> **数据源**：2026-07-24 实测 `c:\workspace\phet\lib\` 3 已复刻模块（optics/circuit/forces）
> **本文档消费者**：4 个新复刻模块（color-vision / sound / radio-waves / wave-interference）+ 2 个债务修复需求
> **PhET Java 蓝本路径**（2026-07-24 实测确认）：`PHET_JAVA_ROOT = c:\workspace\phetTrunk\phetTrunk\`（嵌套两层）· 详见 `java-blueprint-scan-log.md`

---

## 一、现状盘点（L0 · 已存在的通用层）

**位置**：`c:\workspace\phet\lib\common\`（实测 · 2026-07-24）

| 子目录 | 组件 | 尺寸 | 现有使用者 |
|---|---|---|---|
| `common/chart/` | `chart_painter.dart` `chart_series.dart` `graph_suite.dart` `phet_chart.dart` | 4 文件 | 主要 forces（图表） |
| `common/controls/` | `phet_slider.dart` `phet_combo_box.dart` `phet_radio_group.dart` `phet_number_field.dart` `arrow_painter.dart` `game_timer.dart` `spectrum_slider.dart` | 7 文件 | optics + circuit + forces + color-vision 四家共用 |
| `common/widgets/` | `property_control_panel.dart` `time_control_bar.dart` `phet_tab_bar.dart` `game_scoreboard.dart` `game_over_dialog.dart` | 5 文件 | 三家共用 |
| `common/` 顶层 | `simulation_clock.dart` | 1 文件 | 全局仿真时钟 |

**硬性约束**：4 新模块开工时**必须优先复用 L0**，禁止各自造 slider / combo / radio / number_field / property_panel / time_control_bar。若发现需求超出 L0 能力，先走"新增新组件到 common"审批，不允许在模块本地造平行组件。

---

## 二、待抽象候选（L1 · 3-Time Rule 门禁）

**规则**：以下候选**不预抽**，等各需求 spec/design 阶段自然触发；一旦累计 ≥ 3 使用者证据（含本文列举的候选使用者），由 tech-leader 决策提取到 `lib/common/`。

### 候选 1 · PositionElementBase 位置元件基类

**证据**：
- 现有 1 用户：`lib/optics/models/optical_element.dart` 的 `OpticalElement` 抽象基类（含 id/type/x/y/rotation/width/height/copyWith/hitTest）
- 4 新模块候选使用者：
  - `color-vision`：光源 / 滤色片 / 屏
  - `wave-interference`：波源 / 挡板 / 缝 / 屏
  - `radio-waves`：发射天线 / 接收天线
  - `sound`：波源 / 探测器

**抽哪些**：
- ✅ **抽**：`id / type / x / y / rotation / width / height` 6 字段 + `copyWith` + `hitTest` 命中检测
- ❌ **不抽**：`interact(rays)` `intersect(ray)`（光学特化 · 波动/电磁场不适用）
- 🟡 待评估：`paint(Canvas, Paint, World)` —— 每模块的 world 类型不同，可能用泛型 `PositionElement<TWorld>` 或干脆让子类各自定义

**建议路径**：`lib/common/elements/position_element.dart`
**触发时机**：第 3 个新模块（如 wave-interference）开工 spec 阶段，若确认需要相同 6 字段 + copyWith → 立即提取（届时已有 optics + 3 新模块 = 4 用户）

### 候选 2 · ScenarioManagerBase 场景管理器基类

**证据**（已 3 用户 · **强触发**）：
- 现有 3 用户：
  - `lib/optics/config/scenario_manager.dart`（204 行）
  - `lib/circuit/config/scenario_manager.dart`（161 行 · 注释里明说"对应光学 ScenarioManager"）
  - `lib/forces/config/scenario_manager.dart`（38 行 · 最简版）
- 4 新模块候选使用者：4 个模块**必然**都需要（Q2=A+C 配置化能力是四原则之一）

**已识别的共性**（3 家都有）：
```dart
abstract class ScenarioManagerBase<TScenario> {
  final List<TScenario> _scenarios = [];
  List<TScenario> get scenarios => List.unmodifiable(_scenarios);
  Future<void> loadScenarios();  // 读 manifest + 单场景失败降级
  TScenario? findById(String id);
}
```

**已识别的分歧**（不能强行统一）：
- `loadScenario(id)` 返回类型：optics 返回 `OpticsWorld` / circuit 返回 `CircuitState` / forces 返回 `ForcesScenario` 本身
  - **方案**：泛型 `<TScenario, TState>` + 抽象 `TState buildInitialState(TScenario)` 由子类实现
- `validateConstraints` / `checkObjectives`：optics + circuit 有 · forces 无
  - **方案**：作为**可选模板方法**，子类不 override 就返回空列表 / true

**建议路径**：`lib/common/scenario/scenario_manager_base.dart`
**触发时机**：**已符合 3-Time Rule 强触发** → 单独立需求 `req-refactor-scenario-manager-common` 立刻做（Q3=B 已拍板）

### 候选 3 · WaveFieldRenderer 波场渲染器

**证据**：0 现有用户；候选 3 用户：sound / wave-interference / radio-waves 都需要"波形传播动画"表征

**结论**：**不预抽**。第 1 个做的模块（推荐 sound）自己在 `lib/sound/widgets/` 造；第 2 个做时观察是否 ≥ 70% 相似 · 相似则改造第 1 个为公共版 · 否则各造。

**建议路径**（若触发）：`lib/common/waves/wave_field_renderer.dart`

### 候选 4 · DragDropWorkspace 拖放工作台 ✅ 已上抽

**已完成 · 详见 `requirements/req-refactor-optics-layout` phase 3**：
- 现有位置：`lib/common/widgets/drag_drop_workspace.dart`（6.5KB · 通用泛型拖放画布）
- 现有用户：optics（`lib/optics/screens/optics_screen.dart`）· circuit（`lib/circuit/screens/circuit_screen.dart`）
- 触发时机：req-refactor-optics-layout P1 债务清理时发现 circuit 已在使用它 · 相似度 100%（同名同接口）· 直接触发 3-Time Rule 第 2 用户上抽 · 顺手做完

**候选新用户**（第 3-4 用户 · 无需再走 3-Time Rule · 已在 common）：
- color-vision（拖 RGB 灯到位 · 如接入挑战模式）
- wave-interference（拖波源/缝到位 · 如接入挑战模式）

### 候选 5 · CelebrationDialog 通用喜庆达成弹框

**证据**：
- 现有 1 用户：`lib/common/widgets/celebration_dialog.dart`（`color_vision` 挑战模式 · 100% 精确匹配时弹窗庆祝）
- 候选新用户：
  - `sound`：让驻波节点对齐挑战模式（如果加）
  - `radio-waves`：接收信号强度达标挑战模式（如果加）
  - `wave-interference`：形成完美干涉条纹挑战模式（如果加）
  - 任何 sim 的"闯关/成就达成"正反馈场景

**已抽公共部分**：
- 五彩纸屑动画（60 片，8 色调色板，方形/圆形随机）
- 大 emoji + 大喜字（accentColor 主题化）
- 可选 showcaseColor 圆盘（展示达成的目标值/颜色）
- 双按钮（primary / secondary · 主题化）
- 弹跳缩放入场动画（Curves.elasticOut）

**为什么不与 GameOverDialog 合并**：
- GameOverDialog 侧重"结算展示"（星级+得分+分数），偏 UI 密度
- CelebrationDialog 侧重"庆祝瞬间"（动画+大字），偏 UI 冲击力
- 两者目标不同 · 强合并会互相牺牲

**建议路径**（已就位）：`lib/common/widgets/celebration_dialog.dart`
**触发时机**：第 2 用户出现时评估 API 稳定性 · 第 3 用户强制固化 API 并写单测

### 候选 6 · ScenarioMenuButton 场景切换菜单按钮（✅ 已完工上抽 · 2026-07-28）

**证据**（3 用户齐全 · G3 强触发已履行）：
- 用户 1（第 1/3）：`lib/sound/screens/sound_screen.dart`
- 用户 2（第 2/3）：`lib/radio_waves/screens/radio_waves_screen.dart`
- 用户 3（第 3/3 · 强制上抽）：`lib/wave_interference/screens/wave_interference_screen.dart`

**共性抽象内容**：
- 两态渲染：`loading || entries.isEmpty` → 16x16 白色 spinner（AppBar 加载态）；否则 → `PopupMenuButton<String>` + radio icon 前缀 + 选中态高亮
- 固定视觉：`Icons.tune_rounded, size:20` · 菜单项 fontSize 13 · icon size 16
- tooltip 默认 `'Choose scenario'`（可覆盖）

**已识别的分歧（参数化解耦）**：
- 类型差异：每 sim 的 `<Sim>Scenario` 类型不同 → 抽出 `ScenarioMenuEntry(id, name)` 值对象，调用方 `.map(...).toList()` 后传入
- 主题色差异：sound 青 `0xFF0D9488` / radio-waves 紫 `0xFF7C3AED` / wave-interference 蓝 `0xFF2563EB` → 参数 `accentColor` 由调用方传入
- 回调差异：`_applyScenario` 主体各 sim 各写各的（waveType 是否受影响、多少字段需要同步等）→ 参数 `onSelected: ValueChanged<String>` 由调用方传入

**建议路径**（已就位）：`lib/common/widgets/scenario_menu_button.dart`（2.6 KB · 含 `ScenarioMenuEntry` 值对象 + `ScenarioMenuButton` StatelessWidget）

**改造收益**（实测）：
- 每 sim 削减 ~25 行样板代码（3 sim × 25 = ~75 行清理）
- 未来新 sim（bending-light / photoelectric 等）只需 3 行接线即可获得菜单能力
- 一致 UX：所有 sim 的场景切换视觉与交互严格一致，无需重复测试

**验证结果**（2026-07-28）：
- `flutter analyze lib\common\widgets\scenario_menu_button.dart lib\sound lib\radio_waves lib\wave_interference` → No issues found
- 单测回归：sound 22 + radio-waves 21 + wave-interference 18 = **61/61 通过**

### 候选 7 · NineGridLayout 九宫格屏幕适配布局（✅ 已落地 · 2026-08-06 · **强制通用方案**）

**状态**：**非候选 · 已升级为所有 sim 强制屏幕适配方案**（2026-08-06 用户明确："公共通用方案 · 所有 sim 都要支持 · 强制要遵守"）。第 1 版等分实现被用户否决 → 改为非等分。

**尺寸规则**（非等分 · 强制约束 · 2026-08-07 用户确认"面积 ≥ 70%"）：
- 中间格（第 5 格）**面积 ≥ 70% 屏幕**：默认 `centerAreaRatio = 0.7` · 宽、高各取 `sqrt(面积比)`（≈ 0.837 屏 · 边条各 ≈ 8%）· `kMinCenterAreaRatio = 0.7` 强制下限 clamp · 传值 < 0.7 自动抬升 · 承载实验主画面
- 其余 8 个周边格贴各自屏幕边缘 · 均分剩余空间 · 内容为信息展示 + 交互控件混合（各 sim 自行安排）
- 所有格子尺寸随视口自动计算 · 无硬编码像素 · 无 `Positioned` 绝对定位（Row/Column flex 分配 · 满足 L0-1/L0-3）

**已抽象内容**：
- 9 格参数化（`center` 必填 + 8 边格可选 · 空参自动占位不崩溃）
- `centerAreaRatio` 面积比例可调（默认 0.7 · 下限 clamp 0.7 · 上限 0.9025）
- 可选 `padding` + `backgroundColor`
- 格子内内容用 `LayoutBuilder` 自适应渲染（组件只分格 · 不约束内容尺寸）

**路径**：`lib/common/widgets/nine_grid_layout.dart`（+ `test/common/nine_grid_layout_test.dart` · 6 用例全通过：面积 70% / 贴边 / 自适应 / 下限强制 / 自定义比例 / 空边格）

**落地义务**：所有现有 + 未来 sim 的屏幕适配**必须**基于本组件，禁止各 sim 自造平行布局方案。

---

## 三、明确不抽象（L2 · 模块专属）

以下**禁止**放到公共层（用户强调："特有的不硬塞"）：

| 类型 | 例子 | 理由 |
|---|---|---|
| 物理算法 solver | `optics_solver.dart` / `circuit_solver.dart` / 波场演化算法 / 天线场计算 | 数学差异大 · 硬统一反而牺牲精度与可读性 |
| 域特化状态模型 | `OpticsWorld` / `CircuitState` / `ForcesSimulation` / 待建的 `WaveField` | 字段差异大 · 强行泛化会掉进反射泥沼 |
| 域特化渲染细节 | 光线追迹 / 电流小球 / 波场热图 / 天线场线 | 视觉表征本质不同 · 统一美学不成立 |
| 场景 JSON schema | `optics_scenario.dart` 的字段定义 | 每模块 scenario 字段差异大（元件类型/约束类型/目标类型） |

---

## 四、4 新模块的通用组件复用清单（开工必读）

### req-port-color-vision（33 文件 · 首推首个开工）

| 组件 | 来源 | 必用/可选 |
|---|---|---|
| `PhetSlider` `PhetComboBox` `PhetRadioGroup` | `lib/common/controls/` | 必用 |
| `PropertyControlPanel` `TimeControlBar` | `lib/common/widgets/` | 必用 |
| `SimulationClock` | `lib/common/simulation_clock.dart` | 必用 |
| `ScenarioManagerBase`（**待 P2 抽出**） | `lib/common/scenario/`（P2 完工后） | 必用 · **依赖 P2 需求先完成** |
| `PositionElementBase`（候选 1） | 若届时已抽则用 · 未抽则本模块先自建、评估是否顺便抽 | 可选 |
| `DragDropWorkspace` | 若届时 P1 已完成迁移 → `lib/optics/widgets/` 参考实现 | 可选（视 UI 设计而定） |

### req-port-sound（111 文件 · 中等）

| 组件 | 来源 | 必用/可选 |
|---|---|---|
| L0 全套 controls / widgets | 同上 | 必用 |
| `ScenarioManagerBase` | 同上 | 必用 |
| `WaveFieldRenderer` 首个孵化点 | 本模块内 `lib/sound/widgets/` | 独有 · 第 2 用户出现时再评估上抽 |
| 波形/频谱图 | `lib/common/chart/` 现有 | 尽量复用 · 差异过大再讨论 |

### req-port-radio-waves（57 文件 · 中等）

| 组件 | 来源 | 必用/可选 |
|---|---|---|
| L0 全套 | 同上 | 必用 |
| `ScenarioManagerBase` | 同上 | 必用 |
| `WaveFieldRenderer` | 若 sound 已上抽则复用 · 否则本模块内造 | 视情况 |
| 天线场线渲染 | 本模块 `lib/radio_waves/widgets/` 独有 | L2 · 不上抽 |

### req-port-wave-interference（196 文件 · 大型 · 多 loop）

| 组件 | 来源 | 必用/可选 |
|---|---|---|
| L0 全套 | 同上 | 必用 |
| `ScenarioManagerBase` | 同上 | 必用 |
| `PositionElementBase` | 若届时已抽（本模块可能是触发点） | 优先复用 |
| `WaveFieldRenderer` | 若 sound/radio-waves 已上抽则复用；本模块很可能是**决定上抽的关键第 3 用户** | 强建议评估上抽 |
| 波场演化 solver | 本模块 `lib/wave_interference/models/` 独有 | L2 · 不上抽 |

---

## 五、顺带发现的架构债务（本次统一识别）

### 债务 P1 · optics 模块架构未收敛 ✅ 已解决（req-refactor-optics-layout · 2026-07-28）

**原现象**：optics 一半在 `lib/optics/{models,physics,solvers,config,widgets}/`，另一半散落在 `lib/{screens,widgets,models,services}/` 顶层。

**实际清理结果**（大量转死代码清理 · 最小化方案胜利）：

| 原文件 | 预期动作 | 实际动作 |
|---|---|---|
| `lib/screens/optics_screen.dart`（25.7 KB） | 迁 `lib/optics/screens/` | ✅ 迁 · import 全量修正 |
| `lib/widgets/optics_scene.dart`（25.4 KB） | 迁 `lib/optics/widgets/` | 🗑️ **删死代码**（无外部引用 · 头部自标 Legacy） |
| `lib/widgets/drag_drop_workspace.dart`（6.5 KB） | 迁 `lib/optics/widgets/` | ✅ **上抽 `lib/common/widgets/`**（G3 第 2 用户 · circuit 已在用） |
| `lib/widgets/control_panel.dart`（7.9 KB） | 迁 `lib/optics/widgets/` | 🗑️ **删死代码**（依赖已删的旧 optics_state） |
| `lib/widgets/objective_panel.dart`（7.6 KB） | 迁 `lib/optics/widgets/` | 🗑️ **删死代码**（optics_screen 内自绘 `_RightPanel` 绕过） |
| `lib/widgets/constraint_indicator.dart`（2.4 KB） | 迁 `lib/optics/widgets/` | 🗑️ **删死代码**（同上） |
| `lib/models/optics_solver.dart`（6.3 KB） | diff 判定 | 🗑️ **删死代码**（旧 legacy · 仅被死代码 optics_scene 引用） |
| `lib/models/optics_state.dart`（3.4 KB） | diff 判定 | 🗑️ **删死代码**（同上） |
| `lib/services/sound_effects.dart`（0.4 KB） | 归属决定 | ✅ 迁 `lib/circuit/services/`（全 lib/ 唯一使用者是 circuit_screen） |

**最终 optics 顶层结构**：
```
lib/optics/
├── config/     (已在)
├── models/     (已在)
├── physics/    (已在)
├── solvers/    (已在)
├── widgets/    (仍为空 · 因为 5 个候选 widget 全为死代码或已上抽)
└── screens/    (新建 · optics_screen.dart)
```

**顶层遗留合法**：`lib/screens/{home_screen,scenario_selection_screen}.dart` 是跨模块的**导航/选择屏**，语义上不属于任何单一 sim · 保留在顶层 `screens/` 是正确的收敛结果。

**验证**：`flutter analyze` = 0 error / 0 warning / 23 info（全部与本次迁移无关的历史遗留）。

**顶层保留**：`lib/main.dart` `lib/screens/home_screen.dart` `lib/screens/scenario_selection_screen.dart`（跨模块路由）

**风险**：25.7 KB 的 `optics_screen.dart` + 25.4 KB 的 `optics_scene.dart` 是大型文件 · 迁移涉及 import 路径调整 · 需一次到位不能拆多 commit（否则中间态编译不过）

### 债务 P2 · ScenarioManager 三重造轮

**现象**：optics(6.47 KB) / circuit(5.71 KB) / forces(1.18 KB) 三份 ScenarioManager 存在大段"复制—微调"代码，共性能力（manifest 加载 / 场景缓存 / debugPrint 降级）在 optics 与 circuit 之间几乎 1:1（circuit 的注释里明说"对应光学 ScenarioManager"）。

**违反**：`§10 §5 3-Time Rule` 强触发条件。

**修复方案**：单独立需求 `req-refactor-scenario-manager-common` · 抽 `lib/common/scenario/scenario_manager_base.dart`（泛型基类 + 可选模板方法）· 3 现有模块改继承 · 4 新模块直接用。

**风险**：改动 3 现有模块的 config 层 · 需完整回归 3 模块的 scenario 加载功能

---

## 六、实施顺序建议

```
Now ──▶ [req-refactor-scenario-manager-common]  P2 债务 · 前置阻塞
             │
             ▼ (完成后)
        [req-port-color-vision]                  首个新模块 · 最小最简 · 用新公共 ScenarioManagerBase
             │
             ├─▶ (并行) [req-refactor-optics-layout]  P1 债务 · 不阻塞新模块但要清
             │
             ▼
        [req-port-sound]                          孵化 WaveFieldRenderer 第 1 用户
             │
             ▼
        [req-port-radio-waves]                    WaveFieldRenderer 第 2 用户 · 评估上抽
             │
             ▼ (评估 PositionElementBase 是否已 4 用户 → 上抽)
        [req-port-wave-interference · loop 1..N]  大型 · WaveFieldRenderer 第 3 用户 · 强触发上抽
```

**理由**：
- P2 前置：4 新模块都要用 · 先抽避免又造 4 个副本
- color-vision 首推：33 文件最小 · 作为"新公共 ScenarioManagerBase 首个消费者"验收改造效果
- P1 与 color-vision 并行：optics 债务不阻塞新模块开工，可以插空推进
- sound → radio-waves → wave-interference 顺序做：让 WaveFieldRenderer 有 1→2→3 用户的自然演进节奏，避免过度设计

---

## 七、门禁与合规

**任何新模块开工时**，spec 阶段必须回答：
1. 本模块用了哪些 L0 组件？（如未用某明显应用的，说明原因）
2. 本模块是否触发某 L1 候选的第 N 使用者门槛？如是，是否需要提前抽出？
3. 本模块是否引入新的"疑似 L1"候选？（若是，登记在 notes.md 供后续需求参考）

**任何"抽到 common"的动作**必须：
1. 有 ≥ 2 具体使用者（不是想象的未来用户）
2. 通过 tech-leader review
3. 抽完立即改造既有使用者验证接口设计合理

**引用**：
- 工程原则：`00-engineering-principles.mdc` §2 编辑优于新建 · §4 最小化方案
- vibecoding：`10-vibecoding-protocol.mdc` §2 小步快跑 · §5 3-Time Rule
- 验证前行动：`20-verify-before-act.mdc` §信心阈值
- 状态同步：`45-state-sync-protocol.mdc` §先写后做
- 相关需求：`requirements/req-port-{color-vision,sound,radio-waves,wave-interference}/meta.yaml` · `requirements/req-refactor-{scenario-manager-common,optics-layout}/meta.yaml`
