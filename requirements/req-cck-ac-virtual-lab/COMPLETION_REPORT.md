# COMPLETION_REPORT · Circuit Construction Kit: AC - Virtual Lab

需求：`req-cck-ac-virtual-lab`  
日期：2026-09-02  
入口：Home → 物理 → 电学与电路 → **AC 虚拟实验室**  
代码：`lib/cck_ac_virtual_lab/`  
原版：https://phet.colorado.edu/sims/html/circuit-construction-kit-ac-virtual-lab/latest/circuit-construction-kit-ac-virtual-lab_all.html

不允许声称「完全一模一样」。下列标签是结论，不是口号。

---

## 总状态

| 维度 | 标签 |
|---|---|
| 求解器 / 公式 | [源码一致] |
| 时钟 / Reset / Zoom 动画参数 | [源码一致] |
| 工具箱元件集合（Lab，无非接触安培计） | [源码一致] |
| 拖拽 SNAP / 开关 / 熔断 | [行为一致] |
| 页面 chrome | [有意差异] AppBar + NineGrid |
| 视觉 | [视觉近似] |
| 原版运行截图对照 | [待确认：缺少原版运行截图] |
| 架构拍板 | 无阻塞（未改 common API、未合并 `lib/circuit`） |

---

## 完成了什么

1. 独立移植 PhET HTML5 CCK-AC Virtual Lab（单屏 `LabScreen(false)`）。
2. LTA companion + MNA 薄 QR；Painter 不重解。
3. 原版 PNG 从 `*_png.ts` 抽出，不自制 bitmap。
4. NineGrid 页面布局 + 画布局部坐标。
5. Home 第二张电学卡片；`lib/circuit` 不动。

## 测试

```
flutter test test/cck_ac_virtual_lab          # 19 passed
flutter test test/widget_test.dart test/magnetism/magnet_home_nav_test.dart  # 9 passed
```

## analyze

`flutter analyze lib/cck_ac_virtual_lab lib/screens/home_screen.dart` → 0 issues

## 构建

Debug APK：`build/app/outputs/flutter-apk/app-debug.apk`

## 有意差异

- 无 i18n / PDOM / PhET-iO / spice / 键盘拖 / real-extreme 元件
- 无 Undo（原版也没有 circuit undo）
- 图表为简易折线，不套 GraphSuite / 不复刻 bamboo 皮肤
- 工具箱点击在画布中心放置（非跨 NineGrid 拖出）
- 电荷 equalize 顺序确定性
- 电容 lifelike 非 scenery-phet 3D `CapacitorNode`

## 遗留（只记录，不修）

| 类 | 项 |
|---|---|
| 5 证据不足 | 缺原版可运行视口截图，无法 overlay/diff |
| 5 | 灯泡电荷走直线而非 filament 折线 |
| 4 缺失资源 | clone 内无 cut/break 音频；未自制替代音 |
| 3 既有工程 | Android Kotlin plugin 未来迁移警告 |
| 1 已处理 | 本 sim 目录内 bug |

## blocked

无用户决策阻塞。
