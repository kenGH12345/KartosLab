# Flutter 已复刻模块 ↔ PhET Java 源码定位

> 目的（关系 c3）：帮助 Flutter kratos 复刻者快速找到"当前已有 3 个模块的 Java 参考实现在哪、哪些功能可以从 Java 版借鉴补齐"
> 数据源：[Flutter 侧 systems/module-index.md](../kratos/systems/module-index.md) × [kartosos-java catalog](module-catalog.md)
> 分析日期：2026-07-22

## 三大模块对应关系总览

| Flutter 模块 | 主要 Java 蓝本 | 相关 Java sim | 复刻程度评估 |
|---|---|---|---|
| **electric / circuit** | `circuit-construction-kit`（CCK） | `battery-resistor-circuit`, `signal-circuit`, `capacitor-lab`, `travoltage`, `balloons` | Flutter 版为**简化子集**（无电容/电感/交流） |
| **optics / bending-light** | `bending-light` | `color-vision`, `wave-interference`（光学部分） | Flutter 版为**简化子集**（只做几何光学 · 无水/光/声波干涉） |
| **forces / motion** | `forces-and-motion-basics` | `forces-1d`, `the-ramp`, `moving-man`, `motion-series` | Flutter 版覆盖**主体模式**（motion / netforce）但缺 `the-ramp` 斜坡 |

---

## 一、Circuit 模块 ↔ Java 电路 sim 群

### 主蓝本：`circuit-construction-kit`（CCK）

- **Java 源码位置**：`<PHET_JAVA_ROOT>/simulations-java/simulations/circuit-construction-kit/src/edu/colorado/kartos/circuitconstructionkit/`
- **规模**：172 Java 文件 · 依赖 `jfreechart-kartos + Jama + nanoxml`（Jama 用于矩阵解方程）
- **Flutter 对应**：
  - 状态：`lib/models/circuit_state.dart`（对应 CCK 的 `Circuit` 模型）
  - 求解：`lib/models/circuit_solver.dart`（**Flutter 版为简化连通图法**，CCK 用矩阵解基尔霍夫方程 → Jama 库）
  - 场景：`lib/circuit/config/`（**Flutter 独有** · JSON 场景系统 · CCK 无此层）
  - 详见 [kratos/systems/circuit-module.md](../kratos/systems/circuit-module.md)

### 相关辅助 sim（可借鉴功能）

| Java sim | 可借鉴给 Flutter circuit 的部分 | Java 文件位置 |
|---|---|---|
| `battery-resistor-circuit` | 电子小球动画（Flutter 已删除的 ElectronAnimator 可参考 CCK 之外的极简版） | `simulations/battery-resistor-circuit/src/edu/colorado/kartos/batteryresistorcircuit/` |
| `signal-circuit` | 信号脉冲传播可视化 | `simulations/signal-circuit/src/edu/colorado/kartos/signalcircuit/` |
| `capacitor-lab` | 电容元件（Flutter 尚未支持） | `simulations/capacitor-lab/src/edu/colorado/kartos/capacitorlab/` |
| `balloons` / `travoltage` | 静电基础（若未来扩静电模块） | `simulations/balloons/src/` · `simulations/travoltage/src/` |

### Java → Flutter 复刻要点提示

- **CCK 的 `Circuit` 类是电路元件的中心容器**，其 `Branch` / `Junction` 二分与 Flutter 的 `CircuitState` 内嵌 `Vertex`（`lib/models/circuit_state.dart:48`）对应
- **CCK 用 Jama 解矩阵方程**求电流分布 → Flutter 版**故意简化为连通图法**（因教学场景不需要精确电流），这是有意的差异化，不需要复刻矩阵求解
- Flutter 侧的 **场景 JSON + AI 生成 prompts/schemas**（详见 [kratos/architecture/design-patterns.md](../kratos/architecture/design-patterns.md)）是**领先 CCK 的原创能力**，复刻新功能时应同步补 JSON schema

---

## 二、Optics 模块 ↔ Java 光学/波动 sim 群

### 主蓝本：`bending-light`

- **Java 源码位置**：`<PHET_JAVA_ROOT>/simulations-java/simulations/bending-light/src/edu/colorado/kartos/bendinglight/`
- **规模**：62 Java 文件 · 依赖 `piccolo-kartos`（🟢 PC · 复刻门槛低）
- **功能覆盖**：折射、反射、全反射、棱镜、多层介质、光速可视化
- **Flutter 对应**：
  - 状态：`lib/optics/models/optics_world.dart`（对应 bending-light 的 `LightRayModel`）
  - 求解：`lib/optics/solvers/optics_solver.dart` + `lib/optics/physics/optics_math.dart`（**Flutter 版为二光线法 · 面向透镜/镜面**，bending-light 用斯涅尔定律真实光线追迹）
  - 元件：`lib/optics/models/{lens,mirror,light_source,screen}_element.dart`（Flutter 抽象为"透镜/镜面/光源/光屏"四元件；bending-light 更聚焦"介质界面折射"）
  - 场景：`lib/optics/config/`（**Flutter 独有** · JSON 场景系统）
  - 详见 [kratos/systems/optics-module.md](../kratos/systems/optics-module.md)

### 相关辅助 sim（可借鉴功能）

| Java sim | 可借鉴给 Flutter optics 的部分 | Java 文件位置 |
|---|---|---|
| `color-vision` | 光的颜色 / RGB 合成（Flutter optics 尚未涉及） | `simulations/color-vision/src/edu/colorado/kartos/colorvision/` |
| `wave-interference` | 光波干涉（若扩展到"波动光学" · **196 Java 文件**大型 sim，慎抽） | `simulations/wave-interference/src/edu/colorado/kartos/waveinterference/` |
| `fourier` | 傅里叶合成（波形叠加 · 与光学干涉相关） | `simulations/fourier/src/edu/colorado/kartos/fourier/` |

### Java → Flutter 复刻要点提示

- **bending-light 的核心是"光线追迹 + 斯涅尔定律"**（`snellsLaw` 函数遍布模型），Flutter 版**故意用二光线法简化**（透镜成像的物光线 + 光心光线），是**用途差异**不是缺陷
- **Flutter 的 4 元件抽象（透镜/镜面/光源/光屏）超越 bending-light 的"介质片"模型**——bending-light 只处理界面折射，Flutter 支持透镜聚焦这一更复杂场景
- **未来若要复刻"介质折射"功能**（如水中筷子），可完整移植 bending-light 的 `MediumSelector` + `IntersectionCalculator`

---

## 三、Forces 模块 ↔ Java 力学 sim 群

### 主蓝本：`forces-and-motion-basics`

- **Java 源码位置**：`<PHET_JAVA_ROOT>/simulations-java/simulations/forces-and-motion-basics/src/edu/colorado/kartos/forcesandmotionbasics/`
- **规模**：28 Java 文件 · 依赖 `piccolo-kartos`（🟢 PC · **最小最直接的蓝本**）
- **功能覆盖**：Motion（施力观察运动）· NetForce（拔河，多力合成）· Basics（简化入门）· Friction（摩擦力扩展）
- **Flutter 对应**：
  - 引擎：`lib/forces/models/forces_simulation.dart`（对应 Java 版的 `MotionModel` / `ForcesModel`）
  - 屏幕：`lib/forces/screens/{forces_home,motion_screen,netforce_screen}.dart`（**覆盖了 Java 版的 Motion + NetForce 两屏**）
  - 未覆盖：Java 版的 Friction 屏 / Acceleration 屏
  - 场景：`lib/forces/` 下的 `assets/scenarios/forces/*.json`（**Flutter 独有**）
  - 详见 [kratos/systems/forces-module.md](../kratos/systems/forces-module.md)

### 相关辅助 sim（可借鉴功能）

| Java sim | 可借鉴给 Flutter forces 的部分 | Java 文件位置 |
|---|---|---|
| `forces-1d` | 一维力分析（Java 文件 65 · 更详细的 Motion 屏原型） | `simulations/forces-1d/src/edu/colorado/kartos/forces1d/` |
| **`the-ramp`** | **斜坡场景（Flutter 尚未支持 · 强烈推荐补齐）** | `simulations/the-ramp/src/edu/colorado/kartos/theramp/` |
| `moving-man` | 位置/速度/加速度 三图联动（Flutter forces 若加图表可参考） | `simulations/moving-man/src/edu/colorado/kartos/movingman/` |
| `gravity-and-orbits` | 引力（若扩展二维万有引力） | `simulations/gravity-and-orbits/src/edu/colorado/kartos/gravityandorbits/` |
| `energy-skate-park` | 能量守恒（若扩展"能量视角"） | `simulations/energy-skate-park/src/edu/colorado/kartos/energyskatepark/` |

### Java → Flutter 复刻要点提示

- **forces-and-motion-basics 是 PhET 官方 Java 版里最"简洁"的力学 sim**（28 文件），非常适合 1:1 对照阅读
- **Flutter 已覆盖 Motion + NetForce 两屏**，最容易补齐的下一步是 **the-ramp 斜坡**（Java 文件 97 · 中等 · 🟠 依赖 kartosgraphics 老栈需注意图形层需要重写）
- **Flutter 的 4 模式设计**（motion / netforce / friction / acceleration）已在 `ForcesSimulation` 引擎中预留，Java 蓝本的 Friction 和 Acceleration 屏可以直接对应补齐

---

## 复刻工作流（通用模板）

针对每个候选 Java sim，Flutter 复刻建议按以下 5 步：

1. **理解 Java 蓝本**：阅读 `<sim>/src/edu/colorado/kartos/<sim>/` 目录顶层 `<Sim>Application.java` + `<Sim>Module.java` + `model/*.java`
2. **抽 MVC 三层**：
   - M（模型）→ Flutter 的 `@immutable` 状态类 + `copyWith`
   - V（视图）→ Flutter 的 `CustomPainter` + Widget
   - C（控制）→ Flutter 的 tick / handler 纯函数
3. **补配置化层**（**Flutter 独有**）：
   - 定义 `<sim>_scenario.dart` 数据模型
   - 在 `assets/scenarios/<sim>/` 建 JSON 样本
   - 补 `docs/prompts/<sim>_scenario.md` + `schemas/<sim>_scenario.schema.json`
   - 详见 [kratos/architecture/design-patterns.md](../kratos/architecture/design-patterns.md) "配置化"节 与 [kratos/architecture/ai-generation-readiness.md](../kratos/architecture/ai-generation-readiness.md)
4. **遵守四原则合规**：MVC / 组件化 / 通用化 / 配置化（详见 [kratos 侧四原则表](../kratos/systems/module-index.md#设计原则对照总表速查)）
5. **验证**：至少 3 个 sample JSON scenario 能通过 schema 校验并在 UI 中跑通

## 参考文档

- 复刻优先级排序（含打分表）→ [shortlist-for-flutter-port.md](shortlist-for-flutter-port.md)（Loop 3 产出）
- 完整 sim 分学科清单 → [module-catalog.md](module-catalog.md)
- Flutter 侧模块深度文档 → [kratos/systems/](../kratos/systems/)
