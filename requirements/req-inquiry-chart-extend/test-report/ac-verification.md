# AC 验收对照（req-inquiry-chart-extend）

> 本需求为推广接线需求（无独立 AC 清单），验收对照 5 项（按主会话定义）。
> 前置：req-inquiry-chart-poc（commit 708f7a6）已验收 · SnapshotChart 公共组件已就位。

## 验收项

| # | 验收项 | 状态 | 实现/验证位置 |
|---|---|---|---|
| ① | 6 sim（optics/netforce/motion/sound/radio/wave）默认选轴语义合理 | ✅ | 逐 JSON snapshotColumns 核对：optics `basic-lens-imaging.json:107-110`（物距×像距）· netforce `netforce-tug.json:112-115`（左力×合力）· motion `motion-explore.json:98-101`（力×加速度）· sound `default.json:43-45`（频率×波长）· radio `default.json:46-48`（频率×波峰数）· wave `default.json:48-50`（频率×条纹间距）——均为"param×reading"数值对 |
| ② | circuit 默认 y=current（列序调整） | ✅ | `assets/scenarios/circuit/simple-series.json:132-137`：`resistance(param)/current(reading)/voltage(reading)/brightness(reading)` → 默认选轴 resistance×current，直接可见 I=V/R 反比趋势；AC-2.4 用 Set 比较 key（`test/circuit/inquiry_snapshot_test.dart:26-27`）与列序无关 |
| ③ | color_vision 空态文案不误导 | ✅ | `lib/common/chart/snapshot_chart.dart:76-86` 双分支：rows<2 → "记录 ≥2 组后自动生成"；rows≥2 但 points<2 → "有效数值数据不足 2 组"（color_vision y=colorName 全文本 → 命中后者）· 用例 `test/common/snapshot_chart_test.dart:179-192` 验证 |
| ④ | 全量回归无破坏 | ✅ | `test-report/integration-test.log`：**205/205 通过**（All tests passed!）· common+circuit 61/61（含 snapshot_chart 10 用例） |
| ⑤ | 组件保持零 sim 依赖 | ✅ | `snapshot_chart.dart` 仅 import `flutter/material` + `flutter/foundation` + `experiment_logger.dart`（ColumnDef）· 0 处 `lib/circuit/` 等 sim import |

## 测试证据

- 日志：`test-report/integration-test.log`（真实 `flutter test` 输出 · 末尾 `All tests passed!`）
- 新增/变更用例：`test/common/snapshot_chart_test.dart`（10 用例全绿）
- forces 组未跑（已知 `netforce-tug` 基线超时 10 分钟 · 本需求零改动 forces · 与前置需求一致非本需求引入）

## 诚实声明

- 本需求无独立 integration_test 功能断言（推广接线需求 · 验证以 widget 测试 + 全量回归为自动化验证）
- 未运行真实 UI（`flutter run`）· 布局/视觉以 widget 测试 + 前置 POC 验收为证据
