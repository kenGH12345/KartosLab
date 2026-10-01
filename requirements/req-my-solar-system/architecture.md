# Architecture · My Solar System（Intake，非最终 EDD）

> 先搜索 `lib/`：最相似已实现是 **Kepler's Laws**（同 solar-system-common UI 骨架，**不同 Solver**）。  
> 建议目录跟随 Kepler：`lib/astronomy/my_solar_system/`，**不**用 `lib/src/simulations/`。

## 1. 数据流（强制）

```
手势 / SimulationClock.dt
        ↓
MySolarSystemController  (ChangeNotifier)
        ↓  改 Body[] / 调 Solver / 改 visible
NumericalEngine  (纯 Dart，无 Widget)
        ↓
RenderData (只读 DTO + MVT)
        ↓
Painters + Overlay Widgets
```

禁止在 `CustomPainter.paint` 里算万有引力或 PEFRL。

## 2. 推荐目录

```
lib/astronomy/my_solar_system/
  my_solar_system_constants.dart
  my_solar_system_strings.dart
  my_solar_system_colors.dart
  model/
    orbit_body.dart          # 可参考 Kepler orbit_body，加 pathPoints / isOffscreen
    body_info.dart
    center_of_mass.dart
    visible_properties.dart
    orbital_system.dart      # 枚举 id，数据来自 JSON
  solver/
    numerical_engine.dart    # PEFRL 逐行对齐
  controller/
    my_solar_system_controller.dart
  render/
    mss_mvt.dart
    render_data.dart
  painters/
    bodies_painter.dart
    path_painter.dart
    vectors_painter.dart
    grid_painter.dart
    com_painter.dart
    measuring_tape_painter.dart
  widgets/
    time_panel.dart
    visibility_panel.dart
    values_panel.dart
    preset_combo.dart
    zoom_buttons.dart
  screens/
    my_solar_system_home.dart   # Tab Intro | Lab
    my_solar_system_screen.dart
assets/scenarios/my_solar_system/*.json
test/astronomy/my_solar_system/
```

Home：`home_screen.dart` 仅在天体力学组 **追加** 卡片。

## 3. 80-checklist 四原则（Intake 自答）

### MVC

- Model：Body[]、visible、preset、time、CoM  
- Solver：NumericalEngine  
- Controller：tick、drag、reset  
- View：Screen + Painters  
- 禁止 View 写 mass/position

### 元件化

物理元件：Body（×2/×4）、CoM、Path、VelocityVector、GravityVector、Grid、Tape。  
一元件一 Painter（Path 可共享一个 Canvas 画所有体，对齐原版单 CanvasNode）。

### 通用化 G1/G2/G3

| L0 | 用？ |
|---|---|
| KratosSlider | 质量、重力缩放 |
| KratosComboBox | Lab preset |
| KratosRadioGroup | Fast/Normal/Slow |
| KratosNumberField | Data 数字 |
| PropertyControlPanel | 否：可见性不是 scenario 参数面板 |
| TimeControlBar | **否**（API 不够，同 Kepler） |
| SimulationClock | 是 |
| NineGridLayout | 是 |
| KratosTabbedScreen | 是 |
| arrow_painter | 是 |
| ScenarioManagerBase | Build 接 JSON preset |
| Chart | 否 |

G2：TimePanel、Bodies spinner、Keypad 质量编辑 = 本 sim 新组件，登记 L1「第 1/3 用户」若 Kepler Time 控件能抽则算第 2 用户——**本需求不改 Kepler**。

G3：本 sim 是 solar-system-common 的 **第 2 个** Flutter 用户。相似度高（Body/MVT/Tape/Grid）。门禁建议改造第 1 个进 common。**与「不改 Kepler」冲突 → 本需求在 sim 内复制公式，notes 登记，Close 再上抽。**

### 配置化

Preset 必须 JSON，禁止 `if (preset==1)`。Intro 默认也是一份 JSON。  
`edd_template_version: v2.0` 已写入 meta。EDD 12 章在 **phase 2/Build 前或并行** 补（Intake 先有简述）。

### 布局 L0-1..4

主图居中；LayoutBuilder；禁止硬编码 Canvas 像素；NineGrid 中心 ≥70%。

## 4. Kepler 复用 vs 禁止

**参考（复制模式，不 import Kepler 内部文件除非后续抽取）：**

- `orbit_body.dart` 字段、massToRadius  
- `keplers_mvt.dart` Y-up  
- grid / vectors / measuring tape / zoom 动画是否存在  
- Home 注册方式  
- Time 三档常量  

**禁止复用：** `EllipticalOrbitEngine`、Kepler zoom 45–100、engineTimeScale 0.002、太阳钉死原点、allowedOrbit 停表。

## 5. 最相似已有 4 Java-port sim

sound / radio-waves / color-vision / wave-interference：**波场**，与 N-body 不像。  
真正相似：**Kepler's Laws**（astronomy）。

## 6. 性能

- PEFRL 内层 4000/N：必须在 isolate？Intake 建议先主 isolate + 仅最后一步 notify；卡再优化  
- Path 限制长度（对齐 MAX_PATH 二次实现前用视口长度启发式）  
- Painter 不每帧 new Path 以外的大对象；mutate 轨迹缓冲  

## 7. 测试

Unit：力、PEFRL 一步、CoM、碰撞动量、preset JSON 加载、stepOnce time。  
Widget：Tab、Play、preset 切换、Reset、Zoom、More Data。  
禁止用全仓无关失败测试作为本 sim 门禁（Kepler 先例：forces_scenario_test 卡住）。

## 8. Skill / 规则冲突（不静默改 Skill）

| 项 | 冲突 | 选择 |
|---|---|---|
| product-manager「禁止读源码」 | 用户 + 80-checklist 要求源码 Intake | **源码优先**；本会话主会话写产物（Cursor 无 PM Task 类型） |
| `.cursor/rules/80-phet-sim-checklist.mdc` | 链到别的仓库 phet checklist | 以 `.codebuddy/rules/80-kratos-sim-checklist.mdc` 为准（AGENTS.md） |
| 无 Flutter/Canvas/物理 project Skill | INDEX 仅 core 框架 Skill | 用 conventions `add-custom-painter` + Kepler 先例 |
| 3-Time Rule 上抽 | 不改已完成 Kepler | 本需求不抽 common |

## 9. Build 拆分（批准后）

Loop 1 壳+Tab+空 Canvas → 2 Body/MVT → 3 PEFRL → 4 Time → 5 拖 Body → 6 Data → 7 Path/矢量 → 8 CoM → 9 Grid/Tape/Zoom → 10 JSON preset → 11 Lab 控件 → 12 响应式 → 13 性能 → 14 测试。
