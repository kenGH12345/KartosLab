# MAGNET MIGRATION M3

> 阶段：**Behavior / Regression Tests**
> 日期：2026-08-31
> 前置：M1 拆分完成 · M2 runtime 脱离 Legacy
> 证据级别：`[已确认]` = 工具调用实证 · `[推测]` = 标注推测依据 · `[待确认]` = 需用户拍板

本阶段目标：证明结构迁移没有改变原 B 实现的核心行为。

未改业务代码。未发现 migration bug。未接 Home / 未改 NineGrid / 未修 Earth / 未修 Electromagnet / 未删 Legacy。

注：`MAGNET_MIGRATION_M1.md` 在仓库中不存在；M1 状态以用户给定清单 + target 12 文件为准。

---

## 1. 新增测试

目录：`test/magnetism/`

| 文件 | 用例数 | 类型 |
|---|---|---|
| `magnet_state_test.dart` | 4 | unit |
| `magnetic_field_test.dart` | 5 | unit |
| `compass_behavior_test.dart` | 4 | unit + widget |
| `magnet_screen_test.dart` | 6 | widget |
| **合计** | **19** | |

略高于计划的 12–18，原因：Painters 无崩溃渲染 + Screen 交互/Reset/生命周期/拖拽均需独立用例才能锁定 B 行为。未为凑数复制公式。

---

## 2. 测试矩阵

| Area | Test | Source behavior | Priority | 落地 |
|---|---|---|---|---|
| MagneticField | compute dipole + 远场衰减 + strength 线性 | B `k=strength×18000` 两极模型 | P0 | `magnetic_field_test` |
| MagneticField | flip 反向 | B `sign` 翻转 | P0 | 同上 |
| MagneticField | angle / position | B `nPole/sPole` 随 angle/pos | P0 | 同上 |
| MagneticField | earthField | B 垂直偶极 · 忽略 angle | P0 | 同上 |
| MagneticField | 极点距离 clamp | B `distN2.clamp(1.0, inf)` | P0 | 同上 |
| MagnetState | defaults | B `initState` 12 字段 | P0 | `magnet_state_test` |
| MagnetState | copyWith / mutation | B 公开可变字段 + copyWith | P0 | 同上 |
| Compass | angle 输入 / paint / shouldRepaint | B `CompassPainter(needleAngle)` | P0 | `compass_behavior_test` |
| Compass | fieldAngle 翻转 π | B `atan2` + flipped | P0 | 同上 |
| Compass | Screen 上 needleAngle 随时间变化 | B `_tickCompass` 可观察结果 | P0 | `magnet_screen_test` |
| Magnet position | drag + clamp | B `_buildMagnet` onPanUpdate | P0 | `magnet_screen_test` |
| Reset | 恢复默认 | B `_reset()` | P0 | `magnet_screen_test` |
| Screen | initialization | B 控件 / 75% / 磁场 / 罗盘 | P1 | `magnet_screen_test` |
| Screen | interactions | Flip / See Inside / Field Meter / strength | P1 | `magnet_screen_test` |
| Lifecycle | dispose | B `_compassCtrl.dispose()` | P1 | `magnet_screen_test` |

未覆盖（无 public API，未为测试暴露内部）：

| 项 | 原因 |
|---|---|
| `_compassVelocity * 0.85` 阻尼系数 | private · 改为断言 needleAngle 随时间变化 |
| `magnetAngle` 的 Screen 手势 | UI 无旋转控件 · 仅 State + Field 层覆盖 |
| Earth 渲染路径 | 见 §9 |

---

## 3. MagneticField coverage

对照 Legacy `simulations/magnet_and_compass.dart:72-128` 与 target `model/magnetic_field.dart`：**公式逐行等价**（`earthField` 分支、两极 `1/r³`、`k=strength*18000`、`dist².clamp(1.0, inf)`、`magnitude` / `fieldAngle`）。

| 用例 | 断言（可观察结果，未复制公式） |
|---|---|
| 远场衰减 | r 加倍时 \|B\| 比 ≈ 8（容差 1.5）· strength 减半 \|B\| 减半 |
| 极性翻转 | `B_flipped = -B` |
| 角度 / 位置 | angle=π/2 时主导分量换轴 · 平移磁铁与平移采样点场相等 |
| earthField | 改变 `angle` 场不变 · 竖轴上 \|By\| > \|Bx\| · unflipped By < 0（Flutter y 向下 · N 极朝上）· flip 反向 |
| 极点 / 多点 | 采样在 N 极位置有限 · `magnitude`/`fieldAngle` 与向量一致 · 4 个样点有限 |

**FINAL_PLAN TC-2.4「中点零场、B 垂直于轴线」与实际 B 不符。** 磁铁中点两极场沿轴线叠加，不为零、也不垂直。按用户指令锁定当前 B，不改公式。记为原实现事实，不是 migration bug。

---

## 4. MagnetState coverage

`MagnetState` 无默认构造函数。测试用 B `initState` 字面值作为 defaults。

| 用例 | 覆盖字段 |
|---|---|
| defaults | 12 字段：pos/angle/strength=0.75/flipped=false/showField=true/seeInside=false/earthField=false/showCompass=true/showFieldMeter=false/compassPos/compassAngle=0/fieldMeterPos |
| copyWith 单字段 | 只改 strength · 其余不变 · 原对象不被污染 |
| copyWith 多字段 | magnetPos / magnetAngle / compassAngle / earthField / flipped |
| in-place mutation | 全部 12 个 public 字段直接赋值 |

---

## 5. Widget coverage

| 用例 | 断言 |
|---|---|
| CompassPainter API | `needleAngle` 构造 · `shouldRepaint` 仅在角度变化时为 true |
| CompassPainter paint | 0 / π/2 / π 不抛 |
| 其它 Painters | `BarMagnetPainter` / `FieldNeedlePainter` / `VerticalMagnetPainter` / `EarthGlowPainter` / `MiniCompassPreviewPainter` 渲染不抛（**不**走 `SvgPicture.asset`） |
| Screen init | Bar Magnet · 75% · Flip Polarity · Compass · Field Meter · Slider · refresh · 5 个 Checkbox 默认值 · FieldNeedle / BarMagnet / CompassPainter 存在 |
| 交互 | Flip → `flipped` · See Inside → `seeInside` · Field Meter → `B =` · 强度箭头 → 80% |
| 罗盘动画 | 200ms 后 `CompassPainter.needleAngle` 变化 |
| 拖拽 | 右移 left 增大 · 超量右拖 clamp 到 `800 - kMagnetWidth` · 超量左拖 clamp 到 0 |

Screen 测试 **未勾选 Earth**。

Widget 测试中 B 控制面板 Slider 行在宽 208 约束下 overflow ~55px。这是 **原 B 布局问题**，测试用 `takeException()` 吞掉 overflow 字符串，**未改** `control_panel.dart`。

未做 Golden。

---

## 6. Reset

操作后点 refresh：

- strength 80% → **75%**
- Flip Polarity → `flipped=false`
- See Inside → `false`
- Field Meter 关闭（无 `B =`）
- Compass 重新出现
- Checkbox：Field ✓ · See Inside ✗ · Earth ✗ · Compass ✓ · Field Meter ✗
- 磁铁 Positioned 回到 `(0.42w - kMagnetWidth/2, 0.50h - kMagnetHeight/2)`

`magnetAngle` Screen 层无手势可改；`_reset()` 仍写入 `0`（与 B 一致）。角度复位在 `MagnetState` / `MagneticField` 层覆盖。

---

## 7. Lifecycle

卸载 `MagnetAndCompassScreen`（`pumpWidget(SizedBox.shrink())`）后 `tester.takeException()==null`（overflow 已在 pump 时消费）。`AnimationController.dispose()` 无泄漏异常。

---

## 8. Legacy comparison

| 行为 | Legacy B | Target | 测试结论 |
|---|---|---|---|
| `SimState` 12 字段 + copyWith | `:11-67` | `MagnetState` | 等价（改名） |
| `MagneticField.compute` | `:72-128` | `model/magnetic_field.dart` | 逐行等价 |
| initState 默认 | strength=0.75 · showField=true · earthField=false | 同 | 等价 |
| `_initPositions` | 0.42 / 0.50 / 0.60 / 0.66 / 0.28 / 0.30 | 同 | 等价 |
| `_tickCompass` | velocity `*0.85 + diff*0.08` | 同 | 可观察 needleAngle 变化 · 未测系数 |
| `_reset` | 恢复默认 + velocity=0 | 同 | 等价 |
| 磁铁 clamp | `kMagnetWidth/2` … `w - kMagnetWidth/2` | 同 | 等价 |
| `CompassPainter(needleAngle)` | `:793-867` | `painters/compass_painter.dart` | API 不变 · Electromagnet 可继续 import |
| 常量 500 / 128 / 180 / 76 | `:143-146` | `magnet_and_compass_constants.dart` | 等价 |

测试 **没有** import 或复制 `simulations/magnet_and_compass.dart`。

---

## 9. Earth blocked status

**Earth rendering path remains blocked by missing earth.svg.**

- 未创建 SVG
- 未下载资源
- 未修改 `_buildEarth`
- 未绕过 `earthField`
- Screen 测试未勾选 Earth checkbox

earthField **物理计算**（`MagneticField.compute(..., earthField: true)`）已测，不依赖 asset。

---

## 10. Electromagnet blocked status

**BLOCKED**（保持）

- 未修改 Electromagnet 任何文件
- `CompassPainter({required needleAngle})` 仍为 public API（`compass_behavior_test` 锁定）
- 未创建 `electromagnet_model.dart`

---

## 11. flutter analyze

```
flutter analyze lib/magnetism/magnet_and_compass test/magnetism
→ No issues found! (ran in 2.0s)
```

Magnet lib + 新测试目录：**0 error / 0 warning / 0 info**。无新 Magnet analyzer error。

---

## 12. test result

```
flutter test test/magnetism
→ 19 tests passed
```

```
flutter test test/chemistry/build_a_nucleus
→ 407 tests passed
```

Build a Nucleus 不受影响。

---

## 13. [已确认]

1. Target 12 类真实 API 与 B 一致（State 改名除外）。
2. 新增 19 个测试，全部通过。
3. 未改 `lib/magnetism/magnet_and_compass/` 业务代码。
4. 未发现 migration bug。
5. earth.svg 路径未触发。
6. Electromagnet 未改，仍 BLOCKED。
7. Legacy 文件未删、未被测试 import。
8. BAN 回归 407 passed。
9. 控制面板 overflow 55px 为原 B 布局问题，测试记录并吞掉，未“优化”UI。
10. FINAL_PLAN「中点零场垂直」与实际 B 两极模型不符；测试锁定实际行为。

---

## 14. [推测]

1. `_tickCompass` 的 0.85 / 0.08 系数未单独测，但 needleAngle 随时间变化说明 tick 仍在跑。
2. 控制面板 overflow 在真机宽屏上可能不明显（面板贴右上，debug 黄黑条仅测试表面暴露）。

---

## 15. [待确认]

1. 是否在后续阶段修复控制面板 Slider 行 overflow（原行为，非 M3 范围）。
2. `earth.svg` 来源（仍 BLOCKED）。
3. 阻尼系数是否需要抽成可测常量（当前禁止为测试暴露内部）。
4. Home 接入时机（明确不在 M3）。

---

M3 到此停止。
