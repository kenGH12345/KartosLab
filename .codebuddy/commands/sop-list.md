---
description: "列出可用的 SOP 与简介"
allowed-tools: [Read, Glob]
model: sonnet
---

# /sop-list — 列出 SOP

## 步骤

### 1. 扫描 .codebuddy/sop/ 目录

```
Glob .codebuddy/sop/*.md
```

排除 `_template_sop.md` 与 `INDEX.md`。

### 2. 解析每个 SOP

对每个 SOP 文件读取首部段落（一般是 YAML frontmatter 或前 30 行）提取：
- name
- description
- 阶段数
- 适用场景

### 3. 输出表格

```md
## 可用 SOP（{{N}} 个）

| SOP | 阶段数 | 适用场景 | 文件 |
|---|---|---|---|
| **agile-vibe** （默认）| 4 | 功能探索、快速原型、bugfix、技术改进 | .codebuddy/sop/agile-vibe.md |
| **deep-vibe** | 5 | 跨团队大需求、架构变更、需正式评审 | .codebuddy/sop/deep-vibe.md |
| <custom> | ... | ... | .codebuddy/sop/<name>.md |

## 选择建议
- 不确定 → agile-vibe（默认）
- 跨团队 / 需要文档作为合同 → deep-vibe

## 切换方式
- 新需求时 `/pm-new` 询问
- 现有需求改 `meta.yaml` 中的 `sop:` 字段
- 自定义 SOP：复制 .codebuddy/sop/_template_sop.md 改写后放在 .codebuddy/sop/ 即可
```
