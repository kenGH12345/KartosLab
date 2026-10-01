# ASSET_MAPPING.md · Bending Light

> 优先级：原版 PhET Asset → SVG/PNG → Scenery geometry → CustomPainter  
> **禁止** Material Icons / Emoji / 网络图 / “差不多”自绘替代原版 asset  
> 审计日期：2026-09-18

---

## 1. Runtime Images（必须复用）

| Original Asset | Flutter Path（规划） | Usage | Transform | Notes |
|---|---|---|---|---|
| `images/knob.png` (34×31) | `assets/bending_light/images/knob.png` | Prisms 激光尾旋钮；棱镜旋转旋钮 | Laser: scale **0.58**；Prism: `knobHeight/height`（knobHeight=15） | license: CU Boulder · Noah Podolefsky |
| `images/laser.png` (144×57) | `assets/bending_light/images/laser.png` | `LaserTypeRadioButtonGroup` 三态图标 | scale **0.6**；clip `Shape.rectangle(100,0,44,100)` | 仅电台图标，**不是**主激光体 |
| `images/laserKnob.png` (177×57) | `assets/bending_light/images/laserKnob.png`（可选归档） | **JS 零引用** | — | 保留文件但 **Substituted 判定：N/A unused**；主激光≠此图 |

`images/license.json`：三者均为 © University of Colorado Boulder，`contact phethelp@colorado.edu`。

---

## 2. Screen Mipmaps（Home / Navbar 图标）

| Original Asset | Flutter Path（规划） | Usage | Transform |
|---|---|---|---|
| `mipmaps/introScreen.png` (1142×777) | `assets/bending_light/mipmaps/introScreen.png` | Intro home icon | ScreenIcon 标准缩放 |
| `mipmaps/moreToolsScreen.png` (1142×777) | `assets/bending_light/mipmaps/moreToolsScreen.png` | More Tools home icon | 同 |
| `mipmaps/prismsScreenWhite.png` (1142×777) | `assets/bending_light/mipmaps/prismsScreenWhite.png` | Prisms home icon | 同 |
| `mipmaps/prismsScreenWhiteNavBar.png` (1142×777) | `assets/bending_light/mipmaps/prismsScreenWhiteNavBar.png` | Prisms navbar icon | 同 |

`mipmaps/license.json`：© CU Boulder · Amy Rouinfar。

---

## 3. Design Sources（非运行时 · 不直接打包进 APK 除非导出）

| Original | Role |
|---|---|
| `assets/Intro_Screen.ai` | Intro 图标源稿 |
| `assets/More_Tools_Screen.ai` | More Tools 图标源稿 |
| `assets/Prisms_Screen_White.ai` | Prisms home 源稿 |
| `assets/Prisms_Screen_White_NavBar.ai` | Prisms navbar 源稿 |
| `assets/laser.ai` | 激光矢量源稿（对照 LaserPointerNode） |
| `assets/laser_knob.ai` | 旋钮源稿 |
| `assets/wave_detector_probe.ai` | 波探头设计（运行时用 ProbeNode 矢量） |

---

## 4. Marketing Screenshots（仅 QA / 文档对照）

| File | Role |
|---|---|
| `assets/bending-light-screenshot.png` | README 主图 |
| `assets/bending-light-screenshot-alt1.png` … `alt3.png` | 备用 |
| `assets/bending-light-screenshot-screen1.png` … `screen3.png` | 分屏对照（≈ Intro / Prisms / More Tools） |
| 用户提供的 3 张运行截图 | Visual QA 基准（workspace assets） |

**禁止**把截图 crop 当可交互 asset。

---

## 5. Vector / Scenery Components（无独立 PNG · 必须几何复刻）

| Component | Package | Visual Role | Flutter Strategy |
|---|---|---|---|
| `LaserPointerNode` | scenery-phet | 灰金属圆柱激光 + 红电源键 | L1 CustomPainter / 组件；对照上游几何与渐变；**禁止** `Icons.*` |
| `ProtractorNode` | scenery-phet | 黄量角器 | L1；查 `lib/common` 是否已有 |
| `WavelengthSlider` | scenery-phet | 可见光谱条 + 红柄 | L1 |
| `ProbeNode` | scenery-phet | Intensity / Wave 探头 | L1 |
| `WireNode` | scenery-phet | 探头连线 | L1 / Path |
| `TimeControlNode` | scenery-phet | 播放控制 | L1 |
| `ResetAllButton` | scenery-phet | 橙圆 Reset | **L0 `KratosResetAllButton` radius=19** |
| `ShadedRectangle` / `Panel` | scenery-phet / sun | 面板 chrome | L0 panel 风格 |
| `ArrowNode` / `CurvedArrowShape` | scenery-phet | 拖拽提示箭头 | Painter |
| `Checkbox` / `ComboBox` / `HSlider` / `AquaRadioButton` / `ArrowButton` / `RectangularRadioButtonGroup` | sun | 控件 | L0/L1 PhET 风格 |
| `MediumNode` fill | sim | 介质背景色 | `MediumColorFactory` 色值 + rect |
| `NormalLine` | sim | 竖直虚线 | CustomPainter dash |
| `LightRay` / Wave / WhiteLight canvas | sim | 光线与波 | CustomPainter / Shader |
| Prism shapes | sim Path | 半透明蓝棱镜 α=0.5 | Path + fill |
| `AngleNode` arcs | sim | 角度弧 | Painter |
| Intersection normals | sim | 交点法线短线 | Painter |

---

## 6. Asset Count Summary

| Category | Count |
|---|---|
| Runtime PNG used in JS | **2**（knob, laser） |
| Runtime PNG unused | **1**（laserKnob） |
| Mipmap PNG | **4** |
| Design AI | **7** |
| Marketing PNG | **7** |
| SVG | **0** |
| Sounds | **0** |
| **Substituted Assets（目标）** | **必须 = 0** |

---

## 7. Copy Plan（Phase 2+ 执行 · Phase 0 不改工程 assets）

```
# 建议目标布局（尚未执行复制）
assets/bending_light/
  images/knob.png
  images/laser.png
  images/laserKnob.png          # 归档，代码不引用
  mipmaps/introScreen.png
  mipmaps/moreToolsScreen.png
  mipmaps/prismsScreenWhite.png
  mipmaps/prismsScreenWhiteNavBar.png
```

`pubspec.yaml` 注册仅在接入模块时添加；**本阶段不修改**。

---

## 8. ASSET_MAP 交付门槛（对标规则 85）

最终 QA 前必须另建完整 `ASSET_MAP.md`（或升格本文），每行含：

- Original Path  
- Used By  
- Flutter Path  
- Scale / Rotation / Crop / Opacity / Transform  

判定标签示例：`[原版资源一致]` `[布局已对齐]` `[动态绘制已对齐]`

---

## 9. KartosLab Home 接入提示（Phase 8）

- 现有分类：`物理` → `光学与波动`（已有：几何光学、色觉、波的干涉、Waves Intro、声波…）  
- Bending Light 应落入 **光学与波动**，勿新建学科树  
- Phase 0 **不修改** `home_screen.dart`

---

*ASSET_MAPPING · req-bending-light · Phase 0*
