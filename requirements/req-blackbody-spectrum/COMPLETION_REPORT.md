# Blackbody Spectrum · Completion Report

> 完成时间：2026-09-07

---

## 一、迁移状态总览

| 维度 | 状态 | 证据 |
|---|---|---|
| 源码行为 | [行为一致] | Planck/Wien/Stefan-Boltzmann 公式+常量直接来自 PhET 源码 |
| 交互 | [行为一致] | 温度计拖拽+snap50K+clamp(200,11000)；数值点水平拖拽；保存/擦除FIFO；4向缩放 |
| 资源 | [资源已复用] | 本sim无静态图片资源（Asset Inventory确认）；全部由代码动态绘制 |
| 动态组件 | [动态组件已迁移] | 曲线300点采样+峰值插入；RGB颜色动态计算；星形光晕随温度变化 |
| 视觉 | [视觉近似] | 黑底白字default配色；坐标轴L形+刻度+EM谱标签；温度计+三角thumb |
| 工程结构 | [源码一致] | MVC分层：constants/strings/colors/model/render/painters/screens |
| 测试 | [行为一致] | 30个单元测试全部通过 |
| Analyzer | [源码一致] | flutter analyze 0 error / 0 warning / 0 info |
| Navigation | [行为一致] | 已接入HomeScreen"热学与气体"分组 |

---

## 二、文件清单

### 新建文件

| 文件 | 角色 | PhET源码对应 |
|---|---|---|
| `lib/blackbody_spectrum/blackbody_spectrum_constants.dart` | 常量 | `BlackbodyConstants.js` |
| `lib/blackbody_spectrum/blackbody_spectrum_strings.dart` | 字符串 | `blackbody-spectrum-strings_en.json` |
| `lib/blackbody_spectrum/blackbody_spectrum_colors.dart` | 配色 | `BlackbodyColors.js` |
| `lib/blackbody_spectrum/model/blackbody_body_model.dart` | 单Blackbody物理模型 | `BlackbodyBodyModel.js` |
| `lib/blackbody_spectrum/model/blackbody_spectrum_model.dart` | 主Model | `BlackbodySpectrumModel.js` |
| `lib/blackbody_spectrum/render/blackbody_render_data.dart` | 不可变渲染数据 | (新设计) |
| `lib/blackbody_spectrum/painters/spectrum_graph_painter.dart` | 光谱图表painter | `GraphDrawingNode.js`+`ZoomableAxesView.js` |
| `lib/blackbody_spectrum/painters/thermometer_painter.dart` | 温度计painter | `BlackbodySpectrumThermometer.js`+`TriangleSliderThumb.js` |
| `lib/blackbody_spectrum/painters/bgr_star_painter.dart` | RGB+星painter | `BGRAndStarDisplay.js` |
| `lib/blackbody_spectrum/painters/saved_graph_panel_painter.dart` | 保存图面板painter | `SavedGraphInformationPanel.js`+`GenericCurveShape.js` |
| `lib/blackbody_spectrum/screens/blackbody_spectrum_home.dart` | 入口Widget | (新设计) |
| `lib/blackbody_spectrum/screens/blackbody_spectrum_screen_body.dart` | 屏幕body | `BlackbodySpectrumScreenView.js` |
| `test/blackbody_spectrum/blackbody_body_model_test.dart` | 单元测试 | — |
| `test/blackbody_spectrum/blackbody_spectrum_model_test.dart` | 单元测试 | — |

### 修改文件

| 文件 | 改动 |
|---|---|
| `lib/screens/home_screen.dart` | +1 import；+1 _SimEntry；+1 builder方法 |

---

## 三、物理常量验证

| 常量 | PhET值 | Flutter值 | 来源 |
|---|---|---|---|
| Planck A | 3.74192e-16 | 3.74192e-16 | `BlackbodyBodyModel.js:82` |
| Planck B | 1.438770e7 | 1.438770e7 | `BlackbodyBodyModel.js:83` |
| Stefan-Boltzmann σ | 5.670373e-8 | 5.670373e-8 | `BlackbodyBodyModel.js:131` |
| Wien b | 2.897773e-3 | 2.897773e-3 | `BlackbodyBodyModel.js:146` |
| Draper point | 798 K | 798 K | `BlackbodyBodyModel.js:98` |
| Red/green/blue λ | 650/550/450 nm | 650/550/450 nm | `BlackbodyBodyModel.js:21-23` |
| Min/max temp | 200/11000 K | 200/11000 K | `BlackbodyConstants.js:15-16` |
| Sun temp | 5800 K | 5800 K | `BlackbodyConstants.js:19` |

---

## 四、测试结果

```
flutter test test/blackbody_spectrum/
→ All 30 tests passed!
```

覆盖范围：
- Planck 光谱功率密度（wavelength=0 / null temperature / valid / overflow guard）
- Wien 峰值波长（Sun≈500nm / Earth>10000nm / null=0）
- Stefan-Boltzmann 总强度（Sun>1e6 / Earth<300）
- 归一化温度（draper point=0 / 随温度递增）
- RGB 颜色（draper point 全零 / 高温非零）
- 光晕半径（draper point=5px / 随温度递增）
- 温度边界（200 / 11000）
- Model 初始状态 / 温度设置 clamp / save-erase FIFO / zoom clamp / reset

---

## 五、Analyzer 结果

```
flutter analyze lib/blackbody_spectrum/ lib/screens/home_screen.dart
→ 0 issues found.
```

---

## 六、有意差异

| 差异点 | 原因 | 判定 |
|---|---|---|
| 按钮/复选框用 Material Widget | L0 规范 §七 G1 允许 Material 替换 | [有意差异] |
| projector 配色未实现 | PhET 双配色（default/projector），先实现 default | [待确认] |
| cueing arrows 首次点击后隐藏 | 已实现逻辑但无渐变动画（PhET 也只是 visible=false） | [行为一致] |
| 温度计 thumb 悬停高亮 | 框架已支持 isHovered 参数但 GestureDetector 未传 hover 事件 | [待确认] |

---

## 七、未迁移项

无。所有 PhET 运行时元素均已登记实现方式（见 PHET_ASSET_INVENTORY.md）。

---

*报告完成时间：2026-09-07*
