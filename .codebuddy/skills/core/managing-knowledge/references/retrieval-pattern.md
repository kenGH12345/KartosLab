# context/project/ 目录与文件命名约定

> 本文件定义项目知识库的标准目录结构与命名约定。
> `managing-knowledge` Skill 的 `target_path_hint` 解析与新增文件的落点判断都基于本约定。

## 标准目录结构

```
context/project/<project_name>/
├── INDEX.md                      # 必需：项目知识库主入口
├── README.md                     # 可选：项目介绍（≠ INDEX）
├── architecture/                 # 架构层
│   ├── INDEX.md
│   ├── overview.md
│   ├── tech-stack.md
│   └── decisions/                # ADR
│       ├── 0001-...md
│       └── ...
├── services/                     # 各服务/子系统
│   ├── INDEX.md
│   ├── <service-A>/
│   │   ├── README.md             # 服务说明（职责、对外接口、依赖）
│   │   ├── modules/              # 模块层
│   │   │   └── <module>.md
│   │   └── flows/                # 该服务内的关键流程
│   │       └── <flow>.md
│   └── <service-B>/
│       └── ...
├── api/                          # 接口契约（跨服务汇总）
│   ├── INDEX.md
│   └── <service-A>.md
├── data-model/                   # 数据模型
│   ├── INDEX.md
│   ├── er-diagram.md
│   └── tables/<table>.md
├── flows/                        # 跨服务的端到端流程
│   ├── INDEX.md
│   └── <flow>.md
├── conventions/                  # 通用约定
│   ├── INDEX.md
│   ├── naming.md
│   ├── error-handling.md
│   ├── logging.md
│   └── git-workflow.md
├── experience/                   # 已验证的踩坑/经验
│   ├── INDEX.md
│   └── <topic>.md
├── config.md                     # 关键配置项总览
├── dependencies.md               # 依赖服务/库总览
└── performance.md                # 性能基线与目标
```

## 落点选择规则

`managing-knowledge` 的 `target_path_hint` 按 candidate.type 推算：

| candidate.type | 默认落点规则 |
|---|---|
| `module-responsibility` | `services/<service>/README.md` 的"对外接口"段，或新建 `services/<service>/modules/<module>.md` |
| `api-contract` | `api/<service>.md`（增量追加表行） |
| `architecture-pattern` | `architecture/INDEX.md` 或 `architecture/overview.md` |
| `flow` | 跨服务流程 → `flows/<flow>.md`；单服务内 → `services/<service>/flows/<flow>.md` |
| `config` | `config.md`（增量追加表行） |
| `convention` | `conventions/<topic>.md`（如 topic 不存在则新建） |
| `experience` | `experience/<topic>.md`（如 topic 不存在则新建） |
| `data-model` | `data-model/tables/<table>.md`（按表名） |

## 文件命名约定

- 全部小写 + kebab-case：`error-handling.md`，不是 `ErrorHandling.md` 也不是 `error_handling.md`
- 中文命名仅在以下位置允许：
  - 需求目录下（`requirements/<id>/spec/需求文档.md`）
  - 项目知识库的 `architecture/decisions/`（ADR 标题可用中文）
- API/字段名保持原文（不翻译）

## INDEX.md 规则

每个一级目录下必须有一个 `INDEX.md`，包含：

```md
# <Section> 索引

## 目录结构
（mermaid 或文本树）

## 文档清单
| 文档 | 说明 | 最近更新 |
|---|---|---|
| [overview.md](overview.md) | ... | YYYY-MM-DD |

## 跨引用
- 与其他目录的关系
```

`docs-index-updater` Skill 会自动维护"文档清单"段；其他段落由人工/agent 维护。

## 单一源原则

如同一事实在多个文档可能落点都合理：

1. **优先选最具体的位置**（如某接口属于服务 A，落 `api/A.md` 而非 `api/INDEX.md`）
2. **其他位置只引用**（用 markdown link 或 `参见 <path>`）
3. **不重复完整内容**

## 如何拆分大文件

- 单个 .md > 500 行 → 考虑拆分（但本 Skill 只建议，不自动拆）
- 拆分需建立子目录，原文件改为索引型 README

## 不属于知识库的内容

不要回写以下到 `context/project/`：

| 类型 | 应去的位置 |
|---|---|
| 需求过程的变通 | `requirements/<id>/notes.md` |
| 个人调试笔记 | 用户自己的笔记 |
| 设计稿 / UI 资源 | 项目代码仓 / 设计工具 |
| 临时数据 / 日志 | `.vibe/cache/`（不入版本库） |
| 团队 SOP / 流程 | `.codebuddy/sop/`（本仓库根） |
