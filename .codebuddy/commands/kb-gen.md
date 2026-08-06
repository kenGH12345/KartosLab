---
description: "调用 knowledge-base-generator Skill 扫描源码目录，生成项目结构化知识库（context/project/<name>/）"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, WebSearch]
model: sonnet
---

# /kb-gen — 生成项目知识库

调用 `knowledge-base-generator` Skill，扫描源码自动生成结构化知识库。

## 使用方式

```bash
# 最简调用（自动检测项目类型）
/kb-gen <项目名> <源码路径> <语言>

# 显式指定项目类型（跳过自动检测，推荐）
/kb-gen <项目名> <源码路径> <语言> --type=<project_type>

# 强制重新生成（覆盖已有知识库）
/kb-gen <项目名> <源码路径> <语言> --force
```

## 入参

| 输入 | 类型 | 必需 | 说明 |
|---|:-:|---|
| project_name | string | ✓ | 项目名，决定 `context/project/<name>/` 根路径 |
| source_root | path | ✓ | 源码根目录绝对路径（如 `d:\MyProject\src`） |
| language | string | ✓ | 主要编程语言（c / cpp / csharp / go / typescript / python / rust / lua 等） |
| project_type | enum | 否 | 显式指定类型：`game` / `backend` / `web-frontend` / `cli-tool` / `embedded` / `data-ai` |
| framework_notes | string | 否 | 框架/平台补充（如"基于 STM32 HAL 库"、"Express + Prisma"） |
| force_regenerate | bool | 否 | 默认 false；true = 即使 INDEX.md 已存在也重新生成 |

## 示例

```bash
# Unity 游戏项目
/kb-gen wepop-trunk d:\WePop_trunk\Assets csharp --type=game

# Go 后端服务
/kb-gen user-service d:\project\user-service go --type=backend --framework="Gin + GORM"

# C 语言嵌入式项目
/kb-gen stm32-firmware d:\project\firmware c --type=embedded --framework="STM32 HAL"

# TypeScript Web 前端
/kb-gen web-app d:\project\web typescript --type=web-frontend --framework="React + Vite"

# 不指定类型，自动检测
/kb-gen my-tool d:\project\my-tool go

# 强制重新生成
/kb-gen wepop-trunk d:\WePop_trunk\Assets csharp --force
```

## 执行流程

### 1. 加载 Skill

```
Read .codebuddy/skills/core/knowledge-base-generator/SKILL.md
```

### 2. 步骤 1：结构发现（Discovery）

- 扫描 `source_root` 顶层目录结构
- 定位关键入口文件（main.go / Program.cs / App.tsx 等）
- 记录模块清单

### 3. 步骤 2：分类决策（Classification）

- 自动检测项目类型（若未显式指定 `project_type`）
- 按项目类型启用对应分类体系（游戏→`gameplay/`，嵌入式→`hardware/`，Web前端→`frontend/` 等）
- 每分类至少 3 文件才独立建目录，否则合并到 `architecture/`

### 4. 步骤 3：深度提取（Deep Extraction）

对每个分类的子主题，从源码提取结构化技术事实：
- 关键文件路径、核心类/接口签名
- 生命周期流程图（mermaid）
- 注册/调用机制、设计模式标注

### 5. 步骤 4-6：输出 + 索引 + 验证

- 写入 `context/project/<name>/` 目录
- 生成 INDEX.md 入口索引
- 运行质量自检（覆盖度 / 引用准确性 / 可操作性）

## 输出

```md
## /kb-gen 执行结果
- 项目: <project_name>
- 项目类型: <project_type>（自动检测 / 用户指定）
- 输出路径: context/project/<name>/
- 生成目录:
  - architecture/          <N 个文档>
  - conventions/           <N 个文档>
  - systems/               <N 个文档>
  - [类型特定目录...]      <如有>
- INDEX.md: ✓
- 质量自检: ✓
```

## 适用场景

| 场景 | 说明 |
|---|---|
| 项目首次接入 | `context/project/<name>/INDEX.md` 不存在时 |
| 重大架构变更 | 框架升级、模块重组后知识库过期 |
| 用户主动要求 | "生成项目知识库" / "扫描项目生成文档" |

## 不适用场景

- 日常文档补充 → 用 `managing-knowledge` Skill 增量回写
- 修改单个文档 → 直接编辑目标文件
- 纯代码需求（不涉及知识库建设）

## 与其他命令的关系

| 命令 | 关系 |
|---|---|
| `/kb-gen` | 生成首次知识库（本命令） |
| `/improve` | 扫描历史需求，生成经验库（跨项目沉淀） |
| `/doctor` | 检查知识库一致性，索引对齐 |
| `managing-knowledge` Skill | 增量回写，单文档更新 |

## 变更历史

> 2026-07-15 by 主会话：
> 初始创建，补充 SKILL.md 中 frontmatter 声明的 `/kb-gen` 命令入口。
> - 与 `knowledge-base-generator` SKILL.md 的输入参数、分类体系、执行步骤对齐
> - 支持 6 种项目类型（game / backend / web-frontend / cli-tool / embedded / data-ai）
> - 提供完整调用的 7 个示例（覆盖各类型）