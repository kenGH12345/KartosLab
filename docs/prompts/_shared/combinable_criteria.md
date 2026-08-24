# 附录：successCriteria 组合算子（可选）

> **单一源文件**。本段由 `scripts/ai_scenario_gen/generate.py` 在组装 system prompt 时
> 自动拼接到每个 `docs/prompts/<sim>_scenario.md` 之后——**不要把内容复制进各 sim 的
> prompt**，否则会产生 8 份副本漂移。
>
> 契约权威源：`lib/common/scenario/success_condition.dart`（Dart model）
> 与各 `schemas/<sim>_scenario.schema.json` 的 `definitions.criterion`。

`successCriteria` 数组的每一项除平铺叶子（`{id, type, description, params}`）外，
还可以是**组合条件**，表达平铺格式无法覆盖的判定逻辑（否定 / 或 / 分组）：

| 键 | 语义 | 值 |
|---|---|---|
| `all` | 全部子条件满足（且） | 非空子条件数组 |
| `any` | 任一子条件满足（或） | 非空子条件数组 |
| `not` | 子条件取反（非） | 单个子条件对象 |

组合节点的 `id`/`description` 可选（供 UI 提示）；子条件可以是叶子，也可以继续嵌套组合。

## 使用规则

- **默认用平铺叶子**——仅在平铺表达不了时才用组合。典型场景：
  - 否定语义：「溶液**不得**饱和」「**未**使用提示完成」
  - 或语义：「两条操作路径任一达成」
  - 分组语义：「A 成立 且（B 或 C）」
- 嵌套深度 ≤ **4 层**（解析端硬上限，超深直接 FormatException → 场景被拒载）。
- 叶子与组合键**互斥**：同一对象里 `type` 不能与 `all`/`any`/`not` 共存。
- `all`/`any` 数组不能为空。
- 顶层 `successCriteria` 数组本身的语义仍是「全部满足」（与平铺行为一致）。

## 示例：浓度达标且不得饱和（平铺无法表达的 not）

```json
"successCriteria": [
  {
    "id": "g-1",
    "description": "浓度精确回到 0.45 M 且无沉淀",
    "all": [
      { "id": "sc-1", "type": "concentrationReached", "description": "浓度达到 0.45 M",
        "params": { "targetConcentration": 0.45, "tolerance": 0.01 } },
      { "id": "sc-2", "description": "溶液不得饱和",
        "not": { "id": "sc-2n", "type": "solutionSaturated", "description": "溶液饱和", "params": {} } }
    ]
  }
]
```

（示例中的 `type` 名与 `params` 字段以各 sim 的枚举表为准。）

## 自查清单

- [ ] 仅在平铺表达不了时使用组合算子（默认平铺）
- [ ] 嵌套深度 ≤ 4 层
- [ ] 叶子对象不含 `all`/`any`/`not` 键；组合对象不含 `type` 键
- [ ] `all`/`any` 数组非空
- [ ] 组合内的叶子 `type` 仍是本 sim 合法枚举值
