# Architecture Plan — Capacitor Lab Basics

> Phase 1 · 2026-09-12  
> 依据：SOURCE_ANALYSIS + ASSET_MAP + KARTOSLAB 惯例  
> **无高风险架构决策需人工确认** → Phase 1 完成后自动进入 Phase 2（Model + 常量骨架）

---

## PHASE: Architecture Design（随 Intake 一并完成）
## STATUS: DONE

---

## 1. Target directory

```
lib/capacitor_lab_basics/
├── clb_constants.dart
├── clb_colors.dart          # 从 CLBConstants 颜色抽出
├── clb_strings.dart
├── common/
│   ├── model/               # CLBModel 基类、Circuit、Battery、Capacitor、Switch、Wire、meters
│   ├── transform/           # YawPitchMvt
│   ├── render/              # 不可变 RenderData snapshot
│   ├── painters/            # battery / capacitor / wire / switch / field / charge / current…
│   └── widgets/             # view control、toolbox、bar meters、voltmeter、drag handles
├── capacitance/
│   ├── model/
│   ├── controller/
│   ├── render/
│   └── screens/
├── light_bulb/
│   ├── model/
│   ├── controller/
│   ├── render/
│   └── screens/
└── screens/
    └── capacitor_lab_basics_home.dart

assets/simulations/capacitor_lab_basics/   # Phase 2 拷贝 6 PNG
test/capacitor_lab_basics/
```

对齐 PhET：`common` + 双屏包；不机械复制 CCK 电路求解器（本 sim 为专用 ParallelCircuit，非通用网表）。

---

## 2. Data boundary（强制）

```
Model (SSOT: V, geometry, connection, Q/C/U/E derived, meter visibility, probes…)
        ↓ step(dt) / 手势 API
Derived (current amplitude, polarity, arrow color, bulb brightness factor…)
        ↓
RenderData（几何 path 点、asset keys、颜色、显隐、文字）
        ↓
Painter / Widget（只读；手势 → Controller → Model）
```

- Widget **不**算电容/放电  
- Painter **不**持有业务可变状态  
- Controller：时钟、`step`、拖拽坐标变换、notify

---

## 3. Screen shell

| 层 | 选择 | 理由 |
|----|------|------|
| Home | `CapacitorLabBasicsHome` | 双屏入口 |
| Tabs | `KratosTabbedScreen`：Capacitance \| Light Bulb | 对齐其他双屏 sim |
| Layout | `layoutBounds` 逻辑 **1024×618**；NineGrid 或 Stack+锚点 | 对齐 CLBModel world |
| MVT | `YawPitchMvt(scale:12000, pitch:30°, yaw:−45°)` | 源码默认 |

两屏 **各自** Model；仅 `switchUsed` 共享。

---

## 4. Asset 策略

| 策略 | 对象 |
|------|------|
| `Image.asset` | probe×2, voltmeterBody, switchCueArrow, capacitanceScreenIcon, lightBulbBase |
| CustomPainter | battery, plates, E-field, charge, wires, bars, handles, bulb glass/filament/halo, current arrows |
| L0 复用优先 | ResetAll、TimeControl、Stopwatch、Checkbox/Radio/Panel —— Phase 2 前 `grep lib/common` |
| 禁止 | Material Icons、emoji、截图 crop、自制电池/电容图 |

`Substituted Assets` 目标：**0**

---

## 5. 实施阶段（Build）

| Phase | 内容 | 退出标准 |
|-------|------|----------|
| **2** | 常量/字符串/枚举；Circuit+Capacitor+Battery 模型；unit 测公式；**拷贝 6 PNG + pubspec** | C/Q/U/E/discharge 测试 PASS |
| **3** | MVT + Circuit 静态渲染（电池/板/线/开关）；双屏壳 | 与原版默认布局可对照 |
| **4** | 交互：V 滑条、开关、板拖、条形表、view control | 行为矩阵主路径 PASS |
| **5** | 电压表 + 探针 + 导线；toolbox | 测量路径 PASS |
| **6** | Light Bulb：放电、亮度、TimeControl、Stopwatch | LB 屏主路径 PASS |
| **7** | 电流指示动画、cue arrow、Reset、polish | |
| **8** | Visual QA + Final 报告（含 Asset 计数） | Substituted=0 |

本 Phase 1 **不**做 2–8 的大规模编码。

---

## 6. 风险与决策

| 项 | 决策 | 需用户？ |
|----|------|----------|
| 不用通用 CCK solver | 按 ParallelCircuit 专用实现 | 否 |
| DebugLayer | 不上线 | 否 |
| joist 1024×618 | 采用 CLBModel 尺寸 | 否 |
| Stopwatch / TimeControl | 先 grep L0，无则按 scenery-phet 行为重建 | 否 |
| `PhetColorScheme.RED_COLORBLIND` | Phase 2 查依赖常量写入 colors | 否 |
| query `switch=twoState` | MVP 可只做 threeState；参数留扩展 | 否（默认 three） |

**结论：无阻塞级人工架构决策。**

---

## 7. 与资产政策的衔接

任何 UI 图形变更必须先更新 `ASSET_MAP.md` 对应行，并遵守 `VISUAL_ASSET_POLICY.md`。  
视觉 Diff 顺序：Asset → 加载 → 尺寸 → anchor → transform → Layer → Painter → Text → Color。
