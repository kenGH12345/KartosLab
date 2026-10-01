# ASSET_MAP — Gas Properties

> 源码根：`phet sourses/gas-properties-main/gas-properties-main`  
> 原则：优先复用 PhET 原资源；程序绘制 → Flutter `CustomPainter`；禁止 emoji / Material Icon 冒充。

---

## 1. 仓库内位图 / 矢量

| PhET Asset | 类型 | 用途 | Flutter 路径（建议） | 是否直接复用 |
| ---------- | --- | --- | ---------- | ------ |
| `images/phetGirlLabCoat.png`（经 `phetGirlLabCoat_png.ts`） | PNG | OopsDialog 图标（`GasPropertiesOopsDialog`） | `assets/simulations/gas_properties/phet_girl_lab_coat.png` | Yes |
| `images/license.json` | JSON | 许可证元数据 | （文档保留，不打包） | N/A |
| `assets/` | — | **空目录** | — | — |

**[已确认]** Gas Properties 本体仓库几乎**没有** UI 雪碧图；视觉以程序节点为主。

---

## 2. 程序绘制（必须 CustomPainter / 矢量复刻）

| PhET 组件 | 类型 | 用途 | Flutter 路径（建议） | 是否直接复用 |
| --------- | --- | --- | ---------- | ------ |
| `ParticleNode` / `ShadedSphereNode` → Sprite canvas | 程序绘制 | Heavy/Light/Diffusion 粒子球体 + 高光 | `lib/gas_properties/painters/particle_painter.dart` | No（重绘） |
| `IdealGasLawContainerNode` / `DiffusionContainerNode` | 程序绘制 | 容器壁、盖、开口、divider | `…/painters/container_painter.dart` | No |
| `LidHandleNode` / `ResizeHandleNode` | 程序绘制 | 盖把手、宽度把手 | `…/painters` + widgets | No |
| `PressureGaugeNode` + post gradient | 程序绘制 | 压力表与立柱 | `…/widgets/pressure_gauge.dart` | No |
| `GasPropertiesThermometerNode`（包装 scenery-phet `ThermometerNode`） | 依赖库 | 温度计 | `…/widgets/thermometer.dart` | No（复刻几何） |
| `GasPropertiesBicyclePumpNode`（`BicyclePumpNode`） | 依赖库 | 打气筒 + 手柄动画 | `…/widgets/bicycle_pump.dart` | No（复刻几何） |
| `GasPropertiesHeaterCoolerNode`（`HeaterCoolerNode`） | 依赖库 | 加热/冷却 | `…/widgets/heater_cooler.dart` | No（复刻几何） |
| `GasPropertiesStopwatchNode` | 依赖库包装 | 秒表 | 优先复用项目已有 stopwatch；否则自绘 | 视 common |
| `CollisionCounterNode` | 程序绘制 | 壁碰撞计数器 UI | `…/widgets/collision_counter.dart` | No |
| `HistogramNode` / `BinCountsPlot` | 程序绘制 | Speed / KE 直方图 | `…/painters/histogram_painter.dart` | No |
| `DimensionalArrowsNode` / width indicator | 程序绘制 | 容器宽度标注 | painters | No |
| `WallVelocityVectorNode` | 程序绘制 | Explore 壁速度矢量 | painters | No |
| `CenterOfMassNode` | 程序绘制 | Diffusion 质心标记 | painters | No |
| `ParticleFlowRateNode` | 程序绘制 | 粒子流率箭头/读数 | widgets | No |
| `ScaleNode` | 程序绘制 | Diffusion 下方刻度 | painters | No |
| `DividerNode` / `DividerToggleButton` | 程序绘制 | 隔板与切换 | widgets | No |
| `GasPropertiesIconFactory` Screen icons | 程序绘制 | Home 四屏图标 | `…/widgets/screen_icons.dart` | No |
| `EraseParticlesButton` | 程序绘制/按钮 | 清除粒子 | widgets | No |
| `ReturnLidButton` | 按钮 | 复位盖子 | widgets | No |
| Accordion / Panel / AquaRadio / Checkbox | sun UI | 右侧/左侧控制面板 | 优先项目 L0/通用组件 | 部分复用 |

---

## 3. 颜色（非图片 · 必须对齐）

来源：`js/common/GasPropertiesColors.ts`（default profile；另有 projector）

| Token | Default | 用途 |
|-------|---------|------|
| screenBackground | black | 屏背景 |
| panelFill | rgb(40,40,40) | 面板 |
| panelStroke | rgb(55,55,55) | 面板边 |
| textFill | white | 文字 |
| heavyParticle | rgb(119,114,244) | 重粒子 |
| lightParticle | rgb(232,78,32) | 轻粒子 |
| diffusionParticle1 | rgb(0,230,255) | Diffusion 种 1 |
| diffusionParticle2 | rgb(232,78,32) | Diffusion 种 2 |
| dividerColor | rgb(70,205,85) | 隔板 |
| speedHistogramBar | white | 速度直方 |
| kineticEnergyHistogramBar | PhetColorScheme.KINETIC_ENERGY | KE 直方 |
| collisionCounterBackground | rgb(254,212,131) | 计数器 |
| stopwatchBackground | rgb(80,130,230) | 秒表 |

Flutter：`lib/gas_properties/gas_properties_colors.dart` 集中定义；支持后续 projector 配置。

---

## 4. 字符串

| PhET Asset | 类型 | 用途 | Flutter 路径 | 是否直接复用 |
| ---------- | --- | --- | ---------- | ------ |
| `gas-properties-strings_en.json` | JSON | 全部 UI / Oops 文案 | `lib/gas_properties/gas_properties_strings.dart` | Yes（内容移植） |

关键 Oops 文案必须 1:1：

- Temperature cannot be held constant when empty / open  
- Pressure cannot be held constant when empty / volume too large / too small  
- Maximum temperature reached  

---

## 5. 外部依赖资源说明

下列**不在**本仓库 `images/`，而在 PhET `scenery-phet` 等依赖中：

- Bicycle pump 几何与动画帧逻辑  
- Heater/Cooler 火焰与冰块几何  
- Thermometer 玻璃管几何  
- Stopwatch 表盘几何  

**策略**：**[已确认需求]** 按 PhET 行为与可见几何复刻；禁止用 Material Icon / emoji 替代。若项目 `lib/common/` 已有等价组件则优先复用（Phase 2 前 grep 确认）。

---

## 6. 禁止事项（资产）

- ❌ emoji 代替粒子 / 泵 / 加热器  
- ❌ Material Icons 冒充 PhET 图标  
- ❌ 第三方气体/泵图片替换  
- ❌ 截图当可交互 UI  
- ❌ 粒子用随机色块代替 shaded sphere  

---

## 7. 打包清单（Phase 3 执行时）

1. 从源码提取 `phetGirlLabCoat.png`（若仅有 `.ts` 嵌入，从 TS/构建产物或上游 GitHub `images/` 取出）  
2. 注册 `pubspec.yaml` assets  
3. 其余全部代码绘制  

**[待确认]** 当前本地 `images/` 仅见 `phetGirlLabCoat_png.ts`（模块封装），Phase 3 需确认原始 PNG 提取方式。
