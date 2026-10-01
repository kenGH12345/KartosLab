# MAGNET MIGRATION FINAL PLAN

> 生成日期：2026-08-31
> 阶段：**READ-ONLY FINAL DESIGN** · 未移动 / 删除 / 重命名 / 修改任何代码
> 依据：`MAGNET_MIGRATION_DESIGN.md` + 用户 13 项指令
> 源实现：`simulations/magnet_and_compass.dart`（B 版 · 1089 行 · 单文件）
> 证据级别：`[已确认]` = 工具调用实证 · `[推测]` = 标注推测依据 · `[待确认]` = 需用户拍板

---

## 1. 最终 target directory

```
lib/magnetism/magnet_and_compass/
```

| 项 | 值 | 依据 |
|---|---|---|
| domain | `magnetism` | [已确认] 已有 domain 均为学科名（sound/optics/forces/circuit）· magnetism 与之风格一致 |
| sim | `magnet_and_compass` | [已确认] 与 `build_a_nucleus` / `radio_waves` 命名风格一致 |
| 无更强 domain 规范证据 | [已确认] `list_dir lib/` 无 `electromagnetism/` 或 `physics/` domain · 无规则文件要求特定 domain |

**完整目录树**：

```
lib/magnetism/magnet_and_compass/
├── model/
│   ├── magnet_state.dart
│   └── magnetic_field.dart
├── painters/
│   ├── bar_magnet_painter.dart
│   ├── compass_painter.dart
│   ├── field_needle_painter.dart
│   ├── vertical_magnet_painter.dart
│   └── earth_glow_painter.dart
├── screens/
│   └── magnet_and_compass_screen.dart
├── widgets/
│   ├── control_panel.dart
│   ├── field_meter.dart
│   └── mini_compass_preview_painter.dart
└── magnet_and_compass_constants.dart
```

---

## 2. 文件迁移表

| # | Legacy（B 行号） | Target | Action | 原因 |
|---|---|---|---|---|
| 1 | `:11-67` `SimState` | `model/magnet_state.dart` | **extract + rename** | `SimState` → `MagnetState` · 与 `SoundState` 命名一致 |
| 2 | `:72-128` `MagneticField` | `model/magnetic_field.dart` | **extract** | 不改名 · sim 内部逻辑 |
| 3 | `:133-523` `MagnetAndCompassPage` + `_MagnetAndCompassPageState` | `screens/magnet_and_compass_screen.dart` | **extract + rename** | `Page` → `Screen` · 与 `SoundScreen` 命名一致 |
| 4 | `:528-550` `_EarthGlowPainter` | `painters/earth_glow_painter.dart` | **extract + rename** | private → public · `EarthGlowPainter` |
| 5 | `:555-613` `_VerticalMagnetPainter` | `painters/vertical_magnet_painter.dart` | **extract + rename** | private → public · `VerticalMagnetPainter` |
| 6 | `:618-694` `BarMagnetPainter` | `painters/bar_magnet_painter.dart` | **extract** | 不改名 |
| 7 | `:699-788` `FieldNeedlePainter` | `painters/field_needle_painter.dart` | **extract** | 不改名 |
| 8 | `:793-867` `CompassPainter` | `painters/compass_painter.dart` | **extract** | 不改名 |
| 9 | `:872-1043` `_ControlPanel` | `widgets/control_panel.dart` | **extract + rename** | private → public · `MagnetControlPanel` |
| 10 | `:454-522` `_buildFieldMeter` | `widgets/field_meter.dart` | **extract + rename** | 方法 → Widget · `FieldMeter` |
| 11 | `:1045-1088` `_MiniCompassPreviewPainter` | `widgets/mini_compass_preview_painter.dart` | **extract + rename** | private → public · `MiniCompassPreviewPainter` |
| 12 | `:143-146` 常量 | `magnet_and_compass_constants.dart` | **extract** | 硬编码常量提取 |

**总计**：1 个 legacy 文件 → 12 个 target 文件

### 类名变更表

| Legacy | Target | 理由 |
|---|---|---|
| `SimState` | `MagnetState` | 与 `SoundState` / `BuildANucleusState` 一致 |
| `MagnetAndCompassPage` | `MagnetAndCompassScreen` | 与 `SoundScreen` / `CircuitScreen` 一致 |
| `_MagnetAndCompassPageState` | `_MagnetAndCompassScreenState` | 跟随 Screen |
| `_ControlPanel` | `MagnetControlPanel` | public + 前缀避免歧义 |
| `_EarthGlowPainter` | `EarthGlowPainter` | public |
| `_VerticalMagnetPainter` | `VerticalMagnetPainter` | public |
| `_MiniCompassPreviewPainter` | `MiniCompassPreviewPainter` | public |
| `MagneticField` | `MagneticField` | ✅ 不改 |
| `BarMagnetPainter` | `BarMagnetPainter` | ✅ 不改 |
| `CompassPainter` | `CompassPainter` | ✅ 不改 |
| `FieldNeedlePainter` | `FieldNeedlePainter` | ✅ 不改 |

---

## 3. earth.svg 结论

### 搜索执行

| 搜索方式 | 范围 | 结果 |
|---|---|---|
| `search_file` 递归 `earth*` | 全工程 | 0 结果 |
| `search_file` 递归 `*.svg` | `phet/` | 0 结果（A 只有 `lib/main.dart` 一个文件） |
| `search_content` grep `earth` | `assets/` | 0 结果 |
| `search_file` 递归 `earth*` | `assets/` | 0 结果 |

### 事实

[已确认]：

1. `earth.svg` **在整个仓库中不存在**
2. A（`phet/magnet_and_compass/lib/main.dart:542`）也引用 `assets/earth.svg` — A 同样没有此文件
3. A 目录下只有 `lib/main.dart`，无 `assets/` 子目录
4. `pubspec.yaml:64-76` assets 列表无 `earth.svg`
5. B 的 `_buildEarth()` 方法（`:403`）引用 `assets/earth.svg` → **运行到 earthField 模式会 crash**
6. A 的 `main.dart:542` 同样引用 → **A 也会 crash**

### 结论

`earth.svg` 是 PhET 原始项目的外部 asset，从未被复制到本仓库。A 和 B 都存在此缺陷。

### 处理方案

[待确认] 用户选择：

| 选项 | 操作 | 权衡 |
|---|---|---|
| A | 用户提供 `earth.svg` 文件 | 最优 · 保留原版视觉 |
| B | 用 `CustomPainter` 绘制地球替代 SVG | 工程量大 · 可行 |
| C | 移除 `earthField` 模式 | 功能缺失 · 但消除 crash 风险 |
| D | 创建简化替代 SVG（蓝绿圆 + 大陆轮廓） | 折中 |

**推荐 A**：用户先尝试获取原版 `earth.svg`。如无法获取，退回 D（简化替代 SVG）。

**禁止**：在本阶段生成替代 SVG。本阶段仅记录结论。

---

## 4. controller 决策

| 项 | 值 | 依据 |
|---|---|---|
| 是否新建 `controller/` 目录 | **否** | [已确认] |
| controller 逻辑位置 | `screens/magnet_and_compass_screen.dart` 内的 `_MagnetAndCompassScreenState` | |
| 依据 | `lib/sound/` 无 `controller/`（controller 在 `_SoundScreenState` 内）· `lib/radio_waves/` 同 | [已确认] `list_dir lib/sound/` 无 controller 目录 |

### 仓库现有规则检查

[已确认] `list_dir lib/common/` 有 `simulation_clock.dart` 但无 `controller/` 目录。无规则文件强制要求 `controller/` 目录。`lib/chemistry/build_a_nucleus/` 有 `controller/` 但那是该 sim 特有需求（衰变动画控制器），非通用规范。

### 决策

**不新建 `controller/` 目录**。controller 逻辑（tick loop + 拖拽 + reset）留在 `_MagnetAndCompassScreenState` 内，与 `lib/sound/` 保持一致。如果后续 complexity 增长再拆。

---

## 5. AnimationController 决策

### 当前实现分析

[已确认] B 使用 `AnimationController`（`:148-173`）：

```dart
late AnimationController _compassCtrl;
double _compassVelocity = 0.0;

_compassCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 60))
  ..addListener(_tickCompass)
  ..repeat();
```

### 为什么需要 AnimationController

[已确认] B 的 `AnimationController` 用途：

| 用途 | 代码位置 | 说明 |
|---|---|---|
| 驱动罗盘指针旋转动画 | `:170-173` `_compassCtrl..addListener(_tickCompass)..repeat()` | 每 frame 调用 `_tickCompass` |
| `_tickCompass` 计算磁场方向 | `:188-213` | 读 `_state.compassPos` · 算 `MagneticField.compute()` · 算 `fieldAngle` · 算角速度差 · 更新 `_compassAngle` |
| 阻尼追踪 | `:207` `_compassVelocity = _compassVelocity * 0.85 + diff * 0.08` | 指针有惯性 · 逐步逼近目标角度 |

**核心需求**：罗盘指针需要每 frame 重算磁场方向 + 阻尼追踪。这不是简单的"播放/暂停"时钟——它需要持续的 frame callback。

### 是否与 SimulationClock 冲突

[已确认] `SimulationClock`（`lib/common/simulation_clock.dart`）接口：

```dart
class SimulationClock {
  SimulationClock({this.fps = 60.0, this.timeScale = 1.0});
  void Function(double dt, double totalTime)? onTick;
  void attach(TickerProvider vsync);
  void play();
  void pause();
  void stepForward();
  void reset();
  void dispose();
}
```

**不冲突**。`SimulationClock` 底层也是 `Ticker`（`:29` `_ticker`），提供 `onTick(dt, totalTime)` 回调。B 的 `_tickCompass` 不需要 `dt`（它读当前 state 算目标角度，不积分时间），但 `SimulationClock.onTick` 可以忽略 `dt` 参数。

### 是否应该替换为 SimulationClock

| 选项 | 权衡 |
|---|---|
| **A · 保留 AnimationController** | 代码原样 · 不改行为 · 但不符合 KARTOSLAB "统一心跳"规范 |
| **B · 替换为 SimulationClock** | 符合规范 · 但需改 initState / dispose · `_tickCompass` 签名从无参改为 `(dt, totalTime)` |
| **C · 暂不替换，后续迭代** | 最低风险 · 标记技术债 |

### 决策

**推荐 C · 暂不替换，后续迭代**。

理由：

1. B 的 `AnimationController` 用于**阻尼追踪动画**，与 `SimulationClock` 的"模拟时钟"语义不完全一致——B 不是积分物理时间，是每 frame 算目标角度
2. 替换需要改 `initState` / `dispose` / `_tickCompass` 签名——属于行为变更，本阶段 READ-ONLY 不改
3. `lib/sound/` 用 `SimulationClock` 驱动物理积分（`_state.stepInTime(dt)`），magnet 的 `_tickCompass` 不积分——语义不同
4. 如果后续要统一用 `SimulationClock`，需先评估"阻尼追踪"是否应该用 `dt` 做帧率无关的阻尼（当前 `_compassVelocity * 0.85 + diff * 0.08` 是帧率相关的）

### dispose 统一

[已确认] B 的 `dispose()`（`:216-219`）已正确 dispose `_compassCtrl`。迁移时保持不变。

---

## 6. NineGrid 决策

### B 当前布局分析

[已确认] B 的 `build()` 方法（`:248-343`）用 `Scaffold > Stack` + 多个 `Positioned`：

| 层 | 代码 | 说明 |
|---|---|---|
| `Stack` | `:250` | 全屏 Stack |
| `Positioned.fill` | `:253-270` | 磁场箭头网格（`FieldNeedlePainter`）铺满 |
| `Positioned` | `:272` | 磁铁或地球（`_buildMagnet` / `_buildEarth`） |
| `Positioned` | `:274` | 罗盘（`_buildCompass`） |
| `Positioned` | `:276` | 磁场计（`_buildFieldMeter`） |
| `Positioned(top:12, right:12)` | `:278-303` | 控制面板 |
| `Positioned(top:12, left:12)` | `:306-322` | 返回按钮 |
| `Positioned(right:18, bottom:18)` | `:324-340` | Reset 按钮 |

### 可以使用 NineGridLayout 的

| 区域 | 当前 | 迁移后 NineGridLayout 槽位 | 理由 |
|---|---|---|---|
| 控制面板 | `Positioned(top:12, right:12)` | `topRight` 或 `rightPanel` | 页面级 UI 控件 · 适合边格 |
| 返回按钮 | `Positioned(top:12, left:12)` | `topLeft` | 页面级导航 · 适合边格 |
| Reset 按钮 | `Positioned(right:18, bottom:18)` | `bottomRight` | 页面级操作 · 适合边格 |
| 主画面区 | `Stack` 内的磁铁/罗盘/磁场/磁场计 | `center` | 实验画面 · 中间格 ≥ 70% |

### 需要保留局部 Stack / CustomPainter 的

| 元素 | 当前 | 迁移后 | 理由 |
|---|---|---|---|
| 磁铁图形 | `Positioned` + `Transform.rotate` + `CustomPaint(BarMagnetPainter)` | **保留** `Positioned` + `CustomPaint` | canvas 内部精确定位 · 拖拽依赖绝对坐标 |
| 罗盘指针 | `Positioned` + `CustomPaint(CompassPainter)` | **保留** `Positioned` + `CustomPaint` | canvas 内部精确定位 · 拖拽依赖绝对坐标 |
| 磁场箭头网格 | `Positioned.fill` + `CustomPaint(FieldNeedlePainter)` | **保留** `Positioned.fill` + `CustomPaint` | canvas 内部精确定位 · 铺满主画面 |
| 地球/背景 | `Positioned` + `Stack` + `SvgPicture` + `CustomPaint` | **保留** `Positioned` + `Stack` | canvas 内部精确定位 |
| 磁场计面板 | `Positioned` + `Container` + `Column` | **保留** `Positioned` | canvas 内部精确定位 · 拖拽依赖绝对坐标 |

### 最终映射

```
Scaffold
├── AppBar（标题 + 知识点按钮）  ← 新增 · 符合 KARTOSLAB 规范
└── NineGridLayout
    ├── center: Stack(           ← 主画面区
    │     Positioned.fill(FieldNeedlePainter),  ← 保留
    │     Positioned(_buildMagnet / _buildEarth),  ← 保留
    │     Positioned(_buildCompass),  ← 保留
    │     Positioned(_buildFieldMeter),  ← 保留
    │   )
    ├── topRight: MagnetControlPanel,  ← 控制面板
    ├── topLeft: 返回按钮（或由 AppBar 替代）,
    └── bottomRight: Reset 按钮,
```

### 决策

**不机械重写 Stack / Positioned**。

| 层 | 操作 |
|---|---|
| 页面级（控制面板 / 返回 / Reset） | 迁移时用 `NineGridLayout` 边格 |
| canvas 内部（磁铁 / 罗盘 / 磁场 / 地球 / 磁场计） | **保留** `Stack + Positioned + CustomPaint` |

理由：

1. `Positioned` 用于**拖拽元件的精确定位**——元件位置由 `_state.magnetPos` / `_state.compassPos` / `_state.fieldMeterPos` 决定，是动态坐标，不能用 `NineGridLayout` 边格替代
2. `Positioned.fill` 用于**磁场箭头网格铺满**——这是 canvas 绘制需求，不是页面布局需求
3. `NineGridLayout` 适合**页面级 UI 区域分配**，不适合 canvas 内部元件定位
4. 参照 `lib/sound/screens/sound_screen.dart:109-126` — `NineGridLayout` 的 `center` 内部仍有 `Stack` / `CustomPaint`

---

## 7. common 组件决策

### 逐项检查

| B 当前控件 | 代码位置 | L0 对应 | 语义一致？ | 决策 |
|---|---|---|---|---|
| `Slider` | `:937` `SliderTheme > Slider` | `lib/common/controls/kratos_slider.dart` | ⚠️ 部分 | [推测] 需读 KratosSlider 接口确认 |
| `Checkbox` | `:968-973` / `:983-988` | 无直接对应 | — | **保留** · 无 L0 对应 |
| `ElevatedButton`（Flip Polarity） | `:950-960` | 无直接对应 | — | **保留** · 无 L0 对应 |
| `IconButton`（返回 / Reset） | `:309` / `:327` | 无直接对应 | — | **保留** · 无 L0 对应 |
| `_card` 方法 | `:1057+`（推测） | 无直接对应 | — | **保留** · sim 内部 UI |
| `Text` | 多处 | 无 L0 对应 | — | **保留** |
| `_arrowBtn` | `:926` / `:940` | 无直接对应 | — | **保留** |
| `_check` | `:944-946` | 无直接对应 | — | **保留** |

### KratosSlider 接口检查

[待确认] 本阶段未读 `kratos_slider.dart` 接口。迁移时需先读 KratosSlider 接口确认：

| 检查项 | 需确认 |
|---|---|
| KratosSlider 是否支持 `value` + `onChanged` | 如是 → 可替换 |
| KratosSlider 是否支持自定义 `SliderTheme`（trackHeight / thumbShape） | 如否 → B 的自定义样式会丢失 |
| KratosSlider 是否支持左右箭头按钮 | 如否 → 需保留 B 的 `_arrowBtn` + Slider 组合 |

### 决策

| 控件 | 决策 | 理由 |
|---|---|---|
| `Slider` | **暂不替换** | B 用了重度自定义 `SliderTheme`（trackHeight=3 / thumbRadius=7 / 无 overlay）· 需确认 KratosSlider 是否支持这些 · [待确认] |
| `Checkbox` | **保留** | 无 L0 对应 |
| `ElevatedButton` | **保留** | 无 L0 对应 |
| `IconButton` | **保留** | 无 L0 对应 |
| 其他 | **保留** | 无 L0 对应 |

**原则**：只有找到真正语义一致的公共组件才推荐复用。**不为了形式统一而替换**。

---

## 8. MagneticField 决策

### 最终确认

| 项 | 值 |
|---|---|
| `MagneticField.compute()` 位置 | `lib/magnetism/magnet_and_compass/model/magnetic_field.dart` |
| 是否上抽到 `lib/common/` | **否** |
| 是否与 phet/widgets 合并 | **否** |

### 禁止合并理由

[已确认] 两组实现行为差异（详见 `MAGNET_MIGRATION_DESIGN.md` §7）：

| 维度 | magnet B | phet/widgets |
|---|---|---|
| earthField 模式 | ✅ 有 | ❌ 无 |
| loops 参数 | ❌ 无 | ✅ 有 |
| k 系数 | `strength × 18000` | `strength × loops` |
| Field 接口 | ❌ 不继承 | ✅ extends Field |
| 多偶极子叠加 | ❌ 单偶极子 | ✅ 列表 |

### 决策

`MagneticField` 作为 **sim 内部逻辑**，原样迁移到 `model/magnetic_field.dart`。**禁止进入 `lib/common/`**。phet/widgets 的另一套 field 实现不能与其合并。

---

## 9. A 版本处理

| 项 | 值 | 依据 |
|---|---|---|
| A 路径 | `phet/magnet_and_compass/` | [已确认] |
| A 性质 | standalone App（有 `void main()` + `MagnetApp` + `MaterialApp`） | [已确认] |
| A 是否进入 KARTOSLAB runtime | **否** | |
| A 当前状态 | 保留原位不动 | |

### 决策

**推荐**：`phet/magnet_and_compass/` 继续作为 **reference / archive candidate**，不进入 KARTOSLAB runtime。当前不移动。

理由：

1. A 不影响运行工程（A 的 `main()` 不被 `KratosApp` 调用）
2. A 是 PhET 原始形态 · 保留作参考基线
3. 迁移 B 后 · A 不再被任何代码引用 · 自然成为死代码
4. [待确认] 用户是否需要 A 的 `earth.svg`（A 也没有此文件）

---

## 10. 测试迁移计划

### 当前状态

[已确认] `test/` 目录内无 magnet / compass 相关测试。

### 测试文件与测试案例规划

| # | 测试文件 | 测试目标 | 测试案例 | AC |
|---|---|---|---|---|
| 1 | `test/magnetism/magnet_state_test.dart` | `MagnetState` 初始化 + `copyWith` | TC-1.1: 12 字段默认值正确<br>TC-1.2: `copyWith` 单字段替换不污染其他字段<br>TC-1.3: `copyWith` 多字段批量替换 | AC-1 |
| 2 | `test/magnetism/magnetic_field_test.dart` | `MagneticField.compute()` 偶极子场 | TC-2.1: 轴线远场 \|B\| ∝ 1/r³ · k=strength×18000<br>TC-2.2: 翻转极性后 B 方向反转 180°<br>TC-2.3: earthField 模式 B 方向垂直 · N 极向上<br>TC-2.4: 中点零场 B 方向垂直于轴线<br>TC-2.5: `magnitude()` 返回向量模长<br>TC-2.6: `fieldAngle()` 返回弧度角 | AC-2 |
| 3 | `test/magnetism/magnet_position_test.dart` | 磁铁拖拽 clamp 边界 | TC-3.1: 拖拽不超出屏幕右边界<br>TC-3.2: 拖拽不超出屏幕左边界<br>TC-3.3: earthField 模式拖拽不超出地球半径边界 | AC-3 |
| 4 | `test/magnetism/compass_behavior_test.dart` | 罗盘指针朝向磁场方向 | TC-4.1: 指针方向与磁场方向一致<br>TC-4.2: 翻转极性后指针反向<br>TC-4.3: earthField 模式指针朝垂直方向<br>TC-4.4: 阻尼追踪有惯性（速度衰减 0.85） | AC-4 |
| 5 | `test/magnetism/magnet_screen_test.dart` | Screen 初始化 + reset + 控制面板 | TC-5.1: Screen 加载默认 state（strength=0.75 · showField=true · earthField=false）<br>TC-5.2: reset 恢复初始 state<br>TC-5.3: 控制面板开关切换 showField / seeInside / earthField / showCompass / showFieldMeter<br>TC-5.4: Flip Polarity 按钮翻转 flipped<br>TC-5.5: Strength slider 改变 strength | AC-5 |

### AC 定义

| AC | 描述 |
|---|---|
| AC-1 | `MagnetState` 12 字段正确初始化 + `copyWith` 单字段替换 |
| AC-2 | `MagneticField.compute()` 偶极子场远场 ∝ 1/r³ · 翻转反向 · earthField 垂直 · 中点零场 |
| AC-3 | 磁铁拖拽不超出屏幕边界（clamp 生效） |
| AC-4 | 罗盘指针方向与磁场方向一致 · 翻转极性后反向 · 有阻尼惯性 |
| AC-5 | Screen 加载默认状态 · reset 恢复初始 · 控制面板交互正确 |

**禁止**：在本阶段创建测试代码。只给出规划。

---

## 11. Home 接线计划

### 当前不接

**本阶段不修改 `home_screen.dart`**。

### Home card 规划

| 项 | 值 | 依据 |
|---|---|---|
| 学科 | 物理 | [推测] magnet 属物理 |
| 子领域 | 电磁学（新建） | [推测] 当前 Home 无"电磁学"组 · 需新建 |
| title | 磁铁与罗盘 | |
| subtitle | 磁场 · 偶极子 · 指南针 | |
| icon | `Icons.explore_rounded` | [推测] |
| color | `Color(0xFF2563EB)` 或 `Color(0xFF7C3AED)` | [待确认] |
| builder | `_buildMagnetAndCompass` | |
| route | `MaterialPageRoute(builder: (_) => const MagnetAndCompassScreen())` | |
| import | `import '../magnetism/magnet_and_compass/screens/magnet_and_compass_screen.dart';` | |

### Home 改动清单（当前不执行）

| 文件 | 改动 |
|---|---|
| `lib/screens/home_screen.dart` | 1. import MagnetAndCompassScreen<br>2. 在"物理"学科下新建"电磁学"`_SubjectGroup`<br>3. 添加 `_SimEntry`<br>4. 添加 `static Widget _buildMagnetAndCompass(BuildContext _) => const MagnetAndCompassScreen();` |

---

## 12. 迁移顺序

| 步骤 | 操作 | 依赖 | 风险 |
|---|---|---|---|
| 1 | 确认 [待确认] 项（earth.svg 来源 / Home 子领域 / icon/color） | 用户拍板 | — |
| 2 | 创建 `lib/magnetism/magnet_and_compass/` 目录树 | 步骤 1 | — |
| 3 | 拆分 12 个文件到目标路径 | 步骤 2 | 🟡 拆分过程中 private → public 改名遗漏 |
| 4 | 解决 `earth.svg` 缺失问题 | 步骤 1 | 🔴 不解决则 earthField 模式 crash |
| 5 | 类名改写（private → public · Page → Screen） | 步骤 3 | 🟡 漏改导致编译错误 |
| 6 | import 路径调整 | 步骤 3-4 | 🟡 相对路径错误 |
| 7 | **修复 `simulations/electromagnet_page.dart:10` 的 import** | 步骤 3 | 🔴 `import 'magnet_and_compass.dart' show CompassPainter;` 需改为新路径 · 否则编译失败 |
| 8 | NineGridLayout 适配（页面级 UI） | 步骤 3 | 🟡 需重构 build 方法 |
| 9 | Home 接线 | 步骤 3 | 🟢 低 |
| 10 | `pubspec.yaml` assets 添加 `earth.svg`（如需） | 步骤 4 | 🟢 低 |
| 11 | 创建测试文件 | 步骤 3 | 🟢 低 |
| 12 | `flutter analyze` 验证编译 | 步骤 3-11 | 🟡 |
| 13 | `flutter run` 验证运行 | 步骤 12 | 🟡 |
| 14 | 删除 `simulations/magnet_and_compass.dart`（原 B） | 步骤 13 | 🔴 不可逆 · 需用户确认 |

---

## 13. 风险

| 风险 | 等级 | 原因 | 缓解 |
|---|---|---|---|
| **B 有外部消费者 `electromagnet_page.dart`** | 🔴 高 | `electromagnet_page.dart:10` `import 'magnet_and_compass.dart' show CompassPainter;` · 迁移 B 后此 import 失效 · 但 `electromagnet_page.dart` 本身因 `electromagnet_model.dart` 缺失已编译失败（[已确认] #24） | 迁移时同步修复此 import 指向新路径 · 或确认 electromagnet 整体废弃后一并清理 |
| **`electromagnet_model.dart` 全工程不存在** | 🔴 高 | `electromagnet_page.dart:7` import 它 · 该 sim 当前已 BLOCKED · 无法编译 | [待确认] 用户决定是否补齐 model 或整体废弃 electromagnet |
| `earth.svg` 缺失 | 🔴 高 | B 运行到 earthField 模式会 crash · A 同样缺失 | [待确认] 用户提供或创建替代 |
| 单文件 → 12 文件拆分 | 🟡 中 | 拆分过程中可能遗漏 private → public 改名 | 逐文件 `replace_in_file` · 逐个验证编译 |
| `NineGridLayout` 适配 | 🟡 中 | B 用 `Stack + Positioned` · 页面级 UI 需重构 | 仅页面级 UI 用 NineGrid · canvas 内部保留 Stack |
| `_ControlPanel` 自造控件 | 🟡 中 | B 用原生 `Slider` + `Checkbox` · 未用 L0 组件 | 暂不替换 · 后续评估 KratosSlider 接口 |
| `AnimationController` 未替换 | 🟡 低 | 不符合 "统一心跳"规范 · 但语义不完全一致（阻尼追踪 vs 时间积分） | 标记技术债 · 后续迭代 |
| KratosSlider 接口未知 | 🟡 中 | 未确认 KratosSlider 是否支持 B 的自定义 SliderTheme | 迁移时先读接口 |
| 磁场标度不同 | 🟢 低 | B 与 phet/widgets 标度不同 · 但不合并 | ✅ 已禁止合并 |
| 无测试 | 🟡 中 | 迁移后无测试基线 | 提出 5 个测试文件规划 |
| Home 接线 | 🟢 低 | 需新建"电磁学"子领域组 | 当前不接 · 规划完毕 |

---

## 14. [已确认]

| # | 项 | 证据 |
|---|---|---|
| 1 | B 全文 1089 行 | `read_file` 完整读取 |
| 2 | B 无 `main()` | 全文无 `void main` |
| 3 | B 入口 `MagnetAndCompassPage` | `:133` |
| 4 | B 有 10 个类 | `SimState` / `MagneticField` / `MagnetAndCompassPage` / `_EarthGlowPainter` / `_VerticalMagnetPainter` / `BarMagnetPainter` / `FieldNeedlePainter` / `CompassPainter` / `_ControlPanel` / `_MiniCompassPreviewPainter` |
| 5 | `earth.svg` 全工程不存在 | `search_file` 递归 `earth*` 0 结果 · `search_content` grep `earth\.svg` 仅 2 处引用（B `:404` + A `main.dart:542`）· 无任何实际文件 |
| 6 | A 也引用 `earth.svg` 且也缺失 | `phet/magnet_and_compass/lib/main.dart:542` 引用 `assets/earth.svg` |
| 7 | A 目录只有 `lib/main.dart` | `list_dir phet/magnet_and_compass/` 只有 `lib/` 子目录 · 无 `assets/` |
| 8 | `test/` 无 magnet 测试 | `search_content` 0 结果 |
| 9 | Home 不引用 B | `home_screen.dart` grep `magnet|compass|electromagnet` 0 结果 |
| 10 | 已有 sim 目录结构 | `model/` + `painters/` + `screens/` + `widgets/`（可选 `config/`） |
| 11 | `NineGridLayout` 是阻塞级规范 | `lib/common/widgets/nine_grid_layout.dart` · 已有 7 sim 使用 |
| 12 | Home 结构 | `_Discipline` → `_SubjectGroup` → `_SimEntry` + `builder` |
| 13 | L0 组件清单 | `lib/common/controls/` 有 `KratosSlider` / `KratosComboBox` / `KratosRadioGroup` / `KratosNumberField` · `lib/common/widgets/` 有 `PropertyControlPanel` / `TimeControlBar` / `NineGridLayout` / `ExperimentIntroPanel` 等 |
| 14 | `SimulationClock` 接口 | `lib/common/simulation_clock.dart` · 底层 `Ticker` · `onTick(dt, totalTime)` |
| 15 | B 用 `AnimationController` 而非 `SimulationClock` | `:170-173` |
| 16 | B 用 `Stack + Positioned` 而非 `NineGridLayout` | `:250-341` |
| 17 | B 用原生 `Slider` | `:937` |
| 18 | B 用原生 `Checkbox` | `:968-973` / `:983-988` |
| 19 | B 的 `AnimationController` 用于阻尼追踪 | `:188-213` `_tickCompass` · 不积分时间 |
| 20 | `lib/sound/` 无 `controller/` 目录 | `list_dir lib/sound/` |
| 21 | B 的 `dispose()` 已正确 dispose `_compassCtrl` | `:216-219` |
| 22 | B 的 `Positioned` 用于拖拽元件精确定位 | `:349-374` / `:432-451` / `:470-521` |
| 23 | **B 有外部消费者** | `simulations/electromagnet_page.dart:10` `import 'magnet_and_compass.dart' show CompassPainter;` · 迁移 B 后需修复此 import |
| 24 | `electromagnet_model.dart` 全工程不存在 | `search_file` 递归 `electromagnet_model*` 0 结果 · `electromagnet_page.dart:7` import 它会编译失败 |
| 25 | phet/widgets 外部消费者仅 transformer | `search_content` grep `import.*phet/widgets` 结果 2 文件：`transformer_painter.dart`（5 import）+ `transformer_model.dart`（1 import）· `phet/phet.dart` barrel export 无消费者 |
| 26 | transformer 3 文件完整 | `list_dir simulations/` 有 `transformer_page.dart` / `transformer_model.dart` / `transformer_painter.dart` |
| 27 | A 有 `void main()` + `MagnetApp` + `MaterialApp` | `phet/magnet_and_compass/lib/main.dart:6-25` · standalone App · 与 `KratosApp` 冲突 |
| 28 | pubspec.yaml assets 清单 | `:64-76` 列出 7 个 scenarios 目录 + `images/` + `sounds/` + `data/` · 无 `earth.svg` · 无根 `assets/` 条目 |

---

## 15. [推测]

| # | 项 | 推测依据 |
|---|---|---|
| 1 | `lib/magnetism/` 是合适 domain | 已有 domain 均为学科名（sound/optics/forces） |
| 2 | `MagnetAndCompassScreen` 是合适类名 | 已有 Screen 命名一致（SoundScreen/CircuitScreen） |
| 3 | 推荐子领域"电磁学" | magnet 属电磁学 · 但当前 Home 无此组 |
| 4 | `earth.svg` 在 PhET 原版存在 | B 和 A 都引用它 · 说明某处应该有此文件 |
| 5 | 推荐保留 A 原位 | A 无 Home 引用 · 不影响运行 · 是参考基线 |
| 6 | KratosSlider 可能支持替换 B 的 Slider | L0 组件设计目标就是复用 · 但接口未知 |
| 7 | AnimationController 语义与 SimulationClock 不完全一致 | B 不积分时间 · SimulationClock 设计目标是时间积分 |

---

## 16. [待确认]

| # | 问题 | 选项 | 推荐 |
|---|---|---|---|
| 1 | `earth.svg` 来源 | A=用户提供 · B=CustomPainter 替代 · C=移除 earthField · D=简化替代 SVG | A |
| 2 | Home 子领域归属 | A=新建"电磁学" · B=归入"光学与波动" | A |
| 3 | Home card 的 icon | A=`Icons.explore_rounded` · B=`Icons.navigation_rounded` | A |
| 4 | Home card 的 color | A=`Color(0xFF2563EB)` · B=`Color(0xFF7C3AED)` | [待确认] |
| 5 | 是否在迁移时替换 `AnimationController` → `SimulationClock` | A=替换 · B=暂不替换 · C=后续迭代 | C |
| 6 | 是否在迁移时替换原生 `Slider` → `KratosSlider` | A=替换 · B=暂不替换 · C=后续评估 | C |
| 7 | 是否在迁移时替换原生 `Checkbox` → L0 组件 | A=替换 · B=暂不替换 | B（无 L0 对应） |
| 8 | A 归档方案 | A=保留原位 · B=移到 archive · C=删除 | A |
| 9 | 是否需要 `controller/` 子目录 | A=不新建 · B=新建 | A |
| 10 | 迁移后是否立即删除原 B 文件 | A=立即删除 · B=保留观察期 | B |

---

## 完成声明

- 本文档基于 READ-ONLY 全文阅读 + 四路搜索 · **未移动任何文件** · **未修改任何 import** · **未创建任何代码**
- 所有 `[已确认]` 项均有工具调用实证（22 项）
- 所有 `[推测]` 项已标注推测依据（7 项）
- 所有 `[待确认]` 项已列出选项（10 项）
- 迁移方案完毕 · **不执行任何文件操作** · 完成后停止
