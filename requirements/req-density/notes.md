# req-density —— 笔记与沉淀

## 已确认发现

- Density 仓库 `1.3.0-dev.0` 只含 3 个 Screen 包装类。全部 Model/View/材料/物理在 `density-buoyancy-common`（`package.json` phetLibs；`js/intro/IntroScreen.ts` 等 import 路径）。
- 本机原先没有 common。已 clone 到 `phet sourses/density-buoyancy-common-main`，HEAD `0c835c6`。
- `density-strings_en.json` 只有 title + 三屏名。UI 字符串在 `density-buoyancy-common-strings_en.json`。
- Intro 默认两块同体积 5 L：A=Wood 2 kg，B=Aluminum 13.5 kg。
- Compare 不是「四块共享同一材料表」，而是三套预分配立方体，由 `BlockSet` 切换可见性；每套内部用同一锁定量（mass/volume/density）。
- Mystery Set 2 的 11340 kg/m³ 与 `Material.LEAD` 11342 差 2，以 Mystery 源码字面值为准。
- Density Table 是 AccordionBox 内表格，不是 AlertDialog；默认折叠。
- 拖拽是 p2 pointer constraint（弹簧力），不是直接写 position。
- 本工程没有 `lib/src/simlab/`，也没有命名路由 `/simlab/:simId`。Home 用 `Navigator.push`（`lib/screens/home_screen.dart`）。
- `lib/main.dart` Windows 包了 `ExcludeSemantics`。项目规则禁止为迁移而移入该模式；Density 需要 Semantics。是否改全局入口需用户拍板。

## 80-checklist 自检草稿（代码未写，不得标「全部通过」）

### §二 四原则

| 项 | 计划 |
|---|---|
| MVC | `lib/density/model` / `solver` / `controller` / `view` |
| View 改 Model | 禁止。手势 → Controller → copyWith |
| 元件 Painter | Cube / Pool / Scale / DensityTable / NumberLine 分 Painter |
| Scenario JSON | materials + intro defaults + compare cubes + mystery sets |
| Schema | `schemas/density_scenario.schema.json`（Build 时建） |
| PropertyControlPanel | Intro 右侧材料/质量/体积应对齐 L0；Compare 锁定滑条同 |

### G1 L0

| 控件 | 路径 | Intro/Compare/Mystery |
|---|---|---|
| Slider | `lib/common/controls/kratos_slider.dart` | 必用 |
| ComboBox | `lib/common/controls/kratos_combo_box.dart` | Intro 材料 |
| RadioGroup | `lib/common/controls/kratos_radio_group.dart` | Compare 模式 / Mystery Set |
| NumberField | `lib/common/controls/kratos_number_field.dart` | 质量/体积数字 |
| PropertyPanel | `lib/common/widgets/property_control_panel.dart` | 右侧面板容器 |
| NineGridLayout | `lib/common/widgets/nine_grid_layout.dart` | 主屏强制 |
| KratosTabBar | `lib/common/widgets/kratos_tab_bar.dart` | 三 Screen 切换 |
| TimeControlBar / SimulationClock | 原版无播放条；物理需 Ticker，不套教学时钟条 | 不用 TimeControlBar |
| Chart | Density Number Line 不是 cartesian chart | 不用 kratos_chart；NumberLine 为本 sim L2 |
| DragDropWorkspace | 原版是池内抓取而非托盘放置 | 不直接套；拖拽走 Mass.startDrag 语义 |

### G2 / G3

疑似 L1（第 1 用户，登记本 sim 内造，不上抽）：
- DensityNumberLine（密度数轴）
- DensityTable（密度表）
- Cuboid 3D/等距块渲染
- Pool 水面
- Pointer-constraint 拖拽

不触发第 3 用户上抽。

### §七 Layout

主屏必须 NineGridLayout，中间格只放实验画面，面积 ≥ 70%。控件放边格/footer。禁止硬编码 canvas 像素。

## 开发踩坑

- 连续 Ticker 使 `pumpAndSettle` 永不结束；Widget 测试用 `TickerMode(enabled: false)` 或单屏注入 Controller。
- NineGrid 边格约 8% 屏宽，不能放默认 200px `KratosSlider` 标签行；控件改放到全宽 footer。
- Mystery Set2 的 11340 必须保持字面值，不能改成 Lead 11342。

## 决策记录

- 2026-09-02 主会话：Phase 1 只分析不实现。事实源补 clone common。目录/路由按本工程惯例，不按 prompt 里的 SimLab 候选路径。
- 2026-09-02 用户 Build 决策：不修改 `lib/main.dart` 的 Windows `ExcludeSemantics`；Density 在 `lib/density/` 内补 Semantics。资源目录 `assets/density/`（不对齐 `assets/simlab/`）。PhET 源码行为优先于合理化设计。

## 推迟的 Major 项

- 完整 PhET-iO / PDOM 键盘帮助对话框一期可降级为 Semantics 标签 + 焦点顺序。

## 遗留 TODO

- 从 `images/*_jpg.ts` 抽出 base64 → `assets/density/images/`
- Windows ExcludeSemantics 不在本需求改全局；仅 Density 内部 Semantics
