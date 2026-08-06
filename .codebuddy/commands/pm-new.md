---
description: "创建一个新需求，初始化目录骨架并启动需求澄清"
argument-hint: "[req-id]"
allowed-tools: [Bash, Write, Read, Edit, AskUserQuestion, Task]
model: claude-opus-4.7-1m
---

# /pm-new — 新建需求

请按以下步骤推进，**严格遵守 SOP 阶段切换的"先写状态后做事"顺序**（参见规则 `45-state-sync-protocol.mdc`）。

## 步骤

### 1. 收集元数据

用 `AskUserQuestion` 一次性问：

- **req-id**：短标识（kebab-case，如 `user-profile-edit`）。如用户在 `$ARGUMENTS` 已提供则直接用
- **title**：需求标题（中英文均可）
- **SOP**：`agile-vibe`（默认，4 阶段轻量）/ `deep-vibe`（5 阶段含正式评审）
- **代码目录**：用 `AskUserQuestion` 提供以下 6 个选项：

| 选项 | 版本 | 代码路径 |
|---|---|---|
| `trunk` | Wepop（国内） | /data/home/chennychen/trunk/dev/src |
| `Wepop_release` | Wepop（国内） | /data/home/chennychen/Wepop_release/dev/src |
| `Wepop_release_YJ` | Wepop（国内） | /data/home/chennychen/Wepop_release_YJ/dev/src |
| `KartRider_Trunk` | KartRider（国际） | /data/home/chennychen/KartRider_Trunk/dev/src |
| `KartRider_International_Release` | KartRider（国际） | /data/home/chennychen/KartRider_International_Release/dev/src |
| `KartRider_International_Release_YJ` | KartRider（国际） | /data/home/chennychen/KartRider_International_Release_YJ/dev/src |

用户选择后自动解析：
- `repo_key` = 选项名（如 `trunk`、`KartRider_Trunk`）
- `repo_path` = 对应的代码路径
- `variant` = KartRider 开头的选项 → `KartRider`，其余 → `Wepop`

- **是否需求来自 TAPD/Wiki/PRD 链接**：是 → 继续问链接

### 2. 检查 req-id 不冲突

```bash
ls requirements/req-<req-id> 2>/dev/null
```

存在 → 提示用户改名或用 `/pm-continue`。

### 3. 创建需求骨架

调用 `.codebuddy/scripts/new-requirement.sh`：

```bash
./.codebuddy/scripts/new-requirement.sh -i <req-id> -t "<title>" -s <sop> -k <repo-key>
```

脚本会自动解析 `variant`、`repo_path` 并替换所有占位符。

### 4. 更新需求索引

- `requirements/INDEX.md` 由 `rebuild-index.sh` 自动重建

### 5. 委派 product-manager

用 `Task` 工具委派 `product-manager` agent：

```
prompt 应包含：
- 需求 ID 与目录路径
- 用户提供的需求素材（链接 / 文本 / 截图说明）
- SOP 类型（决定输出文件名：需求简述.md vs 需求文档.md）
- variant（Wepop / KartRider）——决定读取哪个知识库
- 提示：先加载 context/project/WepopAIVibeCodingProj/<variant>/INDEX.md 了解业务背景
```

### 6. 等待 product-manager 返回

按返回的 `当前状态` 处理：
- `completed` → 通知用户，建议下一步（agile-vibe 直接进迭代；deep-vibe 委派 tech-leader）
- `awaiting_user_input` → 把 product-manager 的提问转给用户，**用户回答后重新委派 product-manager**（不要自己整理回答写文档）

## 输出

- 在 `process.txt` 追加："[time] 需求初始化完成，进入阶段 1（需求定义），委派 product-manager"
- 向用户汇报：
  - 需求目录路径
  - 当前阶段
  - 版本（variant）与代码目录
  - product-manager 的初步反馈摘要
