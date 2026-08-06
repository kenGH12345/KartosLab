# AC 验证报告 · req-verify-selftest-color-vision · 2026-08-03

> **模板来源**：`.codebuddy/skills/core/self-testing/references/ac-verification-template.md`
> **验证靶子**：`lib/color_vision/`（single_bulb screen）
> **验证目的**：实跑 agile-vibe v0.2.1 阶段3第9条「AI 自主功能测试」闭环，验证 self-testing skill + code-reviewer 步骤2.5 + check-before-done 检查6 是否可落地。

---

## 概况

- **需求**: 验证 self-testing 功能测试闭环（靶子 color_vision）
- **执行者**: 主会话（hy3 agent）
- **首次执行时间**: 2026-08-03 14:43 - 14:50
- **补测时间**: 2026-08-05 17:22 - 17:24（下载 3 张真操作截图 · 用户人工在 sim 窗口操作产出）
- **产物启动方式**: `flutter analyze lib/color_vision/`（L2 代码测试真跑）；`flutter run -d windows`（L1 GUI 用户人工操作 + 截图）
- **单测框架**: 本项目 color_vision 无 `test/` 单测目录 → 仅 L2 analyzer 级验证

---

## 逐 AC 验证

### AC-1 · Source 切到 Mono → 出现 SpectrumSlider → 拖到 650nm → 光束呈红色

**用户操作路径**（推演自 `lib/color_vision/screens/single_bulb_screen.dart`）：
1. 点 Source 的 `Mono` ChoiceChip → `_setBulbMode(BulbMode.mono)`（`single_bulb_screen.dart:71`）
2. build() 中 `if (_bulbMode == BulbMode.mono) SpectrumSlider(...)` 出现（`single_bulb_screen.dart:161`）
3. 拖 slider → `_setWavelength(nm)` → `_state.setBulbWavelength(nm)`（`single_bulb_screen.dart:78`）
4. Painter 用 `_state.bulbColor` 渲染光束

**验证结果**：

| 步骤 | 预期 | 实际 | 证据 | 结论 |
|---|---|---|---|---|
| 1 | 切 Mono 后 slider 出现 | 代码逻辑确认（build 条件分支） | `single_bulb_screen.dart:161` | ⚠️ 静态推演 |
| 2 | 拖到 650nm 光束变红 | 需 GUI 真拖 | 无截图 | ❌ 未验证 |

**AC-1 总体结论**：⚠️ 通过代码静态推演 · GUI 真操作**未验证**

---

### AC-2 · Source=White + Filter=Red → "Person sees: red"

**推演**：`_perceivedColor()` 中 `filterType != none && bulbMode == white` 时返回 `Color(255*pr, 255*pg, 255*pb)`，red 滤光片 `passRates = (1,0,0)` → 红色（`single_bulb_screen.dart:113`）

| 步骤 | 预期 | 实际 | 证据 | 结论 |
|---|---|---|---|---|
| 1 | 默认 White + None 滤片 · Person sees: White | 实测：控制面板显示 "Person sees: White" · 主图白色光束射向 person | `screenshots/ac-2-step-1-white-nofilter.png` (297 KB) | ✅ 真操作通过 |
| 2 | 点选 Red 滤片 · Person sees: Red · 光束右段变红 | 实测：Red ChoiceChip 高亮红色 · "Person sees: Red" 文字与红色方块渲染正确 · 光束经过 filter 后变红 | `screenshots/ac-2-step-2-white-redfilter.png` (307 KB) | ✅ 真操作通过 |

**AC-2 总体结论**：✅ **真操作通过**（本会话首个真 GUI 实证 AC）

---

### AC-3 · Source=White + Filter=Blue → "Person sees: blue"

（同 AC-2 结构，blue passRates=(0,0,1) → 蓝色。`single_bulb_screen.dart:113`）

**AC-3 总体结论**：⚠️ 代码推演通过 · GUI 真操作**未验证** · **实证债务**记入 `notes.md`，下次真需求偿还（用户明确决策 1a · 2026-08-05）

---

### AC-4 · Source=Mono(任意) + Filter=Red → 单色光按 passRates 调色

**推演**：`_perceivedColor()` mono+filter 分支用 `filter.passRates` 缩放 `bulbColor`（`single_bulb_screen.dart:100-106`）

**AC-4 总体结论**：⚠️ 代码推演通过 · GUI 真操作**未验证**

---

## 补充证据

### 代码测试（L2 · 真跑）

- **框架**: Flutter analyzer（项目无 unit test 目录）
- **命令**: `flutter analyze lib/color_vision/`
- **结果**: ✅ **No issues found! (ran in 1.0s)** — 真实运行于 2026-08-03 14:48
- **详细日志**: `test-report/code-test.log`

### 视觉回归（L3 · 未执行）

- **触发原因**: 改动涉及 `lib/color_vision/screens/`（UI 类）
- **3 视口截图**: **未生成**
- **未执行理由**: 本会话为命令行 agent，**无 GUI 交互/截图能力**，`flutter run -d windows` 启动的窗口无法由 agent 真实操作（拖 slider / 点 ChoiceChip / 截窗口图）
- **诚实标注**: 此项**未验证**，不构成 ✅

---

## 汇总

| 维度 | 数量 |
|---|---|
| AC 总数 | 4 |
| ✅ 真操作通过 | 1（AC-2） |
| ⚠️ 代码推演通过（GUI 未验证） | 3（AC-1/AC-3/AC-4） |
| ❌ 失败 | 0 |
| 未验证（实证债务） | 3（AC-1/AC-3/AC-4 · 下次真需求偿还） |

---

## 衍生发现（本次实证意外收获）

### 发现 · color_vision Single Bulb 屏在窄视口下主图消失 · L0-2/L0-3 违规

- **触发场景**: 用户为验证屏幕适配故意缩小窗口宽度到约 800px 后，切换 Filter=Red
- **现象**: 主图 CustomPaint 完全消失，屏幕只剩「颜色过滤原理」知识面板 + 控制面板（见 `screenshots/ac-BUG-layout-overflow-red.png` · 101 KB）
- **根因（信心 95%）**: `lib/color_vision/screens/single_bulb_screen.dart:118-201` 的 `Column` 三层布局中：
  - 主图用 `Expanded(flex:5, child: CustomPaint(size: Size.infinite, ...))`
  - `_buildKnowledgePanel()` 与 `PropertyControlPanel` 均为 `Column` 的 free children，无高度约束
  - Filter=Red 时 `KnowledgeItem.active=true` 触发额外 border/aura 渲染 → 知识面板高度膨胀
  - 窗口高度不足时 → `Expanded(flex:5)` 分到 0 或负数空间 → 主图彻底消失
- **违反的规则**: `.codebuddy/rules/80-phet-sim-checklist.mdc` §七
  - **L0-2**（响应式无溢出 · 320-1920px 视口内主要控件可见）· 主图在窄视口消失 = 主要控件不可见
  - **L0-3**（主图尺寸随视口缩放 · LayoutBuilder + `side = min(viewportW×0.6, viewportH×0.7)` 保底）· 未用 LayoutBuilder · 无主图 minHeight 保底
- **处置**: 已立独立跟进需求 `req-color-vision-layout-fix`（见其 `spec/需求简述.md`）· 本需求不修，仅记录
- **对本闭环验证的价值**: 这个 Bug **只有真跑窄视口 + 真切 filter 才能发现**——纯静态推演永远看不到。这**正面证明了** self-testing skill v0.1.1 §"零真操作边界"的必要性：如果本次没在 Diff-2 阶段坚持要真操作截图，这个 L0-2/L0-3 违规会被漏掉，直接进入未来的存量债务

---

## 诚实声明

> 依据 `60-citation-and-honesty.mdc` + `agile-vibe.md` 阶段3第9.4条

- [x] 每个 ✅ 的 AC 都由本会话真实操作产物完成，非源码推理 → **AC-2 由用户人工在 sim 窗口操作截图产出 2 张 PNG · 由本会话 PowerShell WebClient 从会话附件 URL 下载落盘到 screenshots/ · 满足 SKILL v0.1.1 §「零真操作边界」的 "真操作 AC 数 ≥ 1" 硬约束**
- [x] 所有截图均由本次运行产出（mtime 在 phase 3 期间），非历史缓存 → **screenshots/ 3 张 PNG 的 mtime 均为 2026-08-05 17:22-17:23**
- [x] 未验证 / 部分失败的 AC 已在报告中显式标注 → **AC-1/AC-3/AC-4 保持 "⚠️ 静态推演" · 实证债务记入 notes.md 待偿还**

**签署**：主会话（hy3 agent）
**首次签署时间**：2026-08-03 14:50
**补测签署时间**：2026-08-05 17:24（补 AC-2 真操作证据 + 追加衍生发现段）

---

## 附录：本次自测未覆盖的风险面（诚实告知）

1. **GUI 真交互（部分覆盖）**：AC-2 White+Red 已真验；AC-1 mono slider 拖拽、AC-3 Blue、AC-4 Mono+Filter 未真验——记入 `notes.md` 实证债务
2. **PhotonBeam 渲染**：AC-2 截图确认光束在 filter 前后颜色变化正确；帧率 / 60fps 未量化验证
3. **rgb_bulbs_screen**：本次仅验 single_bulb，rgb 三灯泡混色未触及
4. **跨视口布局**：意外发现窄视口下主图消失（衍生发现段）· 已立独立需求 `req-color-vision-layout-fix` 跟进 · 本需求不覆盖标准 3 视口截图（375/1024/1920）
