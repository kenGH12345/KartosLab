# Energy Forms and Changes · Project Discovery

> Phase 0 · 2026-09-10  
> 取证范围：KARTOSLAB Flutter 工程 + 本地 PhET TS 源码  
> 证据标记：`[已确认]` / `[推测]` / `[待确认]` / `[BLOCKED]`

---

## PHASE: 0 — Project Discovery
## STATUS: DONE

---

## 一、KARTOSLAB 工程现状

### 1.1 工程定位 `[已确认]`

| 项 | 值 | 证据 |
|---|---|---|
| 包名 | `kratos` | `pubspec.yaml` |
| Dart SDK | `^3.11.1` | `pubspec.yaml` |
| 入口 | `lib/main.dart` → `HomeScreen` | 强制横屏 |
| 依赖 | `flutter_svg`, `audioplayers` | `pubspec.yaml` |
| 代码根 | `d:\OneDrive\Desktop\KartosLab\KartosLab`（本工作区） | — |

**规则冲突记录**：`AGENTS.md` 写「单一代码库 `c:\workspace\kratos`」。本任务以**当前 Cursor 工作区**为准，不跨盘改另一副本。`[已确认：工作区隔离]`

### 1.2 已接入 Simulation `[已确认]`

`lib/` 下约 27+ sim 包；Home 通过 `lib/screens/home_screen.dart` 静态 `_SimEntry` + `Navigator.push` 注册（无命名路由）。

**Energy Forms and Changes：Flutter 侧尚不存在**（无 `lib/energy_forms*` / 无 `req-energy-forms-and-changes` 历史 / 无 assets）。

### 1.3 最相关参考 sim `[已确认]`

| sim | 相关点 | 参考价值 |
|---|---|---|
| `energy_skate_park` | 多屏 + `KratosTabbedScreen` + Controller + clock | **双屏壳层**首选 |
| `gases_intro` | 热学域、双独立 Model、LayoutPolicy、MVT | 热学布局/时钟 |
| `curve_fitting` | Model→RenderData→Painter、NineGrid | 分层模板 |
| `blackbody_spectrum` | 固定场景、源码优先迁移报告范式 | 文档范式 |

### 1.4 L0 组件复用预判（G1）

| L0 | 路径 | EFAC 使用 | 说明 |
|---|---|---|---|
| `NineGridLayout` | `lib/common/widgets/nine_grid_layout.dart` | ✅ 强制 | 页面级壳 |
| `KratosTabbedScreen` | `lib/common/widgets/kratos_tab_bar.dart` | ✅ | Intro / Systems 双屏 |
| `SimulationClock` | `lib/common/simulation_clock.dart` | ✅ | 60fps tick；对齐 `SIM_TIME_PER_TICK_NORMAL=1/60` |
| `TimeControlBar` | `lib/common/widgets/time_control_bar.dart` | ⚠️ 外观不等价 | PhET 用 `TimeControlNode`（圆按钮 + Fast Forward）；L0 为 Material Icon。**行为可复用 clock，UI 需按原版自绘/定制** |
| `KratosSlider` | `lib/common/controls/kratos_slider.dart` | ⚠️ 局部 | Systems：biker/clouds；Intro burner 为 HeaterCooler 二维控件，**禁止用普通 Slider 冒充** |
| Chart / PropertyControlPanel / ScenarioManager | — | ❌ | 无图表/无 scenario 面板 |

### 1.5 屏幕适配硬约束 `[已确认]`

遵循 `.codebuddy/rules/80-kratos-sim-checklist.mdc` §七：NineGrid、居中、响应式。  
**Sim 内部**使用 Stack/Positioned/CustomPainter + PhET MVT（用户提示 §6）——NineGrid 不强制每个物体。

### 1.6 架构分层惯例 `[已确认]`

```
Screen (Home / Tab)
  → Model (ChangeNotifier) + optional Controller(clock/drag)
    → Solver / pure logic
      → RenderData (immutable)
        → Painter / Widgets
```

### 1.7 规则冲突：配置化 / Scenario JSON `[已确认冲突]`

Checklist 原则 4 要求 scenario JSON + schema + PropertyControlPanel。  
本 sim 为 **PhET 固定双屏**（query params 仅 Intro 调试用），与 `blackbody_spectrum` 同类。  
**本任务优先级**（用户提示）：源码行为保真 > 工程规范。  
→ **不创建 scenario JSON**；Intrinsic 写入 `efac_constants.dart`。冲突已记录，不阻塞迁移。

---

## 二、PhET 源码结构

### 2.1 源码根 `[已确认]`

```
phet sourses/energy-forms-and-changes-main/energy-forms-and-changes-main/
├── package.json                 # name=energy-forms-and-changes, version=1.5.0-dev.5
├── dependencies.json            # joist/scenery/axon/twixt… SHA 锁定
├── energy-forms-and-changes_en.html
├── energy-forms-and-changes-strings_en.json
├── images/                      # 105 × *_png.ts（base64 嵌入，无裸 png）
├── assets/                      # 设计源稿（.ai）等；非运行时必须
├── js/
│   ├── energy-forms-and-changes-main.ts   # 入口
│   ├── common/{EFACConstants,EFACQueryParameters,model/,view/}
│   ├── intro/{EFACIntroScreen,model/,view/}
│   └── systems/{SystemsScreen,model/,view/}
```

**本 checkout 为 sim-only**：无 sibling `joist/` / `scenery/` 仓库。`[已确认]`

### 2.2 入口与屏幕 `[已确认]`

`js/energy-forms-and-changes-main.ts:25-27`：

1. `EFACIntroScreen` → `EFACIntroModel` + `EFACIntroScreenView`
2. `SystemsScreen` → `SystemsModel` + `SystemsScreenView`

### 2.3 设计尺寸 / 时钟 `[已确认]` + `[推测]`

| 项 | 值 | 置信度 |
|---|---|---|
| `SCREEN_LAYOUT_BOUNDS` | `ScreenView.DEFAULT_LAYOUT_BOUNDS` | `[已确认]` `EFACConstants.ts:197` |
| 数值 | **1024 × 618** | `[已确认]` joist 自 2014 起默认（GitHub joist#640）；本地无 joist 源，与工程内多数 HTML5 移植一致 |
| Intro MVT | origin `(W×0.5, H×0.85)`, scale **1700** | `[已确认]` |
| Systems MVT | origin `(W×0.5, H×0.475)`, scale **2200** | `[已确认]` |
| `maxDT` | 0.1 s | `[已确认]` |
| tick | `SIM_TIME_PER_TICK_NORMAL = 1/60` | `[已确认]` |
| Intro fast-forward | ×4 | `[已确认]` |

### 2.4 EnergyType `[已确认]`

`THERMAL | ELECTRICAL | MECHANICAL | LIGHT | CHEMICAL | HIDDEN`  
（`js/common/model/EnergyType.ts`）

### 2.5 Intro vs Systems 一句话 `[已确认]`

| | Intro | Systems |
|---|---|---|
| 域 | 热传导 + 可拖动物体 + 温度计 | Source→Converter→User 能量管线 |
| Chunk | Wander 容器内 | PathMover 路径 |
| 时间 | Play + FastForward | Play only |
| 默认元素 | iron/brick/water/oliveOil + 2 burners | Biker + Generator + BeakerHeater |

### 2.6 Assets `[已确认]`

- **105** 个 `images/*_png.ts` 嵌入模块（运行时资源）
- **无** 本地 `mipmaps/`、`sounds/`
- Flame/Ice/Faucet 等部分依赖 **scenery-phet** 矢量组件 → Flutter 需等价重绘或从相关 PhET 包取证 `[待确认：scenery-phet 资产路径]`

### 2.7 Strings `[已确认]`

`energy-forms-and-changes-strings_en.json`：intro/systems、energySymbols、formsOfEnergy、feedMe、linkHeaters、clouds、normal/fastForward 等。

---

## 三、Home 接入预规划 `[已确认]`

目标：`物理 → 热学与气体 → Energy Forms and Changes`

现有同组：Diffusion / Gases Intro / Gas Properties / Blackbody Spectrum  
（`home_screen.dart` ~273–302）

接线阶段（Phase 11）仅追加最小 `_SimEntry` + builder。

---

## 四、基线质量

### 4.1 flutter analyze `[已确认 · C 类既有]`

| 范围 | 结果 |
|---|---|
| 全仓 | **499 issues**（error≈371, warning≈2, info≈126）——大量来自 `phet/quantum_coin_toss` 等旁路，**不修** |
| `flutter analyze lib` | **0 error / 0 warning / 18 info** |

本 sim 验收以 **`lib/energy_forms_and_changes/**` 0 error** 为准。

### 4.2 Tests `[已确认]`

- 全仓 `flutter test` 超时未完成（C 类：体量大）→ 终止，不阻塞  
- 抽样：`test/blackbody_spectrum` + `test/curve_fitting` → **98 passed**

### 4.3 既有问题分类

| 类 | 项 | 处理 |
|---|---|---|
| C | 全仓 analyze 大量 error（`phet/` 等） | 记录不修 |
| C | 全仓 test 过慢 | 本 sim 自有镜像测试 |
| D | scenery-phet 依赖不在 checkout | Phase 1/5 逐项取证或等价实现 |
| E | ENERGY_PER_CHUNK 运行时数值 | Phase 4 用同公式计算并单测锁定 |

---

## 五、风险与范围

### 高复杂度（需分屏分期落地）

1. Intro 热交换顺序敏感 + EC balance 算法  
2. Systems 10+ 元素 + carousel twixt 过渡  
3. 105 raster + 程序化蒸汽/水滴/光线  
4. HeaterCooler / FaucetNode 外部组件复刻  

### 不在本 Phase 决策（无人工阻塞）

目录将定为 `lib/energy_forms_and_changes/`（snake_case，对齐工程）；双屏用 `KratosTabbedScreen`。无需暂停。

---

## 六、本阶段产出

1. Completed：工程 + PhET 结构取证；基线 analyze/tests；规则冲突记录  
2. Files：`meta.yaml`, `process.txt`, `PROJECT_DISCOVERY.md`, `_baseline_analyze*.txt`  
3. Evidence：见上文标注  
4. Tests：抽样 98 pass  
5. Analyze：lib 0 error  
6. Visual：未截图（Phase 2）  
7. Blocked：无  
8. Known limitations：无 joist/scenery-phet 源码树；全仓 analyze 噪声  
9. Next：Phase 1 — `SOURCE_ANALYSIS.md`

---

*Phase 0 完成 → 自动进入 Phase 1*
