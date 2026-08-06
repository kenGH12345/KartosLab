# EDD 模板 v2.0（Experiment Design Document Template）

> **Template Version**: 2.0
> **覆盖范围**：memory 2q03lm2g §4.6.7 原 8 章 + 项目四原则补 4 章 = **12 章**
> **消费者**：product-manager / tech-leader / 主会话
> **强制规则**：每个 sim 的完整 EDD 必须覆盖 §1-§12 全章节 · 每章"必答项"不可跳过
> **实例参照**：`edd/color-vision-EDD.md`（首个 v2.0 完整 EDD · 10 章已覆盖 · §11/§12 待 retro 补）
> **触发条件**：`20-verify-before-act.mdc` 信心阈值 —— spec 阶段如未读此模板 → 信心 < 70% → 必须停
> **版本历史**：v1.0（memory 2q03lm2g §4.6.7 原始 8 章 · EGPLab 沉淀）→ v2.0（2026-07-24 · phet-java-simulations 项目补 §9-§12 · 闭合四原则覆盖）

---

## 模板版本与演进路径

### 当前版本（v2.0）章节总览

| 章 | 名称 | 来源 | 必答项数 | Gate 映射 |
|---|---:|---|:---:|:---:|
| §1 | 实验概览 | v1.0 原 | 3 项 | — |
| §2 | 元件清单（Q1.A + Q1.B） | v1.0 原 | 3 表 | C27（元件唯一性） |
| §3 | 参数联动声明（Q5） | v1.0 原 | 2 表 + 联动图 | C30/D23（Intrinsic vs Derived） |
| §4 | 元件交互与状态机（Q3 + Q4） | v1.0 原 | 规则表 + 状态机图 | C28（相互作用完备） |
| §5 | 实验流程与教学脚本（Q6 + Q7） | v1.0 原 | 目标表 + 脚本表 | C29（教学目标可达） |
| §6 | 预期现象声明（Q8 · 必答） | v1.0 原 | 现象表 + 无声明段 + 边界段 | C31（Q8 必答） |
| §7 | 学生交互操作（Q9 · 必答） | v1.0 原 | 交互表 + 无操作段 | C32（Q9 必答） |
| §8 | 实验改造与扩展（Q10） | v1.0 原 | 5 子节 | D26/D27（Q10 完备） |
| **§9** | **可配置化声明** | **v2.0 新增** | **6 项** | 项目四原则第 4 条 |
| **§10** | **AI 可生成化声明** | **v2.0 新增** | **5 项** | 项目四原则加成 |
| **§11** | **通用化组件清单** | **v2.0 新增** | **4 项** | 项目四原则第 3 条（3-Time Rule） |
| **§12** | **质量属性声明** | **v2.0 新增** | **5 项** | 可测试性 / 性能 / i18n |

### 向 v3.0（C 演进）的准备

当前 v2.0 是"文件级模板" · v3.0 的目标是"agent 级强制"：

| 演进阶段 | 模板消费方式 | 触发条件 |
|---|---|---|
| **v2.0（当前）** | 主会话在 ANALYSE/PRODUCT 阶段手工读此文件并逐章填 | 人工纪律 · 4 个 sim EDD 产出已验证可行性 |
| **v2.1（中期）** | `product-manager` agent prompt 追加"启动时必读 `edd-template.md`"段落 · 自动检测 EDD 是否漏章 | 4 个 sim EDD 全完成 + ≥ 2 次"漏章"实证 → 触发 40-agent-self-evolution 协议 |
| **v3.0（长期）** | product-manager 与 tech-leader 的 agent prompt 内嵌 12 章强制清单 · 漏章 = block 进入 design 阶段 | v2.1 跑通 → 正式改 agent |

**v2.0 为 C 演进预留的接口**：
- 每章有固定的 Markdown 二/三级标题（如 `## §9 · 可配置化声明`）· agent 可通过 `grep "^## §[0-9]"` 自动检测完整性
- 每章有 `### X.X 必答项清单（DoD）` 子节 · 用 `- [ ]` 勾选框格式 · agent 可 grep 统计通/未通
- `meta.yaml` 引入 `edd_template_version: v2.0` 字段 · 让 audit 脚本可检测"这个需求用的哪个模板版本"

---

## §1 · 实验概览（Experiment Overview）

### 1.1 必答项清单（DoD）

- [ ] 学科与知识点定位表（学科 / 主题 / 课标关联 / 典型学段 / 学习时长）
- [ ] 子屏结构表（每屏的中文名 / 蓝本类 / 教学重点 / 元件数量）
- [ ] 教学目标表（Bloom 认知层次 × 具体目标，覆盖记忆→评价 ≥ 4 层）

### 1.2 模板

```markdown
### 1.1 学科与知识点定位

| 项 | 值 |
|---|---|
| **学科** | <填入> |
| **主题** | <填入> |
| **课标关联** | <填入 · 如"义务教育《物理课程标准》光现象主题"> |
| **典型学段** | <填入> |
| **学习时长（单次）** | <填入> |

### 1.2 子屏结构（如有≥2屏）

| 子屏 | 蓝本类 | 教学重点 | 元件数量 |
|---|---|---|---|
| **子屏 1 · <名称>** | `<SourceFile>.java` (. KB) | <一句话> | <N> |

### 1.3 教学目标（Bloom 认知层次映射）

| 层次 | 目标 |
|---|---|
| **记忆** | <目标> |
| **理解** | <目标> |
| **应用** | <目标> |
| **分析** | <目标> |
| **评价** | <目标> |
```

---

## §2 · 元件清单（Component Inventory · Q1.A + Q1.B）

### 2.1 必答项清单（DoD）

- [ ] 核心物理元件表（元件名 / 蓝本类 / 职责 / 物理对应物）
- [ ] 辅助表征概念元件表（概念 / 蓝本类 / 说明）
- [ ] 复用与省略清单表（类 / Flutter 复刻策略）

### 2.2 Gate 要求

C27（元件唯一性）：每类物理元件只能出现一次 · 无功能重复 · 派生元件必须标明派生源

### 2.3 模板

```markdown
### 2.1 核心物理元件（Q1.A）

| # | 元件 | 蓝本类 | 职责 | 物理对应物 |
|---|---|---|---|---|
| C1 | **<名称>** | `<SourceFile>.java` (.K) | <一句话> | <学生容易联想到的实物> |

### 2.2 辅助表征概念元件（Q1.B）

| # | 概念 | 蓝本类 | 说明 |
|---|---|---|---|
| A1 | **<名称>** | `<SourceFile>.java` | <非物理实体的教学表征意图> |

### 2.3 复用与省略清单

| 类 | Flutter 复刻策略 |
|---|---|
| <Java 类名> | ✅ 保留 / ❌ 替代 / 🟡 部分复用（<策略>） |
```

---

## §3 · 参数联动声明（Parameter Coupling · Q5）

### 3.1 必答项清单（DoD）

- [ ] Intrinsic 参数表（元件 / 参数名 / 类型 / 范围 / 默认值 / 控件）
- [ ] Derived 参数表（派生量 / 由何计算 / 公式 / 严禁作为独立字段）
- [ ] 参数联动图（Mermaid `graph LR` 或文字描述等价）

### 3.2 Gate 要求

C30/D23（Intrinsic vs Derived）：
- Intrinsic = 物质常数或独立可调（学生可操作）
- Derived = 由 Intrinsic 计算得出（必须标注公式 · 严禁在 Component 中存储为独立字段）
- 判定方法（memory 2q03lm2g §3.5）："如果改变 Intrinsic_A 会导致这个值变化 → Derived"

### 3.3 模板

```markdown
### 3.1 Intrinsic 参数（学生可直接调）

| # | 元件 | 参数 | 类型 | 单位/范围 | 默认值 | 控件 |
|---|---|---|---|---|---|---|
| P1 | <元件名> | `<paramName>` | Intrinsic | <范围> | <值> | <UI 组件名> |

### 3.2 Derived 参数（由 Intrinsic 计算得出）

| # | 派生量 | 由何计算 | 公式 | 蓝本证据 |
|---|---|---|---|---|
| D1 | `<derivedName>` | <依赖的 Intrinsic 参数列表> | `<公式或伪代码>` | `<SourceFile>.java:<line>` |

### 3.3 参数联动图

\`\`\`mermaid
graph LR
    P1[<元件.参数>]
    P2[<元件.参数>]
    P1 --> D1[<派生量>]
    P2 --> D1
    D1 --> Output[<最终效果>]
\`\`\`
```

---

## §4 · 元件交互与状态机（Component Interaction · Q3 + Q4）

### 4.1 必答项清单（DoD）

- [ ] 空间关系描述（每子屏一个拓扑段落或 ASCII 图）
- [ ] 相互作用规则表（规则编号 / 条件 / 触发方式 / 处理逻辑 / 蓝本证据）
- [ ] 关键元件的状态机图（Mermaid `stateDiagram-v2` 或等价文字）

### 4.2 Gate 要求

C28（相互作用完备）：规则表必须覆盖所有元件间的所有可能交互 · 不允许 "A 碰 B 没定义"

### 4.3 模板

```markdown
### 4.1 空间关系（Q3）

**<子屏名称> 拓扑**：
\`\`\`
[元件A] (<x>, <y>) ─→ [元件B] (<x>, <y>) ─→ [元件C] (<x>, <y>)
\`\`\`

### 4.2 相互作用规则（Q4）

| 规则 | 条件 | 触发方式 | 处理逻辑 | 蓝本证据 |
|---|---|---|---|---|
| R1 | <条件> | <谁触发> | <核心逻辑 · 可含伪代码> | `<file>.java:<line>` |

### 4.3 <关键元件> 状态机

\`\`\`mermaid
stateDiagram-v2
    [*] --> StateA
    StateA --> StateB: <condition>
    StateB --> StateA: <condition>
\`\`\`
```

---

## §5 · 实验流程与教学脚本（Experiment Flow · Q6 + Q7）

### 5.1 必答项清单（DoD）

- [ ] 实验目标问答表（每子屏 ≥ 2 条 Q/A 式学习目标）
- [ ] 推荐教学脚本章节表（步骤号 / 屏 / 操作 / 观察 / 讲授点 · ≥ 6 步）
- [ ] 反直觉现象清单（≥ 2 条 · 附教学价值说明）

### 5.2 Gate 要求

C29（教学目标可达）：所有 Q6 目标必须能通过最多 4 步学生操作触发

### 5.3 模板

```markdown
### 5.1 实验目标（Q6）

**<子屏名> · 学习问答**：
- Q: <问题> → A: <答案>
- Q: <问题> → A: <答案>

### 5.2 推荐教学脚本（Q7）

| 步骤 | 屏 | 操作 | 观察 | 讲授点 |
|---|---|---|---|---|
| 1 | <屏名> | <学生做什么> | <看到什么> | <老师讲什么> |

### 5.3 反直觉现象清单

1. <现象描述>（学生常预测 X · 实际是 Y）
2. <现象描述>
```

---

## §6 · 预期现象声明（Phenomena Declaration · Q8 · 必答）

### 6.1 必答项清单（DoD）

- [ ] 有现象的视觉/听觉/触觉声明表（现象编号 / 触发条件 / 表征 / 蓝本证据）
- [ ] **无现象声明段**（如无声/无温度/无力学 · 必须显式写出，不可省略）
- [ ] 特殊边界现象段（至少 1 条 · 如 intensity=0 时的残影处理策略）

### 6.2 Gate 要求

C31（Q8 必答）：即便结论为"无特殊现象"，也必须有一行声明 · 不可留空

### 6.3 模板

```markdown
### 6.1 视觉/听觉/触觉现象

| # | 现象 | 触发条件 | 表征 | 蓝本证据 |
|---|---|---|---|---|
| Ph1 | <描述> | <条件> | <视觉/听觉表现> | `<file>.java:<line>` |

### 6.2 无声/无温度/无力学现象

- ❌ 无声音效
- ❌ 无温度变化
- ❌ 无<其他不建模的物理效果>

### 6.3 特殊边界现象

- <边界条件>：<行为描述> · 蓝本 `<file>.java:<line>`
```

---

## §7 · 学生交互操作（Student Interactions · Q9 · 必答）

### 7.1 必答项清单（DoD）

- [ ] 交互清单表（每子屏一张 · 交互编号 / 触发 UI / 后端反应 / 教学价值）
- [ ] **无操作场景段**（哪些看起来应该能操作但不行的 · 附理由）
- [ ] 交互引导段（首次进入的 WiggleMe 或 tutorial 策略）

### 7.2 Gate 要求

C32（Q9 必答）：交互列表必须覆盖所有可调 Intrinsic 参数 · 0 个可调参数也应显式声明"无"

### 7.3 模板

```markdown
### 7.1 <子屏名> · 交互清单

| # | 交互 | 触发 UI | 后端反应 | 教学价值 |
|---|---|---|---|---|
| I1 | <学生做什么> | <UI 组件名> | <Model 层变化> | <教学意图> |

### 7.2 无操作场景

- ❌ 不允许 <操作>（理由：<如"布局固定，不允许学生移动">）
- ❌ 不允许 <操作>

### 7.3 交互引导（首次进入）

- <引导策略描述 · 如 WiggleMe 位置/触发条件>
```

---

## §8 · 实验改造与扩展（Adaptation & Organization · Q10）

### 8.1 必答项清单（DoD）

- [ ] 学科正确性矩阵（维度 / 正确性 ✅ 🟡 ❌ / 说明）
- [ ] 复刻改进机会表（≥ 3 条 · 含复杂度评估）
- [ ] 与其他 sim 的组织关系表
- [ ] EGPSpace 合规性声明（如涉及实体位移 · 描述/渲染分离）
- [ ] 元件化绘制合规性声明（Canvas 按物理元件分发）

### 8.2 Gate 要求

D26/D27（Q10 完备）：学科正确性矩阵必须有 ≥ 5 行 · 组织关系 ≥ 2 sim

### 8.3 模板

```markdown
### 8.1 学科正确性矩阵

| 维度 | 正确性 | 说明 |
|---|---|---|
| <维度名> | ✅ / 🟡 / ❌ | <一句话说明 · 若为 🟡 或 ❌ 需附教学简化理由> |

### 8.2 复刻改进机会

| # | 改进点 | 原因 | 复杂度 |
|---|---|---|---|
| M1 | <描述> | <理由> | 低/中/高 |

### 8.3 与其他 sim 的组织关系

| 相邻 sim | 关系 |
|---|---|
| <sim 名> | <关系描述> |

### 8.4 EGPSpace 合规性声明

⚠️ / ✅ / ❌ <结论> · <说明>

### 8.5 元件化绘制合规性声明

✅ / ⚠️ <结论> · <说明>

\`\`\`
lib/<sim>/
├── model/      (<模型 · 纯数据 · extends ChangeNotifier)
├── view/
│   ├── screens/    (<Screen · Widget 组合)
│   ├── painters/   (<CustomPainter · 一元件一 Painter)
│   └── widgets/    (<可复用 Widget)
└── controller/  (<整合 model tick + notify)
\`\`\`
```

---

## §9 · 可配置化声明（Configuration-Driven · v2.0 新增）

> **来源**：项目 `overview.md:144-150` "第二步必须补一层提取硬编码到 JSON scenario"
> **参照现有**：`c:\workspace\phet\assets\scenarios\{circuit,forces}\` + `docs/prompts/*.md` + `schemas/*.schema.json`

### 9.1 必答项清单（DoD）

- [ ] 配置化边界表（每类参数归属：JSON / 代码 / 两者）
- [ ] scenario 目录结构草案（≥ 3 个 scenario JSON 名 + 意图）
- [ ] scenario JSON 契约骨架（完整的 JSON 示例 · 不是伪代码）
- [ ] ScenarioManagerBase 对接说明（依赖 P2 债务或独立实现）
- [ ] 配置化验收标准（≥ 5 条 · 含 schema 校验 / UI 驱动 / 降级策略）
- [ ] `paramRanges` 段（含 min/max/step/unit · 对齐 `w0-3-property-control-draft.md` 的 `PropertyControlPanel.fromScenarioParams`）

### 9.2 配置化边界判定规则

| 类别 | 归属 | 判定依据 |
|---|---|---|
| **物理常数** | 🔒 代码硬编码 | 不因教学需求变化 · 如光速、光子步长、万有引力常数 |
| **元件初始状态** | ✅ JSON | 学生/教师希望从不同起点开始 |
| **元件可调范围** | ✅ JSON | 不同教学阶段可能需要收窄或放宽滑条范围 |
| **场景布局** | ✅ JSON | 不同实验可能需要元件在不同位置 |
| **教学目标** | ✅ JSON | successCriteria/hints · 每场景不同 |
| **算法流程** | 🔒 代码 | 物理正确性不可通过 JSON 改（如积分方式、碰撞检测） |
| **性能调优** | 🟡 代码常量 + JSON 覆盖 | 默认在代码 · JSON 可覆盖（如粒子池大小） |

### 9.3 模板

```markdown
### 9.1 配置化边界表

| 类别 | 归属 | 说明 |
|---|---|---|
| <参数分类> | ✅ JSON / 🔒 代码 / 🟡 代码+JSON | <理由> |

### 9.2 提议的 scenario 目录结构

\`\`\`
assets/scenarios/<sim>/
├── manifest.json
├── default.json              # 默认场景 · 学生自由探索
├── <scenario-id-1>.json       # <教学意图>
├── <scenario-id-2>.json       # <教学意图>
└── <scenario-id-n>.json       # ≥ 3 个
\`\`\`

### 9.3 scenario JSON 契约骨架

\`\`\`jsonc
{
  "scenarioId": "<unique-id>",
  "name": "<中文名>",
  "description": "<一句话教学意图>",
  "screen": "<screenEnum>",
  "initialParams": {
    // 对齐 EDD §3.1 的 Intrinsic 参数 · 每个参数一个键
  },
  "paramRanges": {
    // 对齐 EDD §3.1 的控件范围 · 含 min/max/step/unit
  },
  "successCriteria": [
    // 对齐 EDD §5.1 Q6 目标 · type + params 驱动
  ],
  "hints": [
    // 对齐 EDD §5.2 教学脚本 · trigger + message
  ]
}
\`\`\`

### 9.4 ScenarioManagerBase 对接

- 依赖：`req-refactor-scenario-manager-common`（P2 债务 · shared-abstraction-plan.md）
- Dart 模型类：`lib/<sim>/config/<sim>_scenario.dart`
- 加载器：`lib/<sim>/config/<sim>_scenario_manager.dart extends ScenarioManagerBase`

### 9.5 配置化验收标准（DoD）

- [ ] `assets/scenarios/<sim>/manifest.json` 存在 · ≥ 3 scenario
- [ ] `schemas/<sim>_scenario.schema.json` 存在 · CI 校验通过
- [ ] `lib/<sim>/config/<sim>_scenario.dart` fromJson/toJson 单测覆盖
- [ ] UI 右侧参数面板通过 `PropertyControlPanel.fromScenarioParams` 生成
- [ ] 场景切换后 · 元件位置/初值/可调范围全按 JSON 生效
- [ ] 加载失败降级为 default 场景（不 crash）
```

---

## §10 · AI 可生成化声明（AI-Generatable · v2.0 新增）

> **来源**：项目 `overview.md` "AI 可生成"
> **参照现有**：`docs/prompts/{circuit,forces,optics}_scenario.md`
> **原则**：schema 完备的 sim 必须产出可让 LLM 直接读来生成新场景的 prompt 文档

### 10.1 必答项清单（DoD）

- [ ] AI 生成友好度评分矩阵（≥ 5 个维度 × ⭐评级）
- [ ] prompt 文档骨架（≥ 8 段 · 含 Role/Model/Screen/Constants/FewShot/Criteria/Constraints/Validation）
- [ ] AI 生成能力矩阵（≥ 4 类场景 × 输入示例 × 期待输出）
- [ ] 三层校验策略声明（Schema / 物理约束 / 教学有效性）
- [ ] AI 可生成化验收标准（≥ 4 条 · 含真实 LLM 回归测试）

### 10.2 AI 生成友好度评分维度

每个 sim 必须自评以下维度：

| 维度 | 满分条件 | 减分因素 |
|---|---|---|
| **元件类型少** | ≤ 5 类物理元件 | 元件多 + 组合爆炸 |
| **参数值离散** | 参数值域是有限枚举或小步长 | 连续参数 + 任意精度 |
| **教学目标可枚举** | successCriteria 有限种 type | 目标开放 + 无客观判据 |
| **反直觉现象丰富** | ≥ 3 个经典陷阱 | 无反常 → 无生成价值 |
| **无时序编排** | 场景是静态初值 + 学生调节 | 需要时间轴/节拍/动画编排 |
| **物理边界明确** | schema + criteria 双约束 | 边界模糊 → AI 易越界 |

### 10.3 模板

```markdown
### 10.1 为什么本 sim 适合/不适合 AI 生成

| 维度 | 评分 | 说明 |
|---|---|---|
| **元件类型少** | ⭐⭐⭐⭐⭐ | <N 类 · 说明> |
| <继续其他 5 个维度> | ... | ... |

**综合评估**：<一句话 · 如"4 个待复刻 sim 中 AI 生成成本最低">

### 10.2 提议的 AI 生成 prompt 骨架

1. **Role Definition** · "You are a <sim> experiment designer..."
2. **Model Overview** · 参数表（对齐 EDD §3.1）+ 元件表（对齐 EDD §2.1）
3. **Screen Modes** · 子屏差异表 + 屏枚举值
4. **Physical Constants**（AI 不得改）· 光速/步长/白哨兵/边界
5. **Few-Shot Examples** · ≥ 3 例（教学/反直觉/挑战）
6. **successCriteria Types** · type 枚举 + params 契约
7. **Constraint Types** · type 枚举 + params 契约
8. **Output Format** · Only JSON · `schemas/<sim>_scenario.schema.json`
9. **Validation Checklist** · ≥ 6 条（schema + 语义混合）

### 10.3 提议的 AI 生成能力矩阵

| 分类 | AI 生成任务 | 输入示例 | 期待输出 |
|---|---|---|---|
| C1 · 基础演示 | <描述> | <教师提示> | <JSON 特征> |
| C2 · 反直觉挑战 | <描述> | <教师提示> | <JSON 特征> |
| C3 · 探索序列 | <描述> | <参数列表> | <JSON 特征> |
| C4 · 综合教案 | <描述> | <学段/时长> | <manifest + N 个 JSON> |

### 10.4 三层校验策略

1. **Schema 校验**（机械）· JSON 通过 `schemas/<sim>_scenario.schema.json`
2. **物理约束校验**（模型级）· Dart 加载器验证边界规则
3. **教学有效性校验**（人工 / LLM 二审）

### 10.5 AI 可生成化验收标准（DoD）

- [ ] `docs/prompts/<sim>_scenario.md` 存在 · 覆盖完整 9 段
- [ ] ≥ 3 个 few-shot examples
- [ ] `AI 不可修改` 常数清单明确列出
- [ ] Validation Checklist ≥ 6 条
- [ ] 真实测试：LLM 生成 ≥ 5 个新 scenario · 100% schema 通过
```

---

## §11 · 通用化组件清单（Common Abstraction Checklist · v2.0 新增）

> **来源**：项目四原则第 3 条（通用化）· `shared-abstraction-plan.md`
> **原则**：每个 sim 的 EDD 必须显式声明 3 类组件——从 common 复用的 / 待抽到 common 的 / 保留 sim 专属的

### 11.1 必答项清单（DoD）

- [ ] **复用自 common** 表（组件名 / 来源路径 / 必用/可选 / 理由）
- [ ] **待抽出候选表**（组件名 / 当前 sim 内路径 / 3-Time Rule 触发条件 / 评估）
- [ ] **sim 专属保留表**（组件名 / 保留理由 / 违反了哪条抽象原则）
- [ ] 与 `shared-abstraction-plan.md` 的联动引用

### 11.2 3-Time Rule 触发判定

同一组件跨 ≥ 3 个 sim 出现 → 触发抽象到 `lib/common/`：
- 本 sim = 第 1 使用者 → 先在本 sim 造 · 标记"待第 2/3 使用者出现时评估"
- 本 sim = 第 2 使用者 → 比较与第 1 使用者的相似度 · ≥ 70% 则改造第 1 使用者为公共版
- 本 sim = 第 3 使用者 → 强触发 · 必须上抽

### 11.3 模板

```markdown
### 11.1 复用自 lib/common/ 的组件

| 组件 | 来源路径 | 必用/可选 | 理由 |
|---|---|---|---|
| `<组件名>` | `lib/common/<path>` | 必用 / 可选 | <说明> |

### 11.2 待抽出候选（3-Time Rule 监控）

| 组件 | 当前路径 | 使用者计数 | 触发条件 | 评估 |
|---|---|---|---|---|
| `<名>` | `lib/<sim>/<path>` | N/3 | 等第 N+1 个使用者出现 | 预留 / 强触发 / 已触发 |

### 11.3 sim 专属保留

| 组件 | 保留理由 | 违反的抽象原则 |
|---|---|---|
| `<名>` | <为什么不能/不该上抽> | <如"特有物理算法 · L2 不抽象"> |

### 11.4 与 shared-abstraction-plan.md 联动

- 本 sim 涉及的 L0 层（已存在通用层）：<列表>
- 本 sim 涉及的 L1 层（候选抽象）：<列表 + 触发计数>
- 本 sim 涉及的 L2 层（明确不抽象）：<列表>
```

---

## §12 · 质量属性声明（Quality Attributes · v2.0 新增）

> **来源**：项目四原则的横向工程质量需求（可测试性/性能/i18n/无障碍）
> **为什么纳入 EDD**：这些应在设计阶段声明 · 而不是 CODE 阶段临时补救

### 12.1 必答项清单（DoD）

- [ ] 单测/widget test/golden test 覆盖率目标 + 关键被测类清单
- [ ] 帧率目标（目标 fps / 每帧预算 ms / 劣化场景枚举 / 池子上限）
- [ ] 状态持久化策略（场景切换时保留什么 / App 重启恢复什么 / 用什么存储）
- [ ] i18n 键位规划（哪些文本进 .arb / 预估键数量 / 多语言优先级）
- [ ] 可访问性声明（色盲替代表征 / 屏幕阅读器 / 触控目标大小 · 如涉及视觉实验必须回答）

### 12.2 模板

```markdown
### 12.1 测试目标

| 测试类型 | 覆盖率目标 | 关键被测类 |
|---|---|---|
| Unit Test | ≥ N% | <列出> |
| Widget Test | ≥ N 个关键 widget | <列出> |
| Golden Test | ≥ N 个状态截图 | <列出> |
| Integration | ≥ N 个完整 scenario 流程 | <列出> |

### 12.2 性能目标

- **目标帧率**：60 fps（16.67 ms/帧）
- **劣化场景枚举**：
  - 场景 1：<条件> · <预算>
  - 场景 2：<条件> · <预算>
- **粒子/元件池上限**：<N>

### 12.3 状态持久化策略

| 场景 | 保留什么 | 存储方式 |
|---|---|---|
| 子屏切换 | <列表> | <方案> |
| App 重启 | <列表> | <方案> |
| Scenario 切换 | <列表> | <方案> |

### 12.4 i18n 键位规划

- 预估键数量：<N>
- 文本来源：蓝本 `ColorVisionStrings.java`（如有）→ Dart `.arb`
- 多语言优先级：zh_CN > en_US > <其他>

### 12.5 可访问性声明

- 色盲替代表征：<方案 · 如"色觉实验需额外提供波长数值作为替代表征">
- 屏幕阅读器：<策略>
- 触控目标：≥ 48×48 dp（Material 规范）
```

---

## 附录 T · 模板使用指南（给 Agent 和主会话）

### 哪些 Agent 必须读此模板

| Agent | 阶段 | 什么时候读 | 读后产什么 |
|---|---|---|---|
| **product-manager** | phase 2.requirement | 需求澄清 → 出 spec 前 | spec 中嵌 EDD 骨架（至少填 §1/§2/§5 primitive） |
| **tech-leader** | phase 3.design | design 文档产出前 | design 中引用此 EDD · 确保 §3/§4/§8 技术可行 |
| **主会话** | phase 1.intake 或手动深读 | 决定"是否新 sim 需要 EDD"时 | 直接读 `edd-template.md` · 逐章填 |

### 主会话执行 EDD 时的操作顺序

1. `read_file edd-template.md` · 确认 12 章结构
2. `read_file 4-sim-lightweight-EDD-index.md` · 确认轻量索引中已有的 Q1-Q6
3. 深读 Java 蓝本 Model 类（至少读完所有 model/*.java）
4. 写 `edd/<sim>-EDD.md` · 按 12 章顺序填充
5. 写完后自查：grep `- [ ]` 统计未勾选必答项 → 为 0 才可提交

### 如何 grep 检测 EDD 完整性

```bash
# 检查 12 章标题是否存在
grep -c "^## §[0-9]" edd/<sim>-EDD.md
# 应输出: 12 (或 10 如果 §11/§12 待补)

# 检查必答项是否全部勾选
grep -c "\[ \]" edd/<sim>-EDD.md
# 应输出: 0（全部已填 [x]）
```

### v2.0 → v3.0（C 演进）的路标

当以下条件全部满足时，触发 C 演进（走 40-agent-self-evolution 协议）：

- [ ] 4 个 sim 的完整 EDD（含 §9-§12）全部产出
- [ ] ≥ 2 次"主会话遗漏 §9/§10/§11/§12"的实证记录在 process.txt
- [ ] `edd-template.md` 的 §11/§12 已被 ≥ 2 个 sim 验证实用
- [ ] phet-java-simulations 项目进入稳定期（不再有新 sim 立项）

届时操作：
1. 触发 40 协议改 `product-manager` agent · 在 prompt 追加"启动时必读 `edd-template.md`"段落
2. 同步改 `tech-leader` agent · 追加"design 阶段用 edd-template §3/§4/§8/§12 审查"
3. 补充 `edd-template.md` 的版本号到 v3.0

---

## 变更历史

> 2026-07-24 by 主对话（用户追问"为什么会漏掉配置化/AI 生成化 · 是否写入规则"）：
> 模板 v2.0 初版。扩原 8 章为 12 章，闭合项目四原则覆盖。
> - 新增 §9 可配置化 / §10 AI 可生成化 / §11 通用化组件清单 / §12 质量属性声明
> - 每章含必答项清单（DoD）+ Gate 映射 + Markdown 模板
> - 触发原因：color-vision EDD 遗漏 §9/§10 → 诊断"EDD 模板只覆盖物理/教学 · 未覆盖工程四原则"
> - 附录 T：Agent 消费指南 + grep 完整性自检 + v2.0→v3.0 路标
> - 用户选 B + 逐步向 C 演进 → 模板内嵌接口（固定标题格式 + meta.yaml edd_template_version 字段）
