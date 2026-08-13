# 项目配置系统（三类拆分）

> 来源: 首次扫描 + 源码核对 | 创建时间: 2026-07-17

按 `knowledge-base-generator` 架构层配置规范，本项目配置按数据归属拆为三类独立说明。**本项目没有"数据映射类"配置**（详见 §2）。

## 三类配置对比

| 类别 | 本项目的载体 | 是否影响程序行为 | 修改者 |
|---|---|---|---|
| 代码逻辑类 | `pubspec.yaml` 依赖声明 + `MaterialApp` 主题注册 | 是（缺依赖编译失败，改主题改外观） | 开发者 |
| 数据映射类 | **无** | — | — |
| 外部数据类 | `assets/scenarios/*.json`（场景/约束/目标） | 是（运行时由 `ScenarioManager` 加载） | 内容作者（非代码） |

## "我应该看哪个文档"决策表

| 我想改的东西 | 去哪 |
|---|---|
| 加一个 Dart 包 / 升级版本 | §1 `pubspec.yaml` |
| 改 App 主题色 / 字体回退 | §1 `MaterialApp` 主题 |
| 改某个光学场景的教学目标 / 约束 | §3 `assets/scenarios/*.json` |
| 加一个新场景 | §3 + `ScenarioManager` |
| 协议 ID / UI 路径映射 | **本项目不存在此类别** |

## §1 代码逻辑类配置

### `pubspec.yaml` 依赖（`lib` 之外，影响构建）

**文件**：`pubspec.yaml`（3.9 KB，94 行）

| 字段 | 值 | 说明 |
|---|---|---|
| `name` | `kratos` | 包名（`pubspec.yaml:2`） |
| `sdk` | `^3.11.1` | Dart SDK 下限（`pubspec.yaml:24`） |
| `flutter` SDK | 依赖 `flutter` | 框架本体（`pubspec.yaml` dependencies） |
| `cupertino_icons` | `^1.0.8` | iOS 风格图标 |
| `flutter_svg` | `^2.3.0` | SVG 资产渲染（`assets/images/*.svg` 依赖它） |
| `audioplayers` | `^6.7.1` | 音效播放（`SoundEffects` 依赖它） |
| `flutter_lints` | `^6.0.0` | dev 依赖，lint 规则集 |
| `flutter.assets` | `assets/images/`、`assets/sounds/`、`assets/scenarios/` | 资产目录声明（`pubspec.yaml` flutter 段） |

> ⚠️ 新增第三方包必须同时：(1) 在 `dependencies:` 加版本约束；(2) 运行 `flutter pub get`；(3) 若用到资产类型（如新增图片格式），在 `flutter.assets` 补路径。

### `MaterialApp` 主题注册

**文件**：`lib/main.dart:31-49`（`KratosApp.build`）

| 配置项 | 值 | 代码位置 |
|---|---|---|
| `useMaterial3` | `true` | `lib/main.dart:38` |
| `seedColor` | `0xFF1177AA` | `lib/main.dart:33` |
| `scaffoldBackgroundColor` | `0xFFF6FAFC` | `lib/main.dart:39` |
| `fontFamilyFallback` | `[Microsoft YaHei, PingFang SC, Noto Sans CJK SC, Arial]` | `lib/main.dart:40-45` |
| `debugShowCheckedModeBanner` | `false` | `lib/main.dart:32` |
| Windows 语义包裹 | `ExcludeSemantics`（仅 `!kIsWeb && Windows`） | `lib/main.dart:27-30` |

## §2 数据映射类配置

**本项目无此类别。** 不存在协议 ID 映射表、UI 路径映射表、红点 ID、上报 ID 等"仅增删条目、代码定义读取通道"的映射配置。所有模块间引用均通过 Dart 类型与 import 直接耦合，无需映射表。如未来接入后端 API，应在此处补协议 ID 映射文档。

## §3 外部数据类配置（场景系统）

**载体**：`assets/scenarios/manifest.json` + `assets/scenarios/<id>.json`
**加载方**：`ScenarioManager.loadScenarios` → `loadScenario(id)`（`lib/optics/config/scenario_manager.dart`）

每个场景 JSON 的结构（由 `LabScenario` 模型反序列化，`lib/optics/config/lab_scenario.dart`）：

| 字段 | 类型 | 说明 |
|---|---|---|
| `domain` | string | 学科域（如 "几何光学"） |
| `ui` | object | 界面文案与布局提示 |
| `initialLayout` | object | 初始世界布局（由 `loadScenario` 建 `OpticsWorld`） |
| `inventory` | object | 可用元件清单与 `defaultParams` |
| `constraints` | list | `Constraint` 列表，运行时由 `c.validate(world)` 校验 |
| `objectives` | list | `LearningObjective` 列表，`checkAchieved(world)` 判定 |

校验与判定链路：`ScenarioManager.validateConstraints` / `checkObjectives` → 右侧 `_RightPanel` 实时显示（`lib/screens/optics_screen.dart`）。计分规则由 `GameRules` 固定公式 `100 - 0.5*秒 - 10*违规数`（`lib/optics/config/game_rules.dart`）。

---

*关键源文件: `pubspec.yaml`, `lib/main.dart`, `lib/optics/config/scenario_manager.dart`, `lib/optics/config/lab_scenario.dart`, `lib/optics/config/game_rules.dart`*
