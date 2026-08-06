# Mermaid 模板库

> 6 类常用图的可复用模板。`visual-doc-generator` Skill 按 nodes / edges 填充。

## 1. flowchart（流程图 / 模块图）

```mermaid
flowchart LR
  user[用户] --> api[API 网关]
  api --> auth[认证服务]
  api --> svc1[业务服务 A]
  svc1 --> db[(MySQL)]
  svc1 --> cache[(Redis)]
```

变体方向：`LR`（左右）/ `TD`（上下）/ `BT`（下上）

子图分组：

```mermaid
flowchart LR
  subgraph 前端
    fe1[页面 A]
    fe2[页面 B]
  end
  subgraph 后端
    be1[服务 A]
    be2[服务 B]
  end
  fe1 --> be1
  fe2 --> be2
```

## 2. sequence（时序图 / 调用顺序）

```mermaid
sequenceDiagram
  autonumber
  participant U as 用户
  participant FE as 前端
  participant BE as 后端
  participant DB as 数据库
  
  U->>FE: 点击登录
  FE->>BE: POST /api/auth/login
  BE->>DB: SELECT user
  DB-->>BE: user record
  BE-->>FE: 200 + token
  FE-->>U: 显示首页
  
  Note over BE,DB: 失败时返回 401
```

要点：
- 用 `participant ... as ...` 给参与者起短名
- `->>` 实线（同步），`-->>` 虚线（响应/异步）
- `Note over A,B: 内容` 加注释

## 3. state（状态机）

```mermaid
stateDiagram-v2
  [*] --> draft
  draft --> in_progress: 用户开始编辑
  in_progress --> awaiting_review: 提交审核
  awaiting_review --> approved: 审核通过
  awaiting_review --> in_progress: 审核打回
  approved --> [*]
  in_progress --> [*]: 用户取消
```

## 4. class（类/接口关系）

```mermaid
classDiagram
  class User {
    +string id
    +string name
    +string email
    +login() Token
  }
  class Order {
    +string id
    +User customer
    +Item[] items
    +submit() bool
  }
  class Item {
    +string sku
    +int quantity
  }
  
  Order "1" --> "*" Item
  Order "*" --> "1" User
```

## 5. er（数据库关系）

```mermaid
erDiagram
  USER ||--o{ ORDER : places
  ORDER ||--|{ LINE_ITEM : contains
  PRODUCT ||--o{ LINE_ITEM : refers_to
  
  USER {
    string id PK
    string email UK
    string name
  }
  ORDER {
    string id PK
    string user_id FK
    timestamp created_at
  }
```

关系符号：
- `||--||` 一对一
- `||--o{` 一对多（必/可）
- `}o--o{` 多对多（可/可）

## 6. gantt（时间排期）

```mermaid
gantt
  title 需求排期
  dateFormat YYYY-MM-DD
  
  section 阶段 1
  需求定义       :a1, 2026-05-01, 3d
  评审           :a2, after a1, 1d
  
  section 阶段 2
  方案设计       :b1, after a2, 5d
  方案评审       :b2, after b1, 1d
  
  section 阶段 3
  编码           :c1, after b2, 10d
```

## 通用约定

| 约定 | 说明 |
|---|---|
| 节点 ID | 全 ASCII，下划线分隔（`user_login` 而非 `用户登录`） |
| 节点 label | 用引号包裹中文：`["用户登录"]` |
| 注释 | 加在图外（mermaid 代码块前后用 markdown 段落） |
| 颜色 | 默认主题，不要 hardcode 颜色（影响主题切换） |
| 复杂图 | 拆成多个子图，分别附说明 |

## 反模式

- ❌ 在 flowchart 里画时序（用 sequence 即可）
- ❌ 在 sequence 里画很多 `if/else`（改用 `alt/else/end`）
- ❌ ER 图把所有字段都列上（用 table 更清晰）
- ❌ 一张图超过 15 个节点（应拆分）
