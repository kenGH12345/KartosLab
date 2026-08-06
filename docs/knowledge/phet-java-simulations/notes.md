# phet-java-simulations 知识库 · 决策与局限记录

> 目的：记录本次分析的关键决策、采样局限、待办入口，供后续维护者接手

## 一、关键决策记录

### 决策 1：知识库定位为"独立且引用"

- **决定**：新建 `context/project/phet-java-simulations/` 独立知识库，与 `context/project/phet/`（Flutter 复刻）**并列**
- **理由**：Java 版是**只读参考蓝本**，与 Flutter 复刻不属于同一"实施项目"；用户明确选了关系 c（并列 + 交叉引用）
- **反面选项**：也可以放到 `context/project/phet/reference/java-simulations/`（作为 Flutter 项目的子目录），但会混淆"我们要维护的项目"和"我们要参考的蓝本"

### 决策 2：路径占位符约定

- **决定**：所有文档中出现 Java 源码绝对路径时，用 `<PHET_JAVA_ROOT>` 占位
- **对应**：当前调研时的实际路径是 `C:\workspace\phetTrunk\phetTrunk`
- **理由**：用户明确选了 Q4=b（占位符），保证文档在其他环境（Linux / mac / 其他 Windows 用户）可移植
- **实际写法示例**：`<PHET_JAVA_ROOT>/simulations-java/simulations/bending-light/src/`

### 决策 3：Top-15 打分维度权重

- **决定**：四维加权（复杂度25% / 依赖20% / Fit25% / Value30%）
- **理由**：Value 权重最高（因为 phet 复刻主要目标是"教学价值")；Fit 与 复杂度并列（技术风险控制）；依赖最低（因为 🔴 3D 已经在候选池外）
- **可调整**：若 Flutter phet 团队优先级不同（例如"快速出 PR"），可提高复杂度权重；若"追求教学影响"，可提高 Value 权重

## 二、采样局限（诚实边界）

### 局限 1：Java 文件数 ≠ 代码行数
- `fractions` 229 文件用 functionaljava 函数式风格，单文件很小
- `circuit-construction-kit` 172 文件多为 UI 节点，单文件中等
- **补救**：Top-15 若需精确 LOC，需要 `grep -c` 补测
- 参见 [module-catalog.md § 汇总统计](module-catalog.md#汇总统计) 采样局限段

### 局限 2：教学价值 (Value) 打分主观
- 基于 PhET 官网 [phet.colorado.edu/en/simulations/browse](https://phet.colorado.edu/en/simulations/browse) 的公开热度经验判断
- 未做严格的下载量 / 教师使用率统计
- **可靠性**：与 K-12 教材经典 sim（`balloons` / `gravity-and-orbits` / `build-an-atom` / `ph-scale`）有较强共识；冷门 sim 分档误差可能更大

### 局限 3：Flutter 相似度 (FlutterFit) 打分主观
- 基于本次调研对 Flutter phet 3 模块（[phet/systems/*.md](../phet/systems/)）的阅读
- 未做真实"移植 PoC" 验证
- **补救**：真做第一个复刻 PR 时可反馈校准

### 局限 4：抽样覆盖不完全
- 79 个 sim 做了 Java 文件计数（约 98% 覆盖）
- 6 个未采样（如 `battery-voltage` / `advanced-acid-base-solutions` 等）
- 未采样 sim 均在长尾（低教学价值）区域，不影响 Top-15 结论
- 参见 [module-catalog.md § 采样局限](module-catalog.md#采样局限)

### 局限 5：📢 用户明确纠正的边界
- **知识库存在性**：Loop 1 之前调研过程中我错误声称"没有 phet 项目的知识库"，用户提醒后才发现 `context/project/phet/` 早已存在完整知识库（含 INDEX / systems / architecture）
- **教训**：任何"我不知道"的技术判断必须先 grep + list_dir 确认 `context/` 目录内容再下结论，遵循 `20-verify-before-act.mdc` 知识库优先原则

## 三、后续入口 / TODO

### 短期（如果决定要做第一个复刻 PR）
1. 从 Top-15 里选定 1 个（推荐 Wave A/B 内的 `molarity` 或 `the-ramp`）
2. 深读该 sim 的 `<Sim>Application.java` + `<Sim>Module.java` + `model/*.java`
3. 按 [existing-flutter-map.md § 5 步复刻工作流](existing-flutter-map.md#复刻工作流通用模板) 走
4. 完工后回到 shortlist-for-flutter-port.md 反馈"实际工作量 vs 打分预期"，校准打分维度

### 中期（本知识库的补充方向）
- **[待办 A]** 深度模块页：为 Wave A/B 的 8 个候选 sim 各建 `<sim>-deep-dive.md`（1-2 页 · 含 MVC 三层结构 + 关键 Java 类图 + Flutter 复刻 checklist）
- **[待办 B]** 精确 LOC 统计：对 Top-15 补测 `grep -c` 的真实代码行数
- **[待办 C]** 依赖库解剖：本次未展开 24 个 common 库的功能划分（如 phetcommon / piccolo-phet 各自负责什么）· 若要复刻大量 sim 建议补一份 [`common-libraries.md`]
- **[待办 D]** 依赖库与 Flutter 生态映射：如 Piccolo2D → Flutter Canvas + CustomPainter；Jama → dart 矩阵库；jbox2d → forge2d；lwjgl → flutter_gl / 降级为 2D

### 长期（生态型工作）
- **[待办 E]** PhET HTML5 版对照：PhET 官方还有 `simulations-html`（JavaScript 版），部分 sim 可能是从 Java 迁到 HTML5 的现代版，比 Java 蓝本更接近现代技术栈（虽然本次未纳入调研）
- **[待办 F]** 复刻覆盖率仪表盘：随着 Flutter phet 复刻推进，建议在 [existing-flutter-map.md] 里维护"已完成 / 进行中 / 待办"三色标记

## 四、维护提示

### 何时应更新本知识库
- ✅ Flutter phet 完成一个新模块复刻 → 更新 [existing-flutter-map.md]（补该 sim 的 Java 蓝本映射）
- ✅ 发现某个 sim 的 Java 文件数 / 依赖标签有变化 → 更新 [module-catalog.md]
- ✅ 打分维度权重需要调整（例如团队引入 games 层后，游戏化 sim 的 Fit 上升）→ 更新 [shortlist-for-flutter-port.md]
- ❌ **不要**：删除 Java 版原始事实（如 sim 数量 / 依赖标签），这些是稳定不变的历史归档

### 何时不用改本知识库
- Flutter phet 内部重构（不涉及 Java 蓝本映射）
- Flutter phet 的 AI 生成工具链演进
- 只涉及 [phet/](../phet/) 侧的文档

## 五、本次 3-Loop 执行摘要

| Loop | 目标 | 产出 | 关键洞察 |
|---|---|---|---|
| **1** | 顶层俯瞰 | [INDEX.md](INDEX.md) · [overview.md](overview.md) | 有效 sim ~85 · 主栈 Java+Piccolo2D+Ant · Flutter 独有 JSON+AI 生成 |
| **2** | 分学科清单 + Flutter 映射 | [module-catalog.md](module-catalog.md) · [existing-flutter-map.md](existing-flutter-map.md) | 精确 81 个 sim · 🔴 高门槛只 4 个 · Flutter 3 模块都有明确主蓝本 |
| **3** | 打分与优先级 | [shortlist-for-flutter-port.md](shortlist-for-flutter-port.md) · [notes.md](notes.md) | Top-15 分 Wave A/B/C · 首选 `molarity` / `the-ramp` / `capacitor-lab` |
| **3+** | Wave 0 追加 | [shortlist-for-flutter-port.md § Wave 0](shortlist-for-flutter-port.md#wave-0--通用基础组件优先复刻先于-sim-本身) | 通用基础组件 Top-8 · P0 三项 Chart/Clock/PropertyControl · 补齐后 Top-15 sim 批量降本 |
| **3++** | W0-2 深挖 | [w0-2-simulation-clock-draft.md](w0-2-simulation-clock-draft.md) | SimulationClock Dart API 草案（读 Java IClock/ConstantDtClock/ClockListener/TimeControlPanel + MotionModel · 翻译为 @immutable + callback 范式） |
| **3+++** | W0-1 深挖 | [w0-1-chart-draft.md](w0-1-chart-draft.md) | Chart 图表控件 Dart API 草案（Java ControlGraph 785 行 + ControlGraphSeries + GraphSuite · 翻译为 CustomPainter 方案） |
| **3++++** | W0-3 深挖 | [w0-3-property-control-draft.md](w0-3-property-control-draft.md) | PropertyControl 控件族 Dart API 草案（Java VSliderNode 211 行 + HSliderNode 152 行 + RadioButtonStrip + §C2 合规） |

### 数据源汇总
- 目录清单：`Get-ChildItem -Path <PHET_JAVA_ROOT>/simulations-java/simulations -Directory`（2026-07-22 实测）
- Java 文件数：`Get-ChildItem -Recurse -Filter *.java`（2026-07-22 实测 79 个 sim）
- 依赖标签：`<sim>/<sim>-build.properties` 的 `project.depends.lib`（2026-07-22 实测）
- Flutter 侧参考：`context/project/phet/systems/module-index.md` + `<module>-module.md`
- PhET 官方文档：`<PHET_JAVA_ROOT>/README.txt` + `<PHET_JAVA_ROOT>/simulations-java/simulations/README.txt`

### 未使用的工具（诚实声明）
- 未使用 `knowledgebase_search`（背景知识库都是 AgentHub 相关，与 PhET 无关）
- 未使用 web_search（本次分析全部基于本地文件事实，避免外部信息干扰）
- 未生成 Mermaid / PlantUML（本知识库偏"清单型" · 少流程图需求）
