# phet 项目级 notes

> 用途：项目级"决策 / 踩坑 / 参考链接" 沉淀（对应 `45-state-sync-protocol.mdc` §四件套 中的 `notes.md`）。
> 与需求级 notes 的区别：本文件跨需求、跨 session 保留，只写"未来 agent 需要知道"的项目级知识；与 `INDEX.md` 的区别：INDEX 是索引，本文件是"经验 / 决策"。

---

## 决策记录

### 2026-07-20 · 配置化升为项目硬约束（§C1-§C4）

- **授权**：用户拍板 Q1=A · Q2=B · Q3=C · Q4=C
- **落地**：`architecture/design-patterns.md` §配置化项目硬约束 + `architecture/ai-generation-readiness.md` status=adopted-framework-standard
- **影响**：所有模块必须走 ScenarioManager + JSON 驱动 + AI 工具链（prompt + schema + ≥3 samples）；新模块加入按同标准立项。

### 2026-07-21 · 三模块 §C1-§C3 全合规达成

三个模块在同一天完成配置化 + AI 工具链补齐：

| 模块 | ScenarioManager | JSON 场景数 | AI Prompt | JSON Schema |
|---|---|---|---|---|
| optics | ✅ `lib/optics/config/scenario_manager.dart` | 3 | ✅ `docs/prompts/optics_scenario.md` | ✅ `schemas/optics_scenario.schema.json` |
| circuit | ✅ `lib/circuit/config/scenario_manager.dart` | 7 | ✅ `docs/prompts/circuit_scenario.md` | ✅ `schemas/circuit_scenario.schema.json` |
| forces | ✅ `lib/forces/config/forces_scenario_manager.dart` | 5 | ✅ `docs/prompts/forces_scenario.md` | ✅ `schemas/forces_scenario.schema.json` |

**关键顺序**：先 circuit → forces → 最后补 optics AI 工具链（其配置化本身早已存在，仅缺 AI 生成配套）。

### 2026-07-21 · 光学元件拖动体验修复（相对位移 vs 绝对跳跃）

- **问题**：场景初始化的元件"很难拖动"——需要两次手势操作（先点击选中再按住）。
- **根因 A**：`onTapUp` 与 `onScaleStart` 互斥，导致必须先点击。
- **根因 B**：`onScaleUpdate` 直接把元件中心跳到手指绝对位置，用户按边缘拖时视觉跳格。
- **修法**：`_OpticsScene` 改 StatefulWidget，用 `_dragId + _dragElementStart + _dragPointerStart` 三锚点记录初始位移；`newPos = _dragElementStart + (currentPointer - _dragPointerStart)`。
- **教训**：Flutter 手势系统里，`onScaleStart` 天然承担"按下"职责，不要期待 `onTapDown` + `onScaleUpdate` 组合能覆盖所有场景。

### 2026-07-21 · 电路导线折线功能补齐

- **状态断层**：数据模型（`WireSegment.controlPoints` + `addControlPoint/moveControlPoint/removeControlPoint/buildPath`）+ 渲染层完整，但 UI 无双击入口——"能显示、能拖、但不能创建"。
- **修法**：`GestureDetector.onDoubleTap` + `_doubleTapWorld` 缓存 + `_onDoubleTap` 分派：
  - 双击拐点手柄 12px 内 → 删除
  - 双击导线空白段 → 在最近线段插入
  - 双击元件/画布 → 无效果（防误触）
- **相邻功能兼容**：双击元件已用于开关切换，本次逻辑靠"最近命中优先"分派避免冲突。

### 2026-07-21 · 光学求解器 6 处修复（#1-#6）

关键修法（详细见 commit 历史）：

| # | 问题 | 修法 |
|---|---|---|
| 1 | `ImageInfo.focalLength` 字段返回物距 | 引入 `lastFocalLength` 变量正确赋值 |
| 2 | 透镜公式在 3 处独立实现 | 统一调用 `OpticsMath.imageDistance` |
| 3 | `_extendFrom` 双份 | 旧求解器改调 `OpticsMath.extendFrom` |
| 4 | 镜面反射仅平面 | 新增球面反射逻辑 + 小曲率半径回退 |
| 5 | 光屏检测仅左→右单向 | 用叉积判同侧支持双向 |
| 6 | 新旧 `SolvedOptics` / `RayPath` 混淆 | 旧求解器头部加 🗑️ legacy 注释 |

### 2026-08-07 · 9宫格强制屏幕适配方案（NineGridLayout）

- **授权**：用户拍板"公共通用方案 · 所有 sim 都要支持 · 强制要遵守" + "全部立即迁移"
- **落地**：`lib/common/widgets/nine_grid_layout.dart`（L0 通用组件）+ `.codebuddy/rules/80-phet-sim-checklist.mdc` §七 L0-4（阻塞级）+ `shared-abstraction-plan.md` 候选 7
- **核心规则**：屏幕划为 3×3 九宫格 · 中间格**面积 ≥ 70%** 屏幕（宽高各 `sqrt(0.7)`≈0.837 屏 · 边条各≈8%）· `centerAreaRatio` 下限 0.7 强制 clamp · 周边 8 格贴边放"信息展示 + 交互控件混合" · 无 `Positioned` / 无硬编码像素
- **迁移共性**：7 sim 9 主屏已全部迁移（`req-nine-grid-layout`）· 长文本知识卡改弹窗 · 横排 chips 改 `Wrap` · 每格 `SingleChildScrollView` 兜底防溢出（L0-2 合规）· 拖拽工作区类（optics/circuit）整体入中间格
- **教训**："占 N% 屏幕"必须先澄清含义（面积 vs 宽高）——本需求曾两次误解（先等分、后宽高各 70%），最终用户确认为面积 ≥70%

---

## 踩坑

### 2026-07-21 · 知识库权威源同步失责

- **现象**：多轮任务里我（AI）修完代码只顺手改 `INDEX.md`，漏改 `architecture/design-patterns.md` §各模块合规现状表（权威源），导致索引层比源头更新。
- **根因**：违反 `20-verify-before-act.mdc` §知识库优先——每次动手前应先读权威源，动手后应回写权威源，我把权威源当"最后才读的文档"。
- **补救**：本次审查一并修 `design-patterns.md` §合规表 + `ai-generation-readiness.md` migration_status + `module-index.md` 文件数 + `optics-module.md` §C3 引用 + 新建本 `notes.md`。
- **提醒未来的 agent**：修 §C1-§C3 相关代码后必须回头核对**四份权威文档**：
  1. `architecture/design-patterns.md` §各模块合规现状
  2. `architecture/ai-generation-readiness.md` migration_status + artifacts
  3. `systems/module-index.md` §设计原则对照总表
  4. `systems/<module>-module.md` §场景配置系统

### 2026-07-21 · `module-index.md` 文件数漂移

- **现象**：文档写 "55 个 .dart"，磁盘实际 54 个。
- **根因**：批量加 `lib/circuit/config/` 5 个文件时按算数加，但同期可能有别处删除未同步。
- **保底手段**：每次改文件数前跑 `Get-ChildItem lib -Recurse -Filter '*.dart' | Measure-Object`；不要凭"上次 + 增量"心算。

---

## 参考链接

- 权威源入口：[INDEX.md](INDEX.md)
- 配置化条款：[architecture/design-patterns.md · §配置化项目硬约束](architecture/design-patterns.md)
- AI 生成完整评估：[architecture/ai-generation-readiness.md](architecture/ai-generation-readiness.md)
- 外部资产：
  - `C:\workspace\phet\docs\prompts\{circuit,forces,optics}_scenario.md`
  - `C:\workspace\phet\schemas\{circuit,forces,optics}_scenario.schema.json`
  - `C:\workspace\phet\assets\scenarios\` （optics 3 + circuit 7 + forces 5 = 15 samples）
