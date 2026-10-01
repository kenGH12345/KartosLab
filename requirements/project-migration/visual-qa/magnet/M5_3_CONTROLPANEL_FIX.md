# MAGNET M5-3 · ControlPanel Visual / Responsive Fix

> 日期：2026-08-31  
> 范围：**只修右上浮动 ControlPanel**  
> 未改：NineGrid / Canvas 映射 / Magnet / Compass / FieldMeter / Reset / MagneticField / Theme / Home / Earth

---

## 0. 结论

55px overflow **不是 Slider**。[已确认]

修前（Pixel Tablet 1280×800，卡片内宽 208）：

| Child | Width | Available | Overflow |
|---|---:|---:|---:|
| Slider（含 Expanded） | **164** | 208 − 44（双箭头）= **164** | **0** |
| `_arrowBtn` ×2 | 22+22=44 | 44 | 0 |
| Strength: + 75% 徽章 | 上一行 | 208 | 0 |
| 0% / 50% / 100% | Spacer 行 | 208 | 0 |
| See Inside | 132.5 + 24 | 208 | 0 |
| Earth | 短 | 208 | 0 |
| Compass / Field Meter 行 | Expanded 文本 | 208 | 0 |
| **`Magnetic Field (B)` 整行** | 20+4+**238.5** = **262.5** | **208** | **54.5 ≈ 55** |

`_check()` 把长标签放在非 flex `Text` 里。原版同源，debug 同样 `overflowed by 55 pixels`。

修复：该行 `Expanded` + `FittedBox(scaleDown)`。面板仍 **宽 230、center 内 `top:12, right:12`**。Flutter debug overflow：**0**。Slider 仍可拖、可步进。

---

## 1. 原版 ControlPanel geometry

A `phet/.../main.dart` `_ControlPanel` 与 B `simulations/magnet_and_compass.dart` 结构相同。[已确认]

| 项 | 值 |
|---|---|
| 锚点 | 全屏 Stack `Positioned(top: 12, right: 12)` |
| 宽 | **230**（`SizedBox`） |
| 高 | 内容决定 · 本视口 **298** |
| 卡片 | `#f0f4f8` · radius 10 · border grey 1 · padding **all 10** · shadow |
| 卡片内宽 | 230 − 20 − 2 = **208** |
| Strength 行 | 标签 12px + 间距 6 + 白底徽章 |
| 刻度 | 上一行 `0% / 50% / 100%` font 9 · Spacer |
| Slider 行 | 箭头 22 + `Expanded(Slider)` + 箭头 22 |
| Slider | `onChanged` · **无 divisions** · min 0 max 1（`strength`） |
| SliderTheme | trackHeight 3 · thumb radius 7 · `noOverlay` |
| checkbox 行 | 20×20 shrinkWrap + 间距 4 + **裸 Text 13**（无 Expanded） |
| Flip | 满宽 ElevatedButton padding 垂直 6 |
| 第二卡片 | Compass / Field Meter · 文本已 `Expanded` |
| footer / 边格 | **无** |

原版 **没有**单独的 slider 宽度常量；track 吃 `Expanded` 剩余。本 SDK 上剩余 164，Slider 实际也是 164。

---

## 2. Flutter geometry（M5-3 后 · 1280×800）

仍在 NineGrid **center** 内浮动，不是 footer、不是边格。

| | Original 窗口 | Flutter 窗口 | 说明 |
|---|---|---|---|
| Panel | (1038, 12) 230×298 | **(933.5, 117.7) 230×298** | 相对 center `top:12, right:12` |
| Slider | 164×14 | 164×14 | 未改 |
| Magnetic Field 标签 | 238.5（溢出卡片） | **184**（scaleDown） | 仅此条缩小 |
| See Inside | 132.5 | 132.5 | 短标签仍 13px |
| 标题 Bar Magnet | 14px | 14px | 未改 |

相对 canvas：`top = canvas.top+12`，`right = canvas.right−12`。[已确认] 测试 1280 / 1024 / 640。

窗口位置与原版不同是 AppBar+NineGrid。[有意差异：NineGrid]  
不要求与原版像素重合。

---

## 3. Overflow 根因

M4-1 曾把 55px 算成「Slider minWidth ≈ 219」。M5-3 实测否定：

- 异常：`A RenderFlex overflowed by 55 pixels on the right.`
- Slider `w=164` = 正好是行剩余
- `Magnetic Field (B)` intrinsic **238.5**；行需求 262.5；内宽 208；**262.5−208=54.5**

[已确认] 源码：`_check` 的 `Text` 无 `Expanded`。Compass 行反而有 Expanded，所以不溢。

---

## 4. 修复方案

优先级：宽 230 → 右上浮动 → 相对比例 → 消 Flutter overflow。

**只改** `lib/magnetism/magnet_and_compass/widgets/control_panel.dart` 的 `_check`：

```dart
Expanded(
  child: FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(label, style: TextStyle(..., fontSize: 13)),
  ),
)
```

- 短标签（See Inside / Earth）不缩放
- 长标签缩到内宽 184
- 未扩面板、未改 padding、未改 Slider API、未换 KratosSlider、未动 Theme

Slider 行保持原 `Expanded` + `SliderTheme.padding: zero`。不必 `year2023: false`。

---

## 5. 修前 / 修后 bounds

| | 修前 | 修后 |
|---|---|---|
| Panel | 230×298 · center 右上 | **同** |
| 锚点 | Positioned top 12 right 12 | **同** |
| Slider | 164×14 | **同** |
| Magnetic Field 文本宽 | 238.5 | 184 |
| debug overflow | 55px | **0** |
| 原版 overflow | 仍 55px（未改 phet / Legacy） | — |

---

## 6. Slider behavior

| 项 | 状态 |
|---|---|
| 拖动 `onChanged` | 保持 · widget 测试 `drag` 后不再停在 75% |
| min / max | 0…1（`strength`） |
| value | `state.strength` |
| divisions | 原版 **无** · 未加 |
| 箭头 ±0.05 | 保持 |
| Reset 回到 75% | 保持 |

[视觉近似：Material] thumb / track 仍是 Material Slider，不是 PhET Sun。未引入完整控件体系。

---

## 7. Material differences

- Theme：Kratos M3 light vs 原版 `ThemeData.dark()`（卡片本身仍是浅底）
- Checkbox / Slider 外观：[视觉近似：Material]
- 长标签略缩小：[工程差异] 为消 overflow，不是 NineGrid 强迫改 padding

---

## 8. Responsive

| 视口 | overflow | 宽 230 | 右上锚 | 备注 |
|---|---|---|---|---|
| 1280×800 | 0 | ✓ | center+12 | 主 QA |
| 1024×768 | 0 | ✓ | center+12 | |
| 640×360 | 0 | ✓ | center+12 | 面板高 298 > center 高 ≈220，画出格外；**允许紧张**，未重排页面 |

640 上磁铁 500 与 230 面板重叠更重，属固定尺寸+小屏，本阶段不重排。[待确认] 若产品要小屏可用性再开阶段。

---

## 9. Tests

```
flutter test test/magnetism     → 31 passed
  （原 26 全过；新增 3 视口 + slider + lifecycle = 5）
flutter test test/chemistry/build_a_nucleus → 407 passed
flutter analyze lib/magnetism/magnet_and_compass test/magnetism → No issues
```

`magnet_screen_test` 不再吞 overflow，改为 `_expectNoOverflow`。

新增 `test/magnetism/control_panel_layout_test.dart`：

- 三视口 0 overflow
- panel 宽 230、相对 canvas 右上
- slider 可拖、箭头、Reset
- 隐藏 Compass 后面板仍在

---

## 10–13. 分类

| 项 | 标签 |
|---|---|
| 55px = Magnetic Field (B) 行，不是 Slider | `[已确认]` |
| 修后 Flutter 0 overflow；宽 230；右上浮动 | `[已确认]` |
| Slider 交互语义 | `[已确认]` |
| thumb/track Material vs 原版 | `[视觉近似：Material]` |
| 面板窗口坐标因 AppBar+NineGrid | `[有意差异：NineGrid]` |
| 长标签 scaleDown | `[视觉近似]`（比例在 230 内） |
| 640 面板高出 center | `[待确认]` 产品小屏策略；本阶段允许 |
| Earth | `[无法验证：missing earth.svg]` · 未勾选 |

---

## 截图

`requirements/project-migration/visual-qa/magnet/m5-3/screenshots/`

- `flutter_default.png` / `original_default.png`
- `flutter_control_panel.png` / `original_control_panel.png`

`m5-3/rects.json`：`overflow.flutter == []`，原版仍 55px。

---

## 停止

**M5-3 完成。停止。**

不处理 FieldMeter、Reset、Typography、Colors、Earth、Home、Legacy。
