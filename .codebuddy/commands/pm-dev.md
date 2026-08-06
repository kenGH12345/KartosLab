---
description: "从已完成的策划需求（game-design SOP）快速创建开发需求，自动引用策划案"
argument-hint: "<source-req-id>"
allowed-tools: [Bash, Write, Read, Edit, AskUserQuestion, Task]
model: sonnet
---

# /pm-dev — 从策划案创建开发需求

> 快速从一个已完成的 `game-design` 策划需求，衔接创建一个 `agile-vibe` 或 `deep-vibe` 开发需求。
> 自动引用源策划案，省去重复描述。

## 步骤

### 1. 确认源策划需求

如用户在 `$ARGUMENTS` 提供了 source-req-id，直接用。否则用 `AskUserQuestion` 问：

- **source-req-id**：已完成的策划需求 ID（如 `req-game-concept-01`）

校验：
- `requirements/<source-req-id>/meta.yaml` 存在
- `sop` 字段 = `game-design`
- `status` 字段 = `done`（策划已完成才能衔接开发）
- `spec/最终策划案.md` 存在

不满足 → 提示用户先完成策划需求。

### 2. 收集开发需求元数据

用 `AskUserQuestion` 问：

- **dev-req-id**：开发需求短标识（默认建议 = `<source-req-id 去 concept 后缀>-dev`，如 `game-01-dev`）
- **title**：开发需求标题（默认 = 源策划标题 + "-开发实现"）
- **SOP**：`agile-vibe`（默认）/ `deep-vibe`
- **代码工程位置**：repo path

### 3. 创建开发需求骨架

```bash
bash .codebuddy/scripts/new-requirement.sh \
  -i <dev-req-id> \
  -t "<title>" \
  -s <sop>
```

### 4. 自动关联策划案

创建完骨架后：

1. 在新需求的 `spec/context/` 下创建 `策划案引用.md`：

```markdown
# 策划案引用

本开发需求基于以下策划案实现：

- **源策划需求**: `<source-req-id>`
- **最终策划案**: `../../<source-req-id>/spec/最终策划案.md`
- **核心玩法**: `../../<source-req-id>/spec/核心玩法.md`
- **美术需求**: `../../<source-req-id>/spec/美术需求.md`（如有）
- **数值系统**: `../../<source-req-id>/spec/数值系统.md`（如有）

> 开发过程中如需查看策划细节，直接引用上述路径。
```

2. 更新新需求的 `meta.yaml` 的 `related_requirements` 字段：

```yaml
related_requirements:
  - <source-req-id>
```

3. 在新需求的 `notes.md` "已确认发现"段追加：

```
- [来源: 策划需求 <source-req-id>] 本开发基于已完成策划案，详见 spec/context/策划案引用.md
```

### 5. 推进到阶段 2/3

按所选 SOP 推进：
- **agile-vibe**：如策划案足够详细（有 AC/验收标准），可直接跳到 `3.iteration`（主会话直接编码）
- **deep-vibe**：进入 `1.thinking`，但 product-manager 可从策划案直接提取 AC（不用再从头问用户）

在 `process.txt` 追加：

```
[time] init: 从策划需求 <source-req-id> 衔接创建开发需求
[time] 关联策划案: spec/context/策划案引用.md
```

### 6. 向用户汇报

```
✅ 开发需求 <dev-req-id> 已创建

- 源策划：<source-req-id>（spec/最终策划案.md）
- 开发 SOP：<sop>
- 需求目录：requirements/<dev-req-id>/
- 当前阶段：<phase>

下一步：
- agile-vibe → 主会话可直接开始编码
- deep-vibe → 委派 product-manager 从策划案提取 AC
```

## 输出

- 新需求目录完整
- INDEX.md 自动更新（rebuild-index.sh）
- process.txt 有完整记录
- 策划案引用建立
