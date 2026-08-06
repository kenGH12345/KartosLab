# 新需求骨架模板

> 本文件给出新建需求时使用的标准模板。`managing-requirement` Skill 的 `create` operation 会基于这些模板填充。

## 目录结构

```
requirements/<req-id>/
├── meta.yaml             # 必需：元数据 + 当前阶段/状态
├── process.txt           # 必需：追加式过程日志
├── plan.md               # 必需：里程碑与本轮目标
├── notes.md              # 必需（可空）：踩坑、决策、沉淀
├── spec/                 # 阶段 1/2 产出
│   └── context/          # 来源归档（可选）
├── design/               # 阶段 2 产出
└── tasks/                # 阶段 2/3 产出
    └── features.json     # 可选：任务清单（在 add_task 时创建）
```

## meta.yaml 模板

```yaml
# 需求元数据。本字段被主会话（PM 角色）/ managing-requirement / 各 SOP 读取。
# 不要手工修改 phase / status——通过 /pm-continue 或 /pm-phase 切换。

req_id: {{REQ_ID}}
title: {{TITLE}}
sop: {{SOP}}                # agile-vibe / deep-vibe / <custom>
created_at: "2026-05-29 13:40"
updated_at: "2026-05-29 13:40"

# 当前位置
phase: 1.init               # 阶段标识，按 SOP 定义
status: draft               # draft / in_progress / awaiting_user_input / blocked / done

# 关联
repo_path: "d:\WePop_trunk"  # 代码工程绝对路径或相对路径，可空
related_requirements: []    # 关联需求 ID 列表

# 阶段切换历史（force_phase 操作时追加）
phase_overrides: []
```

## process.txt 模板

```
[2026-05-29 13:40] init: 创建需求骨架，sop={{SOP}}
```

> process.txt 是**追加式**日志，每次写一行，格式 `[YYYY-MM-DD HH:MM] <event>: <description>`。
> 可读性优先，不强制结构化（结构化数据放 meta.yaml）。

## plan.md 模板

```markdown
# {{TITLE}}（{{REQ_ID}}）

> 本文件用于记录里程碑、本轮目标、关键决策点。
> 与 spec/ 不同，plan.md 是「**当前在做什么**」的快速视图。

## 1. 总目标

<一句话总目标，由用户在阶段 1 或 2 早期填>

## 2. 里程碑

| 里程碑 | 完成标志 | 状态 |
|---|---|---|
| M1：需求定义清楚 | spec/ 文档完成 | pending |
| M2：方案就位 | design/ 文档完成（仅 deep-vibe） | pending |
| M3：编码完成 | tasks 全 done | pending |
| M4：测试通过 | 测试报告无新增失败 | pending |
| M5：评审通过 + 收尾 | 最终需求文档生成 | pending |

## 3. 本轮目标（agile-vibe iteration 阶段使用）

<本轮要做什么的一句话，每轮 vibe-loop 时由用户填或调整>

## 4. 关键决策点

<在本需求过程中需要用户确认的决策。每条带状态：pending / decided / deferred>

- [ ] <决策 1>
- [ ] <决策 2>

## 5. 关联资源

- 设计稿: <如有>
- 外部素材: <如有 TAPD ID / Wiki 链接>
- 关联需求: <如有>
```

## notes.md 模板

```markdown
# {{TITLE}} —— 笔记与沉淀

> 本文件追加式记录：
> - 已确认的发现（带依据）
> - 开发踩坑（描述坑 + 解决方案）
> - 决策记录（为什么选 A 不选 B）
> - 推迟的 Major 项 / 遗留 TODO
>
> 这些内容**不会**进入 spec / design / tasks（那是历史快照），但会被 closer 在收尾时用来生成最终摘要，被 knowledge-maintainer 用来识别"项目级发现"回写到 context/。

## 已确认发现

<段落空，由 product-manager / leader / dev 在过程中追加>

## 开发踩坑

<段落空，由 dev 在过程中追加>

## 决策记录

<段落空>

## 推迟的 Major 项

<段落空，由 code-reviewer 评审后由用户决定推迟时追加>

## 遗留 TODO

<段落空>
```
