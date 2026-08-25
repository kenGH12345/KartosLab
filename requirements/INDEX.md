# 需求索引

> 所有需求的总览。每个需求一个独立目录，命名 `req-<short-id>`。
> 本文件由 `.codebuddy/scripts/rebuild-index.sh` 自动生成，**不要手动编辑**。

## 需求清单

| 需求 ID | 标题 | 状态 | SOP | 阶段 |
|---|---|---|---|---|
|  | AI 场景生成工具链闭环（A 任务） | in_progress | agile-vibe | 2.requirement |
| req-color-vision-layout-fix | 修复 color_vision single_bulb 屏窄视口下主图消失（L0-2/L0-3 违规） | in_progress | agile-vibe | 3.iteration |
| req-criteria-composable | successCriteria 可组合条件升级 + 计分规则配置化（LLM 生成能力第 3 层） | in_progress |  | 4.closing |
| req-home-screen-overflow-fix | 修复 HomeScreen → ColorVisionHome 导航链某 Column 在 1600x900 视口下 overflow 49px | done | agile-vibe | done |
| req-inquiry-chart-extend | 记录数据图表化推广——7 sim 图表适配确认 + snapshotColumns 校验 + 全量回归 | done | agile-vibe | 4.closing |
| req-inquiry-chart-poc | 记录数据图表化 POC——SnapshotChart 公共组件 + ExperimentLogger 数据暴露 + circuit 单 sim 验证 | in_progress | agile-vibe | 4.closing |
| req-inquiry-extend | 做中学探究工作流推广——optics/forces/sound/radio_waves/wave_interference 接入 | done | agile-vibe | 4.closing |
| req-inquiry-learning | 从"可视化可操作"到"做中学"——探究工作流整体升级（通用组件 + 2 pilot sim） | done | agile-vibe | 4.closing |
| req-lesson-runtime | 教学剧本 lesson-plan 编排层实现（P1 线性 + P2 条件分支 + P3 AI 生成链路） | in_progress | deep-vibe | 3.coding |
| req-lesson-scripting | 教学剧本：多场景流程编排评估（场景解锁/分支/课时序列） | in_progress | deep-vibe | 2.design |
| req-nine-grid-layout | 9宫格强制屏幕适配方案（中间格面积 ≥70% · 周边8格贴边自适应 · 全部 7 sim 强制迁移） | done | agile-vibe | 4.closing |
| req-panel-bottom-migrate | 操作面板底部横排推广——其余 9 屏底部迁移（molarity 试点验收后的推广迭代） | done | agile-vibe | done |
| req-port-molarity | molarity 摩尔浓度 sim 复刻——Flutter 化学模块首个（24 文件最小蓝本 · EDD v2.0 全流程） | done | agile-vibe | 4.closing |
| req-predictive-inquiry | 探究预测题（猜测→验证）功能 | in_progress | agile-vibe | 3.iteration |
| req-single-bulb-inquiry | 色觉单光源屏接入做中学探究抽屉（InquiryDrawer） | done | agile-vibe | 4.closing |
| req-ui-interaction-polish | 主界面交互优化与实验引导通用化——学科编排 + ExperimentIntroPanel + 操作面板统一布局 | done | agile-vibe | done |
| req-unify-projection-layer | 投影层统一技术债——两套平行投影合并公共层 + 消除混用转换 workaround + 命中检测上抽 | done | agile-vibe | 4.closing |
| req-verify-selftest-color-vision | 验证 agile-vibe v0.2.1 第9条 AI 自主功能测试闭环（靶子=color_vision sim） | in_progress | agile-vibe | 3.iteration |

---
*索引自动生成于：2026-08-25 10:23*
