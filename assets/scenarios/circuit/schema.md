# 电路场景 JSON Schema（Step 1a · draft）

> 权威源：`lib/circuit/config/circuit_scenario.dart`  
> 需求：`req-phet-circuit-config-json` Step 1a  
> 版本：1.0

## 顶层结构

```json
{
  "scenarioId": "string · 场景唯一 id",
  "name":       "string · 场景显示名（中文）",
  "description":"string · 场景描述（可空）",
  "version":    "string · schema 版本 · 默认 1.0",
  "initialLayout": { ... }
}
```

## initialLayout 三层拓扑

电路拓扑由 3 个平行数组表达 · 通过 vertex id 关联。

### components[]

```json
{
  "id":            "string · 元件唯一 id",
  "type":          "string · ComponentType.name (battery/resistor/lightBulb/switch/fuse/ground/wire)",
  "x":             "number · logical pixel · 左上角原点",
  "y":             "number",
  "rotation":      "number · 弧度 · 默认 0.0",
  "value":         "number · 元件值（电池 V / 电阻 Ω / 灯泡 Ω / 保险丝 A）· 默认 10.0",
  "isClosed":      "bool · 开关闭合状态 · 默认 true（非开关元件忽略）",
  "startVertexId": "string · 起始端子顶点 id · 必填",
  "endVertexId":   "string · 结束端子顶点 id · 必填"
}
```

### wires[]

```json
{
  "id":            "string · 导线段 id",
  "startVertexId": "string · 起点顶点 id",
  "endVertexId":   "string · 终点顶点 id",
  "controlPoints": [{"x": 100.0, "y": 50.0}, ...]
}
```

### vertices[]

```json
{
  "id":         "string · 顶点唯一 id",
  "x":          "number",
  "y":          "number",
  "isJunction": "bool · 多导线汇合点 · 默认 false",
  "isTerminal": "bool · 元件端子 · 默认 false"
}
```

## 命名约定

| 前缀 | 含义 | 例 |
|---|---|---|
| `c_` | component id | `c_bat1` `c_r1` |
| `w_` | wire id | `w_1` `w_2` |
| `v_` | vertex id | `v_bat1_pos` `v_r1_a` |
| `v_t_` | terminal vertex（元件端子）| `v_t_bat1_pos` |
| `v_j_` | junction vertex（汇合点）| `v_j_1` |

## 拓扑一致性约束（加载时校验 · Step 1b 起）

- 所有 component 的 startVertexId / endVertexId 必须存在于 vertices[]
- 所有 wire 的 startVertexId / endVertexId 必须存在于 vertices[]
- terminal vertex 必须被恰好 1 个 component 引用
- vertex id 全局唯一

## 与光学 scenario 的区别

| 维度 | 光学 LabScenario | 电路 CircuitScenario |
|---|---|---|
| 拓扑层数 | 1 层 · components 平铺 | 3 层 · components + wires + vertices |
| 元件间关系 | 无（光路由光线自然贯穿）| vertex id 连接（导线拓扑）|
| 教学约束 | constraints[] + objectives[] | ⚠️ 不含 · 留 Step 1c |
| 元件规格来源 | inventory 提供 spec | ⚠️ 不含 · 留 Step 1b |

## 变更历史

- 2026-07-20 · Step 1a draft · 5 字段顶层 + 3 层拓扑
