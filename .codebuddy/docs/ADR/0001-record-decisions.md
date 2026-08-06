# ADR 0001 — 我们使用 ADR 记录架构决策

**Status**: Accepted
**Date**: 2026-05-12 14:32

## Context

在 AI 协作场景下，框架本身的设计决策容易被淹没在对话与代码里。需要一个结构化、可追溯的位置记录"为什么这么做"，让后来者（包括 AI）能快速理解。

## Decision

采用 ADR (Architecture Decision Records) 模式：

- 位置：`.codebuddy/docs/ADR/<NNNN>-<kebab-name>.md`
- 编号：四位数字，从 0001 开始
- 状态：`Proposed` / `Accepted` / `Deprecated` / `Superseded by NNNN`
- 模板：本文件即模板

## Consequences

- ✅ 决策可追溯，新成员（与 AI）能快速理解设计意图
- ✅ Deprecated 决策保留为历史记录，不删除
- ⚠️ 需要纪律：重要决策必须落地为 ADR，否则会被遗忘

## Template

```markdown
# ADR NNNN — Title

**Status**: Proposed | Accepted | Deprecated | Superseded by NNNN
**Date**: YYYY-MM-DD

## Context
（背景：什么问题驱动了这个决策）

## Decision
（决策：我们决定怎么做）

## Consequences
（影响：好处、坏处、需要注意的事）

## Alternatives Considered
（备选方案及为何未采纳）
```
