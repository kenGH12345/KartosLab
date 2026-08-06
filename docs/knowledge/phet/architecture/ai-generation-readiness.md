# phet AI 生成就绪度报告（方案 B）

> **status**: adopted-framework-standard（2026-07-20 采纳为项目基本框架）
> **migration_status**: ✅ **completed（Step 1-3 全部完成于 2026-07-21）**
> **owner**: 待定（迁移需求逐个立项时确定）
> **created**: 2026-07-20
> **adopted**: 2026-07-20（用户拍板 Q1=A · Q2=B · Q3=C · Q4=C）
> **completed**: 2026-07-21（三模块全部达 §C1-§C3 合规，AI 工具链 6 件套齐备）
> **authority**: [design-patterns.md · 配置化项目硬约束](design-patterns.md#配置化--项目硬约束2026-07-20-起生效)（规范条款所在地）
> **prerequisite**: [refactor-baseline-plan.md](refactor-baseline-plan.md)（方案 A · 死代码清理已完成 `bf1d38b`）
> **target form**: Q1=a+c（AI 生成完整实验含教学目标）+ Q2=β（离线设计时 · **B 模式起步 · schema+prompt+人工粘贴生成**）+ Q3=A（所有模块必须遵守 · circuit/forces 分批迁移）
> **estimated effort**: 电路配置化 2-4 天；AI 工具链 B 模式 0.5-1 天；力与运动配置化 5-8 天（含元件抽象重建）；共 7.5-13 天
> **risk level**: 中（涉及新增数据模型、扩展加载路径；不影响现有场景）
> **migration order**（拍板决策 Q3=C · 实际执行结果）:
>   1. Step 0 · 写入硬约束到 design-patterns.md · 30 min · 免 SOP · ✅ **done**
>   2. Step 1 · `req-phet-circuit-config-json` · 电路配置化 · 2-4 天 · agile-vibe · ✅ **done 2026-07-21**
>   3. Step 2 · `req-phet-ai-scenario-toolchain-lite` · AI 工具链 B 模式（三模块）· 0.5-1 天 · agile-vibe · ✅ **done 2026-07-21**
>   4. Step 3 · `req-phet-forces-config-json` · 力与运动配置化 · 5-8 天 · agile-vibe · ✅ **done 2026-07-21**
> **artifacts**（工具链文件清单）:
>   - `docs/prompts/{circuit,forces,optics}_scenario.md`（3 份 System Prompt）
>   - `schemas/{circuit,forces,optics}_scenario.schema.json`（3 份 JSON Schema）
>   - `assets/scenarios/*.json`（optics 3 + circuit 7 + forces 5 = 15 个 few-shot 样本）

---

## 1. 定位与目标

本文档回答一个问题：**如果想让 AI（LLM）为 phet 项目生成新的实验场景，需要做哪些改造？**

- **Q1=a+c**：AI 生成的目标产物是"完整实验"——包含元件配置、初始布局、约束、**教学目标（learning objective）**、UI 权限
- **Q2=β**：AI 生成发生在"离线设计时"——不在运行时嵌入 LLM，只在开发/教研阶段离线生成 JSON → 打包进 assets → 版本控制
- **Q3=甲**：优先改造电路模块（当前枚举驱动），力与运动模块（当前无数据模型层）暂缓

## 2. 光学模块的现状：AI 生成的"活样板"

本次调研读齐了光学 config 五件套完整源码，确认其**已经满足 AI 生成的全部技术要求**。

### 2.1 五件套 schema 结构（`lib/optics/config/`）

| 文件 | 大小 | 职责 | AI 生成时的意义 |
|---|---|---|---|
| `lab_scenario.dart` | 5.45 KB | 顶层容器（scenarioId/name/description/version/level/domain + inventory + initialLayout + constraints + objectives + gameRules + ui）| **AI 生成的顶层目标结构** |
| `component_inventory.dart` | 2.37 KB | 元件规格（`Map<Type, ComponentSpec>` · maxCount/locked/defaultParams）| AI 决定"这个实验能用哪些元件、每种最多几个" |
| `constraint.dart` | 3.94 KB | 约束系统（alignment/distance/order 三类，含 `params` 灵活字段）| AI 决定"学生操作的边界"（如"必须对齐光轴"）|
| `learning_objective.dart` | 6.09 KB | 教学目标（guided/freeExplore/challenge + successCriteria + hints + validation）| **Q1=c 的核心价值承载**——AI 生成教学意图 |
| `game_rules.dart` | 2.16 KB | 游戏化规则（timeLimit/scoreFormula/penalties）| 可选，游戏化实验时 AI 输出 |

### 2.2 加载路径（`ScenarioManager`）

引用 `lib/optics/config/scenario_manager.dart:22-45`：

```dart
Future<void> loadScenarios() async {
  final manifestStr = await rootBundle.loadString('assets/scenarios/manifest.json');
  final manifest = jsonDecode(manifestStr) as Map<String, dynamic>;
  final scenarioIds = (manifest['scenarios'] as List<dynamic>).cast<Map<String, dynamic>>();

  _scenarios.clear();
  for (final scenarioData in scenarioIds) {
    final id = scenarioData['id'] as String;
    final jsonStr = await rootBundle.loadString('assets/scenarios/$id.json');
    final scenario = LabScenario.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    _scenarios.add(scenario);
  }
}
```

**AI 生成流程简单到极致**：
1. LLM 输出一份 `<newId>.json` 文件 → 放到 `assets/scenarios/`
2. 更新 `manifest.json` 的 `scenarios` 数组 → 增加一行 `{"id": "<newId>"}`
3. `flutter run` 即可看到新实验出现在场景选择器

### 2.3 目标产物形态（真实样本）

引用 `assets/scenarios/basic-lens-imaging.json`（2.30 KB / 94 行）——**这就是 AI 单次生成的目标产物**：

```json
{
  "scenarioId": "basic-lens-imaging",
  "name": "凸透镜成像规律",
  "description": "探究凸透镜成像的特点和规律",
  "version": "1.0.0",
  "level": "beginner",
  "domain": "optics-lens",
  "inventory": { ... },          // 元件库存
  "initialLayout": [ ... ],      // 3 个元件初始布局
  "constraints": [ ... ],        // 对齐约束
  "objectives": { ... },         // guided 目标 + successCriteria + hints
  "gameRules": { "enabled": false, "penalties": [] },
  "ui": { ... }                  // 6 个开关
}
```

**LLM 生成量估算**：约 700-800 tokens——单次 completion 完全够用，可用小模型（gpt-4o-mini / claude-haiku 等）低成本批量生成。

### 2.4 现有场景库（AI 训练/微调的 few-shot 样本）

```
c:\workspace\phet\assets\scenarios\
├── basic-lens-imaging.json (2.35 KB · 凸透镜成像)
├── lens-combination.json   (2.63 KB · 透镜组合)
├── mirror-imaging.json     (2.32 KB · 镜面成像)
└── manifest.json           (0.47 KB)
```

**只有 3 个场景样本**——对 AI few-shot 生成是**下限**（推荐 ≥ 5 样本，理想 ≥ 10）。方案 B 落地前需要人工再产 2-3 个光学场景**扩样本池**，成本约半天。

## 3. 电路模块的现状：AI 生成的"结构障碍"

### 3.1 障碍 1：无 scenario 数据模型

电路模块**完全没有**对齐 `LabScenario` 的数据结构。相当于要**从零复刻**光学的五件套，但需要设计电路语义。

### 3.2 障碍 2：`ComponentTypeLabel` 枚举驱动的硬编码

引用 `lib/models/circuit_state.dart:6-31`——元件的 `label / unit / defaultValue / valueMin / valueMax / valueStep` **全部硬编码在 Dart 扩展里**，AI 无法通过 JSON 表达"这个实验里电池默认值改成 9V、最大 12V"。

必须把这些字段迁移到 JSON 可控。

### 3.3 障碍 3：无 scenario 加载入口

引用 `lib/screens/circuit_screen.dart:19`：

```dart
CircuitState _state = const CircuitState();  // 从空状态启动
```

电路 screen 当前**从空状态启动**，无场景加载路径。AI 生成的 JSON 无处挂载。

### 3.4 障碍 4：拓扑复杂度约为光学的 2 倍

| 维度 | 光学 | 电路 |
|---|---|---|
| 元件模型 | 平铺 `List<ElementPlacement>`，位置直接由 (x, y) 定义 | 元件 + `Vertex` + `WireSegment` **三层拓扑**，元件通过 `startVertexId/endVertexId` 引用顶点 |
| 连接关系 | 无（元件独立） | 顶点 + 导线构成图（graph），元件依附于顶点 |
| 动态元素 | 无 | 导线的 `controlPoints`（任意个数控制点，用于弯曲）|
| Undo/Redo | 无 | 有 `CircuitHistory` 栈 |

**AI 生成电路 JSON 时需要额外的语义约束**：
- 生成的每个元件必须有对应的两个顶点存在
- 生成的每条导线必须首尾连接到已存在的顶点
- 若引入"拓扑合法性检查"，AI 需要在生成时保证 graph 联通性——难度高于光学

## 4. 方案：分三阶段推进

### 阶段 1：电路配置化改造（2-4 天，agile-vibe SOP）

#### 4.1 新增数据模型（对齐光学 config/）

新建目录 `lib/circuit/config/`（依赖方案 A 3.2 完成，否则临时放 `lib/config/` 待方案 A 补做时搬移）：

| 新文件 | 参考光学对应文件 | 差异点 |
|---|---|---|
| `circuit_scenario.dart` | `lab_scenario.dart` | 顶层 domain 改 `circuit-*`；initialLayout 需要拆成 `vertices/components/wires` 三段 |
| `circuit_inventory.dart` | `component_inventory.dart` | `Map<ComponentType, ComponentSpec>`（ComponentType 已存在，无需新增枚举） |
| `circuit_constraint.dart` | `constraint.dart` | 新增约束类型：`nodeCount`（节点数上限）、`loopClosed`（回路必须闭合）、`componentPresent`（必须包含某类元件） |
| `circuit_objective.dart` | `learning_objective.dart` | 新增 `CriterionType.brightnessValue`（灯泡亮度达标）、`voltageAtNode`（节点电压达标）、`currentInBranch`（支路电流达标） |
| `circuit_game_rules.dart` | `game_rules.dart` | 可暂时用光学版本（无电路特殊需求） |
| `circuit_scenario_manager.dart` | `scenario_manager.dart` | 加载路径 `assets/circuit_scenarios/` |

#### 4.2 JSON schema 草案（电路版）

```json
{
  "scenarioId": "series-circuit-basic",
  "name": "串联电路认识",
  "description": "了解串联电路中电流的特点",
  "version": "1.0.0",
  "level": "beginner",
  "domain": "circuit-series",

  "inventory": {
    "availableComponents": {
      "battery":    { "maxCount": 1, "locked": false, "defaultParams": { "value": 6.0 } },
      "resistor":   { "maxCount": 2, "locked": false, "defaultParams": { "value": 10.0 } },
      "lightBulb":  { "maxCount": 2, "locked": false, "defaultParams": { "value": 10.0 } },
      "switch_":    { "maxCount": 1, "locked": false, "defaultParams": {} },
      "wire":       { "maxCount": 10, "locked": false, "defaultParams": {} }
    }
  },

  "initialLayout": {
    "vertices": [
      { "id": "v1", "x": 100, "y": 100, "isTerminal": true },
      { "id": "v2", "x": 200, "y": 100, "isTerminal": true },
      ...
    ],
    "components": [
      { "id": "c1", "type": "battery", "x": 150, "y": 100, "rotation": 0,
        "value": 6.0, "startVertexId": "v1", "endVertexId": "v2", "locked": false }
    ],
    "wires": [
      { "id": "w1", "startVertexId": "v2", "endVertexId": "v3", "controlPoints": [] }
    ]
  },

  "constraints": [
    { "id": "c1", "type": "loopClosed", "description": "电路必须构成闭合回路",
      "params": {}, "enforced": true },
    { "id": "c2", "type": "componentPresent", "description": "必须包含至少一个灯泡",
      "params": { "componentType": "lightBulb", "minCount": 1 }, "enforced": true }
  ],

  "objectives": {
    "type": "guided",
    "description": "点亮所有灯泡并观察串联电路电流特点",
    "successCriteria": [
      { "id": "sc1", "type": "brightnessValue", "description": "灯泡 c3 亮度 > 0.5",
        "params": { "componentId": "c3", "minBrightness": 0.5 } }
    ],
    "hints": [
      { "trigger": "brightness == 0", "message": "检查电路是否闭合" }
    ],
    "validation": { "autoCheck": true, "showFeedback": true }
  },

  "gameRules": { "enabled": false, "penalties": [] },

  "ui": {
    "showGrid": true,
    "showZoomControls": true,
    "allowAddComponent": true,
    "allowRemoveComponent": true,
    "allowMoveComponent": true
  }
}
```

**注意**：`initialLayout` 从光学的**平铺数组**改为**嵌套对象**（vertices/components/wires 三段），因为电路拓扑需要三种实体。

#### 4.3 打破 `ComponentTypeLabel` 硬编码的迁移路径

**当前**（`circuit_state.dart:6-31`）：
```dart
extension ComponentTypeLabel on ComponentType {
  double get defaultValue => switch (this) {
    ComponentType.battery => 10.0,
    ...
  };
}
```

**改造后**：
- `defaultValue` / `valueMin` / `valueMax` / `valueStep` 迁移到 `ComponentSpec.defaultParams`（inventory 逐场景可覆盖）
- `label` / `unit` 保留在扩展里（这是**词汇定义**，跨场景不变）
- Screen 加载 scenario 时，`ComponentSpec.defaultParams['value'] / ['valueMin'] / ...` 覆盖扩展默认值

**兼容性**：默认 scenario 空数据时仍走扩展默认值（backward compatible）。

#### 4.4 修改 `CircuitScreen` 支持 scenario 加载

引用 `lib/screens/circuit_screen.dart:19`——`_state = const CircuitState()` 改为：

```dart
class CircuitScreen extends StatefulWidget {
  const CircuitScreen({super.key, this.scenarioId});
  final String? scenarioId;  // null = 空白模式
  ...
}

class _CircuitScreenState extends State<CircuitScreen> {
  late CircuitState _state;
  final CircuitScenarioManager _scenarioMgr = CircuitScenarioManager();

  @override void initState() {
    super.initState();
    _sfx = SoundEffects();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    if (widget.scenarioId == null) {
      setState(() => _state = const CircuitState());
      return;
    }
    await _scenarioMgr.loadScenarios();
    setState(() => _state = _scenarioMgr.loadScenario(widget.scenarioId!));
  }
}
```

同时 `home_screen.dart` 增加"电路场景选择器"入口——参考现有 `scenario_selection_screen.dart` 的光学入口结构。

#### 4.5 阶段 1 验收标准
- [ ] `flutter analyze` 0 error
- [ ] 无 scenario 启动（`scenarioId=null`）行为与改造前完全一致（回归安全网）
- [ ] 至少 1 个电路场景 JSON（`series-circuit-basic.json`）可从 assets 加载 + 交互正常
- [ ] `CircuitScenarioManager.loadScenarios / loadScenario / validateConstraints` 单元测试覆盖
- [ ] 知识库同步：`context/project/phet/systems/circuit-module.md` 加"配置化"章节

### 阶段 2：AI 生成工具链（1-2 天）

#### 4.6 目标：让"教研老师给关键词 → LLM 输出 JSON → 落盘生效"跑通

**推荐架构**（Q2=β 离线设计时）：

```
scripts/                                 ← 新建，与 lib/ 平级
├── ai_scenario_gen/
│   ├── generate.py                       (或 .dart 命令行)
│   ├── prompts/
│   │   ├── optics_scenario.md            (system prompt + few-shot 样本)
│   │   └── circuit_scenario.md
│   ├── schemas/
│   │   ├── optics_scenario.schema.json   (JSON Schema 校验)
│   │   └── circuit_scenario.schema.json
│   └── validate.dart                     (加载 JSON → LabScenario.fromJson / CircuitScenario.fromJson → 若抛错报生成失败)
```

**运行流程**：
1. 教研老师执行 `python scripts/ai_scenario_gen/generate.py --domain circuit --topic "并联电路特点" --level beginner`
2. 脚本调 LLM API（gpt-4o-mini / claude-haiku）读 prompt + few-shot 样本 + 请求生成
3. LLM 输出 JSON 字符串
4. **双重校验**：
   - JSON Schema 结构校验（`schemas/circuit_scenario.schema.json`）
   - **Dart 端语义校验**：`dart scripts/ai_scenario_gen/validate.dart <path>` 加载 JSON → 尝试 `CircuitScenario.fromJson()` → 若抛异常则生成失败
5. 校验通过 → 写入 `assets/circuit_scenarios/<id>.json` + 更新 manifest → git commit → PR review → merge

**关键设计**：**LLM 生成 ≠ 立即上线**。必须过校验闸门 + 人工 PR review 两道门（防止 LLM 幻觉生成非法/危险配置）。

#### 4.7 Prompt 设计要点

- **System prompt**：包含 CircuitScenario schema 完整字段说明 + 3 条硬约束（如"每个元件必须有对应的两个顶点""每条导线必须连接已存在的顶点"）
- **Few-shot**：内联 2-3 个现有场景 JSON 作示范
- **User input**：`domain + topic + level + [可选] 期望约束/教学目标`
- **Response format**：强制 JSON output（OpenAI `response_format: json_object` 或 Claude 的 tool use）

#### 4.8 阶段 2 验收标准
- [ ] 生成脚本能跑通"关键词 → JSON → 校验通过 → 落盘"完整链路
- [ ] JSON Schema 覆盖两模块（光学 + 电路）
- [ ] 端到端测试：3 次生成，至少 2 次通过校验且在 App 里可加载运行
- [ ] 生成失败时给出结构化错误报告（哪个字段不合法）

### 阶段 3（可选 · 力与运动模块）暂缓

按 Q3=甲 决策，力与运动模块**暂缓**。若未来重启，需明确知晓：

- 力与运动**没有元件抽象**（`forces/models/` 只有 simulation/item/motion/netforce 四个业务类，无 `ForcesElement` 基类或 `ForcesElementType` 枚举）
- 要配置化需**先设计元件模型**（物块/斜面/滑轮/弹簧？）——这是一次**建模决策**，不是"照搬光学 schema"
- 保守估计工作量 **5-8 天**（远大于电路的 2-4 天）
- 现有 3 个 forces 实验的"配置感"极弱（不像光学/电路有明确的元件放置），AI 生成价值可能低于投入

**建议**：等电路配置化 + AI 生成工具链稳定运行 3 个月后再回头评估力与运动的收益。

## 5. 风险与开放问题

### 5.1 风险清单

| # | 风险 | 缓解措施 |
|---|---|---|
| R1 | AI 生成的电路 JSON 拓扑不合法（孤立顶点 / 断裂导线）| 阶段 2 的 Dart 语义校验能捕获所有 `CircuitScenario.fromJson` 抛异常的情况；再加拓扑合法性检查函数 |
| R2 | AI 生成的教学目标 `successCriteria` 逻辑错（如"物距 > 2f 缩小实像"写反）| 人工 PR review 兜底；未来可加"LLM 自动生成 + LLM 自动 review"双阶段 |
| R3 | 电路配置化引入的 schema 复杂度让教研老师不会手改 JSON | 阶段 2 的生成脚本兼作"辅助编辑器"——老师改自然语言描述，脚本重新生成 JSON |
| R4 | 现有场景样本量（3 个）不足以支撑 AI few-shot 生成 | 阶段 1 前先人工加 2-3 个光学场景 + 3-5 个电路场景，投入约 1 天 |
| R5 | 电路配置化改造若跳过方案 A（未先重构目录）会加剧文件混乱 | 强推荐方案 A 3.1 + 3.2 先行，或在阶段 1 一并做完 |

### 5.2 开放问题（阶段 1 PM 澄清前需要用户回答）

| # | 问题 | 建议选项 |
|---|---|---|
| Q1 | 电路场景选择器 UX 参考光学的 `scenario_selection_screen.dart` 还是独立设计？ | 参考（沿用现有卡片式）|
| Q2 | AI 生成脚本用 Python 还是 Dart CLI？ | Python（LLM SDK 成熟度高）+ 调用 `dart` 做校验 |
| Q3 | LLM 服务选型？| gpt-4o-mini（低成本 + JSON mode 成熟）；本项目上下文里的 AgentHub 可作二选 |
| Q4 | 生成的 JSON 是否需要 i18n（多语言 name/description）？| 阶段 1 不做；未来另立需求 |
| Q5 | 是否引入"AI 生成质量评分"机制？| 阶段 2 不做；等运行 3 个月看数据 |

## 6. 立需求建议

| 粒度选项 | 说明 | 推荐 |
|---|---|---|
| **粒度 1（推荐）**：三个独立需求分批 | `req-phet-refactor-baseline`（方案 A 3.1+3.2）→ `req-phet-circuit-config-json`（本方案阶段 1）→ `req-phet-ai-scenario-gen`（本方案阶段 2）| ✅ 每个需求都能独立验收、独立回滚 |
| 粒度 2：一个大需求 | `req-phet-ai-generation-ready`（一次搞定方案 A + 方案 B 全部）| ❌ 3-6 天工作量过大，违反 10-vibecoding-protocol §"30 分钟原则"的精神（虽然协议原本针对 vibe-loop） |
| 粒度 3：只做阶段 1 | `req-phet-circuit-config-json` 单独立项 | ⚠️ 只有配置化没有 AI 生成，Q1 目标不完整 |

**SOP 选择**：全部 agile-vibe（含 PM/TL/Dev/Reviewer/Closer 4 阶段）。这些需求都涉及新增数据模型 + 跨模块设计，不适用轻量 SOP。

## 7. 与方案 A 的关系

- 方案 B **强依赖** 方案 A 的 3.1（死代码清理）：否则 AI 生成的电路场景 JSON 与死代码 `circuit_element.dart` / `battery.dart` 里的 `CircuitElementType` 枚举形成**双元件类型系统**（生产用 `ComponentType`，死代码用 `CircuitElementType`）——未来贡献者极易搞错
- 方案 B **强依赖** 方案 A 的 3.2（电路目录重构）：否则 `lib/circuit/config/` 目录无处可建，只能放到 `lib/config/` 顶层，破坏"每模块自成一体"的架构统一性
- 方案 B **弱依赖** 方案 A 的 3.3（`circuit_state.dart` 拆分）：阶段 1 会给 `circuit_state.dart` 加约 100-200 行改动（`fromJson` 相关），若不拆分则文件膨胀到 ~20 KB；建议 3.3 与阶段 1 合并做

## 8. 决策矩阵（给用户 3 分钟做拍板）

| 你想 | 应该 |
|---|---|
| **完整实现 Q1=a+c + Q2=β** | 走"粒度 1"：三需求依次立项，总计 3-6 天 |
| **只想验证 AI 生成可行性** | 先做方案 A 3.1（死代码清理，15 分钟）+ 手工新加 2 个光学场景（0.5 天）+ 直接用 ChatGPT 网页版 few-shot 生成第 3 个（0.5 天）→ 若跑通再谈立项 |
| **短期不推进** | 保留本文档 status=proposal，等业务上有明确 AI 生成需求（如"下个季度要给 20 个新实验"）再启动 |
| **推翻 Q3=甲，也想改造力与运动** | 本方案不覆盖；需要另开单独调研（预计再 1 天调研 + 5-8 天改造）|

## 变更历史

> 2026-07-20：初版。基于以下现状调研产出：
> - 光学 config 五件套完整源码（`lib/optics/config/*.dart`）
> - 光学场景加载路径（`scenario_manager.dart` + `assets/scenarios/manifest.json`）
> - 现有场景 JSON 样本（`assets/scenarios/basic-lens-imaging.json` 等 3 个）
> - 电路当前实现（`lib/models/circuit_state.dart` 枚举驱动 + `lib/screens/circuit_screen.dart:19` 空状态启动）
> - 力与运动摸底（`lib/forces/` 目录 · 无元件抽象）
> 
> 调研会话上下文：AI 生成就绪度评估。触发原因：用户 Q1=a+c/Q2=β/Q3=甲 决策 + 追问"配置化不彻底问题解决了吗"。作者: AI 调研会话。

> 2026-07-20（傍晚）by 用户拍板 Q1=A · Q2=B · Q3=C · Q4=C：
> 从 proposal 升为 adopted-framework-standard。
> - frontmatter status: proposal → adopted-framework-standard
> - target form Q3: 甲（电路优先，力与运动暂缓）→ A（所有模块必须遵守 · 分批迁移）
> - 新增 migration order 4 步锁项 · 明确 Step 0 免 SOP + Step 1-3 走 agile-vibe
> - 授权来源：本次会话最新拍板；配套 `design-patterns.md` 同步升级"配置化项目硬约束"章节（§C1-§C4）
> - 触发原因：用户指令"进行可 ai 生成的配置化改造 要作为项目的基本框架来实现 所有模块都要遵守"

> 2026-07-21 by 会话内迭代 · 三模块全合规达成：
> Step 1-3 全部完成，migration_status: proposal → completed。
> - frontmatter 加 `migration_status: completed` + `completed: 2026-07-21` + `artifacts` 清单
> - migration order 4 步全部标 ✅ done
> - 实证：`docs/prompts/{circuit,forces,optics}_scenario.md` 3 份 + `schemas/{circuit,forces,optics}_scenario.schema.json` 3 份 + `assets/scenarios/` 三目录共 15 个 few-shot 样本齐备
> - 配套：`design-patterns.md` §各模块合规现状表 optics 由 🟡 部分合规 → 🟢 合规
> - 触发原因：用户追问"knowledge base 是否反映了实验实现的基本要求"暴露 §合规表与实际进度不同步；审查结论 D 全量修补
> - 本文档从"规划文档"转为"完成实证文档"，后续新模块加入按本文档同结构立项
