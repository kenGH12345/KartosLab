# notes.md — req-inquiry-chart-extend

记录数据图表化推广——7 sim 图表适配确认 + snapshotColumns 校验 + 全量回归。

本需求为推广接线需求（无独立 spec · 复用 req-inquiry-chart-poc commit 708f7a6 的 SnapshotChart 公共组件）。

---

## 收尾沉淀（closer · 2026-08-10 19:18 · phase 4.closing）

### 已确认发现

1. **SnapshotChart 默认选轴规则是"x=第一个 param 列 · y=第一个 reading 列"**：7 sim 逐 JSON 核对后，6 sim（optics/netforce/motion/sound/radio/wave）的 `snapshotColumns` 天然符合"param×reading"数值对语义，无需改动。**唯一反例是 circuit**：原列序 `resistance(param)/voltage(reading)/current(reading)/brightness(reading)` 导致默认 y=voltage（电压恒定时是水平线），看不出 I=V/R 反比。**经验：设计 snapshotColumns 列序时，第一 reading 列应是"随探究变量最显著变化"的物理量**，否则默认图表无意义。

2. **空态文案需区分"记录不足"与"轴无数值"两种语义**：color_vision 的 y=colorName 是文本列（非数值），SnapshotChart 的 painter 会跳过非数值点 → points=0 → 图表永不出现。此时旧文案"记录 ≥2 组后自动生成"严重误导（学生记录再多也不会出图）。修复为双分支：`rows<2`（还没记录够）vs `rows≥2 但 points<2`（轴有效数值不足）。**经验：若某 sim 的 snapshotColumns 含非数值列且恰是默认 y 轴，图表必空，必须给"轴无数值"提示**，否则学生误以为功能坏了。

### 决策记录

- **D2 circuit 列序调整**：采用"调整 JSON 列序让 current 成为第一个 reading 列"方案（最小改动），而非改 SnapshotChart 选轴逻辑。理由：改组件是架构级改动，风险大；改 JSON 列序最小化且天然满足"默认 y=第一个 reading 列"规则。已确认 AC-2.4 用 Set 比较 key 与列序无关（`inquiry_snapshot_test.dart:26-27`），无回归。
- **D4 补测试方案**：新增用例直接复用 `widget.columns` 默认选轴路径（未传 xKey/yKey），与 InquiryDrawer 实际接线一致（`inquiry_drawer.dart:65`），而非手传 key 走显式路径——确保测试覆盖真实使用场景。

### 踩坑经验

- **文本列混入数值选轴会静默产生空图**：painter 对非数值点直接跳过，`points.length < 2` 时走空态分支。这是**静默失败**——不报错、不渲染，只靠文案提示。排查"图表不出现"问题时，先确认默认 y 轴列是否为数值列。
- **JSON 列序 = 默认选轴语义**：`snapshotColumns` 顺序直接决定 x/y 默认轴。改列序只影响默认选轴与表格列展示顺序，不改变数据语义（key 集合不变）。但**若测试断言列顺序则可能破**——本需求确认所有相关测试用 Set 比较，安全。

### 评审遗留记录

#### Suggestion（已接受取舍 · 不阻塞）

| 项 | 现象 | 取舍理由 | 后续建议 |
|---|---|---|---|
| S1 points==1 边界 | rows≥2 但仅 1 个有效数值点时，也走"有效数值不足 2 组"分支（当前文案已能覆盖，语义正确） | 与 color_vision 同走一条 if 分支，行为一致，非阻塞 | 若补测试，可仿 snapshot_chart_test.dart:179-192 结构构造 rows=2 但仅 1 个数值点的用例 |
| S2 x 非数值但 y 数值对称场景 | x 列非数值但 y 数值（与 color_vision 相反的对称场景）未单测 | 同走一条 if 分支，行为一致，非阻塞 | 同上，构造 x=文本列、y=数值列的用例 |

> Minor 措辞优化已在收尾前修复（"有效数值数据不足 2 组"）+ 测试断言同步，无需记录。

### 遗留项（后续迭代候选 · 全部非阻塞）

1. **forces 基线超时（独立任务）**：`forces_scenario_test.dart` netforce-tug 10 分钟死循环超时，本需求零改动 forces。建议独立排查 `flutter_test` 二次 rootBundle 加载（与 req-inquiry-extend 遗留一致）。
2. **S1/S2 对称场景补单测（可选）**：见上表，非阻塞，可后续补。
3. **auto-extract-failures 脚本不存在（流程待办）**：`.workflow/scripts/auto-extract-failures.{sh,ps1}` 不存在，自动失败提取未运行。若工程需要，建议补脚本或明确豁免。
4. **待审批 commit**：本需求 3 个目标文件 + 收尾产物未 commit。**commit 须隔离范围**——工作区有大量 phet→kratos 品牌迁移 + MNA + 中文化等非本需求改动，须按文件白名单只提交本需求 3 文件 + `requirements/req-inquiry-chart-extend/` 目录。待主会话 + 用户审批。

### 对后续需求的提示

- **快照列选轴语义**：设计 scenario JSON 的 `snapshotColumns` 时，**第一个 reading 列应是随探究变量最显著变化的物理量**，否则默认图表是水平线/空图，探究价值低。
- **非数值列作为选轴**：若某 sim 的探究维度含非数值（文本）列，注意其可能是默认 y 轴 → 图表必空。要么调整列序让数值列在前，要么接受"轴无数值"空态（本次 color_vision 走此路径）。
- **推广接线需求要产出证据链**：agile-vibe v0.2.0 要求推广接线类需求（无独立 AC）同样产出 `test-report/ac-verification.md` + `integration-test.log`。此类需求虽无 spec/AC，但收尾前**必须补证据链**，否则 code-reviewer 会报流程性 Major。
- **全量回归范围**：图表改动影响所有含 snapshotColumns 的 sim（7 sim 共用 InquiryDrawer 容器），改动组件/容器后应跑全量回归（本需求 205/205）而非只跑关联组。
