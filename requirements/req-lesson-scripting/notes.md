# req-lesson-scripting · 决策与发现记录

## 已确认发现

### #5 混合 sim（同屏多物理域）讨论 · 2026-08-24

**背景**：评估报告交付后用户追问"能否进一步支持不同 sim 整合成一个 sim"，引出对拖拽/坐标/命中检测基础设施的实证检查。

**结论**：
- 剧本层跨 sim 流转（节点级切换）已由方案 B 覆盖（评估报告 §3.2）
- 同屏融合（两个物理域同画布）是独立方向，未立项；"同屏共存（无域间联动）"版本技术上中等可行，"域间联动"是新物理系统级工程
- 教学价值待论证，暂记 backlog

### #6 结构性技术债：投影 3 份实现 · 命中检测分层不齐（2026-08-24 实证，用户判断确认）

**与混合 sim 正交——不管做不做混搭都要还的债**。

**投影现状（grep 实证）**：全项目 3 份投影类实现、2 套语义、0 个共享基类：

| 实现 | 位置 | 语义 |
|------|------|------|
| `CanvasProjection` | `lib/common/widgets/drag_drop_workspace.dart:16` | 光学用；origin=(W/2, H×0.55)，scale 由调用方传（光学 20） |
| `SceneProjection` ① | `lib/circuit/widgets/circuit_canvas.dart:5-11` | 电路用；origin 居中 + zoom |
| `SceneProjection` ② | `lib/circuit/screens/circuit_screen.dart:1156-1172` | **与 ① 完全重复的复制粘贴定义**（circuit 模块内部平行实现两份） |

**命中检测现状**：
- optics 走公共层 `lib/common/elements/position_element.dart:37`（hitTest）
- circuit 私有实现 `_hitTest`/`_hitTestWire`（`circuit_canvas.dart:130-135`、`circuit_screen.dart:1057`）——导线"距离阈值命中"是电路特有语义，公共层无此概念

**已有实证伤害**：Major-1/Change-1（2026-08-11，req-ui-interaction-polish）——circuit 屏混用 CanvasProjection 与 SceneProjection 导致拖放错位、点选不中；修复方式为坐标桥接（`circuit_screen.dart:172-182`），未根治结构问题。

**按项目规则已达上抽门槛**（shared-abstraction-plan 组件版 3-Time Rule）：2+ 使用者 + 1 次实证 bug + 模块内重复定义。知识库现仅有"人肉警告"（drag-drop-workspace.md:30 "新增画布时不要混用"）。

**建议**：
- 独立技术债需求立项（投影契约统一：抽公共基类/接口，保留各自 origin/zoom 语义差异；SceneProjection 双定义合并是零风险第一步）
- 若未来"混合 sim"立项，此项为其前置依赖
- 知识库 `drag-drop-workspace.md` 的 DragDropWorkspace 路径已过时（实际在 `lib/common/widgets/`，文中写 `lib/widgets/`）——knowledge-maintainer 收尾时应更新
