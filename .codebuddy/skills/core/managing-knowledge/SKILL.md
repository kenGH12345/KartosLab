---
name: managing-knowledge
description: 用于在需求收尾或定期维护时，把项目级发现回写到 context/project/<project>/，并维护对应 INDEX。强制单一源原则——同一事实只在一处定义，其他位置用引用。被 knowledge-maintainer agent 调用。
tools: Read, Write, Edit, Glob, Grep
---

# managing-knowledge

> 这个 Skill 是**「知识库优先」原则的执行者**。
> 没有这个 Skill，需求做完就散在 notes.md 里，下次相关需求开始时无人能找到——知识库永远停在第一天。

## 何时使用

- ✅ 需求收尾后，`knowledge-maintainer` 把项目级发现回写到 `context/project/`
- ✅ 用户主动请求"定期维护"——扫描近期 commits 与现有知识库的脱节
- ❌ 修改需求产物（spec / design / tasks）：不是本 Skill 范围
- ❌ 修改代码：不是本 Skill 范围
- ❌ 重组目录结构：本 Skill 只追加/新增，重组需用户确认

## 输入

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| source_req_id | string | 部分必需 | 触发本次维护的需求 ID（场景 A 必填，场景 B 可空） |
| project_name | string | ✓ | 项目名（决定 context/project/<name>/ 的根） |
| candidates | array | 部分必需 | 候选回写条目列表（场景 A：从需求 notes/design 提取；场景 B：从 svn log 推断） |
| dry_run | bool | ✓ | true = 只输出报告不实际写入 |

每条 candidate 含字段：

```json
{
  "type": "module-responsibility | api-contract | architecture-pattern | flow | config | convention | experience | shared-experience",
  "title": "简短标题",
  "content": "正文（markdown）",
  "source": "req-xxx, <doc>:<段落>",
  "target_path_hint": "建议落到 context/.../README.md 的某段",
  "cross_project": false
}
```

> `cross_project: true` 时，目标路径为 `context/shared/experiences/<category>/` 而非 `context/project/`。

## 步骤

### 1. 加载现状

```
1. Read context/project/<project_name>/INDEX.md（了解知识库现状）
2. 对每个 candidate 的 target_path_hint 解析：
   - 文件存在 → 读取
   - 文件不存在 → 标记为"新增"
```

### 2. 单一源核查（关键步骤）

对每个 candidate：

| 已有内容判定 | 处理 |
|---|---|
| 完全相同 | 跳过 |
| 大致相同但表述不同 | 跳过（不重写已有的） |
| 已存在但过期 | 追加 `## Change-N (来源: <source>)` 段 |
| 部分覆盖 | 在已有基础上追加补充 |
| 不存在 | 新增条目 |

> [!IMPORTANT]
> **同一事实只在一处定义**。如发现某 candidate 已在另一文档定义，本次新增位置只能写"参见 <link>"。

### 3. 判断「项目级 vs 需求级」

按 `references/level-classification.md` 标准过一遍：

```
判断公式：下个不相关的需求会用到这条知识吗？
- 是 → 项目级，回写
- 否 → 需求级，留 notes.md（不本 Skill 处理）
```

如 candidate 不属于项目级，**不回写**，记录到"不回写"清单。

### 4. 执行回写（dry_run = false 时）

按"已有内容判定"分别处理：

#### 追加（已存在但过期）

```
Edit 现有文件，在末尾追加：

## Change-N（YYYY-MM-DD，来源: req-xxx）

<content>
```

#### 新增（不存在）

```
Write 新文件 context/project/<project>/<dir>/<file>.md，内容：

# <title>

<content>

> 来源: <source>
> 创建时间: YYYY-MM-DD
```

每次写入都要附**来源引用**：`（来源: <source>）`

### 5. 同步 INDEX

调用 `docs-index-updater` 把新增/改名的文档同步到对应 INDEX.md。

如 `cross_project: true` 的 candidate 被确认回写：
1. 写入目标文件到 `context/shared/experiences/<category>/<topic>.md`
2. 同步更新 `context/shared/experiences/INDEX.md`（添加条目到表格）
3. 同步更新对应子目录的 `context/shared/experiences/<category>/INDEX.md`（添加条目）
4. 在 `process.txt` 追加：`[time] managing-knowledge: 经验沉淀到 context/shared/experiences/<category>/<topic>.md`

### 6. 识别"已过期"段落（场景 B 的额外步骤）

如本次是定期维护：

```
对每个现有文档：
  1. Grep 文档中提到的 文件:行号 / 模块名
  2. 校验目标在代码里仍存在
  3. 不存在 → 标注 [已过期: YYYY-MM-DD] 并列入"建议"
```

> 本 Skill **不自动修正过期内容**——只标注与建议。修正需要回源验证，应触发新需求或单独的维护任务。

### 7. 撰写维护报告

写入 `.vibe/cache/<source_req_id>-knowledge-update.md`：

```md
# 知识库更新报告（来源: <source_req_id>）

## 已应用的更新（dry_run = false 时实际生效）
- context/project/.../A.md — 追加 Change-N（接口新增）
- context/project/.../B.md — 新增（API 契约）

## INDEX 同步
- context/project/.../INDEX.md — 加入新文档条目

## 经验沉淀到 context/shared/experiences/
- [ ] coding/<topic>.md — 新/更新（来源: req-xxx, notes.md:XX）
- [ ] workflow/<topic>.md — 新/更新（来源: req-xxx, notes.md:XX）

## 建议（未自行执行）
- 建议拆分 X.md（已超 500 行）
- 已发现过期段落 N 处，建议在下次相关需求中修订
- 建议运行 `/improve` 扫描跨需求重复模式

## 不回写（属于需求级）
- candidate K（理由：<...>）
```

## 输出

```md
## managing-knowledge 执行结果
- 状态: completed / partial
- 报告: .vibe/cache/<source_req_id>-knowledge-update.md
- 已更新: N 个文件（追加 X / 新增 Y）
- INDEX 同步: ✓
- 建议（未执行）: M 项
- 不回写（已留 notes.md）: K 项
```

## 边界与陷阱

> [!IMPORTANT]
> **不**自行重组目录结构。即使发现某文档过大、分类不合理，也只能在"建议"中列出，由用户决定是否重组。

> [!WARNING]
> **不**编造内容。每条更新必须能从 candidate.source 追溯到原始证据。

- ❌ 不要修改 spec / design / tasks（历史快照）
- ❌ 不要修改代码
- ❌ 不要 import 第三方资料源（外部 wiki / 设计稿）：知识库内容必须来自需求过程
- ❌ 不要为了"看起来完整"补一些没证据的描述
- ❌ 不要 INDEX 同步时改其他不相关条目
- ✅ 同一事实只在一处定义，其他位置用引用
- ✅ 每次更新附来源引用
- ✅ 过期内容标注但不自动修正

## 引用资料

- [level-classification.md](references/level-classification.md) —— 项目级 vs 需求级判定标准
- [retrieval-pattern.md](references/retrieval-pattern.md) —— 知识库目录与文件命名约定

## 关联 Skill

- `docs-index-updater` —— INDEX 同步
- `progress-logger` —— 在更新后追加 process.txt（如关联到某需求）

## 变更历史

> 2026-05-28 by 主会话（用户确认「按完整生产方案执行」）：
> 集成 `context/shared/experiences/` 经验沉淀。
> - candidate 类型增加 `shared-experience` 类型 + `cross_project: bool` 字段
> - 步骤 5 增加 `experiences/` 的 INDEX 同步逻辑
> - 步骤 7（维护报告）增加「经验沉淀」章节 +「建议运行 `/improve`」提示
> - 触发原因：`self-improving-agent` 与 `managing-knowledge` 原本各自为营，缺乏经验跨项目沉淀的衔接
> - 与 `self-improving-agent` Skill 的「检测模式 2c 经验盲区」段联动：盲区检测后的 candidate 直接通过本 Skill 写入 `experiences/`

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| 2026-05-28 | 0.1.1 | 集成 experiences 经验沉淀（cross_project 候选类型 + 索引同步） | 生产就绪集成 | 主会话 |
| - | 0.1.0 | 初始创建 | Phase 3 | template |
