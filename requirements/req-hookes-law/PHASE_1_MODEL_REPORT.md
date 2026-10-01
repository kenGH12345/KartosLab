# PHASE 1 — MODEL REPORT · Hooke's Law

> 审计依据：`requirements/req-hookes-law/SOURCE_AUDIT.md`  
> 行为依据：`phet sourses/hookes-law-main/hookes-law-main` TypeScript  
> 日期：2026-09-20  
> 本阶段没有 UI、Widget、Canvas、Screen、Home。

## 1. Status

**PASS**

这是 Phase 1 的模型门禁，不是模拟器验收。  
模拟器整体仍然是 **NOT READY**。本阶段不允许、也没有标记 READY。

| 门禁 | 结果 |
|---|---|
| Spring / F=kx / springForce=-F / E=kx²/2 | PASS |
| clamp + 10 位小数 | PASS |
| Intro 双系统独立 | PASS |
| Systems 串联 / 并联 | PASS |
| Energy 改 k 保持 x | PASS |
| Reset，含当前不显示的那套 | PASS |
| 三屏模型隔离 | PASS |
| 无质量、无振动 | PASS |
| 图的数据（不绘制） | PASS |
| `flutter test test/hookes_law/model/` | 27 passed |
| `dart analyze lib/hookes_law test/hookes_law` | No issues found |

## 2. Files changed

新增，无既有文件改动。

| 文件 | 作用 |
|---|---|
| `lib/hookes_law/constants/hookes_law_constants.dart` | 小数位、滑条/箭头/键盘步长、0.01 m 吸附、一维单位长度 |
| `lib/hookes_law/model/hookes_law_numbers.dart` | `toFixedNumber`、`roundSymmetric`、`roundToInterval`、range |
| `lib/hookes_law/model/number_property.dart` | axon `NumberProperty` 子集：钳位、相等不通知、`link` 立即回调、可重入 |
| `lib/hookes_law/model/spring.dart` | `Spring.ts` |
| `lib/hookes_law/model/robotic_arm.dart` | `RoboticArm.ts` |
| `lib/hookes_law/model/robotic_arm_drag.dart` | `RoboticArmNode` 拖曳写入（先钳位再 0.01 m 吸附） |
| `lib/hookes_law/model/single_spring_system.dart` | Intro / Energy 的单弹簧 + 臂 |
| `lib/hookes_law/model/series_system.dart` | 串联 |
| `lib/hookes_law/model/parallel_system.dart` | 并联 |
| `lib/hookes_law/model/intro_model.dart` | 两套独立系统 |
| `lib/hookes_law/model/systems_model.dart` | 串联与并联同时存在 |
| `lib/hookes_law/model/energy_model.dart` | 一根弹簧，位移是自变量 |
| `lib/hookes_law/model/energy_graph_data.dart` | 柱、抛物线控制点、力线、能量三角形的数值 |
| `test/hookes_law/model/hookes_law_model_test.dart` | 27 个行为测试 |

## 3. Model architecture

三屏三个模型，没有 `GlobalHookesLawModel`。

```
IntroModel
  system1: SingleSpringSystem.intro()
  system2: SingleSpringSystem.intro()

SystemsModel
  seriesSystem: SeriesSystem
  parallelSystem: ParallelSystem

EnergyModel
  system: SingleSpringSystem.energy()
```

`SingleSpringSystem` = 一根 `Spring` + 一根 `RoboticArm`。  
`SeriesSystem` / `ParallelSystem` = 两根实物弹簧 + 一根等效弹簧 + 一根臂。

没有 Mass、重力、速度、加速度、阻尼、`step(dt)`。写完即停。

勾选、Total/Components、1 套/2 套、Bar/Energy/Force 图选择都是 view。模型里没有 `forceDisplayMode`。分力是各 `Spring` 上一直存在的 `appliedForce` / `springForce`。

## 4. Source → Flutter mapping

| PhET | Dart |
|---|---|
| `Spring.ts` | `Spring` |
| `RoboticArm.ts` | `RoboticArm` |
| `SingleSpringSystem.ts` | `SingleSpringSystem` |
| `IntroModel.ts` | `IntroModel` |
| `SeriesSystem.ts` | `SeriesSystem` |
| `ParallelSystem.ts` | `ParallelSystem` |
| `SystemsModel.ts` | `SystemsModel` |
| `EnergyModel.ts` | `EnergyModel` |
| `NumberProperty` + `link` | `NumberProperty` |
| `toFixedNumber(F, 10)` | `HookesLawNumbers.toFixedNumber` |
| `roundToInterval(left, 0.01)` | `applyRoboticArmPointerLeft` |
| `EnergyPlot` / `ForcePlot` / `EnergyBarGraph` 里的数 | `EnergyGraphData` |

## 5. Formula mapping

单弹簧（`Spring.ts`）：

```
x = F / k     当 F 改变，或 Intro/Systems 上 k 改变
F = k * x     当 x 改变，或 Energy 上 k 改变
              然后 constrain 到力范围，再 toFixed 10 位
springForce = -F
E = (k * x * x) / 2
equilibriumX = left + equilibriumLength
right = equilibriumX + displacement
```

改 k 的分支在构造时固定，不是一个带模式参数的 `setSpringConstant`：

| 构造时传入 | 屏 | k 改变 |
|---|---|---|
| `appliedForceRange` | Intro、Systems（含等效弹簧） | 保持 F，`x = F/k` |
| `displacementRange` | Energy | 保持 x，`F = kx` |

串联：

```
Feq = F1 = F2
keq = 1 / (1/k1 + 1/k2)
```

并联：

```
xeq 写入 x1 和 x2
keq = k1 + k2
```

`x1+x2` 与 `xeq`、`F1+F2` 与 `Feq` 是这两条监听算出来的，不是另存的总力字段。

## 6. Property mapping

| 源 | Dart | 写入时 |
|---|---|---|
| `appliedForceProperty` | `appliedForceProperty` | 钳位到力范围；监听器写 `x = F/k` |
| `springConstantProperty` | `springConstantProperty` | 钳位到 k 范围；按上面的分支写 x 或 F |
| `displacementProperty` | `displacementProperty` | 钳位到位移范围；监听器写四舍五入后的 F |
| `leftProperty` | `leftProperty` | 墙端锁定后，任何改变都抛错 |
| `springForceProperty` | `springForce` getter | `-appliedForce` |
| `potentialEnergyProperty` | `potentialEnergy` getter | `(k x x) / 2` |
| `rightProperty` | `rightProperty` | `equilibriumX + x`，臂的 left 跟它走 |
| `rightRangeProperty` | `rightRange` getter | Intro/Systems 随当前 k 变；Energy 是固定位移窗 |
| `RoboticArm.leftProperty` | `RoboticArm.left` | 必须 `< right`；监听器写弹簧位移 |

监听注册顺序与 `Spring.ts` 相同：先 F，再 k，再 x。`link` 会立刻用当前值回调一次。

Intro 位移属性范围是 `F/kMin`，即 ±1 m，比默认 k=200 时实际拉得到的 ±0.5 m 更宽。超出 `Fmax/k` 的位移会被力钳位拉回来。这是源行为，测试覆盖了 `setDisplacement(5)` 在 k=200 时落到 x=0.5、F=100。

## 7. Rounding strategy

位移监听器，与 `Spring.ts` 相同：

1. `F = k * x`
2. `F = appliedForceRange.constrain(F)`
3. `F = toFixedNumber(F, 10)`，即 `double.parse(value.toStringAsFixed(10))`
4. 再写回力。力的监听器写 `x = F/k`
5. 若四舍五入后的力与当前力相同，属性不通知，循环停止

`1/3` m 的测试确认：力的写入次数在 1 到 6 之间，再次写入同一结果不会再改 x 或 F。

能被二进制精确表示的值（0.25、0.5、0.125）用 `==`。  
不能精确表示的值（例如串联 F=20 N）只在 `x1+x2` 与 `xeq` 上使用 **1e-12 m**。这是 10 位小数往返后大约 1 ulp 的余差，比位移显示量子 0.001 m 小 9 个数量级。

## 8. Clamp strategy

`NumberProperty` 在比较之前做 inclusive clamp（`Range.constrainValue`）。

| 量 | Intro | Systems 实物弹簧 | Energy |
|---|---|---|---|
| k | 100 … 1000，默认 200 | 200 … 600，默认 200 | 100 … 400，默认 100 |
| F | −100 … 100，默认 0 | −100 … 100，默认 0 | 由 kMax·x 推出：−400 … 400，默认 0 |
| x | 由 F/kMin 推出：−1 … 1，默认 0 | 同 Intro 的算法，kMin=200，所以属性范围是 ±0.5 | **指定** −1 … 1，默认 0 |

机械臂拖曳（`RoboticArmNode.ts`，不是 `Spring.setDisplacement`）：

1. 钳到当前 `rightRange`
2. `roundToInterval(left, 0.01)`（`roundSymmetric`，半数远离 0）
3. 不再二次钳位
4. 写入 `arm.left`，由监听器改位移

滑条步长只放在常量里，不在每次属性写入时吸附。原因：力滑块是 5 N，箭头是 1 N；位移滑块是 0.05 m，箭头是 0.01 m。源码里吸附发生在对应控件，不在 `Spring` 内部。

## 9. Intro isolation

`system1` 与 `system2` 是两个 `SingleSpringSystem`。改其中一个的 k 或 F，另一个保持 200 N/m、0 N、0 m。  
Reset 两套都恢复。第二套是否显示留给 Phase 2 的 view。

## 10. Systems semantics

两套同时存在，互不改对方的弹簧。

串联默认 keq = 100 N/m（两根 200 的调和平均）。`F1`、`F2` 被设成同一个 `Feq`。  
并联默认 keq = 400 N/m。等效位移写入上下两根弹簧。

Reset 顺序与源码相同：实物弹簧、臂、等效弹簧。看不见的串联也会回到默认。

## 11. Energy semantics

位移是控制量。`setSpringConstant` 只是写入 k；因为构造时传的是位移范围，监听器保持 x、重算 F。  
测试：x=0.5、k 从 100 到 200，x 仍为 0.5，F 从 50 变为 100，E 从 12.5 变为 25。

图数据（不绘制）：

- 柱：E>0 才可见；高度 `max(1, E * 1.1)`
- Energy Plot：d = 1、0.5、0 与 `E=kx²/2`，view 控制点用源码的 `cpx = 2*x2 - x1/2 - x3/2`
- Force Plot：直线端点 `y = -0.25 * k * x`；三角形在显示位移 `toFixed(x, 3) == 0` 时隐藏

## 12. Reset semantics

`Spring.reset` 顺序：F、k、x、left。与源码相同。  
Intro reset 两套。Systems reset 串联和并联。Energy reset 唯一的系统。  
一个屏的 reset 不会动另外两个屏的实例。切屏本身没有模型代码，因此也不会 reset。

## 13. Tests

`flutter test test/hookes_law/model/`

**27 passed.**

覆盖：F=kx、弹簧力、能量、x→F、F→x、10 位小数后不再漂移、钳位、三个范围、Intro 独立、串联、并联、分力与等效力同时可读、Energy 改 k 保持 x、reset、隐藏系统 reset、三屏隔离、拖曳 0.01 m、松手后数值不变、图的控制点与三角形。

## 14. Analyze

```
dart analyze lib/hookes_law test/hookes_law
No issues found!
```

没有对整个仓库跑 `dart analyze`。其他 sim 的既有告警不属于本阶段。

## 15. Known limitations

- 没有 UI。弹簧外观、箭头、滑条、勾选、屏幕都还没做。
- `toFixedNumber` 用的是 Dart `toStringAsFixed`。与 PhET `Number(value.toFixed(n))` 在普通值上一致；恰好卡在半数边界的 JS/Dart 差异没有逐个对照 V8。
- 0.01 m 吸附在 `applyRoboticArmPointerLeft`，不在 `setDisplacement`。Phase 2 的手势必须走这个函数，不能在 Painter 里再写一遍，也不能让每次 `setDisplacement` 都吸附。
- 图只提供源码里的控制点和端点，不是采样折线，也没有画出来。
- 没有 PhET-iO、没有声音、没有键盘焦点。

## 16. Remaining risks

- `ParametricSpringNode`（prolate cycloid）仍在 scenery-phet，不在本仓库。Phase 2/6 的弹簧外观风险还在。
- `layoutBounds` 仍未用 joist SHA `bb6a94e0…` 核对。不影响本阶段模型。
- 串联在非二进制精确的力上，`x1+x2` 与 `xeq` 可以差约 1 ulp。显示到 0.001 m 时相同。不要在 Phase 2 为了“对齐”去改公式。

## 能否进入 Phase 2

可以。Phase 1 门禁是 PASS。  
本回合停在这里，不开始 Intro UI。
