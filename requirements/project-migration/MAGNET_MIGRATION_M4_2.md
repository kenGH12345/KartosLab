# MAGNET MIGRATION M4-2 · Screen Layout Migration

> 日期：2026-08-31
> 依据：M4-1 审计 + 用户批准方案 A（右上浮动 ControlPanel）+ AppBar + NineGrid
> 本阶段未改：MagneticField / Painter 几何 / Earth SVG / Electromagnet / Home / Legacy 删除

---

## 落地结构

```
Scaffold
├── AppBar          back（Navigator 自动）+ title「磁铁与罗盘」
└── NineGridLayout
    ├── center: LayoutBuilder → Stack
    │     ├── FieldNeedlePainter (Positioned.fill)
    │     ├── magnet | earth
    │     ├── compass
    │     ├── field meter
    │     └── MagnetControlPanel  Positioned(top:12, right:12)   ← 方案 A
    └── bottomRight: Reset（原 52px 橙钮）
```

- ControlPanel **不在** AppBar，**不在** footer，**不在** NineGrid 边格。
- Canvas 内部对象仍用 `Stack` + `Positioned` + `CustomPainter`。
- init / reset / clamp 使用 **center LayoutBuilder size**，不再用全屏 `MediaQuery`。

---

## 改动文件

| 文件 | 内容 |
|---|---|
| `screens/magnet_and_compass_screen.dart` | AppBar + NineGrid + canvas 坐标 |
| `widgets/control_panel.dart` | `SliderTheme.padding: EdgeInsets.zero`（未消除 55px overflow） |
| `test/magnetism/magnet_screen_test.dart` | 断言 AppBar/NineGrid；clamp 相对 canvas |

---

## Slider overflow

仍为原 B：卡片内宽 208，Slider 行需求 ~263，**overflow ~55px**。  
`padding: EdgeInsets.zero` 不够。FittedBox / OverflowBox 无法在不改 230 宽或不用自定义 track 的前提下消掉 debug overflow。

**保持 230 浮动面板**（批准约束）。测试继续吞该已知 overflow。完整压缩属后续，非本页重构阻塞。

---

## 验证

```
flutter analyze lib/magnetism/magnet_and_compass test/magnetism  → 0 issue
flutter test test/magnetism                                     → 19 passed
flutter test test/chemistry/build_a_nucleus                     → 407 passed
```

---

## 未做

- 接 Home
- earth.svg
- Electromagnet
- 删 Legacy
- Visual QA / 调色 / 改 Painter
- footer 方案 B

Earth rendering path remains blocked by missing earth.svg.  
Electromagnet remains BLOCKED.
