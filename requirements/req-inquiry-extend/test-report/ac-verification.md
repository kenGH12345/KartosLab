# AC 验证证据链 — req-inquiry-extend

做中学探究工作流推广到 5 sim（optics/forces/sound/radio_waves/wave_interference）。

- 报告时间: 2026-08-07
- 前置: req-inquiry-learning(553d6dc) 通用组件已验收
- 评审结论: ✅ 通过（5 项验收全覆盖；1 项既有基线问题如实标注，非本需求引入）

> 本需求为推广接线需求，无独立 AC 清单。验收对照 5 项（按主会话定义）。

## 验收项表

| # | 验收项 | 验证方式 | 测试引用 / analyze 输出 | 结果 | 备注 |
|---|--------|----------|--------------------------|------|------|
| ① | 5 model 解析 inquiryTask + 向后兼容 | 单测真实执行 | `test/common/inquiry_scenario_parse_test.dart:30-101`（5 个 test，各含「解析 inquiryTask + 向后兼容」断言）| ✅ | Forces/Lab(optics)/Sound/RadioWaves/WaveInterference 5 model 均 `inquiryTask?` 可空字段 + `fromJson` 判空解析；测试断言有 `inquiryTask` 时解析成功、无字段时 `== null` 不崩 |
| ② | 6 screen 编译 + analyze 干净 | `flutter analyze` | `analyze.log`：5 sim 6 screen（optics/netforce/motion/sound/radio_waves/wave_interference）**0 error**；本需求文件仅 1 warning（`inquiry_scenario_parse_test.dart:1` unused_import `dart:convert`）| ✅ | analyze 中全部 error 位于 `docs/knowledge/kartosos-common/*.dart`（知识库参考代码，非本需求代码）；forces/motion 的 `_showChart` final、转义、netforce `scale` deprecated 等 6 条 info 为既有（553d6dc 已有）|
| ③ | 6 JSON 解析 | 静态检查 + 测试 | 6 个 JSON 均含 `inquiryTask` 块（`assets/scenarios/basic-lens-imaging.json:87`、`forces/netforce-tug.json:92`、`forces/motion-explore.json:78`、`sound/default.json:23`、`radio-waves/default.json:26`、`wave-interference/default.json:28`）；解析路径经 ① 测试验证（`inquiry_scenario_parse_test.dart` 内联 JSON 结构同源）| ✅ | 各 JSON 的 `inquiryTask.question/steps/referenceConclusion/snapshotColumns` 结构完整 |
| ④ | 快照 key 与 JSON snapshotColumns 一致 | 静态核对 | 见下表「快照 key 对照」| ✅ | 6 screen 的 snapshotProvider 返回 key 与对应 JSON `snapshotColumns[].key` 逐项一致 |
| ⑤ | 与先例（circuit/color_vision）接入模式一致 | 静态对照 | `lib/circuit/screens/circuit_screen.dart:412-417`、`lib/color_vision/screens/rgb_bulbs_screen.dart:288-293` 与 5 sim 的 `InquiryDrawer` 均传 `task`+`columns`+`snapshotProvider`+`open` 四参数 | ✅ | 5 sim（如 `lib/optics/screens/optics_screen.dart:157-162`）接入签名与两先例完全一致；columns 均由 `inquiryTask.snapshotColumns` 映射 |

## 快照 key 对照表（AC-④）

| sim / screen | JSON snapshotColumns keys | snapshotProvider 返回 keys | 一致 |
|---|---|---|---|
| optics（basic-lens-imaging）| objectDistance, imageDistance, magnification, isVirtual | 同（`optics_screen.dart:184-192`）| ✅ |
| netforce（netforce-tug）| leftForce, rightForce, netForce, winner | 同（`netforce_screen.dart:132-140`）| ✅ |
| motion（motion-explore）| appliedForce, mass, acceleration, speed | 同（`motion_screen.dart:117-124`）| ✅ |
| sound（default）| frequency, amplitude, wavelength | 同（`sound_screen.dart:152-158`）| ✅ |
| radio_waves（default）| frequency, amplitude, waveCount | 同（`radio_waves_screen.dart:134-142`）| ✅ |
| wave_interference（default）| frequency, slitSeparation, fringeSpacing | 同（`wave_interference_screen.dart:184-194`）| ✅ |

## 测试统计

| 测试组 | 总数 | 通过 | 失败 | 跳过 | flaky |
|---|---|---|---|---|---|
| `test/common/inquiry_scenario_parse_test.dart`（本需求核心）| 5 | 5 | 0 | 0 | 0 |
| `test/common/`（全组）| 27 | 27 | 0 | 0 | 0 |
| `test/circuit/inquiry_snapshot_test.dart` + `test/color_vision/` | 12 | 12 | 0 | 0 | 0 |
| `test/forces/forces_scenario_test.dart`（60s 超时验证）| 7 | 6 | 1（超时）| 0 | 0 |

> forces 基线超时（如实声明）：`netforce-tug scenario has valid pullers` 在 553d6dc 前置需求时即已存在（死循环），`test/forces/forces_scenario_test.dart` 文件本需求未改动（git status 无此文件）。属既有基线问题，**非本需求引入**。

## analyze 结果

- 5 sim 6 screen + 5 model：**0 error**
- 本需求新增 warning：`test/common/inquiry_scenario_parse_test.dart:1` unused_import `dart:convert`（import 未使用，不影响编译运行）
- 既有 info（553d6dc 已有）：`motion_screen.dart` `_showChart` final、334 行转义；`netforce_screen.dart:375` `scale` deprecated
- 全部 error 位于 `docs/knowledge/kartosos-common/`（知识库参考代码，非本需求范围）

## 诚实声明（SOP 9.4）

- [x] 所有测试均为真实执行（`flutter test` 输出见 integration-test.log，非代码阅读推断）
- [x] forces 基线超时 1 项已如实标注为非本需求引入（文件零改动，553d6dc 时已存在）
- [x] analyze 结果如实记录（0 error；既有 info/warning 已区分标注；docs/knowledge 历史 error 非本需求范围）

## 备注

- code-reviewer 提出的 Major（motion mass 用 `_model.sim.mass`、场景切换 `_inquiryOpen` 复位）已在本工作区修复，证据见 `motion_screen.dart:120`（`'mass': _model.sim.mass`）与 `sound_screen.dart:75` / `radio_waves_screen.dart:63` / `wave_interference_screen.dart:86`（`_inquiryOpen = false`）。
- 测试证据链真实日志：`requirements/req-inquiry-extend/test-report/integration-test.log`
- analyze 真实输出：`requirements/req-inquiry-extend/test-report/analyze.log`
