# 真实流程示例

> 本文件从实际测试项目摘录，展示模板在真实使用中的流程和产物。
> 用于新用户快速理解"跑起来是什么样的"。

---

## 示例 1：deep-vibe 全 5 阶段（连连看 H5 小游戏）

**项目**：testV10  
**需求**：req-link-game（连连看 H5 小游戏）  
**SOP**：deep-vibe  
**复杂度**：simple  
**总用时**：约 15 分钟（含 AI 执行时间）

### 流程摘要

```
init.sh 初始化 → new-requirement.sh 创建骨架
    ↓
阶段 1（1.thinking）：委派 product-manager
    产出：spec/需求文档.md（9 功能点、28 个 AC）
    ↓
阶段 2（2.design）：委派 tech-leader
    产出：design/技术方案.md + tasks/features.json（11 个任务）
    ↓
阶段 3（3.coding）：委派 frontend-dev
    产出：index.html（914 行，24.9KB）
    ↓
阶段 4（4.testing）：跳过（simple 复杂度，记 phase_overrides）
    ↓
阶段 5（5.closing）：code-reviewer → closer
    产出：代码评审.md + spec/最终需求.md + spec/AC-coverage.md
    ↓
status: done ✓
```

### process.txt 实录

```
[2026-05-08 13:55] init: 需求骨架创建完成（deep-vibe SOP）
[2026-05-08 13:55] phase 1.init → 1.thinking: 进入需求澄清，委派 product-manager
[2026-05-08 13:56] product-manager: 需求分析完成，产出 spec/需求文档.md + spec/context/来源归档.md
[2026-05-08 13:57] phase 1.thinking → 2.design: 进入方案设计，委派 tech-leader
[2026-05-08 14:00] tech-leader 完成，产出 design/技术方案.md + tasks/features.json（11 任务）
[2026-05-08 14:00] phase 2.design → 3.coding: 进入编码实现，委派 frontend-dev
[2026-05-08 14:05] frontend-dev 完成 TASK-1~TASK-11 编码，commit 6667643，28 个 AC 全覆盖
[2026-05-08 14:29] verdict=approve_go / 备注: 编码完成，用户确认进入收尾
[2026-05-08 14:29] phase 3.coding → 5.closing: simple 复杂度跳过 4.testing，进入收尾
[2026-05-08 14:30] code-reviewer 完成，评审结论：0 Blocker / 1 Major / 5 Minor
[2026-05-08 14:30] verdict=approve_go / 备注: Major 降级为 Minor，不阻塞收尾
[2026-05-08 14:35] closer 完成收尾，产出 spec/最终需求.md + spec/AC-coverage.md
[2026-05-08 14:36] phase 5.closing → done: 需求完成
```

### 最终目录结构

```
requirements/req-link-game/
├── meta.yaml            # status: done, completed_at: 2026-05-08 14:35
├── process.txt          # 13 行完整日志
├── notes.md             # 踩坑 + 决策 + 项目级发现候选
├── plan.md              # 里程碑（模板骨架）
├── spec/
│   ├── 需求文档.md      # 284 行，9 功能 + 28 AC
│   ├── 最终需求.md      # 收尾快照
│   ├── AC-coverage.md   # 28/28 全覆盖矩阵
│   └── context/
│       └── 来源归档.md  # 6 条来源
├── design/
│   ├── 技术方案.md      # 432 行，含算法伪代码
│   └── 代码评审.md      # 192 行，三视角评审
└── tasks/
    └── features.json    # 11 个任务（全 pending，由 dev 一次性实现）
```

### 关键观察

1. **主会话只做编排**：不写代码、不写需求文档、不做技术判断
2. **每次阶段切换**：先写 meta.yaml + process.txt + rebuild-index.sh，再委派
3. **跳阶段有据可查**：phase_overrides 记录了跳过 4.testing 的原因
4. **收尾三 agent 串联**：code-reviewer 发现问题 → closer 产出最终文档
5. **rebuild-index.sh 自动同步**：INDEX.md 始终与 meta.yaml 一致

---

## 示例 2：agile-vibe 快速迭代（定时提醒 H5 工具）

**项目**：testV9  
**需求**：req-reminder（定时提醒 H5 小工具）  
**SOP**：agile-vibe  
**总用时**：约 3 分钟

### 流程摘要

```
init.sh → new-requirement.sh → 直接跳到 3.iteration → 主会话写代码 → commit
```

### process.txt 实录

```
[2026-05-08 11:13] init: 需求骨架创建完成（agile-vibe）
[2026-05-08 11:13] phase 1→3: 简单需求，直接进入迭代开发
[2026-05-08 11:14] iteration: 主会话实现 index.html — 多提醒管理、定时检测、浏览器通知+音效、localStorage 持久化
```

### 关键观察

1. **agile-vibe 阶段 3 主会话直接编码**：不委派 dev agent
2. **简单需求可以跳过需求澄清**：1.init → 3.iteration
3. **比 deep-vibe 快 5 倍**：3 分钟 vs 15 分钟

---

## 选择 SOP 的决策依据

| 如果… | 选 |
|---|---|
| 单人、需求明确、< 500 行代码 | agile-vibe |
| 需要多人协作 / 需求复杂 / 有评审要求 | deep-vibe |
| 不确定 | 先 agile-vibe，复杂了再切（`/pm-phase` 命令） |

---
*最后更新：2026-05-08*
