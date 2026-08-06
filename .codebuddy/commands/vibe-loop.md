---
description: "在当前需求上做一轮 vibecoding 迭代（小改→可视反馈→记进度）"
argument-hint: "<req-id>"
allowed-tools: [Read, Edit, Write, Bash, Glob, Grep, AskUserQuestion, Task]
model: sonnet
---

# /vibe-loop — Vibecoding 迭代一轮

> [!NOTE]
> 本命令面向 **agile-vibe SOP 阶段 3（迭代开发）**。
> 适合：用户想"再迭一轮"——加一点功能、跑一下、看效果、记进度。
> deep-vibe 流程下不建议用此命令，应走标准 SOP 流转。

## 步骤

### 1. 解析 req-id

从 `$ARGUMENTS` 取。如缺失，列出 `status=in_progress` 且 `phase` 在迭代阶段的需求让用户选。

### 2. 现场恢复

```
读 meta.yaml（确认 sop=agile-vibe 且 phase 在迭代阶段）
读 process.txt 最近 10 行
读 plan.md 第 3 节"本轮迭代目标"
```

如不是 agile-vibe 或不在迭代阶段：建议改用 `/pm-continue`。

### 3. 用 AskUserQuestion 收集本轮目标

```
- 本轮要做什么？（一句话）
- 验证方式？（默认：跑预览/截图、跑单测）
```

### 4. 执行迭代（vibecoding 五原则）

**严格遵守**规则 `10-vibecoding-protocol.mdc`：

```
1. 30 分钟原则：本轮目标必须能在 30 分钟内拿到可见反馈
2. 小步快跑：单次只改一件事
3. 可视反馈：改完后必须跑预览/截图/单测
4. 状态先写：改之前先在 process.txt 写"打算做什么"，改完写"做了什么"
5. 3-Time Rule：如果发现这是同类操作的第 3 次，提示用户考虑 /skill-new 封装
```

### 5. 提交（须用户审批）

SVN commit = 立即推送到服务器，不可撤销。按 SVN 安全红线执行：

```
1. 运行 svn status — 展示变更文件清单
2. 运行 svn diff — 展示内容变更
3. 告知用户"即将提交到 SVN 服务器，此操作不可撤销"
4. 获得用户 y/n 确认
5. svn commit -m "vibe(<req-id>): <一句话>"
```

### 6. 更新 process.txt

```
[time] 迭代轮次 N
  目标: <本轮目标>
  改动: <文件简述>
  验证: <截图/测试结果>
  revision: r<N>
  下一步打算: <可选>
```

### 7. 询问用户

```
本轮完成。下一步？
- 再迭一轮（重新触发 /vibe-loop）
- 进入收尾（触发 /code-review）
- 暂停（保留 process.txt 即可）
```
