# quality-heuristics.md — 经验质量启发式

> 经验条目质量评估和"直觉"晋升判定的启发式规则。
> 从早期 `.workflow/{instincts,quality-gate-state}.json` 设计中抽取，作为 skill references 沉淀。

## 1. 经验质量评分权重

| 维度 | 权重 | 说明 |
|---|---|---|
| frontmatter 完整（type/source_req/extracted_at 齐全） | 25% | 缺任一字段则该项计 0 |
| 三段结构（`## 场景` / `## 问题分析` / `## 解决方案`） | 25% | 三段全在计满，缺一段按比例扣 |
| 方案可验证（含 file:line 或 commit sha 或运行结果） | 30% | 空口理论不给分 |
| 来源可追溯（req-id + 日期） | 20% | 无法回源的经验直接判 0 |
| **及格线** | **≥ 0.70** | 低于则回炉，不入库 |

## 2. 直觉晋升三条件（必须全部满足）

- 该经验被检索使用 ≥ **3 次**（对应 3-Time Rule）
- 质量分 ≥ **0.70**
- 存在时间 ≥ **7 天**（避免刚沉淀就晋升，需经过冷却验证）

满足全部三条 → 建议从普通经验晋升为"直觉"（存 `context/shared/experiences/instincts/` 或对应位置）。

## 3. 经验入库门禁（Warning 级，不 block）

- 同一 `source_req` 最多 **5 条**（避免单需求灌水）
- `auto-extracted` 状态必须人工审核（`status: draft` → 用户 y/n → `status: verified`）
- 缺失 frontmatter 必填字段 → 提示补全后再入库

## 4. 使用位置

- **self-improving-agent skill** 扫描 `process.txt` / `notes.md` 抽取候选经验时 → 用第 1 节评分打分
- **managing-knowledge skill** 沉淀经验到 `context/shared/experiences/` 时 → 用第 3 节做入库校验
- **主会话在新 session 启动** 决定是否读取某条经验 → 参考第 2 节判断是否已晋升"直觉级"

## 来源

- 原设计：`.workflow/instincts.json` + `.workflow/quality-gate-state.json`（2026-05-28）
- 迁移原因：`.workflow/` 工作流引擎路线放弃（2026-07-23），价值内容合并入 skill references
- 与 `10-vibecoding-protocol.mdc` 第 5 条 3-Time Rule 对齐
