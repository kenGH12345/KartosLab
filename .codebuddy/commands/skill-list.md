---
description: "列出所有 Skill"
allowed-tools: [Read, Glob]
model: sonnet
---

# /skill-list — 列出 Skill

## 步骤

### 1. 扫描 .codebuddy/skills/ 目录

```
Glob .codebuddy/skills/**/SKILL.md
```

按目录归类（`core/` / `project/` / 其他）。

### 2. 解析每个 SKILL.md

读 frontmatter 提取：
- `name`
- `description`
- `tools`（如有）

### 3. 输出表格

```md
## 可用 Skill（{{N}} 个）

### 通用 Skill（core/，{{X}} 个）
| 名称 | 描述 | 路径 |
|---|---|---|
| ... | ... | .codebuddy/skills/core/.../SKILL.md |

### 项目 Skill（project/，{{Y}} 个）
| 名称 | 描述 | 路径 |
|---|---|---|

## 操作
- 创建：/skill-new
- 演进：/skill-evolve <name>
- 阅读：直接 Read .codebuddy/skills/<group>/<name>/SKILL.md
```
