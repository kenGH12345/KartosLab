# Phase 3 — Architecture Plan · CCK AC Virtual Lab

> 日期：2026-09-02  
> 依据：`PROJECT_DISCOVERY.md` + `SOURCE_ANALYSIS.md` + `visual-qa/BASELINE.md`  
> 无不可逆决策 · 自动进入 Phase 4  
> **不复制** Build a Nucleus 目录，**不合并** `lib/circuit/`

---

## 1. 目标目录

```
lib/cck_ac_virtual_lab/
  cck_constants.dart
  cck_colors.dart
  cck_strings.dart
  model/
    ids.dart
    cck_vec.dart
    enums.dart                 # ViewType, CurrentType, ResistorKind, Selection
    vertex.dart
    circuit_element.dart       # 基类 + Wire/Battery/AC/Resistor/Bulb/C/L/Switch/Fuse/SeriesAmmeter
    meters.dart                # Voltmeter, ChartMeter
    circuit.dart               # 图 + 库存计数 + connect/split/clear
    charge.dart
  solver/
    mna_matrix.dart            # QR 最小二乘（对齐 PhET QRDecomposition）
    mna.dart                   # MNACircuit / MNASolution / stamp 方程
    lta.dart                   # companion + TimestepSubdivisions + LTACircuit
    linear_transient_analysis.dart  # Circuit → LTA → 写回
  controller/
    cck_ac_controller.dart     # tick / drag / snap / reset / 工具箱
  render/
    cck_mvt.dart
    cck_render_data.dart       # 只读 DTO，Painter 禁止重解 MNA
  painters/
    wire_painter.dart
    battery_painter.dart
    ac_source_painter.dart
    resistor_painter.dart
    bulb_painter.dart
    capacitor_painter.dart
    inductor_painter.dart
    switch_painter.dart
    fuse_painter.dart
    vertex_painter.dart
    charge_painter.dart
    series_ammeter_painter.dart
  widgets/
    circuit_canvas.dart
    element_toolbox.dart
    display_options_panel.dart
    sensor_toolbox.dart
    advanced_panel.dart
    view_toggle.dart
    time_control.dart
    edit_bar.dart
    voltmeter_overlay.dart
    charts.dart
    zoom_buttons.dart
  screens/
    cck_ac_virtual_lab_screen.dart   # NineGrid + AppBar
```

测试：`test/cck_ac_virtual_lab/`  
资源：`assets/cck_ac_virtual_lab/images/` `sounds/`（仅从原版 base64/mp3 导出，不自制）

Home：物理 → 电学与电路 → 新卡「AC 虚拟实验室」。只改 `home_screen.dart` 注册。

---

## 2. 数据流

```
指针 / Clock(1/60 或 PAUSED_DT)
        │
        ▼
CckAcController  (ChangeNotifier)
        │  改 Circuit 图、选中、zoom、播放
        ▼
LinearTransientAnalysis.solve(circuit, dt)   纯计算
        │
        ▼
Circuit（电流/电压/mna 动态量）+ ChargeAnimator
        │
        ▼
CckState.toRenderData(mvt) → CckRenderData
        │
        ▼
Painters + Overlay Widgets     禁止再跑 MNA / 禁止再算亮度公式以外的拷贝
```

亮度公式允许在 RenderData **构建时**从 I、R 算一次（与 `LightBulb.computeBrightness` 相同），Painter 只读 `brightness` 字段。

SSOT：Controller 持有 `Circuit`。Painter 只读 DTO。

---

## 3. 层职责

| 层 | 做 | 不做 |
|---|---|---|
| Circuit | 拓扑、connect/split、库存、dirty | Flutter、像素 |
| LTA/MNA | companion、QR、子步、写回 I/V | Widget |
| ChargeAnimator | 沿 path 移动电荷 | 改电阻 |
| Controller | dt 门闩、拖拽夹逼、reset | 画正弦 |
| MVT | 电路坐标→center canvas；zoom | 业务 |
| RenderData | 元件几何、电流箭头、亮度 | 手势 |
| Painter | Path/Image | 改拓扑 |
| Screen | NineGrid、手势命中、面板 | 公式 |

---

## 4. 屏结构

单屏 Lab（无 Tab）。

`CckAcVirtualLabScreen`：

- AppBar：标题 + 返回
- NineGrid
  - `center`：浅蓝 Stack（Canvas + 电荷 + 仪表 overlay + 编辑条 + Reset）
  - `midLeft`：垂直工具箱 + Lifelike/Schematic + Zoom
  - `midRight`：DisplayOptions + Sensors + Advanced
  - `footer`：TimeControl（Play/Pause/Step）
- Reset：center 右下 Positioned

模拟对象不拆进九宫格。

---

## 5. 复用 / 不抽 common

**复用：** NineGridLayout、SimulationClock 心跳、KratosSlider/RadioGroup 语义、audioplayers 播 cut/break。

**不抽 / 不套：**

- 不改 `TimeControlBar`（缺暂停仍微步、缺与 Reset 的相对锚）
- 不套 `DragDropWorkspace` 卡片托盘（Carousel 语义不同）
- 不套 `GraphSuite`（bamboo 时序图 + 探头）
- 不用 `lib/circuit` 任何类型/求解器
- 不改 common API
- 不做 scenario JSON

---

## 6. 有意差异（锁定）

| 项 | 原版 | 本工程 |
|---|---|---|
| 导航 | joist 底栏 | AppBar |
| 多语言 / PDOM / PhET-iO | 有 | 不做 |
| spice | 源码已注释 | 不做 |
| 键盘拖 | 有 | 一期指针 |
| real/extreme 元件 | Lab 工具箱无 | 不做 |
| 非接触安培计 | VL 关闭 | 不做 |
| UI 音 | VL 关 | 元件音可保留 |

---

## 7. 测试计划

- Phase 4：`mna_test`（PhET battery+resistor：V0=0,V1=-4,Ibat=2）；RC/RL 指数；AC 公式；保险丝；导线 R=ρL/A；reset 清空；snap 半径常量
- Phase 5：空屏 pump、工具箱 16 槽、背景色
- Phase 6：拖出/吸附/回工具箱/开关拨动
- Phase 7：zoom 0.35s、保险丝火花 0.3s
- Phase 10：analyze + 专项 + 回归；debug APK

---

## 8. 资产

Phase 5 从 `common/images/*_png.ts` 的 data-URL 抽出 PNG，登记 `pubspec.yaml` 仅本目录。缺文件则记录 [待确认]，不自制。
