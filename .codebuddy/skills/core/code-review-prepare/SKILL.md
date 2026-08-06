---
name: code-review-prepare
description: 用于在启动代码评审前，整理 svn diff 范围、提取需求验收项清单、收集设计文档、形成"评审基线"。被 code-reviewer agent 与 /code-review 命令调用。
tools: Read, Bash, Glob, Grep
---

# code-review-prepare

> 评审前的"准备工作"看似简单——但**漏一步就让评审退化为"通读代码"**。
> 这个 Skill 把"评审前要拿到的东西"固化成清单，避免每次都重新搭场。

## 何时使用

- ✅ `code-reviewer` agent 启动时第一步
- ✅ `/code-review` 命令执行时
- ✅ 任何需要"对照需求与方案评审本次改动"的场景
- ❌ 只想看代码风格：用 linter 即可
- ❌ 想跑测试：是 `run-tests-with-baseline` 的事

## 输入

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| req_id | string | 部分必需 | 需求 ID（场景 A 必填） |
| commit_range | string | 部分必需 | SVN 范围如 `r<N>:r<M>`（场景 B 必填） |
| repo_path | string | ✓ | 代码仓库路径 |

至少二选一：req_id 或 commit_range。

## 步骤

### 1. 解析评审范围

#### 场景 A：从 req_id 推断

```bash
cd <repo_path>
# 从 commit message 找含本 req_id 的 revisions
svn log --search "<req_id>" -r1:HEAD -q | grep -oP 'r\d+' > /tmp/req-revisions.txt
# 取首尾
FIRST_REV=$(head -1 /tmp/req-revisions.txt | grep -oP '\d+')
LAST_REV=$(tail -1 /tmp/req-revisions.txt | grep -oP '\d+')
REVISION_RANGE="r${FIRST_REV}:r${LAST_REV}"
```

如未找到任何 revision：stop + report，让调用方传 commit_range。

#### 场景 B：直接用传入的 commit_range

```bash
svn log -r<revision_range> | head -50
```

校验范围有效（>0 个 revision）。

### 2. 收集 diff 概览

```bash
svn diff -r<revision_range> --summarize   # 文件级统计
svn diff -r<revision_range> | wc -l       # 总行数概览
svn log -r<revision_range>                 # revision 列表
```

输出到 `.vibe/cache/<req_id>-review-diff-summary.txt`。

### 3. 提取验收项清单

```
1. Read requirements/<req_id>/spec/需求文档.md（或 spec/需求简述.md）
2. Grep "AC-\d+:" 或解析需求文档第三/四章
3. 形成清单：
   AC-1: <描述>
   AC-2: <描述>
   ...
```

输出到 `.vibe/cache/<req_id>-ac-list.md`。

### 4. 收集设计文档清单

```
Glob requirements/<req_id>/design/*.md
按文件类型分类：
- design/技术方案.md            # 实现层基线
- design/协议定义.md            # 协议层基线
- design/前端方案.md / 后端方案.md  # 端内基线
- design/方案评审.md            # 上一轮评审结论
- design/代码评审.md            # 已存在的代码评审报告（多轮评审场景）
```

如某些文档不存在，标记为"该需求无对应基线"。

### 5. 收集开发踩坑记录

```
Read requirements/<req_id>/notes.md
提取"开发踩坑"段落
```

用于评审时识别"已知偏离方案的合理变通" vs "未记录的偏离"。

### 6. 列出本次改动文件按目录分组

```bash
svn diff -r<revision_range> --summarize | awk '{print $NF}' | sort | awk -F/ '{print $1"/"$2}' | uniq -c | sort -rn
```

形成"按模块统计本次改动量"的视图，帮助评审者识别热点。

### 7. 输出评审准备包

返回结构化数据给调用方（code-reviewer agent）：

```json
{
  "revision_range": "r<N>:r<M>",
  "revision_count": N,
  "files_changed": M,
  "lines_added": X,
  "lines_deleted": Y,
  "ac_list": [
    {"id": "AC-1", "desc": "..."},
    ...
  ],
  "design_docs": ["design/技术方案.md", "design/协议定义.md", ...],
  "absent_docs": ["design/前端方案.md"],
  "modules_touched": [
    {"path": "src/auth", "files": 5, "lines": 120},
    ...
  ],
  "dev_notes_excerpt": "<notes.md 的开发踩坑段>",
  "cache_files": [
    ".vibe/cache/<req_id>-review-diff-summary.txt",
    ".vibe/cache/<req_id>-ac-list.md"
  ]
}
```

## 输出

```md
## code-review-prepare 执行结果
- 状态: completed / partial（缺设计文档）/ blocked（无 revision）
- revision 范围: r<N>:r<M>（N 个 revision / M 个文件 / +X -Y 行）
- 验收项: K 个（提取到 .vibe/cache/...）
- 已收集设计文档: L 个
- 缺失设计文档: <list>（评审时按"无基线"处理）
- 评审准备包: 已返回给调用方
```

## 边界与陷阱

> [!IMPORTANT]
> **不**评审任何代码。本 Skill 只准备数据，评审是 `code-reviewer` agent 的事。

- ❌ 不要 svn switch 切换分支
- ❌ 不要修改任何文件（包括 cache 之外的）
- ❌ 不要"自动猜"AC 编号——只提取需求文档明确写出的
- ❌ 不要把私有/敏感数据写入 cache（如 token / password）
- ✅ 缺失的基线明确标出，让评审者知道"无基线"
- ✅ 所有 cache 输出统一前缀 `<req_id>-` 便于清理

## 关联 Skill

- `code-reviewer` agent 调用本 Skill → 然后做实际评审
- 与 `run-tests-with-baseline` 是平级的"评审/测试前的准备"

## 变更历史

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| - | 0.1.0 | 初始创建 | Phase 3 | template |
