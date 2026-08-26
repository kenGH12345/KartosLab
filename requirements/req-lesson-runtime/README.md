# 教学剧本（lesson-plan）详细需求文档 · 全景整合版

> **定位**：本文档整合"教学剧本"方向从评估到实现的全部结论，供通读与决策。
> **不是**阶段产物的替代——实现合同以 `spec/需求文档.md` 为准，技术设计以 `design/技术方案.md` 为准。
> 整理：主会话 · 2026-08-24 · 来源四份文档（见 §9 文档地图）

---

## 0. 一句话需求

为 KratosLab 增加**课时级多场景编排能力**：老师（或 AI）用一份 JSON"剧本"把多个实验场景串成一节课，支持顺序解锁、按预测题得分分支、完整课时序列；学生按剧本自动流转走完一节课；**现有单场景模式完全不受影响**。

---

## 1. 背景与动机

### 1.1 现状：单场景孤岛

当前 scenario 体系（46 个场景 JSON + 8 份 manifest）中，ScenarioManager 按 id 逐个加载独立实验——场景间**无依赖、无顺序、无分支**。条件树（SuccessCondition）只在单场景内判定 successCriteria。

### 1.2 三大表达力缺口（用户原始诉求）

| # | 缺口 | 例子 |
|---|------|------|
| 1 | **前置解锁** | 先完成场景 A 才能进场景 B |
| 2 | **条件分支** | 预测题得分 ≥80% 进挑战场景，否则进复习场景 |
| 3 | **课时序列** | 一节 40 分钟课 = 3-5 个实验按序/按条件流转 |

评估报告共识别 10 类缺口（G1-G10，必须级 4 / 重要级 4 / 锦上添花 2），上述三项为必须级。

### 1.3 评估结论（req-lesson-scripting，2026-08-24 verdict=go）

- 三方案对比（A 扩展 manifest / **B 新增 lesson-plan 编排层** / C DSL 引擎）× 6 维度 → **推荐 B**：引用式纯增量，6 维中 5 维优/良
- 核心工作量估算 **12 人天**（置信度中）；技术挂点全部源码级实证存在
- 硬前置仅 req-criteria-composable 流程收尾（API 已 339 测试锁定）；试点限定 circuit + color_vision（完成信号真实消费仅此 2 屏）

---

## 2. 用户与使用场景

### 2.1 学生侧：一节"欧姆定律课时"的体验

1. 主界面看到「课时」入口卡片（"欧姆定律课时 · 40 分钟"），点入看到进度指示（1/4 · 当前节点高亮、锁定节点灰显）
2. 节点 1「认识串联电路」自动加载 circuit 的对应场景——实验体验与现状完全一致；学生操作直到达成场景目标
3. 场景完成 → 自动流转到节点 2（带过渡反馈）
4. 节点 2 含预测题：答对率 ≥80% → 挑战路线；否则 → 复习路线（**条件分支**）
5. 两路线各自完成 → 「课时完成」总结

### 2.2 教师侧：创作一个课时

- **手写**：写一份 lesson JSON（见 §4.2 结构），只**引用**既有场景 `{sim, scenarioId}`，不复制场景数据；跨 sim 课时（circuit + color_vision 混排）天然支持
- **AI 生成**（P3 交付后）：自然语言描述课时意图 → AI 按 `docs/prompts/lesson.md` 生成剧本 JSON → schema 校验 → 自动写入资产目录。剧本只引用既有场景 id（无需生成物理正确数据），是全项目 AI 生成友好度最高的资产类型
- **不做**：可视化拖拽编排器（C4 禁区，明确排除）

### 2.3 新旧模式共存（用户已确认的关切）

| 层 | 共存机制 |
|----|---------|
| 数据 | 剧本是独立顶层资产（`assets/lessons/`），纯引用——46 场景 + 8 manifest **零改动**；同一场景可被独立模式和任意多剧本同时引用 |
| 运行 | 剧本模式与学生自由选场景走**同一个** `ScenarioManager.loadScenario(id)` 代码路径 |
| 入口 | 课时入口卡片与现有 sim 入口并列；无课时资产时 app 行为与今天完全一致 |
| 降级 | 剧本引用失效 → FormatException → **仅该课时跳过**，独立模式与其他课时不受影响 |

---

## 3. 功能需求全景（16 功能点 × 3 Phase）

### P1 线性编排地基（~5 人天）

| # | 功能 | 说明 |
|---|------|------|
| F1 | **LessonPlan 数据模型** | 剧本 JSON → 强类型不可变模型；fail loud 解析（格式错误/悬空引用/不可达图 → FormatException → 课时降级跳过） |
| F2 | **LessonRuntime 状态机** | 四步契约：load → enterNode → advanceFrom → onScenarioSuccess（详见 §4.4） |
| F3 | **Lessons manifest** | `assets/lessons/manifest.json` 课时注册表与加载入口 |
| F4 | **课时入口卡片** | home_screen 新增入口（有课时 sim 显示 / 无课时 sim 不变） |
| F5 | **进度指示 UI** | 当前节点标题 + N/M 进度 + 节点列表概览（已完成/当前/锁定态） |
| F6 | **流转反馈 UI** | 节点完成反馈 + 下一节点标题展示 + 课时完成态 |
| F7 | **试点线性剧本 ≥2 条** | circuit + color_vision 各 1 条，≥3 节点，端到端可跑通 |

### P2 条件编排（~4 人天）

| # | 功能 | 说明 |
|---|------|------|
| F8 | **剧本级条件树** | 复用 SuccessCondition 的 all/any/not JSON 契约 + 注入 3 种剧本叶子求值器（§4.3）；深度上限复用 maxParseDepth=4；未知叶子/未作答一律 false（fail-safe） |
| F9 | **unlock 门禁** | 节点可配 unlock 条件树；未解锁节点 UI 锁定态、不可进 |
| F10 | **routes 条件路由** | advance.type=routes 按序求值取首个满足；末项 when=null 为兜底；无兜底 → 解析期 FormatException |
| F11 | **InquiryDrawer 可选转发** | 新增 `onPredictionResult(verified, correct)?` 可选参数（挂 `inquiry_drawer.dart:337-344` 追加一行 `?.call`）；不传时行为完全不变（向后兼容先例：ExperimentLogger.onRowsChanged） |
| F12 | **试点条件剧本 ≥2 条** | 含条件分支 + 前置解锁，端到端可跑通 |

### P3 AI 生成链路（~3 人天）

| # | 功能 | 说明 |
|---|------|------|
| F13 | **lesson.schema.json** | 剧本结构校验（字段类型 + advance.type enum + 叶子 type enum + 兜底路由约束） |
| F14 | **docs/prompts/lesson.md** | 编排原语说明 + 叶子枚举 + few-shot + `_shared` 条件树附录 + 场景 id 清单注入占位（防 AI 引用幻觉） |
| F15 | **generate.py --lesson** | 生成 → schema 校验 → 写入 assets/lessons/ → 自动更新 manifest |
| F16 | **引用守卫测试** | 遍历全部剧本断言 scenarioId 存在（沿用 scenario_runtime_wiring_test 模式）；场景删除 → 测试红灯 |

**明确排除**：P4 B 类 4 sim 判定接线 · P5 进度持久化（跨 session）· 作者侧编排 UI · 跨场景实验数据传递（G5）。

---

## 4. 核心设计契约

### 4.1 资产与代码形态（方案 B）

```
assets/lessons/<lesson-id>.json          ← 剧本（节点图）
assets/lessons/manifest.json             ← 课时注册表
schemas/lesson.schema.json               ← AI 三件套 1/3
docs/prompts/lesson.md                   ← AI 三件套 2/3
scripts/ai_scenario_gen/generate.py --lesson  ← AI 三件套 3/3
lib/common/scenario/lesson_plan.dart     ← 剧本模型（fail loud 解析）
lib/common/scenario/lesson_runtime.dart  ← 编排状态机（ChangeNotifier）
+ 课时入口卡片 / 进度指示 / 流转反馈组件（lib/common/widgets/）
```

新增 ~13 文件；存量修改 5 处**全部为可选参数纯增量**（home_screen 入口 + inquiry_drawer 转发 + 2 个 sim screen 完成信号钩子 + generate.py 新分支）。

### 4.2 剧本 JSON 结构（完整契约示例）

```json
{
  "lessonId": "circuit-ohm-law-40min",
  "name": "欧姆定律课时（40 分钟）",
  "version": "1.0",
  "description": "串并联认知 → 预测验证 → 按预测表现分流挑战/复习 → 汇合收束",
  "entry": "n1",
  "nodes": [
    { "id": "n1", "title": "认识串联电路",
      "scenario": { "sim": "circuit", "scenarioId": "simple-series" },
      "unlock": null,
      "advance": { "type": "onCompleted", "to": "n2" } },
    { "id": "n2", "title": "并联电路与预测验证",
      "scenario": { "sim": "circuit", "scenarioId": "parallel-bulbs" },
      "unlock": { "all": [ { "type": "nodeCompleted",
                 "params": { "nodeId": "n1" } } ] },
      "advance": { "type": "routes", "routes": [
        { "to": "n3-challenge",
          "when": { "type": "predictionScore",
                    "params": { "nodeId": "n2", "metric": "ratio",
                                "operator": "gte", "threshold": 0.8 } } },
        { "to": "n3-review", "when": null } ] } },
    { "id": "n3-challenge", "title": "电路诊断挑战",
      "scenario": { "sim": "circuit", "scenarioId": "open-circuit-debug" },
      "unlock": { "type": "nodeCompleted", "params": { "nodeId": "n2" } },
      "advance": { "type": "onCompleted", "to": "n-end" } },
    { "id": "n3-review", "title": "开关控制复习",
      "scenario": { "sim": "circuit", "scenarioId": "controlled-switch" },
      "unlock": { "type": "nodeCompleted", "params": { "nodeId": "n2" } },
      "advance": { "type": "onCompleted", "to": "n-end" } },
    { "id": "n-end", "title": "课时完成",
      "scenario": null, "unlock": null, "advance": null }
  ]
}
```

> 注：实现版叶子 JSON 还需含 `id` + `description` 必填字段（设计决策 D1——`LeafCondition.fromJson` 非空断言实证，评估报告草案缺此二字段会解析崩溃；schema/prompt/示例已同步修正）。

### 4.3 三种编排模式 + 条件叶子

| 编排模式 | 表达 | 职责 |
|---------|------|------|
| 线性序列 | `advance: {type: "next"}` 数组顺延 / `{type: "onCompleted", to}` 显式跳转 | 自动流转 |
| 条件分支 | `advance: {type: "routes", routes: [{when: 条件树, to}, …, {when: null, to}]}` | 按序求值，兜底路由必须存在 |
| 前置解锁 | `unlock: 条件树`（null=无门禁） | **手动跳转门禁**（管可见性），与 advance（管自动流转）职责正交 |

**剧本级条件叶子**（封闭枚举，复用 all/any/not 组合契约包裹）：

| type | 语义 | 求值逻辑 | 依赖 |
|------|------|---------|------|
| `nodeCompleted` | 指定节点已完成 | `completed.contains(nodeId)` | 剧本 runtime 自身（无外部依赖） |
| `predictionScore` | 预测题正确率/数达阈值 | `correct/verified` 与 threshold 比较（metric: count/ratio · operator: gte/lte/gt/lt/eq） | req-predictive-inquiry 通路（经 F11 转发） |
| `scenarioSuccess` | 指定场景 successCriteria 曾全满足 | A 类判定链 | req-criteria-composable |

### 4.4 运行四步契约

**load**（读 JSON → 解析校验 → 进 entry）→ **enterNode**（`ScenarioManager.loadScenario(scenarioId)` 加载场景 → sim screen 渲染；终点节点触发课时完成）→ **advanceFrom**（next/onCompleted/routes 三型判定下一节点）→ **onScenarioSuccess**（场景判定全满足 → 标记 completed → 触发流转）。

状态暴露：`current` / `completed` 集合 / `progress` / `isUnlocked(nodeId)`。

### 4.5 关键设计决策（design/技术方案.md §1.2，8 条中最重要 5 条）

| # | 决策 | 依据 |
|---|------|------|
| D1 | 叶子 JSON 必含 `id`+`description`（修正评估报告草案契约缺陷） | `success_condition.dart:139-141` 非空断言实证 |
| D2 | 声明式渲染：LessonRuntime(ChangeNotifier) 切 current → LessonScreen 响应重建 | Flutter 惯例（修正评估伪码命令式残留） |
| D4 | sim screen 完成信号经可选参数钩子外发（circuit 门控扩展 + rgb 新增检测路径） | 回源实证，场景数据资产仍零触碰 |
| D5 | 课时完成 = 进入终点节点（修正评估伪码 `requiredNodes.every` 在分支剧本下永不成立的缺陷） | 逻辑修正 |
| D7 | 兜底路由仅末项允许 when=null，其余项必含 when（严格化） | 防歧义 |

### 4.6 试点剧本 4 条（已按 manifest + 判定链现状选定）

| sim | 类型 | 场景序列 | 选定依据 |
|-----|------|---------|---------|
| circuit | 线性 | controlled-switch → open-circuit-debug → fuse-blown | 三场景均需学生操作达成判定（规避"秒完成"场景） |
| circuit | 条件 | simple-series 预测分流 challenge/review 双线 | 全项目唯一 circuit 预测题数据源 |
| color_vision | 线性 | rgb-yellow-only → rgb-cyan-challenge → rgb-challenge-basic | 全 colorMatch 判定已实现 |
| color_vision | 条件 | unlock all/any 组合树展示 | 覆盖组合条件 |

系统性规避：simple-series/parallel-bulbs 初始布局闭合秒完成 → 不入线性剧本；color_vision 判定仅 colorMatch 1/3 → 剧本场景全限定 colorMatch；singleBulb 屏无判定消费 → 引用则解析期拒绝（防运行期卡死）。

---

## 5. 验收标准体系（57 条 + 3 回归）

| 模块 | AC | 核心验收点 |
|------|-----|-----------|
| F1 数据模型 | AC-1~6 | 三模式合法解析；悬空引用/不可达图 → FormatException；降级不 crash |
| F2 状态机 | AC-7~13 | 四步契约逐项；线性三节点端到端；复用 loadScenario 零改动 |
| F3 Manifest | AC-14~15 | 注册表解析；单课时损坏跳过不阻塞 |
| F4-F6 UI 三件 | AC-16~22 | 有课时显示入口 / 无课时首页不变；进度实时更新；流转可感知 |
| F7 线性剧本 | AC-23~26 | ≥2 条覆盖两 sim；端到端跑通 |
| F8 条件树 | AC-27~33 | all/any/not 契约一致；3 叶子求值正确；未知/未作答 false；深度上限 4 |
| F9 unlock | AC-34~36 | 锁定态/解锁/null 三态 |
| F10 routes | AC-37~39 | 按序求值；兜底路由；无兜底解析期拒绝 |
| F11 转发 | AC-40~42 | 可选参数传入转发；不传行为完全不变 |
| F12 条件剧本 | AC-43~45 | 分支+解锁剧本端到端，不同条件走不同路径 |
| F13-F15 AI 链路 | AC-46~55 | schema 正反例；prompt 含 id 清单注入；generate 全流程 |
| F16 守卫 | AC-56~57 | 引用存在性自动断言；场景删除测试红灯 |
| **回归** | AC-R1~R3 | 46 场景加载行为不变；无课时 sim 首页不变；InquiryDrawer 不传参行为不变 |

---

## 6. 硬约束与兼容性承诺

| # | 约束 |
|---|------|
| C-R1 | 方案 B 形态：独立顶层引用式资产 |
| C-R2 | 46 存量场景 + 8 manifest **零改动**，剧本/独立模式共存 |
| C-R3 | 走 ScenarioManager 加载体系，`loadScenario(id)` 零改动复用 |
| C-R4 | AI 可生成化三件套完整（schema + prompt + generate 模式） |
| C-R5 | 禁作者侧编排 UI；运行时仅学生侧三件 |
| C-R6 | 试点 sim 限定 circuit + color_vision |
| C-R7 | 条件树复用 SuccessCondition 契约 + 封闭枚举叶子（不做自由 DSL） |
| C-R8 | fail loud + 课时级降级 |

**零触碰清单**：46 场景 JSON · 8 份 manifest · 8 份 sim schema · ScenarioManagerBase 源码 · SuccessCondition 源码 · 无课时 sim 的全部行为。

---

## 7. 工作量、排期与前置

| Phase | 内容 | 人天 | 前置 |
|-------|------|------|------|
| P1 线性编排 | F1-F7 | 5 | req-criteria-composable 收尾（API 已锁定，仅流程） |
| P2 条件编排 | F8-F12 | 4 | P1 |
| P3 AI 链路 | F13-F16 | 3 | P2（需示例剧本作样本） |
| **核心合计** | | **12**（置信度中——不确定性在范围决策而非技术，挂点全部实证） | |

- P4 B 类 4 sim 接线（+3~4）/ P5 进度持久化（+2~3）：**独立决策，不在本需求**
- 主风险：R2 fuse-blorn 保险丝初始态未回源 → T-P1-12 首步实测，两预案均为纯 JSON 调整零代码

---

## 8. 流程状态

- `req-lesson-scripting`（评估需求）：verdict=go 已留痕（AC10 达成），待收尾
- `req-lesson-runtime`（本需求，deep-vibe）：阶段 2.design——技术方案 + 28 任务已产出，**待方案评审（本项目无 design-reviewer，建议 code-reviewer 代行）→ 通过后进 3.coding**

## 9. 文档地图

| 文档 | 位置 | 内容 |
|------|------|------|
| 评估需求文档 | `req-lesson-scripting/spec/需求文档.md` | 评估范围定义（E1-E6 / AC1-AC10） |
| 评估报告 | `req-lesson-scripting/spec/评估报告.md` | 三方案对比 / PoC / 估算 / 前置（verdict 依据） |
| 实现需求文档 | `req-lesson-runtime/spec/需求文档.md` | 实现合同：F1-F16 详述 + 60 AC 完整定义 |
| 技术方案 | `req-lesson-runtime/design/技术方案.md` | 类与接口设计 / 数据流 / UI 契约 / 测试计划 / D1-D8 决策 |
| 任务清单 | `req-lesson-runtime/tasks/features.json` | 29 任务 × AC 映射 × 依赖 × 验证方式 |
| 交互与操作流程 | `req-lesson-runtime/交互与操作流程.md` | 学生侧操作流 + 老师侧创作流（手写/AI）+ 设计约束 |
