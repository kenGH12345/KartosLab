# My Solar System（req-my-solar-system）

> 当前阶段：1.intake · 禁止业务代码。等待用户批准后进入 Build。

## 1. 总目标

把 PhET My Solar System（本地 HTML5/TS 1.4.0-dev.4）完整迁为 Flutter 原生模拟：Intro + Lab、全部可见 preset、PEFRL N-body、原版交互。不是 WebView，不简化 Lab。

## 2. 里程碑

| 里程碑 | 完成标志 | 状态 |
|---|---|---|
| M1：Intake | spec + 源码/物理/交互/UI/资产/架构 | in_progress |
| M2：Build Vibe Loops 1–14 | 壳 → Solver → 交互 → Preset → 布局 | pending |
| M3：测试 + 三视口 | analyze / unit / widget / 截图 | pending |
| M4：Close | code-reviewer → closer → KM · status=done | pending |

## 3. 本轮目标

完成 Intake Summary，停在 Build 前。

## 4. 关键决策点

- [ ] **solar-system-common 缺失**：Build 是否沿用 Kepler 二次证据（G=4.45669、massToRadius、timeSpeedMap、modelToViewTime），还是用户补本地 common 树后再开工？推荐：先用二次证据开工，缺口标 `[BLOCKED]`，不猜 `constrainDragPoint` 最近点。
- [ ] **Orbital System 1–4**：原版 ComboBox `visible=false`（仅 PhET-iO）。推荐：数据层实现、UI 默认隐藏。
- [ ] **3-Time Rule 第 2 用户**：不改 Kepler；本 sim 内实现 Body/MVT/NumericalEngine；Close 阶段再评估上抽。
- [ ] **有意差异**（建议锁定，对齐 Kepler）：joist → AppBar+Tab；不做 PDOM / PhET-iO / 多语言 / Projector；缺 png/mp3 不自制。

## 5. 关联资源

- 源码基准：见 `meta.yaml` `source_of_truth`
- 关联需求：`req-keplers-laws`（同 solar-system-common，椭圆解析引擎，**不可复用 Solver**）
- Home：物理 → 天体力学 → 新卡片（不改 Kepler 卡片）
