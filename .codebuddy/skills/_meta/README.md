# .codebuddy/skills/_meta/ — Skill 创作元资产

> 本目录包含「**怎么写 Skill**」的所有元素材。
> Skill 自身放在 `.codebuddy/skills/core/` 或 `.codebuddy/skills/project/`，不要放在这里。

## 内容

| 文件 | 用途 | 谁会读 |
|---|---|---|
| [SKILL_TEMPLATE.md](SKILL_TEMPLATE.md) | Skill 文件标准模板，复制即可填空 | `skill-architect` agent / 用户手动 |
| [skill-authoring-guide.md](skill-authoring-guide.md) | Skill 写作指南：命名、description、章节结构、示例 | `skill-architect` / 用户 |
| [self-evolution-protocol.md](self-evolution-protocol.md) | Skill 自进化协议：何时演进、怎么演进、必走的"提案-确认-应用"三步 | `skill-architect` / 主会话 |

## 使用入口

- `/skill-new` 命令 → 委派 `skill-architect` → 读取本目录三件套
- `/skill-evolve <name>` 命令 → 委派 `skill-architect` → 读取 `self-evolution-protocol.md`

## 修改本目录的注意

修改这三个文件等于**修改"怎么造 Skill"的规则**——影响所有未来的 Skill 创作。
变更前请确认：

1. 是否影响已存在的 Skill（向后兼容？）
2. 是否需要同步更新 `.codebuddy/agents/skill-architect.md`
3. 是否需要在 `.codebuddy/docs/SKILL_GUIDE.md` 加 changelog
