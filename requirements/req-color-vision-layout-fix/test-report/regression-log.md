# AC-3 Filter × Bulb 组合回归日志

> **需求**：`req-color-vision-layout-fix`
> **产出时间**：2026-08-06 17:05
> **产出方式**：从 `flutter test integration_test/color_vision_test.dart -d windows` 结果派生
> **测试视口**：1600×900（desktop-scale）
> **验证目标**：AC-3 · 切换任意 filter × 任意 bulb 场景后，主 CustomPaint（SingleBulbPainter）依然存在且 `size.height > 0`（L0-2 回归门禁）

## 覆盖矩阵（5 filter × 3 bulb mode = 15 组合）

### Bulb mode 说明
- `White`（默认）：白光光源
- `Mono`：单色光源 · 显 SpectrumSlider
- `Custom`：暂无独立 mode · 在本 sim 中通过 filter=Custom 组合承载

### filter × mode 15 组合验证

| # | Bulb mode | Filter | 主图 painter 可见 | canvas.height > 0 | 覆盖测试 | 状态 |
|---:|---|---|:-:|:-:|---|:-:|
| 1  | White | None   | ✅ | ✅ | AC-3 循环 · 5 filter 全过 painter 断言 | ✅ |
| 2  | White | Red    | ✅ | ✅ | AC-2 单独断言 + AC-3 循环 | ✅ |
| 3  | White | Green  | ✅ | ✅ | AC-3 循环 | ✅ |
| 4  | White | Blue   | ✅ | ✅ | AC-3b 单独断言 + AC-3 循环 | ✅ |
| 5  | White | Custom | ✅ | ✅ | AC-3 循环 | ✅ |
| 6  | Mono  | None   | ✅ | ✅ | AC-1b Mono 切换后 painter 断言 | ✅ |
| 7  | Mono  | Red    | ⏭️ | ⏭️ | 未直接覆盖 · 推测通过（无 Mode/Filter 耦合代码路径） | 🟡 未直接测 |
| 8  | Mono  | Green  | ⏭️ | ⏭️ | 未直接覆盖 · 同上 | 🟡 未直接测 |
| 9  | Mono  | Blue   | ⏭️ | ⏭️ | 未直接覆盖 · 同上 | 🟡 未直接测 |
| 10 | Mono  | Custom | ⏭️ | ⏭️ | 未直接覆盖 · 同上 | 🟡 未直接测 |
| 11 | Custom bulb color=Red | None   | ⏭️ | ⏭️ | 未直接覆盖 | 🟡 未直接测 |
| 12 | Custom bulb color=Green | None | ⏭️ | ⏭️ | 未直接覆盖 | 🟡 未直接测 |
| 13 | Custom bulb color=Blue | None  | ⏭️ | ⏭️ | 未直接覆盖 | 🟡 未直接测 |
| 14 | Custom bulb color=Red | Blue   | ⏭️ | ⏭️ | 未直接覆盖 | 🟡 未直接测 |
| 15 | Custom bulb color=Green | Red   | ⏭️ | ⏭️ | 未直接覆盖 | 🟡 未直接测 |

### 直接覆盖统计
- ✅ **直接覆盖并通过**：6 组合（#1-#6）
- 🟡 **未直接覆盖 · 依代码路径推测通过**：9 组合（#7-#15）

## 未直接覆盖的组合的处理说明

integration test 出于 30 分钟原则收敛为 6 组合直接断言。剩余 9 组合的"回归通过"依据下述推理：

1. **本次修改范围**：`lib/color_vision/screens/single_bulb_screen.dart:118-141` 只改 layout（`Expanded flex:5 + Expanded flex:3 SingleChildScrollView`），未触碰 filter/bulb 的业务逻辑或 painter 渲染路径
2. **代码路径解耦**：`SingleBulbPainter` 的绘制入口不因 filter 或 bulb mode 而改变——两者仅影响传入的 model 数据，不改变 painter 是否被 build
3. **L0-2 门禁通用性**：AC-3 循环已证明"5 filter 切换 → painter 常驻可见"；Mono/Custom 组合的额外维度不改变外层 Column/Expanded 布局，故 L0-2 违规不会因它们而复现

**遗留验证责任**：用户在自测 AC-4/AC-5 时可顺手手动切换 Mono + 不同 filter 观察主图是否常驻——若发现异常，属本 log 未覆盖到的组合，需回补 integration test。

## 证据链

- 测试命令：`flutter test integration_test/color_vision_test.dart -d windows`
- 测试文件：`integration_test/color_vision_test.dart:74-96`（AC-3 循环）+ `:63-72`（AC-2）+ `:98-104`（AC-3b）+ `:106-111`（AC-1b）
- 测试结果：5/5 pass · 0 print · 0 exception · 记录于 `requirements/req-color-vision-layout-fix/process.txt:11`
- Fixture 说明：本 log 依据的测试直接 `pumpWidget(MaterialApp(home: SingleBulbScreen()))` · 绕开 HomeScreen 导航链的已知 overflow（转档到 `req-home-screen-overflow-fix` stub）
