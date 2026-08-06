# SOP 索引

> SOP（Standard Operating Procedure）定义了从需求到交付的协作流程。
> 模板内置两套，用户也可在此目录新增自定义 SOP。

## 内置 SOP

| SOP | 阶段数 | 适用场景 | 文件 |
|---|---|---|---|
| **agile-vibe**（默认）| 4 | 功能探索、快速原型、bugfix、技术改进、单人/小组 vibecoding | [agile-vibe.md](agile-vibe.md) |
| **deep-vibe**（备选）| 5 | 跨团队大型需求、需要正式评审的架构变更、不可回滚操作 | [deep-vibe.md](deep-vibe.md) |
| **game-design**（游戏策划）| 3 | 游戏核心玩法 / 数值 / 关卡 / 美术 / 叙事策划案细化（**只产出文档，不涉及编码**） | [game-design.md](game-design.md) |

### agile-vibe 阶段

```
1.init → 2.requirement → 3.iteration → 4.closing
                            ↻（多轮）
```

主要 agent：`product-manager`（阶段 2）→ 主会话直撸（阶段 3）→ `code-reviewer` → `closer` → `knowledge-maintainer`（阶段 4）

### deep-vibe 阶段

```
1.thinking → 2.design → 3.coding → 4.testing → 5.finalizing
```

主要 agent：`product-manager` → `tech-leader`（+ `frontend-leader` / `backend-leader` / `design-reviewer`）→ `frontend-dev` / `backend-dev` → `test-runner` → `code-reviewer` → `closer` → `knowledge-maintainer`

### game-design 阶段

```
1.init → 2.design → 3.closing
            ↻（多轮讨论）
```

主要 agent：`game-designer`（阶段 2，可调用 `image_gen` 出概念图）→ `closer` → `knowledge-maintainer`（阶段 3）

**与开发 SOP 的根本区别**：没有编码阶段，所有产出都是 `spec/` 下的策划文档。策划定稿后如需开发，新建 agile-vibe 或 deep-vibe 需求衔接。

## 选择哪个 SOP

- **默认**：`agile-vibe`
- **切换到 `deep-vibe`** 的信号：
  - 需求涉及 ≥ 2 个团队
  - 需要正式技术评审或架构变更
  - 数据 schema 重构 / 不可回滚操作
  - 需求文档需作为合同/审计依据
- **切换到 `game-design`** 的信号：
  - 游戏项目的策划细化
  - 只需要产出策划文档，不需要代码
  - 核心玩法 / 数值 / 美术需求 / 叙事的前期讨论

切换方式：在需求的 `meta.yaml` 中改 `sop: <sop-name>`，并在 `process.txt` 记录切换原因。

## 自定义 SOP

复制 [`_template_sop.md`](_template_sop.md)，按格式填写后放在本目录即可被 [`/sop-list`](.codebuddy/commands/sop-list.md) 识别。

> **修改 SOP 不能静默**——通过 [`/sop-edit`](.codebuddy/commands/sop-edit.md) 命令或 [`35-sop-self-evolution.mdc`](../.codebuddy/rules/35-sop-self-evolution.mdc) 协议走"先提案后修改"流程（5 步，与 Skill 自进化同构）。

## 与其他资产的关系

| 资产 | 关系 |
|---|---|
| 主会话（PM 角色） | 读 SOP 定义判断阶段切换 |
| `managing-requirement` skill 的 `transition_phase` operation | 校验 target_phase 在 SOP 内 |
| `requirements/<id>/meta.yaml` 的 `sop` 字段 | 决定该需求走哪个 SOP |
| `session-restorer` skill | 读 SOP 推断"下一步预期" |

## 常见问题

**Q: 需求做到一半发现 SOP 选错了，怎么办？**
A: 在 process.txt 记录切换原因，修改 meta.yaml 的 sop 字段，然后跑 `/pm-continue`。注意已经产出的 spec/design/tasks 会保留。

**Q: 强制跳阶段？**
A: 用 `/pm-phase` 命令——会要求二次确认与填理由，并在 phase_overrides 段留痕。

**Q: 自定义 SOP 该放哪个目录？**
A: 直接放 `.codebuddy/sop/<your-name>.md`。复制 `_template_sop.md` 起步。

---
*索引最后更新：v0.1.0-alpha (Phase 3 完成)*
