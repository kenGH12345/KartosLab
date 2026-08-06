---
name: visual-doc-generator
description: 用于在需求/方案/知识库文档中生成结构化可视化片段——架构图、流程图、时序图、状态机、ER 图——统一用 mermaid。被 product-manager / tech-leader / leaders / knowledge-maintainer agents 调用。
tools: Read, Write, Edit
---

# visual-doc-generator

> 「一图胜千言」对 AI 阅读上下文同样成立。结构化的 mermaid 图比 200 字描述更容易让下游 agent 理解。
> 这个 Skill 把 6 类常用图的模板与边界固化下来。

## 何时使用

- ✅ 需求文档要表达"模块边界 + 调用关系"
- ✅ 方案文档要表达"流程时序 / 状态机 / 数据模型"
- ✅ 评审文档要表达"协议字段对照"
- ✅ 知识库要表达"系统架构总览"
- ❌ 一句话能说清的内容：不必加图（反而增加噪音）
- ❌ 需要交互/动画：mermaid 不行，跳过

## 输入

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| diagram_type | enum | ✓ | `flowchart` / `sequence` / `state` / `class` / `er` / `gantt` |
| target_doc | path | ✓ | 要插入图的文件路径 |
| insert_position | string | ✓ | 段落标题或行号锚点 |
| nodes | array | ✓ | 节点/参与者数据 |
| edges | array | 部分必需 | 边/调用关系（flowchart / sequence 必填） |

## 步骤

### 1. 选择图类型

| 想表达 | 用 |
|---|---|
| 模块/服务/数据流 | `flowchart` |
| 跨服务/角色调用顺序 | `sequence` |
| 业务对象的状态转移 | `state` |
| 数据模型/类关系 | `class` 或 `er` |
| 数据库表关系 | `er` |
| 时间排期 | `gantt` |

### 2. 按模板生成 mermaid 代码块

使用 `references/mermaid-templates.md` 的 6 类模板，按 nodes / edges 填充。

### 3. 插入到目标文档

```
1. Read target_doc
2. 定位 insert_position（标题 anchor 或行号）
3. 在该位置插入 ```mermaid ... ``` 代码块
4. 用 Edit 工具应用
```

### 4. 校验语法

> mermaid 语法错误会让整个文档在 GitHub / VSCode 渲染失败。

校验清单：
- 节点 ID 不含空格（用 `node1` 不用 `node 1`）
- 节点 label 用引号包裹（`A["My Label"]`）
- 中文 label 必须用引号
- sequence 的参与者声明在最前
- state 的 `[*]` 表示起点/终点

如有疑问，先在内部"试渲染"——按 mermaid 语法手动 trace 一遍。

### 5. 不画图的边界

如属以下情况，stop + report 让调用方决定是否要图：

- nodes ≤ 2 → 一句话能说清
- edges 关系混乱（出现 5 个以上交叉）→ 应拆成多个子图
- 需要表达"如果 X 则 Y" 的复杂条件 → 用文字 + 简化图

## 输出

```md
## visual-doc-generator 执行结果
- 状态: completed / partial（mermaid 语法可能有问题）/ aborted
- 目标文档: <path>
- 插入位置: <section>
- 图类型: <type>
- 节点数: N / 边数: M
- 提示: 在 GitHub / VSCode 中验证渲染效果
```

## 边界与陷阱

> [!WARNING]
> **不**为了"看起来专业"硬塞图。空洞的图比文字更糟糕。

> [!IMPORTANT]
> 图与文字必须**同步**。如果文字描述与图不一致，下游 agent 会困惑该信谁。

- ❌ 不要节点 ID 用中文或带空格
- ❌ 不要 sequence 中遗漏参与者声明
- ❌ 不要嵌套 subgraph 超过 2 层（可读性差）
- ❌ 不要把详细的字段表硬塞进 class/er 图（用 markdown table 反而清晰）
- ❌ 不要修改原文档与图无关的内容
- ✅ 节点用 ASCII id + 中文 label
- ✅ 复杂图拆分为多个子图
- ✅ 图前后留空行（mermaid 代码块前后必须空行才能渲染）

## 引用资料

- [mermaid-templates.md](references/mermaid-templates.md) —— 6 类常用图的可复用模板

## 关联 Skill

- 任何需要生成图的 agent 在准备图前调用本 Skill
- 图生成后由 `docs-index-updater` 同步索引（如新增了图集索引）

## 变更历史

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| - | 0.1.0 | 初始创建 | Phase 3 | template |
