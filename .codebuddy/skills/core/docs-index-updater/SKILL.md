---
name: docs-index-updater
description: 用于在新增 / 改名 / 移动 / 删除文档后，自动同步对应 INDEX.md 与 INDEX.yaml 的"文档清单"段。维护单一源——避免 INDEX 与目录漂移。
tools: Read, Write, Edit, Glob, Bash
---

# docs-index-updater

> 几乎所有"INDEX 与目录不一致"的问题都源于「**改了文档忘了更 INDEX**」。
> 这个 Skill 把 INDEX 同步逻辑标准化，由调用方在文档变更后调用。

## 何时使用

- ✅ 新增 markdown 文档后
- ✅ 改名 / 移动文档后
- ✅ 归档 / 删除文档后
- ✅ `/doctor` 检查发现不一致时
- ❌ 内容变更但路径未变：通常不需要更 INDEX（除非 INDEX 里写了"最近更新时间"列）

## 输入

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| index_path | path | ✓ | 要更新的 INDEX.md（每个目录一个） |
| operations | array | ✓ | 操作列表，每项含 type 与 detail |

每个 operation：

```json
{
  "type": "add" | "rename" | "move" | "remove",
  "path": "<相对于 INDEX 所在目录的路径>",
  "new_path": "<rename/move 时填>",
  "title": "<add 时的显示标题>",
  "description": "<add 时的简介>"
}
```

## 步骤

### 1. 解析当前 INDEX

```
1. Read index_path
2. 用 markdown 解析定位"文档清单"段（特征：表格表头含"文档"或"路径"列）
3. 提取现有条目（保留段外内容不动）
```

### 2. 应用操作

对每个 operation：

#### type = add

- 校验 path 真实存在
- 在表格末尾追加一行
- 表格列按现有 INDEX 的列结构（typically: 文档 / 说明 / 最近更新）

#### type = rename / move

- 校验 new_path 真实存在
- 找到原 path 对应行，更新链接与显示文字
- 如有"最近更新"列，更新为今天

#### type = remove

- 找到 path 对应行
- 删除（或视 INDEX 风格移到"已归档"段）

### 3. 同步 INDEX.yaml（如存在）

如同目录有 `INDEX.yaml`：

- Read 现有 yaml
- 按 operation 同步 yaml 的 entries 段
- 保持 yaml 格式（缩进、引号一致）

### 4. 更新 INDEX 末尾时间戳

如 INDEX 末尾有 "_索引最后更新：..._" 行：

```bash
date "+%Y-%m-%d %H:%M"
```

更新为真实时间。

### 5. 校验链接有效性

对所有变更后的链接：

```bash
test -e <link_target> && echo "OK" || echo "MISSING"
```

如有断链：stop + report，不应用本次更新。

## 输出

```md
## docs-index-updater 执行结果
- 状态: completed / partial / blocked
- 涉及 INDEX: <path>
- 涉及 INDEX.yaml: <path or n/a>
- 应用 operations: N
- 链接校验: 全部有效 / X 个断链（已回滚）
```

## 边界与陷阱

> [!IMPORTANT]
> **绝不**修改 INDEX 中"文档清单"段以外的内容（如目录结构图、跨引用段、自定义分类段）。

> [!WARNING]
> 同时改 INDEX.md 与 INDEX.yaml 时必须保持顺序与命名一致——否则 `/doctor` 会报告不一致。

- ❌ 不要因为发现"INDEX 排序乱"就重排（保留人工排序意图）
- ❌ 不要把 add 操作触发的简介改成"自动生成的占位文字"（要传入真实简介）
- ❌ 不要在 dry_run 之外的场景跳过链接校验
- ✅ 应用前先在内存计算最终结果，应用后再写盘
- ✅ 链接校验通过才写盘

## 关联 Skill

- `managing-requirement` 在创建/归档需求时调用本 Skill
- `managing-knowledge` 在新增/改名知识库文档后调用本 Skill
- `skill-creator` 在新建 Skill 后调用本 Skill 同步 `.codebuddy/skills/INDEX.md`

## 变更历史

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| - | 0.1.0 | 初始创建 | Phase 3 | template |
