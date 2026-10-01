# HI/SP 封板清单（2026-09-29）

## 已对齐（封板范围）

| 模块 | 状态 |
|---|---|
| 右栏 Wave Display → Screen → Tools（原版自上而下） | ✅ |
| Configuration \| Slit Separation 横排贴波区下 | ✅ |
| 波区显示 360×330；左右间隙不叠右栏 | ✅ |
| 粒子选择器 2×2 · 左栏底部空白 | ✅ |
| HI Laser / SP Emitter（SP 高于底部 radios） | ✅ |
| Screen/Graph ABSwitch | ✅ |
| Measuring Tape / Stopwatch | ✅ |
| Time Plot / Position Plot | ✅ |
| Wave chrome（白框 + 距离尺 + fs 时间尺） | ✅ |
| DoubleSlit 三截屏障 + 遮缝 + 探测器黄框/计数 | ✅ |
| 屏距标注 + 绿色双向拖拽箭头（barrierFraction） | ✅ |
| getDisplaySlitLayout（40–220 px） | ✅ |
| Detector 20° 平行四边形 skew | ✅ |
| Tab 交叉渐出/渐入（`KratosTabSwitcher`） | ✅ |

## 已知可延期（不挡封板）

- Screen 面板 Camera / Gallery 图标（现 Snap/View）
- Clear 橡皮擦常显 vs Hits-only
- SlitDetector 闪白动画 / a11y 全链
- Time/Position Plot 轴单位自适应与 RichText
- WaveKernel 色幂 / layered packet 微调
- Experiment 屏独立收口

## 验证

- `flutter test` HI/SP layout + screen + QWI home：**PASS**（见 `HI_SP_LAYOUT_CLOSEOUT_REPORT.md`）
- Debug APK：`build/app/outputs/flutter-apk/app-debug.apk`（若本地已编）
