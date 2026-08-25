# AC 验证报告 — req-unify-projection-layer

> 验证时间: 2026-08-24 21:20 · MT-6 全量回归
> 测试命令: `flutter test`（全量）/ `flutter test integration_test/app_test.dart -d windows`（集成）
> 单测产物: `test/common/geometry/projection_test.dart`（11 用例）+ `test/common/geometry/hit_test_test.dart`（9 用例）

## 逐 AC 核查

### AC-1 投影类统一且位于公共层 — ✅

- **类型**: 结构性（自动化可验）
- **证据**: `lib/common/geometry/projection.dart:12` 为 `class SceneProjection` 唯一定义（grep `class \w*Projection` lib/ 唯一命中）；`CanvasProjection` 与 circuit 两处 `SceneProjection` 重复定义全部删除；origin 参数化 + zoom 默认 1.0 + toScreen/toWorld/toScreenLength
- **测试**: `test/common/geometry/projection_test.dart` 11/11 通过（①旧 CanvasProjection 语义等价 ②zoom 三档往返恒等 ③toScreenLength ④默认参数 ⑤组合极值）
- **登记**: `shared-abstraction-plan.md` 候选 10 已登记（2 使用者证据 + 接入模式 + 禁止平行实现条款）

### AC-2 circuit 拖放落点回归（workaround 移除） — ✅

- **类型**: 交互类（integration_test 覆盖）
- **证据**: `_onComponentDrop` 转换 workaround 与 `_canvasSize` hack 整体删除（circuit_screen.dart 现为直接 `_addComponent(type, worldPos)`）；DropCanvas 经 `projectionFactory` 注入同一投影实例
- **测试**: `integration_test/app_test.dart` 用例通过：`place battery from tray` / `place multiple components` / `place and select component`（拖放落点 + 点选命中）/ `delete selected component`
- **手动 zoom 三档抽验**: 未验证 / 需人工抽验（v0.2.0 视觉证据可选；zoom 正确性由 AC-4 单测 + zoom in/out 集成用例覆盖）

### AC-3 optics 光轴行为保持 — ✅

- **类型**: 行为等价（单测锚定 + widget 测试）
- **证据**: DropCanvas 默认工厂 origin=(w/2, h*0.55) 数值逐位不变；`optics_screen.dart` 光轴渲染 `top: projection.origin.dy - 1` 消费点不变；`scale: 20` 保留
- **测试**: `projection_test.dart` ①组（scale=20 语义等价）；全量 widget 测试 364 通过（含 optics 布局/交互用例）
- **截图比对**: 未验证 / 需人工抽验（v0.2.0 可选）

### AC-4 zoom 语义保留 — ✅

- **类型**: 行为等价（单测 + 集成）
- **测试**: `projection_test.dart` ②组（zoom=0.6/1.0/2.0 往返恒等 + 公式核对）；`integration_test` `zoom buttons work` / `zoom in increases percentage` / `zoom out decreases percentage` 通过

### AC-5 _hitTestWire 平行实现收敛 — ✅

- **类型**: 结构性（grep + 对拍）
- **证据**: `grep _hitTestWire` 唯一定义于 `lib/circuit/screens/circuit_screen.dart:1041`；死代码文件 `circuit_canvas.dart` 已删除（删前复核 CircuitCanvas 零外部引用）；15px 阈值与命中编排不变
- **测试**: `hit_test_test.dart` 9/9 通过（含⑤与旧内联公式 8 点×4 段逐位对拍）
- **评审整改（M1）**: code-reviewer 发现第三份平行实现 `circuit_state.dart:155-167` 的 `_pointToSegmentDistance`（活代码，被 `addControlPoint` 调用）——已改调公共 `pointToSegmentDistance` 并删除私有副本，spec §2 目标 3「消除平行实现」彻底达成

### AC-6 flutter analyze 无新增 issue — ✅

- **类型**: 静态门禁
- **证据**: `dart analyze lib test` 0 error；issues 数 39（全部为 curly_braces 等历史遗留 info + optics unused_import 基线 warning，git show 确认非本需求引入）

### AC-7 flutter test 回归 — ✅

- **类型**: 回归门禁
- **证据**: `flutter test` 全量 **369 passed + 1 skipped**（评审整改后新增 5 个接线用例），无新增失败

## 集成测试备注

`integration_test/app_test.dart` 15/16 通过。唯一失败 `navigate to optics simulation` 为 pumpAndSettle 超时（非坐标断言失败）。**code-reviewer 完成代码级根因闭合**：全仓仅 3 处 `repeat()` 无限动画，全部属并行需求 req-predictive-inquiry（`inquiry_progress_bar.dart`/`inquiry_stage_card.dart` 为未跟踪新文件，git grep 证 HEAD 版 `InquiryDrawer` 不含二者）；只挂 optics 的原因是 `basic-lens-imaging.json:87` 含 `inquiryTask` → `optics_screen.dart:114` 抽屉自动展开 → 动画永不 settle，而 circuit 用 `default.json`（无 inquiryTask）故 12 用例全过。判定：**不构成 Blocker，无需补基线对跑**（当前工作区做干净基线对跑技术上不可行，且代码级根因证明力强于对跑）。

> `optics-timeout-current-code.log`（原名 baseline-optics-check.log）实为**当前代码**运行日志（含并行需求新增的"我已了解任务"按钮 finder 输出），非基线日志，已按 reviewer m7 建议改名避免误导。

## 诚实声明（SOP 9.4）

- [x] 每个 ✅ 的 AC 都由本会话真实跑通 flutter test / integration_test / grep 断言，非源码推理
- [x] 所有测试日志均由本次运行产出（integration-test.log / integration-test-retry.log / optics-timeout-current-code.log 存于本目录），非历史缓存
- [x] 未验证 / 部分失败的 AC 已显式标注（AC-2/AC-3 的手动抽验项标记"需人工抽验"；optics 导航用例超时已记录归因）

## 评审后整改记录（2026-08-24 21:50）

| 编号 | 级别 | 整改内容 | 验证 |
|---|---|---|---|
| M1 | Major | `circuit_state.dart` 第三份 `_pointToSegmentDistance` 收敛为公共函数调用 | 369 tests passed |
| M2 | Major | 新增 `test/common/geometry/projection_wiring_test.dart`（5 用例锁定投影**接线**契约：默认工厂 0.55 光轴 / 工厂注入 origin+zoom / 工厂优先于 scale / zoom 变化重建 / 落点与渲染同源） | 25/25 geometry 全绿 |
| m3 | Minor | `app_test.dart:157` 失实注释同步（workaround 已删除 → 改述为本需求根治） | — |
| m4 | Minor | `docs/knowledge/kratos/notes.md:110-116` 踩坑单一源标注"已根治"+ 根治方式 | — |
| m7 | Minor | 误导性日志改名 `baseline-optics-check.log` → `optics-timeout-current-code.log` | — |
| M3 | Major | commit 拆分策略（MT-1~3 / MT-4~6 两段 + pathspec 精确加文件）→ 交由 closer 阶段执行 | 待 closing |
