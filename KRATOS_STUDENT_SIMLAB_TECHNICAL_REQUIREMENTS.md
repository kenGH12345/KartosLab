# KartosLab 集成至 kratos-student 技术要求

> 文档版本：v1.0
>
> 更新日期：2026-08-27
>
> 目标形态：`kratos-student` 内置仿真实验室子功能
>
> 目标代码目录：`kratos-student/lib/src/simlab`

## 1. 文档目的

本文规定 KartosLab 迁入 `kratos-student` 后必须遵守的工程、架构、交互、资源、测试与发布要求，作为迁移实现、代码评审和验收的共同基线。

本文不是迁移完成声明。当前 KartosLab 仍是独立 Flutter App；迁移时必须按本文逐项改造，不能仅复制目录后视为完成。

## 2. 路径约定

- 本文所有目标路径均以 `kratos-student/` 为工程起点。例如 `lib/src/simlab` 的完整含义是 `kratos-student/lib/src/simlab`。
- 本文不使用任何开发者本机绝对路径。
- 需要描述迁移前文件时使用 `KartosLab/` 前缀；需要描述迁移后文件时使用 `kratos-student/` 前缀。
- 实现代码、测试、资源和文档中同样不得写入开发者本机绝对路径。

## 3. 强制级别

- **MUST**：必须满足；不满足不得合入或发布。
- **SHOULD**：原则上满足；不满足必须在评审记录中说明原因、风险和替代措施。
- **MAY**：可选增强，不作为首期上线门禁。

## 4. 集成结论

KartosLab 必须作为 `kratos-student` 的内部功能模块集成，而不是独立应用、独立 Flutter package 或嵌套工程。

集成后的权威关系如下：

| 事项 | 权威来源 |
| --- | --- |
| App 启动、横屏锁定、崩溃诊断、版本升级 | `kratos-student` |
| 根 `MaterialApp`、主题、路由和页面遥测 | `kratos-student` |
| SimLab 物理模型、场景配置、实验画面和实验控件 | `lib/src/simlab` |
| 依赖、资源声明、Android/iOS 配置、发布版本 | `kratos-student/pubspec.yaml` 及主工程平台目录 |
| 学生身份、业务权限、远端数据和最终业务语义 | `kratos-server` |

迁移后不得存在以下结构：

- `lib/src/simlab/main.dart`
- SimLab 自己的 `MaterialApp`、`ProviderScope` 或根 `Navigator`
- `lib/src/simlab/pubspec.yaml`
- `lib/src/simlab/android`、`ios`、`windows`、`macos`、`linux` 或 `web`
- SimLab 自己的应用版本号、包名、签名配置或发布脚本

## 5. 当前迁移范围

首期迁移范围以 KartosLab 当前源码中已经注册的 8 个实验为准：

| 稳定 ID | 学科 | 实验 |
| --- | --- | --- |
| `forces` | 物理 | 力与运动 |
| `circuit` | 物理 | 电路搭建 |
| `optics` | 物理 | 几何光学 |
| `color-vision` | 物理 | 色觉 |
| `wave-interference` | 物理 | 波的干涉 |
| `sound` | 物理 | 声波 |
| `radio-waves` | 物理 | 电磁波 |
| `molarity` | 化学 | 摩尔浓度 |

首期不包含：

- 重写既有物理算法或重新制作全部实验内容；
- 把 KartosLab 继续保留为可单独发布的第二个 App；
- 让 SimLab 直接访问 `kratos-ai`、第三方 AI 或任意外部业务服务；
- 为迁移方便复制 `kratos-student` 的主题、网络、身份或遥测实现到 `simlab` 内；
- 在未确认产品方案前固化学生首页入口位置。

## 6. 技术基线

### 6.1 工具链

SimLab 必须服从 `kratos-student` 的工具链和根工程约束：

- Flutter：以 `kratos-student` 当前锁定版本为准，当前技术文档基线为 Flutter `3.41.9`；
- Dart：以 `kratos-student` 当前锁定版本为准，当前技术文档基线为 Dart `3.11.x`；
- SDK 约束：使用根 `pubspec.yaml` 的 `>=3.9.0 <4.0.0`，不得在 SimLab 内另设 SDK 范围；
- Lint：使用根工程 `analysis_options.yaml` 和根工程 `flutter_lints` 版本；
- 目标设备：iPad 横屏、Android Pad 横屏；手机、Windows Desktop 和浏览器不作为首期主交付与主验收目标，只保留必要的窄宽防御。

不得为了迁入 SimLab 而单独降低或覆盖 `kratos-student` 的 Flutter、Dart、lint、Android 或 iOS 基线。

### 6.2 依赖

所有依赖只能声明在 `kratos-student/pubspec.yaml`。迁移前必须完成依赖冲突检查和许可证检查。

当前 KartosLab 的新增直接依赖如下：

| 依赖 | 当前用途 | 集成要求 |
| --- | --- | --- |
| `flutter_svg ^2.3.0` | SVG 实验图标与光学铅笔图标 | MUST 在根工程声明，或先改为主工程已有的等价资源方案 |
| `audioplayers ^6.7.1` | 电路点击提示音 | MUST 在根工程声明并验证 iOS/Android，或在明确取消提示音后移除相关代码 |
| `integration_test`（Flutter SDK） | 现有整链测试 | SHOULD 在保留整链测试时加入根工程 dev dependencies |

约束：

- 不得依赖传递依赖；源码直接 import 的 package 必须是根工程直接依赖。
- 不得复制 KartosLab 的整个 `pubspec.yaml` 覆盖主工程。
- `cupertino_icons`、Flutter SDK 和测试 SDK 等重复项以主工程声明为准。
- KartosLab 当前使用 `flutter_lints ^6.0.0`，而主工程当前使用 `^5.0.0`；迁移代码必须通过主工程 lint，不能为了迁移私自升级全 App lint。若确需升级，必须作为独立的全 App 变更评审。

## 7. 目标目录与模块边界

### 7.1 代码目录

建议保留当前已经验证的模块边界，做最小化收口：

```text
kratos-student/
└── lib/src/simlab/
    ├── simlab.dart
    ├── catalog/
    │   └── simlab_catalog.dart
    ├── pages/
    │   ├── simlab_home_page.dart
    │   └── simlab_experiment_page.dart
    ├── common/
    │   ├── chart/
    │   ├── controls/
    │   ├── scenario/
    │   └── widgets/
    ├── forces/
    ├── circuit/
    ├── optics/
    ├── color_vision/
    ├── sound/
    ├── radio_waves/
    ├── wave_interference/
    └── chemistry/
        └── molarity/
```

要求：

- `simlab.dart` 是 SimLab 对主工程暴露的最小公共入口；主工程不得跨过它随意引用实验内部文件。
- 实验之间共享的能力放在 `simlab/common`；某一实验特有的模型、算法、Painter 和控件继续留在该实验目录。
- `lib/src/simlab` 可以依赖 `lib/src/theme`、`lib/src/widgets/app`、公共诊断和主工程明确开放的基础能力。
- `lib/src/simlab` 不得反向修改或复制主工程的身份、练习、报告、题库和发布逻辑。
- SimLab 内部 import SHOULD 优先使用相对路径；跨边界 import 使用 `package:kratos_student/src/...`。
- 所有原有 `package:kratos/...` import 必须改为 `package:kratos_student/src/simlab/...` 或相对 import。

### 7.2 测试目录

```text
kratos-student/
├── test/simlab/
│   ├── common/
│   ├── forces/
│   ├── circuit/
│   └── ...
└── integration_test/simlab/
    └── simlab_navigation_test.dart
```

- 现有 KartosLab 单元和 Widget 测试迁入 `test/simlab`。
- 整 App 导航、返回、资源加载和主要实验 smoke test 迁入 `integration_test/simlab`。
- 测试不得继续 import `package:kratos/main.dart`；应 import `package:kratos_student/...` 或使用主工程正式 App 测试入口。

## 8. App 入口与路由

### 8.1 路由契约

SimLab 必须接入主工程 `GoRouter`，推荐稳定路由：

| 路由 | 用途 |
| --- | --- |
| `/simlab` | 仿真实验室首页 |
| `/simlab/:simId` | 指定实验入口 |

`simId` 只能来自受控 catalog，必须使用第 5 节定义的稳定 ID。未知 ID 必须显示可返回的友好错误页，禁止通过字符串反射、动态脚本或任意文件路径加载实验。

### 8.2 导航要求

- 主工程在 `lib/src/app.dart` 注册 SimLab 路由，并沿用主工程的页面诊断和 telemetry 包装。
- 从上级页面进入 SimLab、从 SimLab 首页进入实验均使用 `context.push`，保留真实路由栈。
- 普通实验页使用标准 `AppBar` 自动返回；只有全屏实验画面可自定义 leading，但存在上级路由时必须保留明确返回操作。
- 不得继续使用 KartosLab 首页当前的 `MaterialPageRoute` 作为功能级导航主路径。
- 不得通过冷启动直达时伪造不存在的返回历史。
- 实验退出时必须停止或释放计时器、Ticker、音频和其它持续任务。

### 8.3 产品入口

技术入口 `/simlab` 是 MUST。学生首页、学科页或学习地图中的可见入口位置为 **[待产品确认]**；确认前不得把入口硬编码进多个页面。

## 9. 根 App、启动与生命周期

### 9.1 根 App 归属

迁移时必须删除或改造 KartosLab 当前独立 App 能力：

| KartosLab 当前能力 | 迁移要求 |
| --- | --- |
| `main()` | 不迁入 `lib/src/simlab` |
| `KratosApp` / 独立 `MaterialApp` | 删除，使用 `KratosStudentApp` |
| 独立横屏设置 | 删除，使用 `AppBootstrap` 的横屏设置 |
| 独立 ThemeData | 删除根主题，实验局部颜色按第 10 节适配 |
| Windows `ExcludeSemantics` | 不迁入；学生端必须保留语义能力 |
| 独立首页 `HomeScreen` | 改为 `SimlabHomePage`，由主路由承载 |

### 9.2 生命周期

每个包含动画、时钟或音频的实验 MUST：

- 在页面不可见、App 进入后台或路由退出时暂停持续计算与播放；
- 在恢复可见时按可验证状态恢复，不重复创建计时器；
- 在 `dispose()` 中释放 `AnimationController`、Ticker、Timer、Stream、ChangeNotifier、FocusNode、ScrollController 和 `AudioPlayer`；
- 避免 `setState()` after dispose；异步加载完成前检查 `mounted`；
- 多次进入、退出同一实验不得叠加后台循环或音效实例；
- 不得因一个实验异常破坏整个学生 App 的路由和会话。

## 10. 视觉、布局与适配

### 10.1 主工程视觉系统

SimLab 的导航壳、首页、卡片、按钮、弹窗、加载、空态和错误态 MUST 遵循 `kratos-student` 的「纸上书院」视觉系统：

- 颜色优先使用 `AppColors`；
- 字体和字号优先使用 `AppTextStyles`；
- 通用卡片、按钮、标签和空态优先使用 `lib/src/widgets/app` 现有组件；
- 继续使用主工程全局 `PadTextDensity`，不得在 SimLab 内覆盖或抵消文字缩放；
- 不增加第二套全局主题或新的 UI 框架。

实验画布可保留学科所需的科学可视化颜色，但应满足：

- 实验颜色只服务于物理量、状态和交互反馈，不替代 App 导航层级；
- 错误、警告、奖励和主操作的语义不与 `AppColors` 冲突；
- 不得只靠颜色表达状态，应同时提供文字、图标、线型或形状。

### 10.2 Pad 横屏布局

- 主验收布局：iPad 横屏、Android Pad 横屏。
- 主实验画面必须使用 `LayoutBuilder` 或等价约束驱动布局，禁止按单一设备硬编码主 Canvas 尺寸。
- 现有 `NineGridLayout` 可继续作为 SimLab 内部统一实验布局，但必须在主工程 `PadTextDensity` 和安全区内验证。
- 关键实验画面、操作控件、返回操作和任务说明在常见 Pad 横屏尺寸下必须首屏可达。
- 页面不得出现 RenderFlex overflow、整页横向滚动或内容被系统安全区裁切。
- 对窄宽至少提供防御性布局；窄宽防御不等于把手机竖屏列为首期主目标。

建议的自动布局视口：

- `1024 × 768`；
- `1280 × 800`；
- `1366 × 1024`；
- 防御性窄横屏 `840 × 520`。

### 10.3 可访问性

- 交互控件必须具备可读 label、selected/enabled 状态和合理触控区域。
- 自绘实验画面必须为关键状态提供 `Semantics` 或旁路文字摘要。
- 不得迁入 KartosLab 独立 App 中针对 Windows 的 `ExcludeSemantics`。
- 连续动画应允许暂停；实验结论不能只存在于瞬时动画中。

## 11. 资源管理

### 11.1 目标资源目录

所有 SimLab 专属资源必须进入独立命名空间：

```text
kratos-student/assets/simlab/
├── images/
├── sounds/
└── scenarios/
    ├── circuit/
    ├── forces/
    ├── color-vision/
    ├── sound/
    ├── radio-waves/
    ├── wave-interference/
    └── molarity/
```

要求：

- 所有源码和测试中的 `assets/images/...`、`assets/sounds/...`、`assets/scenarios/...` 必须改为 `assets/simlab/...`。
- 不得把 SimLab 文件混入主工程通用 `assets/images`，避免名称冲突和所有权不清。
- Flutter 目录资源声明不应假定递归包含子目录；必须在根 `pubspec.yaml` 明确声明实际使用的目录。
- 场景 manifest 中的相对路径必须在迁移后仍可解析。
- 缺失、损坏或不兼容的场景文件不得导致整 App crash；应回退默认场景或显示可恢复错误态。
- 迁移前必须生成“代码引用资源清单”，只迁移运行时、测试和必要归属证明所需文件；不得无审计地把历史 WMF、截图和未引用素材全部打入学生 App。

## 12. 架构与编码要求

### 12.1 分层

每个实验继续遵循 Model / View / Controller 或等价职责分离：

- Model：纯 Dart 状态、物理量和规则，原则上不依赖 Flutter Widget；
- Controller：状态变更、时钟推进、交互命令和生命周期；
- View/Painter：读取状态并渲染，不在 `paint()` 中修改业务状态；
- Config/Scenario：负责 JSON 解析、校验和默认场景；
- Screen/Page：负责布局、页面生命周期和主工程导航接线。

### 12.2 状态管理

- 不要求为了迁移一次性把所有实验内部状态重写为 Riverpod。
- 实验短生命周期状态可继续使用 `StatefulWidget`、`ChangeNotifier` 或现有 controller。
- 跨页面、跨会话或与学生身份相关的状态必须接入主工程现有状态/服务边界，不得新建平行全局单例体系。
- View 不得绕过 Controller 随意改写 Model 字段。
- 可复现的实验应允许通过场景配置和初始状态得到确定性结果，便于测试和问题回放。

### 12.3 公共组件

- 已有 SimLab L0 公共组件必须优先复用，包括 slider、combo、radio、number field、property panel、time control、simulation clock、chart、scenario manager 和 NineGridLayout。
- 只有单一实验使用的物理算法、状态模型和视觉 Painter 不得强行上抽。
- 新公共组件至少应有明确的第二使用者证据；第三次重复出现时必须收口为 `simlab/common` 公共实现。
- 不得为了 SimLab 在 `lib/src/widgets` 平行创建主工程已有的 App 卡片、按钮、空态或标签组件。

### 12.4 场景配置安全

- JSON 场景只表达受控数据，不得包含可执行 Dart、JavaScript、Shell、HTML 或任意命令字符串。
- 解析器必须处理未知字段、缺失字段、非法数值、越界参数和未知枚举。
- 参数必须有物理合理范围和运行预算，禁止通过场景文件创建无界对象、无界数组或无界计算循环。
- 正式包只加载受信任的 bundled 场景；未来如需远端场景，必须由 `kratos-server` 下发版本化协议并在 App 侧严格校验。

## 13. 网络、数据与安全边界

首期 SimLab SHOULD 保持本地运行，不新增网络依赖。

未来如需学生画像、教学任务、实验记录同步或远端场景：

- 只能通过 `kratos-server` 的学生公开 API；
- 必须复用主工程 `ApiService`、鉴权、protobuf envelope、错误处理和会话失效处理；
- App 对外请求必须遵守 `kratos-student` 的统一 HTTPS 域名规则；
- 不得直连 IP、明文 HTTP、对象存储路径、`kratos-ai` 或第三方 AI；
- 业务权限、场景可见性、年级/学科范围和最终展示语义由 Server 决定；
- App 只负责基础渲染、交互采集、本地容错和受控状态回放；
- 不得把学生答案、身份信息或实验记录写入 debug 日志和资源文件。

## 14. 诊断、遥测与错误处理

- SimLab 页面必须通过主工程路由包装进入现有崩溃诊断和页面 telemetry。
- 运行异常应包含稳定 `simId`、场景 ID、阶段和有界错误码，不记录学生隐私或完整业务 payload。
- 场景加载、音频播放和资源读取失败应局部降级，不能使整个 App 白屏。
- Debug 专用日志、fixture 和验收入口必须由 `!kReleaseMode` 或等价编译期条件隔离。
- Release 构建不得包含 `/eval/...`、本地 mock 场景入口、主动触发 crash 的代码或仅供验收的隐藏操作。

## 15. 性能要求

每个实验在目标 Pad 的 profile/release 等价环境中必须满足：

- 空闲或不可见页面不持续执行无意义的逐帧计算；
- 连续动画无明显长期卡顿，拖拽和滑块反馈可用；
- `CustomPainter.shouldRepaint` 与重绘边界合理，不因无关状态重绘整页；
- 场景切换不重复加载不可变资源，资源缓存有上限；
- 连续进入退出同一实验 5 次后，不出现重复音效、重复 timer、明显内存持续增长或后台计算叠加；
- 大量点、波场或电路求解有明确输入上限，异常场景不能阻塞 UI isolate；
- 图片、SVG、音频和 JSON 不在每一帧重复解码或读取。

## 16. 测试与质量门禁

### 16.1 自动化测试

迁移必须保留并重构现有测试，至少覆盖：

1. 纯 Dart 物理模型和 solver 单元测试；
2. 场景 manifest 与 JSON 解析测试；
3. `simlab/common` 公共组件 Widget 测试；
4. 8 个实验的基础渲染和关键交互 smoke test；
5. `/simlab -> /simlab/:simId -> 返回` 路由整链测试；
6. 资源路径和默认场景加载测试；
7. 目标 Pad 视口无 overflow 测试；
8. 页面退出后动画、计时器和音频释放测试；
9. 未知 `simId`、损坏场景和资源缺失的失败恢复测试；
10. Release 不包含 eval-only route/fixture 的构建检查。

### 16.2 必跑命令

迁移合入前至少执行：

```bash
cd kratos-student
flutter pub get
flutter analyze
flutter test test/simlab
flutter test
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols/android-release
```

iOS 由主工程现有本地安装流程验收，不新增 SimLab 自有部署脚本。

### 16.3 实机验收

- 优先使用 `kratos-eval` 中适用的自动验收能力；没有适用套件时补最小 SimLab smoke suite。
- 实机验收使用 USB 连接的 iPad 和 Android Pad。
- 每个平台至少验证：进入实验室、打开 8 个实验、关键交互、场景切换、返回、后台恢复、音频、连续进出和错误恢复。
- 视觉验收必须确认安全区、横屏布局、触控目标、文字可读性、颜色之外的状态表达和无 overflow。

## 17. 迁移实施顺序

1. **基线冻结**：记录 8 个实验、测试、运行时资源和依赖清单。
2. **目录迁移**：源码移动到 `lib/src/simlab`，测试移动到 `test/simlab`。
3. **导入收口**：清除 `package:kratos/...`、独立 `main.dart` 和独立 App 壳。
4. **资源命名空间迁移**：资源移动到 `assets/simlab`，更新代码、测试和根 `pubspec.yaml`。
5. **主路由接线**：注册 `/simlab` 与 `/simlab/:simId`，统一返回和页面诊断。
6. **主题与 Pad 适配**：首页和页面壳接入「纸上书院」，实验画布保留必要的学科视觉。
7. **生命周期收口**：逐实验验证 timer、Ticker、音频和异步资源释放。
8. **测试迁移**：先跑 SimLab 定向测试，再跑全 App 回归。
9. **Release 与实机验收**：Android release 构建、eval 入口排除、USB 双平台验证。
10. **文档同步**：在 `kratos-student` 的项目技术文档和对应索引登记 SimLab 成为正式子功能。

每一步应保持可编译、可测试、可回退；不要把目录移动、主题重做、物理算法重构和产品入口调整捆绑成一个不可审查的大提交。

## 18. 合入验收清单

### P0：阻塞项

- [ ] 所有业务源码位于 `lib/src/simlab`，没有嵌套 Flutter App/package。
- [ ] 根工程是唯一 `MaterialApp`、`ProviderScope`、路由、主题、版本和平台配置来源。
- [ ] `/simlab` 与 `/simlab/:simId` 可达，返回行为符合主工程约定。
- [ ] 8 个实验均可打开并完成至少一个关键交互。
- [ ] 所有资源位于 `assets/simlab` 命名空间，默认场景可加载。
- [ ] 所有 `package:kratos/...` 和旧资源路径已清除。
- [ ] 通过主工程 `flutter analyze` 和全量 `flutter test`。
- [ ] Android release 构建通过，release 不含 eval-only 入口。
- [ ] iPad 与 Android Pad USB 实机 smoke 验收通过。
- [ ] 连续进出实验无重复 timer、Ticker、音效和明显资源泄漏。
- [ ] 无 RenderFlex overflow、白屏、不可返回页和主 App 会话破坏。
- [ ] 上游资源许可证、署名和再分发要求已确认并落地。

### P1：上线前应完成

- [ ] SimLab 首页已适配「纸上书院」组件与文案层级。
- [ ] 自绘画面具备关键语义摘要，不只靠颜色传达状态。
- [ ] 场景错误和资源错误均有局部可恢复状态。
- [ ] `kratos-eval` 已有 SimLab 双平台 smoke suite 或等价证据。
- [ ] `kratos-student` 技术文档与索引已登记该子功能。

## 19. 待确认事项

以下事项不阻塞技术骨架设计，但在正式产品接线前必须确认：

1. SimLab 的学生可见入口放在学习首页、学科页还是学习地图动作中；
2. 8 个实验是否全部首期开放，还是按学科、年级或灰度策略开放；
3. 电路点击提示音是否保留，从而决定是否引入 `audioplayers`；
4. 上游 PhET 复刻代码与资源的许可证、署名和再分发方案；
5. 首期是否记录实验完成、探究结论或学习证据；如需要，必须先设计 Server 权威协议。

在这些事项确认前，代码应通过 catalog 和单一入口保留接线点，不应把产品策略散落到各实验页面。

## 20. 依据与现状引用

本文主要依据以下工程事实制定；路径均以项目名为起点，不包含本机绝对路径：

- 目标设备、Flutter/Dart 和主要依赖基线。
- 主工程使用 `ProviderScope` 和统一 bootstrap。
- 统一横屏、存储、崩溃诊断、版本升级和 telemetry 初始化。
- 根 `MaterialApp.router`、主题、PadTextDensity、升级壳和 GoRouter 归属。
- Pad 文字密度和适用设备判断。
- 当前「纸上书院」主题与颜色语义。
- 根 SDK 和直接依赖现状。
- KartosLab 当前仍有独立 `main()`、`MaterialApp`、主题和 Windows 语义排除逻辑。
- 当前注册的 8 个实验。
- 当前实验入口仍使用 `MaterialPageRoute`。
- 当前 SDK、`flutter_svg`、`audioplayers`、`integration_test` 和资源声明。
- MVC、组件化、通用化和 JSON 场景配置的项目方向。
- SimLab 公共组件层与 NineGridLayout 复用基线。
