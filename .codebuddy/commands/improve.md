---
name: /improve
description: 触发 self-improving-agent 扫描，检测重复踩坑、效率瓶颈、经验盲区，生成改进提案。
tools: Read, Write, Edit, Bash
---

# /improve 命令

触发 WV 的主动自改进扫描。补足「被动触发→主动检测」的闭环缺口。

## 使用方式

| 触发方式 | 命令格式 |
|---|---|
| 扫描最近 5 个需求 | `/improve` 或 `/improve recent` |
| 扫描全部需求 | `/improve all` |
| 扫描指定需求 | `/improve req-<id>` |
| 仅诊断不触发 | `/improve --dry-run` |
| 指定目标类型 | `/improve --type=skill`（skill/sop/agent/all） |

## 执行流程

### 1. 调用 self-improving-agent Skill

```
加载 .codebuddy/skills/core/self-improving-agent/SKILL.md
按参数执行步骤 1→4：
  - 加载历史数据
  - 检测重复模式（踩坑/瓶颈/盲区）
  - 生成改进提案
  - 输出扫描报告到 .vibe/cache/self-improving-scan-<date>.md
```

### 2. 自动提取失败模式（Phase 1 能力 #1）

在 self-improving-agent 扫描前/后，自动运行：

```bash
bash .workflow/scripts/auto-extract-failures.sh <req-id>
```

- 扫描目标需求的 `process.txt`，提取含 error/fail/bug/warning 的行
- 生成结构化 `experiences/` 条目（标记为 `draft` + `auto-extracted`）
- 通过质量门禁（重复性检查、上限控制）

### 3. 经验质量门禁检查（Phase 1 能力 #2）

对 `context/shared/experiences/` 运行快速质量检查：

```bash
# 检查清单：
# - draft 条目不超 30 天未审核
# - auto-extracted 条目必须含「问题分析」「解决方案」段
# - 同一 source_req 的条目不超过 5 条
# - 重复条目检测
```

### 4. 输出与确认

```md
## /improve 扫描结果

- 扫描范围: <N> 个需求
- 检测到问题: <M> 项
  - 重复踩坑: X
  - 效率瓶颈: Y
  - 经验盲区: Z
- 自动提取失败模式: K 条（ drafting，待审核）
- 质量门禁: ✓ / ⚠️ <N 项待处理>
- 报告位置: .vibe/cache/self-improving-scan-<date>.md

### 改进提案（按优先级排序）
1. **[High]** ...（需用户确认 y/n）
2. **[Medium]** ...（需用户确认 y/n）
...

### 下一步
- 回复提案编号 + y/n 确认是否触发演进
- 回复「审核经验」查看 auto-extracted 条目
- 回复「注入经验 <task-type>」为当前 session 注入相关经验
```

## 与现有流程的衔接

| 场景 | 调用时机 | 衔接点 |
|---|---|---|
| 需求 closing | knowledge-maintainer 步骤 6 后 | `self-improving-agent` 自动扫描 |
| 定期维护 | 每完成 5 个需求或用户主动触发 | `/improve` 命令 |
| 用户反馈 | 「同样的问题又遇到了」 | `/improve recent --type=all` |
| Session 启动 | agent 加载上下文时 | `experience-injector.sh` 自动注入 |

## 变更历史

> 2026-05-28 by 主会话（用户确认「按完整生产方案执行」）：
> 从 WA 的 self-improving-agent 适配为 WV 的 `/improve` 命令。
> - 集成 Phase 1 三大能力：失败提取（auto-extract-failures.sh）、质量门禁、自动注入
> - 与 `self-improving-agent` SKILL.md 的「何时使用」段对齐
> - 与 `knowledge-maintainer` agent 的步骤 6 衔接
