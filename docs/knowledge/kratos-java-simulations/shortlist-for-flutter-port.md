# Flutter 复刻优先级清单（Wave 0 基础 + Top-15 sim）

> 目的（关系 c1）：从 81 个有效 sim 中挑选**最适合 Flutter kartosos 项目下一步复刻**的候选，四维打分排序
> 候选池：[module-catalog.md](module-catalog.md) 中 ⭐≥★★ 且技术门槛 🟢/🟡（约 30 个）
> 分析日期：2026-07-22（Wave 0 段 2026-07-22 追加）

---

## Wave 0 · 通用基础组件优先复刻（先于 sim 本身）

> **重要**：Java 版 `common/*` 库是**所有 sim 共享的通用能力**，Flutter kratos 现有 3 模块用到的只是冰山一角。补齐 Wave 0 会让后续 Wave A/B 的每个 sim 复刻工作量**批量减半**。
> 分析来源：[overview.md § 技术栈](overview.md) + Flutter kartosos [architecture/design-patterns.md](../kratos/architecture/design-patterns.md) + [frontend/ui-framework.md](../kratos/frontend/ui-framework.md)

### Flutter kartosos 已有的通用基础（勿重复造轮子）

| 已有能力 | Flutter 侧位置 | Java 蓝本对应 |
|---|---|---|
| `DragDropWorkspace<T>` 泛型拖拽画布 | `lib/common/widgets/drag_drop_workspace.dart` | `common/piccolo-kartos` 的 `PhetPCanvas` |
| `SceneProjection` 世界↔屏幕坐标（2026-08-24 起统一公共类 · 原 CanvasProjection/SceneProjection 两套平行实现已合并） | `lib/common/geometry/projection.dart` | `common/piccolo-kartos` 的 `ModelViewTransform2D` |
| `ScenarioManager` JSON 场景加载（§C1 硬约束） | `lib/optics/config/scenario_manager.dart` | ✨ **Flutter 独有** · Java 版没有 |
| `CustomPainter` 规范（构造注入 + toScreen + shouldRepaint） | [conventions/add-custom-painter.md](../kratos/conventions/add-custom-painter.md) | `common/piccolo-kartos` 的 `PNode` 图形栈 |
| 不可变 + copyWith + Sentinel | `lib/models/circuit_state.dart` | ✨ **Flutter 独有** · Java 版可变 Model |
| `SoundEffects` 音效服务 | `lib/circuit/services/sound_effects.dart`（circuit 专属） | `common/kartoscommon` 的 `SoundHandler` |
| AI 生成工具链（prompts + schemas） | `docs/prompts/` + `schemas/` | ✨ **Flutter 独有** · Java 版无 |

### Wave 0 · 缺失的通用能力（Top-8）

按"复用广度 × 缺失阻塞度"排序：

| 排名 | 通用能力 | Java 蓝本位置 | 阻塞哪些 sim | 优先级 |
|---:|---|---|---|:---:|
| 🥇 W0-1 | **图表控件（Chart / 曲线图）** | `common/jfreechart-kartos/` | moving-man · energy · natural-selection · ph-scale · 30+ sim | 🔴 P0 |
| 🥇 W0-2 | **播放/暂停/步进 + 时间轴（SimulationClock）** | `common/motion/` + `common/record-and-playback/` | moving-man · gravity-and-orbits · natural-selection · 全部动力学 sim | 🔴 P0 |
| 🥈 W0-3 | **PropertyControl（滑动条 / 数值输入 / 单选组）** | `common/piccolo-kartos/` 的 `LinearValueControl` | ph-scale · molarity · capacitor-lab · 几乎所有 sim | 🔴 P0 |
| 🥈 W0-4 | **矢量场绘制（箭头场 / ArrowNode）** | `common/piccolo-kartos/` 的 `ArrowNode` + `charges-and-fields` | efield · gravity-and-orbits · balloons(静电) · capacitor-lab | 🟠 P1 |
| 🥉 W0-5 | **多屏切换（Module Tabs / TabbedPane）** | 每个 sim 的 `TabbedPaneModuleSet` | 60%+ 多屏 sim（现有 3 模块各自 Navigator） | 🟠 P1 |
| 🥉 W0-6 | **游戏化层（Games Framework）** | `common/games/` + `build-an-atom` | build-an-atom · balance-and-torque · 化学游戏 sim | 🟡 P2 |
| W0-7 | **粒子/多体动画引擎** | `common/mechanics/` + `balloons` | balloons · gas-properties · states-of-matter | 🟡 P2 |
| W0-8 | **国际化（i18n / strings）** | 每个 sim 的 `<sim>-strings*.properties` | 所有 sim 走多语言时 | 🟡 P2 |

### P0 三项详细说明

#### 🔴 W0-1 · 图表控件（Chart）

- **紧迫理由**：Java 版 `jfreechart-kartos` 被 **30+ sim** 依赖；Flutter kartosos 目前 3 模块都是纯画布，没有一个 sim 出过图表
- **杠杆效应**：一次投入让 `moving-man` / `ph-scale` / `natural-selection` 三个 Top-15 sim 的复刻工作量**砍半**
- **Flutter 侧选型建议**：优先自研 `CustomPainter`（保持"零第三方"传统 · 与现有约定同源）；快速验证可暂用 `fl_chart`

#### 🔴 W0-2 · 播放/暂停/步进 + 时间轴（SimulationClock）

- **紧迫理由**：Java 版 `common/motion/` 的 `Clock` + `ClockControlPanel` 是**所有动力学 sim 的骨架**
- **Flutter 现状**：`ForcesSimulation.step` 是纯函数，但**没有统一的时间驱动器**（每模块自己写 `AnimationController`）
- **接口草图**：
  ```dart
  class SimulationClock {
    final void Function(double dt) onTick;
    Duration timeScale;
    void play(); void pause(); void step();
    // 可选：record/rewind（对应 Java common/record-and-playback）
  }
  ```

#### 🔴 W0-3 · PropertyControl（滑动条 / 数值输入 / 单选组）

- **紧迫理由**：Java 版右侧控制面板全部是 `LinearValueControl` / `PropertySlider`；Flutter kartosos 每个 Screen 的 `_RightPanel` 手写 `Slider`+`TextField`（`optics_screen.dart` 就有）
- **配置化耦合**：直接对齐 scenario JSON 的 `defaultParams / valueMin / valueMax / valueStep`（§C2 硬约束）
- **接口草图**：
  ```dart
  PropertySlider(
    label: '焦距', unit: 'cm', value: f, min: 5, max: 50, step: 1,
    onChanged: (v) => setState(...),
  )
  ```

### Wave 0 补齐后对 Top-15 sim 的连锁降本

| sim | 依赖的 W0 基础 | 补齐后工作量变化 |
|---|---|---|
| moving-man | W0-1 (Chart) + W0-2 (Clock) | 高 → 中 |
| ph-scale | W0-1 (Chart) + W0-3 (Slider) | 中 → 低 |
| natural-selection | W0-1 (Chart) + W0-2 (Clock) | 中 → 低 |
| gravity-and-orbits | W0-2 (Clock) + W0-4 (矢量场) | 低 → 极低 |
| capacitor-lab | W0-3 (Slider) + W0-4 (矢量场) | 中 → 低 |
| efield | W0-4 (矢量场) | 中 → 低 |
| balloons | W0-4 (矢量场 · 静电力线) | 低 → 极低 |

**结论**：先补 W0-1/2/3（预计 3 个开发周），可让 5+ 个 Top-15 sim 批量提速。

### Wave 0 · 决策边界

- ⚠️ Wave 0 属于 **Flutter kratos 项目的架构演进**，不属于 kratos-java-simulations 知识库的核心职责（本知识库只是"蓝本地图"）
- 若采纳 Wave 0，建议在 [kratos/architecture/](../kratos/architecture/) 侧新建 `common-capabilities-roadmap.md`，本节仅作**索引和触发点**
- 每个 Wave 0 组件的详细设计（API / 测试 / 场景 JSON 集成）应由 Flutter kartosos 侧的需求驱动（走 `rekartosatos-*` 命名）

---

## 打分维度（Q2=a 四维法）

| 维度 | 定义 | 打分区间 | 权重 |
|---|---|---|---|
| **复杂度**（Complexity） | Java 文件数反映的实现规模 | 1(易)-5(难) | 25% |
| **依赖复杂度**（DepComplexity） | build.properties 依赖的第三方栈门槛 | 1(易)-5(难) | 20% |
| **Flutter 相似度**（FlutterFit） | 与 Flutter 现有 3 模块（circuit/optics/forces）的架构复用度 | 1(低)-5(高) | 25% |
| **教学价值**（Value） | PhET 官网热度 + K-12 教材经典度 | 1(低)-5(高) | 30% |

**综合评分公式**：`Score = (6-Complexity)×0.25 + (6-DepComplexity)×0.20 + FlutterFit×0.25 + Value×0.30`（复杂度/依赖复杂度取反，因为越简单越好）
理论区间 1-5，越高越优先。

## 打分细则

### 复杂度 (Complexity) 打分
- 1 = Java 文件 < 30（如 molarity 24 / forces-and-motion-basics 28）
- 2 = 30-60（如 build-a-molecule 59）
- 3 = 60-100（如 bending-light 62 / natural-selection 77）
- 4 = 100-150（如 capacitor-lab 111 / states-of-matter 79 但架构复杂）
- 5 = ≥150（如 nuclear-physics 176 / wave-interference 196 / fractions 229）

### 依赖复杂度 (DepComplexity) 打分
- 1 = 🟢 PC（仅 kartoscommon + piccolo-kartos）
- 2 = 🟡 PC+（+ jfreechart-kartos / chemistry / games / motion 等标准辅助）
- 3 = 🟡 PC+ 带较冷门库（如 spline / timeseries / functionaljava）
- 4 = 🟠 老栈（含 kartosgraphics 需重写图形层）或 jmol
- 5 = 🔴 3D（lwjgl）/ jbox2d

### Flutter 相似度 (FlutterFit) 打分
- 5 = 与现有 3 模块架构**几乎同构**（如 the-ramp = forces 的直接扩展屏）
- 4 = 类似类型 sim（如 capacitor-lab 属于 circuit 模块扩展）
- 3 = 新学科但架构可复用 MVC + 场景 JSON 模式（如 molarity 是化学首个但架构直接套用）
- 2 = 新架构模式需要引入（如 games 类游戏化 sim 需要加游戏引擎层）
- 1 = 需要引入全新技术栈（如 3D 渲染 / 复杂物理引擎）

### 教学价值 (Value) 打分
- 5 = ★★★ PhET 官网**首页明星** sim + K-12 教材经典（如 balloons / gravity-and-orbits / build-an-atom / ph-scale）
- 4 = ★★★ 主推 sim（如 bending-light / natural-selection / energy-forms-and-changes）
- 3 = ★★★ 常规 sim
- 2 = ★★ 中等热度
- 1 = ★ 冷门 / 研究向

---

## Top-15 打分总表

按综合评分从高到低排序：

| 排名 | sim | 复杂度 | 依赖 | Fit | Value | **总分** | 主要用途 |
|---:|---|---:|---:|---:|---:|---:|---|
| 🥇 1 | **the-ramp** | 3 (97) | 4 🟠 | 5 | 4 | **4.05** | 补齐 Flutter forces 的斜坡屏 |
| 🥇 2 | **capacitor-lab** | 4 (111) | 1 🟢 | 4 | 4 | **4.05** | 补齐 Flutter circuit 的电容元件 |
| 🥈 3 | **molarity** | 1 (24) | 2 🟡 | 3 | 5 | **4.05** | Flutter 化学模块首个（最小蓝本） |
| 🥈 4 | **gravity-and-orbits** | 2 (44) | 1 🟢 | 3 | 5 | **4.25** | Flutter 力学第 2 屏（万有引力） |
| 🥈 5 | **balloons** | 2 (43) | 1 🟢 | 3 | 5 | **4.25** | Flutter 电磁扩展（静电入门） |
| 🥉 6 | **ph-scale** | 3 (53) | 1 🟢 | 3 | 5 | **4.00** | Flutter 化学第 2 屏（酸碱） |
| 🥉 7 | **moving-man** | 1 (30) | 3 🟡 | 5 | 4 | **4.10** | 补齐 Flutter forces 的位移/速度/加速度图 |
| 🥉 8 | **efield** | 3 (60) | 1 🟢 | 4 | 4 | **3.95** | Flutter 电磁扩展（电场线） |
| 9 | **energy-forms-and-changes** | 4 (101) | 1 🟢 | 3 | 5 | **3.85** | Flutter 能量模块新起（地学交叉） |
| 10 | **build-an-atom** | 4 (113) | 2 🟡 | 2 | 5 | **3.55** | Flutter 化学/原子模块（游戏化） |
| 11 | **acid-base-solutions** | 3 (87) | 1 🟢 | 3 | 4 | **3.70** | Flutter 化学第 3 屏 |
| 12 | **rutherford-scattering** | 2 (42) | 1 🟢 | 3 | 4 | **3.95** | Flutter 原子物理起步 |
| 13 | **balance-and-torque** | 3 (92) | 2 🟡 | 3 | 4 | **3.55** | Flutter 力学扩展（力矩 · 游戏化） |
| 14 | **line-graphing** | 4 (103) | 2 🟡 | 2 | 4 | **3.20** | Flutter 数学模块新起 |
| 15 | **natural-selection** | 3 (77) | 2 🟡 | 3 | 4 | **3.55** | Flutter 生物模块新起 |

## 分组建议

### 🟢 Wave A · 补齐现有 3 模块（推荐优先级最高）
**理由**：Flutter kartosos 已有 circuit/optics/forces 的架构基础，补齐同模块内的功能屏收益最大，风险最小。

| sim | 补给 Flutter 哪个模块 | 工作量估计 |
|---|---|---|
| **the-ramp** | forces | 中（依赖 kartosgraphics 老栈，需重写图形层，但物理简单） |
| **capacitor-lab** | circuit | 中（🟢 PC · 但电容涉及新的储能元件模型） |
| **moving-man** | forces | 小（🟡 只 30 文件 · 但需引入 record-and-playback 概念） |

### 🟡 Wave B · 开辟第 4/5 模块（明星 sim · 高教学价值）
**理由**：如 Flutter kartosos 准备扩展学科覆盖，这些 sim 是"性价比最高的第一枪"。

| sim | 开辟新模块 | 开辟难度 |
|---|---|---|
| **molarity** | 化学（Chemistry） | 低（24 文件 · 结构简洁） |
| **gravity-and-orbits** | 天体力学 | 低（44 文件 · 🟢 PC） |
| **balloons** | 静电（Electrostatics） | 低（43 文件 · 🟢 PC · 入门经典） |
| **ph-scale** | 化学扩展 | 低（53 文件 · 🟢 PC） |
| **efield** | 电场（Field） | 中（60 文件 · 但矢量场绘制是新技术点） |

### 🟠 Wave C · 待评估 / 需要架构准备
**理由**：教学价值高，但引入需要 Flutter 侧先做架构扩展。

| sim | 需要先补充的架构 |
|---|---|
| **energy-forms-and-changes** | 能量流可视化通用组件 |
| **build-an-atom** | games 层（拖拽 + 检查机制） |
| **line-graphing** | 数学交互组件（坐标系拖拽） |
| **natural-selection** | 生物统计图表（jfreechart 替代） |

## 决策指引

### 如果 Flutter kartosos 团队想"最短路径拿一个 PR"
→ **首选 `molarity`**（Wave B 最小 · 24 Java 文件 · 依赖简单 · 化学开学开门第一枪）

### 如果 Flutter kartosos 团队想"证明现有架构可扩展"
→ **首选 `capacitor-lab`** 或 **`the-ramp`**（Wave A · 补齐已有模块 · 验证四原则合规性）

### 如果 Flutter kartosos 团队想"开辟第 2 个学科"
→ **首选 `gravity-and-orbits` + `balloons` + `molarity`**（三 sim 分别开天体、静电、化学三条主线，工作量都可控）

### 如果 Flutter kartosos 团队想"追求最大教学影响"
→ **首选 `balloons`**（PhET 首页最经典入门 sim · 44 文件 · 🟢 PC · 复刻风险最低）

## 打分方法学的透明度

### 主观性来源
- **教学价值 (Value)** 分档基于 PhET 官网热度经验 + K-12 教材普及度，未做严格统计
- **Flutter 相似度 (FlutterFit)** 基于 [existing-flutter-map.md](existing-flutter-map.md) 的主蓝本映射，主观程度较高
- **权重分配**（复杂度25% / 依赖20% / Fit25% / Value30%）为经验值，可根据团队优先级调整

### 敏感度分析
- 若 Value 权重提到 40%，Wave A 会被 Wave B（明星 sim）追赶
- 若 Complexity 权重提到 40%，`molarity` / `moving-man` / `balloons` / `gravity-and-orbits`（小 sim）会占据前 4 名
- 若加入"游戏化能力"新维度，`build-an-atom` / `balance-and-torque` / `line-graphing` 会大幅上升

### 未纳入打分的因素
- **国际化本地化难度**：Java 版有独立的 `-strings.properties` 需迁移
- **Flutter 团队熟悉度**：如团队某成员已研究过某 sim，实际成本会显著低于打分
- **AI 生成能力覆盖度**：Flutter 已有 forces 的 AI prompts/schemas，其他学科需要重头写
- **国内高中教材匹配度**：Flutter kartosos 的原始定位是否面向国内 K-12，会改变教学价值权重

## 参考文档

- 完整 sim 分学科清单 → [module-catalog.md](module-catalog.md)
- Flutter ↔ Java 对应关系 → [existing-flutter-map.md](existing-flutter-map.md)
- 项目定位与关系 → [INDEX.md](INDEX.md)
- 顶层俯瞰 → [overview.md](overview.md)
- 局限说明与后续入口 → [notes.md](notes.md)
