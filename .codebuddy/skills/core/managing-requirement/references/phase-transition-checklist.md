# 阶段切换检查清单

> 本清单适用于 `managing-requirement` Skill 的 `transition_phase` 与 `force_phase` operation。
> 严格按规则 `45-state-sync-protocol.mdc` 的"先写状态后做事"顺序执行。

## 通用检查（所有切换都过）

- [ ] 取真实时间戳：`date "+%Y-%m-%d %H:%M"`
- [ ] Read 当前 `meta.yaml`，记录 `prev_phase` / `prev_status`
- [ ] 校验 target_phase 严格匹配 SOP 中的 `<id>.<name>` 组合（id 与 name 必须出自 SOP phases 同一项，不允许 4.coding 这种 id↔name 错位）
- [ ] 写 `meta.yaml`：phase / status / updated_at
- [ ] `process.txt` 追加切换日志
- [ ] **不**自动委派下游 agent（调用方决定）

## 各阶段切换的额外检查

### → agile-vibe / 1.init

- [ ] req-id 不重复
- [ ] 目录骨架已创建
- [ ] INDEX 已同步

### → agile-vibe / 2.requirement

- [ ] 上一阶段 status = done
- [ ] （进入此阶段前提：用户确认开始需求定义）

### → agile-vibe / 3.iteration

- [ ] `spec/需求简述.md` 存在且非空
- [ ] 至少有 1 条验收标准

### → agile-vibe / 4.closing

- [ ] 用户已判定"功能基本完成"
- [ ] 至少有 1 个 commit 关联本需求

### → deep-vibe / 1.thinking

- [ ] 同 agile-vibe / 1.init

### → deep-vibe / 2.design

- [ ] `spec/需求文档.md` 存在
- [ ] 验收项已编号（AC-1, AC-2, …）
- [ ] 待确认项均已关闭（无 [待确认]）

### → deep-vibe / 3.coding

- [ ] `design/技术方案.md`（终版）存在
- [ ] `tasks/features.json` 存在且非空
- [ ] `design/方案评审.md` 评审结论为通过

### → deep-vibe / 4.testing

- [ ] tasks/features.json 中所有任务 status = done
- [ ] linter / 编译已通过

### → deep-vibe / 5.finalizing

- [ ] `design/测试报告.md` 评审结论为通过
- [ ] 新增失败 = 0

### → 任何阶段（force_phase）

- [ ] 调用方已提供非空 `reason`
- [ ] `meta.yaml` 的 `phase_overrides` 段已追加记录
- [ ] `process.txt` 追加额外的 ⚠️ 标记
- [ ] **不**校验当前阶段产物（这是 force 的特征）

## 何时该 stop + report 而非切换

| 情况 | 应该 |
|---|---|
| 上述检查项有任意一项不满足 | stop + report，让调用方决定补做或 force |
| meta.yaml 与 process.txt 已经不一致 | 提醒跑 /doctor 修复后再切换 |
| 调用方要求切换到 SOP 未定义的 phase | 拒绝并列出合法 phase 列表 |
| 当前 status = blocked 且未提供解除 blocked 的依据 | stop + report |
