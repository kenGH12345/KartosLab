---

## name: skill-creator
description: 用于在创建一个全新 Skill 时，按 .codebuddy/skills/_meta/SKILL_TEMPLATE.md 生成符合规范的 Skill 目录骨架，并在 .codebuddy/skills/INDEX.md 同步登记。被 /skill-new 命令与 skill-architect agent 调用。
tools: Read, Write, Edit, Glob, AskUserQuestion

# skill-creator

> 这是一个**元 Skill**——用来造其他 Skill 的 Skill。
> 它把"造一个 Skill"的 6 个标准步骤固化下来，避免每次都重新发明流程。

## 何时使用

- ✅ `/skill-new` 命令触发 `skill-architect` agent，agent 加载本 Skill
- ✅ 用户主动请求"帮我创建一个名叫 XX 的 Skill"
- ❌ 改已有 Skill：用 `self-evolution-protocol`（不是本 Skill 的范围）
- ❌ 创建非 Skill 资产（rules / commands / agents）：不是本 Skill

## 输入


| 输入               | 类型                       | 必需  | 说明                  |
| ---------------- | ------------------------ | --- | ------------------- |
| name             | string                   | ✓   | kebab-case          |
| description      | string                   | ✓   | 一句话「何时用」            |
| group            | enum: `core` / `project` | ✓   | 分组                  |
| needs_references | bool                     | ✓   | 是否需要 references/ 目录 |
| needs_scripts    | bool                     | ✓   | 是否需要 .codebuddy/scripts/ 目录    |
| needs_assets     | bool                     | ✓   | 是否需要 assets/ 目录     |


## 步骤

### 1. 收集输入

如缺任一必需输入，用 `AskUserQuestion` 一次性问全。
**特别注意 description**：必须能让 AI 通过它判断"现在该不该用这个 Skill"。

提供 description 写法范例给用户：

> 用于在 [何种触发场景] 时 [做什么具体动作]，产出 [什么]。

### 2. 检查不重复

```
1. Read .codebuddy/skills/INDEX.md
2. Glob .codebuddy/skills/**/SKILL.md
3. 在已有 SKILL.md 的 frontmatter 与一级标题中搜 description 关键词
```

如发现重叠：

- 功能基本一致 → 提示用户：演进现有 Skill 用 `/skill-evolve`，取消创建
- 部分重叠 → 让用户决定：合并 / 创建新 Skill / 取消

### 3. 创建目录骨架

```
skills/<group>/<name>/
├── SKILL.md
├── references/.gitkeep    （如 needs_references）
├── .codebuddy/scripts/.gitkeep       （如 needs_scripts）
└── assets/.gitkeep        （如 needs_assets）
```

### 4. 填充 SKILL.md

```
1. Read .codebuddy/skills/_meta/SKILL_TEMPLATE.md（标准模板）
2. 把模板内容写入 .codebuddy/skills/<group>/<name>/SKILL.md
3. 替换以下占位符（保持其他占位符让用户后续填）:
   - <skill-name> → 实际 name
   - description 字段 → 实际 description
4. 删掉模板顶部的注释块
```

### 5. 同步 .codebuddy/skills/INDEX.md

在对应分组（`Core Skills` 或 `Project Skills`）的表格中追加一行：

```md
| `<name>` | <description 截取前 60 字> |
```

更新文件末尾的"索引最后更新"时间戳。

### 6. 提示首次使用

向 `skill-architect` 返回时建议：

- 用户在第一次实际使用本 Skill 时如发现遗漏 → 触发 `/skill-evolve`
- 模板内的其他占位符（步骤、边界等）需用户自行填或在第一次使用时根据实际操作补全

## 输出

- 新建文件：
  - `.codebuddy/skills/<group>/<name>/SKILL.md`（含 frontmatter + 模板正文）
  - 可选 `references/.gitkeep` / `.codebuddy/scripts/.gitkeep` / `assets/.gitkeep`
- 修改文件：
  - `.codebuddy/skills/INDEX.md`
- 摘要给主会话：

```md
## skill-creator 执行结果
- 状态: completed
- 新 Skill 路径: .codebuddy/skills/<group>/<name>/
- INDEX 同步: ✓
- 后续建议: 实际使用时如发现 SKILL.md 步骤段落不完整，触发 /skill-evolve
```

## 边界与陷阱

> [!IMPORTANT]
> 本 Skill **只创建骨架**。骨架内的「步骤」「边界与陷阱」等需用户根据实际操作补全（或在第一次使用后通过 `/skill-evolve` 完善）——不要自动填充虚构的内容。

- ❌ 不要在 INDEX 同步时改其他 Skill 的行
- ❌ 不要给用户没要求的目录（如 needs_scripts=false 还是建了 .codebuddy/scripts/）
- ❌ 不要 description 写"用于 XXX 操作"这种没说"何时用"的内容
- ❌ 不要 name 与现有 Skill 重叠（包括同义词命中）
- ✅ 创建后必须在 `.codebuddy/skills/INDEX.md` 同步
- ✅ description 必须通过"何时用"测试

## 引用资料

- [SKILL_TEMPLATE.md](../../_meta/SKILL_TEMPLATE.md) —— 标准模板
- [skill-authoring-guide.md](../../_meta/skill-authoring-guide.md) —— 写作指南（命名、章节、反模式）

## 关联 Skill

- 通常由 `skill-architect` agent 配合 `/skill-new` 命令调用
- 本 Skill 完成后，如发现需要演进，调用 `self-evolution-protocol`（在 .codebuddy/skills/_meta/）

## 变更历史


| 日期  | 版本    | 变更   | 触发原因          | 操作者      |
| --- | ----- | ---- | ------------- | -------- |
| -   | 0.1.0 | 初始创建 | Phase 3 模板初始化 | template |


