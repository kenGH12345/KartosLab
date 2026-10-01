# My Solar System —— 笔记与沉淀

## 已确认发现

- 版本 `1.4.0-dev.4`，非 git 工作副本。
- 这是 **N-body PEFRL**，不是 Kepler 椭圆解析。
- Lab 字符串是 **Slingshot / Double Slingshot**，不是用户任务里的 Flyby。
- Return Bodies = `restart()`。
- Follow CoM **按钮**出现条件是派生量 `|r_com|≥1 或 |v_com|≥0.01`，不是用户勾选的「跟随模式」。
- 碰撞不合并质量。
- PEFRL 五步共用一轮加速度（不中途更新力）。
- `engineTimeScale=0.05`；zoom 默认 4 → scale 85。
- OS1–4 ComboBox `visible=false`。
- Four Star Ballet 把重力缩放打到 -1.1（避免「offensive symbol」）。
- 本机无 solar-system-common；与 Kepler `[BLOCKED]` 相同根因。
- `doc/model.md` 的 G=4.4567e-3 与 SUN_PLANET 速度不自洽。

## 开发踩坑

- Loop 6 机械能 golden 曾双计 PE — 改为 i<j 单对 + 相对漂移阈值。
- `numerical_regression_test` 需 `TestWidgetsFlutterBinding.ensureInitialized()` 才能 load assets。
- VisibilityPanel 375px Row 溢出 — `FittedBox` + 紧凑 IconButton（Loop 5）。

## Close（2026-09-02）

- Phase 3 Close 完成：`status=done`，135 module tests，analyze 0 issues。
- 见 `CLOSE_REPORT.md`、`LOOP6_PHYSICS_AUDIT.md`。
- 知识库：`docs/knowledge/kratos-java-simulations/edd/my-solar-system-migration.md`。

## 决策记录

- Intake 由主会话完成源码逆向（见 architecture §8）。
- 目录走 `lib/astronomy/my_solar_system/`。
- 本需求不修改 Kepler。
- 2026-09-01 Build：G 用 Kepler 二次证据 4.45669（见 `G-SOURCE-OF-TRUTH.md`）。OS1–4 `comboVisible=false`。
- V1 Time 控件曾放 NineGrid **footer**。Loop 2 已迁到右上 `TimePanel`（AlignBox 证据：margin 10），footer 删除。Reset All 仍在右下（原版 `resetAllButton` 不在 TimePanel 内）。

## 推迟的 Major 项

- 完整 `constrainDragPoint` 最近点（缺父类源码）
- 音效 / pathIcon png
- PhET-iO OS1–4 UI
- Projector / PDOM / i18n

## 遗留 TODO

- 用户补 `solar-system-common` 本地树后，用文件字面量覆盖 G、mass range、MAX_PATH、MASS_SLIDER_STEP、modelToViewTime、`centerOrbitOffset` MVT。
- EDD 12 章全文（v2.0）可基于 `my-solar-system-migration.md` 扩展。
- `requirements/INDEX.md` 当前仓库不存在，未跑 docs-index-updater。

## Close 状态（2026-09-02）

**done** · 见 `CLOSE_REPORT.md` · 135 tests · analyze 0 issues。
