# FINAL-VISUAL-P2-4

> Available Decays 内部视觉密度 · 2026-08-31

---

## 1. 原版取证 [已确认]

仓库中**没有**独立的 `DecayTypeListNode` / `DecayButton` 类。
结构在 `js/decay/view/AvailableDecaysPanel.ts`：

```
Panel
  VBox(spacing 10)
    HBox(title PhetFont(24) + InfoButton, spacing 15)
    VBox(5 × (RectangularPushButton + IconFactory.createDecayIcon), spacing 10, align left)
    HSeparator
    粒子图例 HBox
```

| 项 | 源码 |
|---|---|
| 键数 | 5（`BANDecayType.enumeration.values`） |
| 键内容区 | **145×35**，`yMargin: 0` |
| 键文案 | **全名**（Alpha Decay…），`PhetFont(18)` |
| 旁图标 | `createDecayIcon`，HBox spacing 15 |
| 行距 / title→键 | **10** |
| Panel | `x/yMargin: 15`，`minWidth: 322`，`cornerRadius: 6`，fill `#F2F2F2`，stroke GRAY |
| disabled | `enabledProperty` → sun 灰显 |
| hover/pressed | sun `RectangularPushButton` 默认 |
| 自适应 | **是**，内容撑开（另含图例） |
| Undo | **面板外**左侧（`undo.right = panel.left - 10`） |

`BANDecayType.decaySymbol`：α / β / β / p / n。原版按钮写全名，符号在旁侧示意图。

---

## 2. 工程约束（未改）

NineGrid / midRight / Stage / nucleus / generator / Half-Life **未改**。

1280×800 逻辑：`midRight` **104.5×495**。原版 panel **minWidth 322** 装不下图例、全名、示意图。

---

## 3. 本次改动（只视觉）

新组件 `lib/chemistry/build_a_nucleus/widgets/available_decays_panel.dart`。

- 矩形键，高 **35**（矮视口先压 spacing，再压高，下限 20）
- 行距 / title→键 **10**
- 符号 α / β- / β+ / p / n，字号随键高（1280 约 19）
- 标题 `FittedBox.scaleDown`（目标 20，左对齐），**不**整板缩放
- Panel：`#F2F2F2` + GRAY 边 + radius 6；padding 6（宽不足时 4）
- `Align` 松开 Expanded 紧约束 → **按内容收缩**
- 启用橙 `#FBB240`；禁用同色 35% 透明
- 业务 / Undo 逻辑 / keys 未改

---

## 4. Fe-69 复测（1280×800 逻辑）

| | 修前 | 修后 | 原版 |
|---|---:|---:|---|
| panel | （无独立盒，48 圆钮） | **96.5 × 255** | 322 × ~360（含图例） |
| title 带 | FittedBox 11 | **84.5 × 18** | PhetFont 24 + Info |
| 每键 | **48×48** 圆 | **84.5 × 35** 矩形 | 145×35 + 图标 |
| 键间距 | 4（padding 2+2） | **10.0** | **10** |
| title→α | 紧贴 | **10.0** | **10** |
| 符号 | 默认 Icon 字 | ~19 bold | 全名 18 + 示意图 |
| midRight | 104.5 | **104.5 未变** | — |
| nucleus cx | 426.7 | **426.7 未变** | 341.3 归一化 |
| Element / Unstable cx | 400 | **400 未变** | 320 归一化 |
| generator cx | 426.7 | **426.7 未变** | — |

截图：`flutter_decay_fe69.png`。

---

## 5. 视口

| 视口 | 结果 |
|---|---|
| 1280×800 | 键 35、间距 10，无 overflow |
| 1024×768 | 同结构，无 overflow |
| 640×360 | 内部压缩 / 必要时滚动；无 overflow、无负尺寸、标题与键可辨 |

---

## 6. 分类

- **[已对齐]** 键高 35；键间距 10；title→键 10；五键左对齐竖排；启用橙色
- **[视觉近似]** 标题（窄栏 FittedBox，无 Info）；短符号代替全名；禁用淡橙（非 sun 灰）；hover/pressed 用 Material splash
- **[有意差异：NineGrid]** panel 宽 96 ≪ 322；无旁侧 decay icon、分隔线、粒子图例；Undo 仍在板内（边格不够外置）；padding 6 ≪ 15

---

## 7. 回归

- `flutter analyze`：No issues found
- BAN：**407/407**

未改 Reset / Electron Cloud / Generator Y / Typography 体系 / 全局 Colors。

停在 P2-4。
