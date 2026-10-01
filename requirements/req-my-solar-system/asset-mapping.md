# Asset Mapping · My Solar System

> 扫描根：本地 `my-solar-system-main`。无 `images/`、`sounds/` 目录。

## Inventory

| 资源 | 位置 | 判断 |
|---|---|---|
| 英文字符串 | `my-solar-system-strings_en.json` | **配置化复用**（Dart strings 或 JSON） |
| Intro/Lab 屏图标 | `IntroScreenIcon.ts` / `LabScreenIcon.ts` | **CustomPainter / 程序绘制**（未读像素文件） |
| Path checkbox 图 | `solar-system-common/images/pathIcon_png.js` | **本机缺失**。用 Icon 或简单轨迹 Painter 替代，不自制假 png 冒充 |
| Grab/Release 音 | `SolarSystemCommonConstants.GRAB_SOUND_PLAYER` | **缺失**。一期静默 |
| Body 轨道循环音 | BodyNode.playSound | **缺失**。一期静默 |
| 添加/删除体音 | LabScreenView bodySoundManager | **缺失**。一期静默 |
| Flash 遗留 | `assets/original-source/*.as` | **无需使用**（非 HTML5 算法） |
| HTML | `my-solar-system_en.html` | 仅入口参考，不嵌入 |
| Font | 无 sim 专用字体 | 用 Kratos 主题 |
| Preset 数据 | `OrbitalSystem.ts` | **JSON scenario** 驱动 |

## 必须复用（逻辑，非文件）

- Preset 数值表  
- 三则 Units Information 字符串  
- 颜色黄/品红/青/绿  

## 应绘制而非贴图

- 天体实心圆 + 序号  
- CoM 红 X  
- 速度/重力箭头（`lib/common/controls/arrow_painter.dart`）  
- 网格、轨迹、测量尺  
- Zoom 放大镜按钮可用 Material icon  

## 配置化

```
assets/scenarios/my_solar_system/
  intro_default.json
  lab_sun_planet.json
  … 每个可见 preset 一份
  lab_orbital_system_1.json  # 隐藏 preset 仍落盘
```

Schema：`schemas/my_solar_system_scenario.schema.json`（EDD §9，Build 后期）。

## 无需使用

- `dependencies.json` 除登记 sha 外  
- PhET-iO overrides  
- `my-solar-system-phet-io-overrides.js`  
- Flash `.as`
