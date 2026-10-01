# MAGNET M5-5-AUDIT · Typography / Color / Micro Geometry

> 日期：2026-08-31  
> 阶段：**只取证。0 实现修改。不进入 Visual Fix。**  
> 对照：A `phet/magnet_and_compass/lib/main.dart` `SimulationPage` · target `lib/magnetism/magnet_and_compass/`  
> 量测：Pixel Tablet 1280×800 · `m5-3/rects.json`（面板/Slider/标签）· Reset 几何见 M5-4

本阶段禁止改 UI / Typography / Color / Geometry / NineGrid / State / Controller / MagneticField / Home / Earth / Electromagnet。

---

## 0. 结论（先看这里）

实验物体（磁铁 / 罗盘 / 场箭头 / FieldMeter 面板 / ControlPanel 字面量）**颜色与字号与原版同源**。[已确认]

真正的视觉差几乎全是：

1. **页面壳**：Flutter 有 AppBar + NineGrid；原版 `SimulationPage` 满屏 Stack、无标题栏  
2. **Material 宿主主题**：原版 `ThemeData.dark()`；Kratos / 测试宿主是 **M3 light**（seed `#1177AA` 或默认 light）  
3. **M5-3 FittedBox**：仅 `Magnetic Field (B)` 被 `scaleDown`（原版同款 13px 但 overflow 55px）

**没有**需要为此重写 Slider / Card / Button / Icon 体系的项。  
**没有**推荐进入 M5-6 typography/color fix。[已确认]

Earth：`[待确认 / BLOCKED：earth.svg]`。Electromagnet：仍 BLOCKED。

---

## 1. Typography

双方 **都没有** `fontFamily` / `height`（line height）/ `letterSpacing` / `textBaseline`（sim 页）。  
未设时：拉丁文走 Flutter 默认 **Roboto**；`TextPainter` 磁铁 N/S 同。  
Kratos `fontFamilyFallback`（微软雅黑等）只影响 **AppBar 中文**，不影响面板英文。

原版唯一 `letterSpacing: 2` 在 **EntryPage**「Magnet & Compass」，不在 `SimulationPage`。本审计不把首页当 sim chrome。

| 表面 | 原版 | Flutter | family | size | weight | line height | letter-spacing | baseline |
|---|---|---|---|---|---|---|---|---|
| Sim 页 title | **无** | AppBar `'磁铁与罗盘'` `fontSize: 16`，未设 weight（M3 title） | CJK fallback | 16 | 主题默认 ≈ w500 | 未设 | 未设 | 未设 |
| Bar Magnet | 14 bold black87 | 同 | 默认 | 14 | bold | 未设 | 未设 | 未设 |
| Strength: / 75% | 12 / 12 bold | 同 | 默认 | 12 | regular / bold | 未设 | 未设 | 未设 |
| 0% 50% 100% | 9 black54 | 同 | 默认 | 9 | regular | 未设 | 未设 | 未设 |
| Check 标签 | 13 black87；长标签 **裸 Text** | 13 同；长标签 **FittedBox scaleDown** | 默认 | 13（长标签有效 ≈11.3） | regular | 未设 | 未设 | 未设 |
| Flip Polarity | 13 w600 | 同 | 默认 | 13 | w600 | 未设 | 未设 | 未设 |
| Compass / Field Meter 行 | 13 | 同 | 默认 | 13 | regular | 未设 | 未设 | 未设 |
| 磁铁 N/S | TextPainter 22 w900 白 + shadow | 同 | 默认 | 22 | w900 | 未设 | 未设 | 几何中心 |
| 垂直磁铁 N/S（地球模式） | 11 w900 | 同 | 默认 | 11 | w900 | 未设 | 未设 | 几何中心 |
| 罗盘面 | **无** N/E/S/W 字 | 同（仅 72 刻度） | — | — | — | — | — | — |
| Mini compass S/N | 8 bold black54 | 同 | 默认 | 8 | bold | 未设 | 未设 | 几何中心 |
| FieldMeter B / θ / Bx / By | 12 bold / 11 / 10 / 10 | 同 | 默认 | 同 | 同 | 未设 | 未设 | 未设 |
| Reset | 无文字；Icon 28 | 同 | Material Icons | 28 | — | — | — | — |

量测（m5-3，标签 `getRect`）：

| 标签 | 原版 | Flutter | Δ |
|---|---|---|---|
| Bar Magnet | 142.5 × 20 | 142.5 × 20 | **0** |
| Strength: | 110.25 × 17 | 110.25 × 17 | **0** |
| See Inside | 132.5 × 19 | 132.5 × 19 | **0** |
| Magnetic Field (B) | **238.5 × 19**（溢出） | **184 × 14.7**（scaleDown） | 宽 −54.5；高 **−4.3** |

FittedBox：短标签不缩放。[已确认]

**Material typography**：AppBar 走 `ThemeData` title；面板/测点全部显式 `TextStyle`，不吃 `textTheme.bodyMedium`。  
**FittedBox**：仅 `_check` 长标签。

---

## 2. Colors

显式色值 **逐字相同**（含 alpha、渐变 stop、描边）。无 disabled 样式（地球勾选仍可点，svg 仍缺）。

| 表面 | 原版 = Flutter 字面量 |
|---|---|
| Scaffold / center 底 | `Color.fromARGB(93, 0, 0, 0)` |
| 面板卡 | `#f0f4f8` · border `grey.shade300` · shadow `black26` blur 6 offset (0,2) |
| Slider | active `Colors.blueAccent` · inactive `grey.shade300` · thumb `Colors.lightBlue` |
| Checkbox `activeColor` | `Colors.blueAccent` |
| Flip | bg `#4fc3f7` · fg `black87` · elevation 0 |
| 箭头钮 | `grey.shade200` / border `shade400` · icon `black54` |
| 磁铁 S/N | `#3949ab` / `#e53935` + lerp 白 0.28 / 黑 0.22 · 描边 `white24` 1.5 |
| 罗盘环 | `#4a4a4a→#1a1a1a` radial · stroke `#555555` 6 · 内盘 `#1e1e1e` / `#444444` |
| 磁针 | 白 `#aaaaaa→#ffffff→#aaaaaa` · 红 `#990000→#ee3333→#990000` |
| 中心帽 | `grey.shade300→shade700` r=12 · 内白 r=5 |
| 场箭头 | `#cccccc` / `#cc2222` · stroke `black26` 0.3 |
| FieldMeter | `#0d2255` α **0.95** · border `lightBlueAccent` **1.5** · glow α 0.2 blur 10 |
| Reset | `#e65100` · icon 白 · shadow `black54` blur 8 |
| Mini compass | 盘 `#2a2a2a` · 环 `#555555` 1.5 · 针 `white70` / `redAccent` |

**主题继承差**（未写死的部分）：

| | 原版 `SimulationPage` | Flutter |
|---|---|---|
| 宿主 | `MagnetApp` → `ThemeData.dark()`（M3） | Kratos `ThemeData` M3 **light** seed `#1177AA`；测试里常为默认 light |
| 未选中 Checkbox 边框 | 暗色 onSurface（浅描边） | 亮色 onSurface（深描边） |
| InkWell / Button ripple | 暗主题 overlay | 亮主题 overlay |
| AppBar | 无 | `#1565C0` + 白字 |

分类：`[视觉近似：Material]`。不要为此换组件体系。

NineGrid 边格无场箭头，露出同一半透明黑：`[有意差异：NineGrid]`。

mean RGB 全屏差来自 AppBar 蓝 + 边格，**不是**磁铁色差。不要优化 mean RGB。

---

## 3. Micro Geometry（只记 ≤ 5px 的明确差）

源码已对齐、量测为 0 的 **不**当差异：

| 项 | 双方 |
|---|---|
| 面板宽 / 内 pad | 230 / `EdgeInsets.all(10)` / radius **10** |
| 面板卡间距 | 8 |
| 标题下 / Flip 上 | SizedBox 6 |
| 行距 | 2 |
| 勾选盒 | 20×20 · 标签左 gap 4 |
| 箭头钮 | 22×22 · icon **18** · radius 3 |
| Slider | `trackHeight: 3` · thumb r **7** · `noOverlay` · 量到 **164×14** |
| Flip 钮 | pad 垂直 6 · radius 6 · 量到 **208×48** |
| Mini compass | 60×22 |
| Field Meter 装饰 | radius 8 · border **1.5** · pad 10 · gps **14** |
| 罗盘中心帽 | 外 r **12** / 内 r **5** / stroke 1.5 |
| 磁铁圆角 | 14 · 高光条 5 |
| Reset 圆 / icon | 52 · **28**（1280 完整） |

**≤ 5px 明确差：**

| 项 | Δ | 说明 |
|---|---|---|
| `Magnetic Field (B)` 行高 | **4.3px** | FittedBox 后 14.7 vs 原版 19 |
| SliderTheme.`padding` | 源码差 | Flutter 有 `EdgeInsets.zero`；原版未写。**量到的 Slider 盒仍 14×164** |

**> 5px、已有分类、本阶段不记为 micro fix：**

- AppBar 44、NineGrid origin、Reset 底 inset 18 vs ≈9.7（M5-4）  
- 长标签宽 238.5 vs 184（overflow 修复）

---

## 4. Material Differences

| 控件 | 原版 | Flutter | 分类 | Action |
|---|---|---|---|---|
| **AppBar** | 无 | 44px `#1565C0` · title 16 | `[有意差异：NineGrid]` 页面壳（KARTOSLAB chrome） | 不修 |
| **Slider** | 同 SliderTheme 色/高/拇指；无 `padding: zero`；宿主 dark | 多 `padding: zero`；宿主 light | `[视觉近似：Material]` | 不修 · 不换 KratosSlider · 不设 `year2023` |
| **Reset** | 满屏 `Positioned(right:18,bottom:18)` 自绘圆 | 同色同 icon；槽在 `bottomRight` | `[有意差异：NineGrid]` + `[视觉已对齐]` 52px@1280 | 不修 |
| **Material icons** | refresh 28 · gps_fixed 14 · add_circle_outline 20 · arrow 18 | 同 codepoint / size | `[源码一致]` | 不修 |
| **Card** | **不用** `Card`；`Container`+Decoration | 同 | `[源码一致]` | 不修 |
| **Buttons** | `ElevatedButton` 显式色 + `InkWell` 箭头 | 同；M3 min height → 双方 Flip 均 **48** | `[视觉近似：Material]` 涟漪 | 不修 |
| **Checkbox** | `activeColor` + shrinkWrap | 同 API；未选中边框跟 brightness | `[视觉近似：Material]` | 不修 |

不要因为上述差异重写组件体系。[已确认]

---

## 5. NineGrid

继续：`[有意差异：NineGrid]`

- 满屏场箭头 vs 仅 center  
- AppBar + 边格  
- Reset 槽位（不进 center）  
- ControlPanel 仍 center 内 `top:12, right:12`（M5-3）

**不要修改 NineGridLayout。**

---

## 6. Earth

`[待确认 / BLOCKED：earth.svg]`

`EarthGlowPainter` / `VerticalMagnetPainter` 色与字 **源码已对齐**，无法对屏。不处理。Electromagnet 仍 BLOCKED。

---

## 7. 总表

| Component | Original | Flutter | Difference | Classification | Action |
|---|---|---|---|---|---|
| Sim title | 无 | AppBar 16 中文 | 页面壳 | `[有意差异：NineGrid]` | 不修 |
| AppBar 字体 | — | 16 + CJK fallback | 仅中文 | `[视觉近似：font family]` | 不修 |
| 面板标题/刻度/Flip 文案 | 14/12/9/13 显式 | 同 | 0（短标签量测 0） | `[源码一致]` `[视觉已对齐]` | 不修 |
| Magnetic Field (B) | 13 · 238.5×19 · overflow 55 | 13 + FittedBox · 184×14.7 | 高 −4.3；宽为 overflow 修复 | `[视觉近似]`（有意） | **保持** FittedBox |
| FieldMeter 文案 | 12/11/10 | 同 | 0 | `[源码一致]` | 不修 |
| 磁铁 N/S | 22 w900 | 同 | 0 | `[源码一致]` `[视觉已对齐]` | 不修 |
| 罗盘刻度（无文字） | 72 tick | 同 | 0 | `[源码一致]` | 不修 |
| Mini S/N | 8 bold | 同 | 0 | `[源码一致]` | 不修 |
| 背景 | ARGB(93,0,0,0) 满窗 | 同色；箭头只在 center | 边格无场 | `[有意差异：NineGrid]` | 不修 |
| 面板/Slider/磁铁/罗盘/测点/Reset 色 | 见 §2 | 字面量同 | 未选中 Checkbox / ripple | `[视觉近似：Material]` | 不修 |
| 面板 radius/pad/border | 10 / 10 / shade300 | 同 | 0 | `[源码一致]` | 不修 |
| Slider 盒 | 164×14 | 164×14 | padding 源码差，盒 0 | `[视觉已对齐]` | 不修 |
| Flip | 208×48 | 208×48 | 0 | `[视觉已对齐]` | 不修 |
| 罗盘中心帽 | r 12 / 5 | 同 | 0 | `[源码一致]` `[视觉已对齐]` | 不修 |
| FieldMeter border | 1.5 lightBlueAccent | 同 | 0 | `[源码一致]` | 不修 |
| Reset inset | 18 / 18 | right≈18 · bottom≈9.7 @1280 | 槽高 | `[有意差异：NineGrid]` | 不修（M5-4 已适配圆） |
| Checkbox 未选中 | dark theme 边 | light theme 边 | Material | `[视觉近似：Material]` | 不修 |
| Earth 视觉 | earth.svg | 缺资源 | 无法对屏 | `[待确认 / BLOCKED：earth.svg]` | 不处理 |
| MagneticField / MagnetState | — | 未改 | — | `[源码一致]` | 不修 |

**[可修复]**：无推荐项。FittedBox 回退会恢复 55px overflow，**不建议**。

---

## 8. 本阶段明确没做

未改任何实现。未进 Visual Fix。未接 Home。未删 Legacy。未造 earth.svg。未动 Electromagnet。

---

## 停止

**M5-5 audit 完成。**
