---
description: "归档某需求（移到 _archived/）"
argument-hint: "<req-id>"
allowed-tools: [Read, Edit, Bash, AskUserQuestion]
model: sonnet
---

# /req-archive — 归档需求

## 何时归档

- 需求长期不再演进
- 已完成且不期望再追加 Change-N
- 项目重构/废弃需要清理需求列表

**不归档**：刚 done 但可能后续有变更的需求 → 保留在原位

## 步骤

### 1. 解析参数

从 `$ARGUMENTS` 取 `<req-id>`。

### 2. 检查状态

读 `meta.yaml`：
- `status: done` → 可归档
- 其他 → 警告并要求用户二次确认（可能丢失进行中的工作）

### 3. 二次确认

```
即将归档需求: <req-id>
当前状态: <status>
当前阶段: <phase>
最近更新: <updated_at>

归档后将移到 requirements/_archived/<req-id>/，
INDEX 表格不再显示，但目录保留。

是否继续？(yes/no)
```

只接受完整 `yes`。

### 4. 移动目录

```bash
mv requirements/<req-id> requirements/_archived/
```

### 5. 更新 INDEX

- `requirements/INDEX.md`: 从主表删除该行（或移到"已归档"段）
- 

### 6. 输出

```
✓ 已归档 req-<id>
  从 requirements/<req-id> → requirements/_archived/<req-id>
  INDEX 已更新
  
如需恢复：mv requirements/_archived/<req-id> requirements/
```
