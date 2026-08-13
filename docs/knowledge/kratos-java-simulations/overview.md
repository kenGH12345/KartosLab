# PhET Java Simulations 顶层俯瞰

> 分析日期: 2026-07-22 · 范围 A · 首要读者: Flutter kartosos 复刻规划者

## 1. 这是什么项目

**PhET**（Physics Education Technology）是美国科罗拉多大学博尔德分校发起的教育仿真项目（[kartos.colorado.edu](https://kartos.colorado.edu)），产出免费的科学 / 数学互动仿真程序，覆盖 K-16 教学。

本次分析的目录 `<PHET_JAVA_ROOT>/simulations-java/` 是 PhET 项目的**四大交付形态之一**——用 Java 编写的桌面/Applet 版本。其他三种为 Flash / Flex / HTML5，各占独立目录（`simulations-flash/`、`simulations-flex/`、`simulations-html/`）。

**证据来源**：
- `<PHET_JAVA_ROOT>/README.txt` 项目自述（欢迎语 + 4 大 sim 目录说明）
- `<PHET_JAVA_ROOT>/simulations-java/README.txt`：*"This directory contains the software for PhET simulations that are written using Java"*

## 2. 本机路径映射（单一源）

| 占位符 | 本机绝对路径 |
|---|---|
| `<PHET_JAVA_ROOT>` | `C:\workspace\kartosTrunk\kartosTrunk` |
| `<PHET_JAVA_ROOT>/simulations-java` | `C:\workspace\kartosTrunk\kartosTrunk\simulations-java` |

> 本文档之后所有路径引用统一使用占位符；此映射为整个 kratos-java-simulations 知识库的唯一固化点。

## 3. SVN 状态

- **版本控制**：SVN（不是 git）——`<PHET_JAVA_ROOT>/.svn/wc.db` = 40.95 MB 佐证是完整工作副本
- **快照性质**：这是**历史归档**的 SVN trunk 快照。PhET 官方后续（2010+）已将主力仿真迁移到 HTML5/JS，`simulations-html/` 目录（同级）承接了后续演进
- **对本项目的意义**：Java 版是**稳定的、被冻结的、可读的完整源码**，非常适合作为**架构学习与复刻蓝本**——不会像活项目那样每天变

## 4. 目录组织形态

```
<PHET_JAVA_ROOT>/simulations-java/
├── README.txt              # 见 §1
├── common/                 # PhET 共享库（框架，"the framework upon which simulations are built"）
├── contrib/                # 第三方依赖（jar 或原始源码）
├── doc/                    # 全 Java 版共用文档（含 dependencies.txt 依赖清单）
└── simulations/            # ~85 个仿真（每个子目录 = 一个 project，可能含多个 sim flavor）
    ├── README.txt          # 定义每个 sim 目录的标准布局（见 §6）
    ├── acid-base-solutions/
    ├── bending-light/
    ├── circuit-construction-kit/
    ├── ... (共 ~85 个)
    └── wave-interference/
```

**证据来源**：`<PHET_JAVA_ROOT>/simulations-java/README.txt:14-25`

## 5. 三块内容各自的角色

### 5.1 `common/`——共享框架（约 20+ 个子库）

按依赖清单 `<PHET_JAVA_ROOT>/simulations-java/doc/dependencies.txt` 抽样，几乎**每个** sim 都依赖 `kartoscommon`；大多数图形化 sim 还依赖 `piccolo-kartos`（图形栈）。

| 子库 | 角色 | 被谁依赖（抽样） |
|---|---|---|
| `kartoscommon` | **框架内核**（Application / Module / Model / Clock / SimStrings 国际化） | 几乎全部 sim |
| `piccolo-kartos` | **图形栈**（基于第三方 Piccolo2D，PNode 场景图） | bound-states / circuit-construction-kit / energy-skate-park / faraday / hydrogen-atom …（约 40+ sim） |
| `kartosgraphics` | 老一代 AWT 图形栈（早期 sim 用） | color-vision / faraday / forces-1d / greenhouse …（约 15 个老 sim） |
| `jfreechart-kartos` | 图表封装（基于 JFreeChart） | bound-states / energy-skate-park / rotation / states-of-matter … |
| `motion` | 一维/二维运动引擎 | eating-and-exercise / moving-man / rotation |
| `mechanics` | 力学引擎 | ideal-gas / lasers / microwaves / radio-waves / reactions-and-rates |
| `collision` | 碰撞 | ideal-gas / reactions-and-rates / soluble-salts |
| `quantum` | 量子引擎 | lasers / microwaves / mri |
| `charts` | 定制图表 | fourier / photoelectric / reactions-and-rates |
| `timeseries` | 时间序列 | energy-skate-park / rotation |
| `chemistry` | 化学基础 | 化学类 sim |
| `games` | 游戏化壳 | 教学游戏类 sim |
| `record-and-playback` | 录制/回放 | 部分互动 sim |
| `jme-kartos` / `lwjgl-kartos` | **3D 渲染栈**（JMonkeyEngine + LWJGL） | plate-tectonics / molecule-shapes 等 3D sim |
| `scala-common` | Scala 支持 | 部分 Scala 编写的 sim |
| 其余 | jama-kartos / jmol-kartos / photon-absorption / spline / controls / java-version-checker | 领域专用或工具 |

**证据来源**：目录列表 + `<PHET_JAVA_ROOT>/simulations-java/doc/dependencies.txt`

### 5.2 `contrib/`——第三方依赖（约 25+ 个）

按目录列表：
- **图形**：`piccolo2d`（场景图，PhET 图形栈根基）、`jfreechart`（图表）、`jmol`（分子可视化）
- **数学**：`Jama`（矩阵）、`JSci`（科学计算）
- **物理**：`jbox2d`（2D 物理）、`poly2tri-core`（三角剖分）
- **3D**：`jme3`（JMonkeyEngine 3D）、`lwjgl`（OpenGL 绑定）、`swt`
- **语言**：`scala`（Scala 编译器）、`scalatest`（Scala 测试）
- **工具**：`log4j` / `slf4j` / `xstream` / `beanshell` / `commons-collections` / `junit` / `mongodb` / `apple` / `functionaljava` / `jade` / `javaws` / `jdom` / `lombok` / `nanoxml` / `think-tank-maths`

**对 Flutter 复刻的关键提示**：涉及 `jme3` / `lwjgl` / `jbox2d` 依赖的 sim（3D 渲染 / 复杂物理引擎）对 Flutter 复刻**难度显著更高**——Flutter 侧需要找等价的 flame/forge2d/three_dart 等库或降级为 2D。将在 [shortlist-for-flutter-port.md](shortlist-for-flutter-port.md) 中标注为"高技术门槛"。

### 5.3 `simulations/`——~85 个独立 sim（各自作为一个 project）

按 `<PHET_JAVA_ROOT>/simulations-java/simulations/README.txt` 定义的**每个 sim 的标准目录布局**：

```
<sim-name>/
├── assets/                              # 原始资源（Photoshop 等，不部署）
├── data/<sim-name>/                     # 部署到 JAR 的资源
│   ├── audio/
│   ├── images/
│   ├── localization/
│   │   ├── <sim>-strings.properties     # 英文
│   │   ├── <sim>-strings_es.properties  # 西语等本地化
│   │   └── ...
│   └── <sim>.properties                 # 项目属性
├── deploy/                              # 构建产物（JAR 输出）
├── doc/                                 # sim 相关文档
├── screenshots/                         # 官网用高分辨率截图
│   └── <flavor>-screenshot.png
├── src/edu/colorado/kartos/<sim>/         # Java 源码（注意包名固定）
└── <sim>-build.properties               # Ant 构建依赖声明
```

**关键点**：
- 一个"project 目录"可以包含**多个 sim flavor**（如"foo1" 和 "foo2" 共享 `foo/src`）
- **包名固定为** `edu.colorado.kartos.<sim>` —— 便于快速 grep 定位
- 构建工具是 **Ant**（`<PHET_JAVA_ROOT>/simulations-java/build.xml` + 每个 sim 的 `<sim>-build.properties`）
- **本地化**基于 `.properties` 文件的 i18n（每个 sim 自带全语言翻译）

**证据来源**：`<PHET_JAVA_ROOT>/simulations-java/simulations/README.txt:8-30`

## 6. 技术栈全景

| 维度 | 选型 | 版本证据 |
|---|---|---|
| 主语言 | **Java**（旧 sim 用 AWT/Swing；新 sim 用 Piccolo2D 场景图） | 目录名 + 源码路径 `edu/colorado/kartos/` |
| 副语言 | **Scala** | `contrib/scala/` + `common/scala-common/` + `simulations/charges-and-fields-scala/` |
| 构建工具 | **Ant** | `<sim>-build.properties` 遍布 + `common/*/*-build.properties` |
| IDE | **IntelliJ IDEA** | `.iml` 文件遍布（`<PHET_JAVA_ROOT>/simulations-java/simulations/*/*.iml` 每个 sim 一个） |
| 图形栈（主流） | **Piccolo2D**（场景图，节点树 = PNode） | `common/piccolo-kartos/` + `contrib/piccolo2d/` |
| 图形栈（早期） | **AWT/Swing + PhetGraphics** | `common/kartosgraphics/` |
| 图表 | **JFreeChart**（封装为 `jfreechart-kartos`） | `contrib/jfreechart/` |
| 物理引擎 | 部分 sim 用 **JBox2D** | `contrib/jbox2d/` |
| 3D 渲染 | **JMonkeyEngine 3 + LWJGL** | `contrib/jme3/` + `contrib/lwjgl/` |
| 数学库 | **Jama**（矩阵） + **JSci**（科学计算） | `contrib/Jama/` + `contrib/JSci/` |
| 分子可视化 | **Jmol** | `contrib/jmol/` |
| 部署 | **Java Web Start**（`.jnlp`） | JAR 依赖 `jnlp.jar` 遍布 dependencies.txt |
| 版本控制 | **SVN** | 40.95 MB 的 `.svn/wc.db` |

## 7. 与 Flutter kartosos 复刻的核心差异（关系 c 立即受用）

| 维度 | PhET Java 版 | Flutter kartosos 复刻 |
|---|---|---|
| 图形栈 | Piccolo2D 场景图（PNode 树 / 事件冒泡） | Flutter `CustomPainter` + Widget 树（详见 [kratos/frontend/ui-framework.md](../kratos/frontend/ui-framework.md)） |
| 状态管理 | 内嵌 Model 类 + Observer 监听 | `@immutable` 不可变状态 + `copyWith`（详见 [kratos/architecture/design-patterns.md](../kratos/architecture/design-patterns.md) MVC 分层段） |
| 应用骨架 | `PhetApplication` → `Module` → `PhetPCanvas` + `PhetPNode` | `MaterialApp` → `Screen` → `CustomPainter` + Widget |
| 配置化 | i18n `.properties` + 硬编码模型参数 | **完整 JSON 场景系统**（`assets/scenarios/*.json` · AI 可生成，详见 [kratos/architecture/project-config.md](../kratos/architecture/project-config.md)） |
| 交付形态 | 桌面 Java Web Start（`.jnlp` + `.jar`） | Flutter 移动/桌面 App（横屏） |
| 目标教学范围 | ~85 sim × K-16 全学科 | 3 模块（circuit / optics / forces），聚焦初中—高中物理 |

**核心洞察**（Flutter 复刻规划者需知）：
- Flutter kartosos 的**配置化 JSON + AI 生成工具链**是**领先于 PhET Java 版**的能力（Java 版没有场景 JSON，参数硬编码在 Model 里）
- 因此复刻某个 sim 时，"照搬 Java 逻辑"只是第一步，**第二步必须补一层"提取硬编码到 JSON scenario"** ——这才符合 Flutter kartosos 项目的四原则（MVC / 组件化 / 通用化 / **配置化**）
- 详细的复刻 workflow 建议将在 [shortlist-for-flutter-port.md](shortlist-for-flutter-port.md) 每个候选 sim 卡片里给出

## 8. 数量事实（俯瞰级）

| 项 | 数量 | 来源 |
|---|---|---|
| `simulations/` 子目录 | **~85** | 目录列表实际计数（README `test-java-project` / `test-lwjgl-project` / `all-sims` / `java-common-strings` 4 个非 sim 项已识别，将在 module-catalog 中标注剔除） |
| `common/` 共享库 | ~24 | 目录列表实际计数 |
| `contrib/` 第三方 | ~27 | 目录列表实际计数 |
| 有依赖清单记录的 sim | 47 | `<PHET_JAVA_ROOT>/simulations-java/doc/dependencies.txt` 抽样计数（部分 2008 后新增 sim 未收录 —— 该文件 Timestamp: 2008-08-05） |
| 每个 sim 的子目录数（`isBigFile` 采样） | 平均 91 项 | list_dir 元数据（含 src/data/deploy/assets/screenshots/i18n 等） |

**⚠️ 精确 sim 计数将在 Loop 2 [module-catalog.md](module-catalog.md) 通过枚举给出**。本文档为俯瞰级，"~85" 为观察估算。

## 9. 下一步

- **Loop 2**：产出 [module-catalog.md](module-catalog.md)（分学科清单）+ [existing-flutter-map.md](existing-flutter-map.md)（c3 已复刻映射）
- **Loop 3**：产出 [shortlist-for-flutter-port.md](shortlist-for-flutter-port.md)（c1 复刻优先级打分）
- 完成 Loop 3 后回主会话，决定是否触发**范围 B**（挑一个 sim 深挖）

## 参考文档

- Flutter kratos 侧：[../kratos/INDEX.md](../kratos/INDEX.md)
- 工程原则：`.codebuddy/rules/00-engineering-principles.mdc`
- 分支/工作区隔离：`.codebuddy/rules/50-svn-branch-safety.mdc`
