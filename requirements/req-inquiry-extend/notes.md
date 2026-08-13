# notes.md — req-inquiry-extend

做中学探究工作流推广到 5 sim（optics/forces/sound/radio_waves/wave_interference）。

---

## 收尾沉淀（closer · 2026-08-07 · phase 4.closing）

### 已确认发现

1. **推广接线模式高度可复用**：5 sim 接入 inquiry 工作流的模式**完全一致**——① scenario model 加 `inquiryTask?` 可空字段 + `fromJson` 判空；② screen 接 `InquiryDrawer`（传 `task`+`columns`+`snapshotProvider`+`open` 四参数）+ 入口按钮；③ 场景 JSON 补 `inquiryTask`。与 req-inquiry-learning 中 circuit/color_vision 的接入签名完全一致（AC-⑤ 验证）。证明通用组件 API 设计合理、接线成本极低（纯复制结构）。

2. **`snapshotColumns` key 与 snapshotProvider 返回 Map key 必须一一对应**（AC-④）：6 screen 逐一核对通过。这是接入时最常见的坑——key 不一致会导致表格列显示占位符。JSON 表头与 screen 快照回调是**双点**，改一处必须同步另一处。

3. **forces 无运行时场景切换的架构差异**：netforce/motion 是各 Tab 独立 screen 实例（`KratosTabBar` 内建），无"运行中切换场景"的路径，故无需 `_inquiryOpen` 复位（Major-2 只涉及 sound/radio/wave/optics）。

### 踩坑经验

- **`_inquiryOpen` 状态泄漏**：场景切换时若不清 `_inquiryOpen`，切换回来后抽屉会莫名重开（State 未销毁，`_inquiryOpen` 残留 true）。凡 screen 支持运行时切场景，**切场景路径必须显式复位抽屉开关状态**。
- **快照读取要同源**：motion 快照 `mass` 曾用 `totalMass`（stack 初始 0）与 `sim.mass`（scenario 10kg）不一致。教训：**快照列取值必须与用户看到的真实物理量同源**，不要用"等价但初始值不同"的字段，否则记录表与场景显示矛盾。

### 评审遗留记录

#### Minor 3（已接受取舍 · 不阻塞）

| Minor | 现象 | 取舍理由 | 后续建议 |
|---|---|---|---|
| M1 optics isVirtual | `stage==null` 时 `isVirtual` 取默认值，快照标签 '虚像?' 语义不精确 | 无成像 stage 时该物理量无意义，占位即可 | 无 stage 时对该列置 `n/a` 更精确（可选） |
| M2 wave fringeSpacing | 估算仅在**双缝模式**（`slitSeparation` 存在）有物理意义；barrier 关闭时记录意义弱 | 单缝/无边时该列无物理解 | 若需精确，按 `slitSeparation==null` 时置 `n/a` |
| M3 radio waveCount | `waveCount = frequency × 6` 为硬编码估算，非真实波峰计数 | 展示"波峰数"只需估算量级即可 | 若需精确，从 painter 真实计数波峰 |

#### Blocker-2 处理说明（工作区范围外改动隔离）

code-reviewer 首轮指出工作区混入范围外改动。经确认，以下为**非本需求**的独立改动，**commit 时必须按文件白名单排除**：

- `lib/circuit/models/circuit_solver.dart` + `circuit_state.dart` + `test/circuit/circuit_solver_mna_test.dart`：**MNA 求解器工作**（会话前遗留，已由 req-inquiry-learning 最终需求交叉证实）
- `lib/color_vision/screens/color_vision_home.dart` + `single_bulb_screen.dart`：**color_vision 中文化**（独立中文化工作）
- `lib/sound/widgets/sound_info_cards.dart`：**sound 中文化**（响度标签）

> 建议：中文化改动另立独立需求登记，避免与推广需求 commit 混在一起难追溯。

### 遗留项（后续迭代候选 · 全部非阻塞）

1. **forces 基线超时（独立任务）**：`forces_scenario_test.dart` netforce-tug 10 分钟死循环超时，forces 零改动。建议独立排查 `flutter_test` 二次 rootBundle 加载。
2. **docs/knowledge/kartosos-common/ 历史 analyze error（独立任务）**：参考文档 8 个 error（历史引入，非运行代码）。
3. **M1/M2/M3 快照占位语义优化（可选）**：见上表，无 stage/无双缝/无真实计数时的列语义可进一步精确化，但当前不影响核心探究功能。

### 对后续需求的提示

- **中文化工作**：color_vision + sound 已出现中文化改动（混在本次工作区），若后续要做"全 sim 中文化"，建议立独立需求统一推进，避免散落在各需求工作区导致 commit 难隔离。
- **其他 sim（bending-light/photoelectric 等）接入**：直接复用本需求接线模式（model 加可空字段 + screen 接 InquiryDrawer + JSON 补 inquiryTask），3 步即可。
- **快照列语义**：设计 scenario JSON 的 `snapshotColumns` 时，要考虑字段在**无对应物理状态**时（如无 stage、无双缝）的语义，提前定好占位规则，避免快照显示误导学生。
- **场景切换状态复位**：任何支持运行时切场景的 sim，在切场景路径统一复位抽屉开关等 UI 状态，形成约定。
