# Lesson Plan（教学剧本）生成 Prompt

> 本 prompt 由 `scripts/ai_scenario_gen/generate.py --lesson` 使用，指导 LLM 生成
> 课时级多场景编排剧本 JSON。剧本**引用既有场景**（`{sim, scenarioId}`），不复制
> 场景数据、不要求生成物理正确的新场景——它是全项目 AI 生成友好度最高的资产。

## 1. 角色与目标

你是 KratosLab 的教学剧本作者。把老师的课时意图（主题、流程、分支条件）编排成
一份**引用既有场景**的多场景剧本 JSON：学生按剧本自动流转走完一节课，支持
「先完成 A 解锁 B」「按预测题得分分流」「完整课时序列」三种编排。

## 2. 结构规范（字段表）

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `lessonId` | string | ✅ | kebab-case 剧本 id（与 manifest entry.id 一致） |
| `name` | string | ✅ | 课时显示名（首页入口卡片用） |
| `version` | string | ✅ | 剧本版本（如 "1.0"） |
| `description` | string | ✅ | 课时教学意图一句话 |
| `entry` | string | ✅ | 入口节点 id（必须存在于 nodes） |
| `nodes` | array | ✅ | 节点数组（≥1，见 3 节） |

每个节点对象字段：

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | string | 节点唯一 id（kebab-case） |
| `title` | string | 节点标题（进度 chips 显示） |
| `scenario` | object\|null | `{"sim": "circuit", "scenarioId": "..."}`。**null = 终点节点**（必须是剧本最后一个节点，且 `advance` 也必须为 null） |
| `unlock` | object\|null | 前置解锁条件树（null = 无门禁）。见 4 节 |
| `advance` | object\|null | 流转指令（null = 终点）。见 3 节 |

## 3. 三种编排原语（advance）

| type | 语义 | 结构 |
|---|---|---|
| `next` | 按 nodes 数组顺序顺延到下一个节点 | `{"type": "next"}`（不能用于数组末位） |
| `onCompleted` | 当前场景达成判定后显式跳转到指定节点 | `{"type": "onCompleted", "to": "<nodeId>"}` |
| `routes` | 按数组序求值各路由条件，首个为 true 的生效；全部 false 走末项兜底 | `{"type": "routes", "routes": [{"to": "...", "when": 条件}, ..., {"to": "...", "when": null}]}` |

路由规则（求值时序注意）：
- **routes 逐项按数组序求值 `when`，首个 true 即生效**（短路，不再看后续项）。
- **末项 `when` 必须为 null**（兜底路由）；其余项 `when` 必须为条件对象。
- 场景完成事件先标记本节点完成、再触发 advance 求值——所以 routes 条件引用
  「本节点已完成」（`nodeCompleted` 指向当前节点）时恒为 true，别这样写。

## 4. 条件树（unlock 与 routes.when）

组合算子 `all` / `any` / `not` 的完整契约见附录 `_shared/combinable_criteria.md`
（generate.py 自动拼接）——**不要在本文件复制该契约正文**。要点：
- 嵌套深度 ≤ 4 层；叶子与组合键互斥；`all`/`any` 数组非空。

剧本专用**叶子枚举**（`params` 契约）：

| type | params | 语义 |
|---|---|---|
| `nodeCompleted` | `{"nodeId": "<nodeId>"}` | 指定节点已完成 |
| `predictionScore` | `{"nodeId": "<nodeId>", "metric": "ratio"\|"count", "operator": "gte"\|"lte"\|"gt"\|"lt"\|"eq", "threshold": <数值>}` | 指定节点预测题得分达标（ratio = 正确数/已验数；未作答/verified=0 时恒 false） |
| `scenarioSuccess` | `{"nodeId": "<nodeId>"}`（可选，缺省 = 运行时当前节点） | 指定节点场景曾达成判定。**unlock 场景请始终显式写 nodeId**（缺省语义在流转后不稳定） |

叶子三件套必填：`id`（唯一）、`type`、`description`。

## 5. 图规则（fail loud 清单）

生成后解析端（Dart `LessonPlan.fromJson`）会全量校验，以下任一违规 → 整份剧本
拒绝加载（课时级降级）。生成时必须避免：

- `entry` 指向不存在的节点；节点 id 重复
- `scenario == null` 但 `advance != null`（终点二元绑定）；`scenario != null` 但 `advance == null`
- `advance.to` / `routes[].to` 指向不存在节点；`routes` 无兜底（末项 when 非 null）
- 条件树叶子 `nodeId` 引用不存在节点；嵌套深度 > 4 层
- 存在从 `entry` 不可达的节点（孤立节点）
- 引用**本 prompt 第 6 节场景清单之外**的 `scenarioId`（场景不存在/不可用于剧本）

## 6. 可用场景清单

以下为本课时可用引用的场景（按 sim 分组）。**只允许引用清单内的 scenarioId**——
清单外的场景要么不存在、要么判定不可完成（引用会导致剧本解析期被拒或学生卡死）。

```
{{SCENARIO_IDS}}
```

> 运行剧本的当前版本仅支持 circuit / color_vision 两个 sim 的运行时宿主
> （其他 sim 的场景即使出现在清单下方，也会在剧本加载时被拒）。

## 7. 示例（few-shot）

### 7.1 线性课时（3 场景顺延）

```json
{
  "lessonId": "circuit-switch-basics",
  "name": "开关与电路诊断",
  "version": "1.0",
  "description": "认识开关控制 → 修复断路 → 观察保险丝保护现象",
  "entry": "n1",
  "nodes": [
    { "id": "n1", "title": "开关控制电路",
      "scenario": { "sim": "circuit", "scenarioId": "controlled-switch" },
      "unlock": null, "advance": { "type": "onCompleted", "to": "n2" } },
    { "id": "n2", "title": "电路诊断挑战",
      "scenario": { "sim": "circuit", "scenarioId": "open-circuit-debug" },
      "unlock": null, "advance": { "type": "onCompleted", "to": "n3" } },
    { "id": "n3", "title": "观察保险丝的保护作用",
      "scenario": { "sim": "circuit", "scenarioId": "fuse-blown" },
      "unlock": null, "advance": { "type": "onCompleted", "to": "n-end" } },
    { "id": "n-end", "title": "课时完成", "scenario": null, "unlock": null, "advance": null }
  ]
}
```

### 7.2 条件课时（预测得分分流 + 前置解锁）

```json
{
  "lessonId": "circuit-ohm-diagnosis",
  "name": "欧姆定律与电路诊断",
  "version": "1.0",
  "description": "欧姆定律探究 → 按预测表现分流挑战/复习 → 汇合观察保险丝保护",
  "entry": "n1",
  "nodes": [
    { "id": "n1", "title": "欧姆定律探究（含预测）",
      "scenario": { "sim": "circuit", "scenarioId": "simple-series" },
      "unlock": null,
      "advance": { "type": "routes", "routes": [
        { "to": "n2-hunt",
          "when": { "id": "g-1", "description": "预测正确率≥50%",
            "type": "predictionScore",
            "params": { "nodeId": "n1", "metric": "ratio", "operator": "gte", "threshold": 0.5 } } },
        { "to": "n2-review", "when": null }
      ] } },
    { "id": "n2-hunt", "title": "电路诊断挑战（表现优秀）",
      "scenario": { "sim": "circuit", "scenarioId": "open-circuit-debug" },
      "unlock": { "id": "u-1", "description": "完成欧姆定律探究",
        "type": "nodeCompleted", "params": { "nodeId": "n1" } },
      "advance": { "type": "onCompleted", "to": "n3" } },
    { "id": "n2-review", "title": "开关控制复习（待巩固）",
      "scenario": { "sim": "circuit", "scenarioId": "controlled-switch" },
      "unlock": { "id": "u-2", "description": "完成欧姆定律探究",
        "type": "nodeCompleted", "params": { "nodeId": "n1" } },
      "advance": { "type": "onCompleted", "to": "n3" } },
    { "id": "n3", "title": "观察保险丝的保护作用",
      "scenario": { "sim": "circuit", "scenarioId": "fuse-blown" },
      "unlock": { "id": "u-3", "description": "完成任一分流节点",
        "any": [
          { "id": "u-3a", "type": "nodeCompleted", "description": "完成挑战线", "params": { "nodeId": "n2-hunt" } },
          { "id": "u-3b", "type": "nodeCompleted", "description": "完成复习线", "params": { "nodeId": "n2-review" } }
        ] },
      "advance": { "type": "onCompleted", "to": "n-end" } },
    { "id": "n-end", "title": "课时完成", "scenario": null, "unlock": null, "advance": null }
  ]
}
```

## 8. 输出要求

- 只输出一个剧本 JSON 对象（`lessonId` 到 `nodes` 完整），不要 prose、不要 markdown 围栏
- `lessonId` 用 kebab-case；节点 id 全局唯一；`unlock`/`advance` 明确写 null 或条件对象（不要省略）
- 引用场景严格限定第 6 节清单；跨 sim 混排（如 circuit→color_vision→circuit）**允许且鼓励**
- 每份剧本必须包含一个 `scenario == null` 的终点节点（课时完成）
