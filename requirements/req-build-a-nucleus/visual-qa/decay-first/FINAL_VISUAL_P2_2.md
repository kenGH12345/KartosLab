# FINAL-VISUAL-P2-2

> Element / Stability 标签移入 center · 2026-08-31  
> 对照：原版 1024×672；Flutter Pixel Tablet 1280×800 @ DPR 2  
> 归一化：去掉 chrome 后 play 仿射到 1024×618（sx=0.8，sy=618/692，chrome 高 108）

---

## 1. 原版几何（源码，非截图像素）

出处：`DecayScreenView.ts`、`BANConstants.ts`、`ElementNameText.ts`、`StabilityIndicatorText.ts`。

| 项 | 源码 | 含义 |
|---|---|---|
| Half-Life 原点 | `left = minX + X_MARGIN + 30`（45）；`y = minY + Y_MARGIN + 80`（95） | 上半屏；宽由节点自身决定（约 550） |
| Half-Life 冻结中心 X | `halfLifeInformationNodeCenterX = halfLifeInformationNode.centerX` | 箭头移动不带动标签 |
| Unstable / Stable | `center = (halfLifeInformationNodeCenterX, availableDecaysPanel.top)` | **center** 锚点；不是顶栏 |
| 元素名 | `center = stability.center.plusXY(0, 60)` | 同 X，中心距 **60** |
| 核 X | `SCREEN_VIEW_ATOM_CENTER_X = layoutBounds.width / 3` | ≈ 341.3 |
| 核 Y | `height * 0.55` | play 内 ≈ 339.9 |
| 与 Half-Life 关系 | 标签 X = 半衰期块中心，不是核 X | 原版 Δx(标签, 核) ≈ 320−341 ≈ **−21** |
| 与核 Y | 元素名在核上方（stability 再下 60 之后仍高于 atomCenterY） | 垂直另一簇 |

垂直顺序（上→下）：

```text
Half-Life
Unstable / Stable     ← Y = availableDecays.top
元素名                 ← +60（center）
Nucleus
```

内部：Stability **在上**，元素名 **在下**。两者都是独立 Text，无 Panel。

字体/颜色（本阶段只记录）：

| | 原版 | Flutter 当前 |
|---|---|---|
| Stability | `REGULAR_FONT` 20，fill black | 13，`#000000` |
| 元素名 | `REGULAR_FONT` 20，fill `Color.RED` | 16 **bold**，`#FF0000` |

颜色已对齐。[有意差异] 字号/字重 → **P3，不修**。

---

## 2. Flutter 映射

`topCenter` 已空。`center` Column：

```text
HalfLifeInformationView
ElementAndStabilityReadout    // Stability 上、名称下、间距 60
Expanded(canvas + nucleus)
```

- 未改 NineGrid / State / Controller / Painter
- 不用截图绝对偏移
- 水平：`CrossAxisAlignment.center`（标签在中心格水平居中）
- 矮视口（640×360 曾溢出 52px）：剩余高度内 `maxHeight: 40%` + `FittedBox.scaleDown`，不改九宫格行高

`stabilityToNameGap = 60` 来自源码 `plusXY(0, 60)`。Column 把它当 **间隙**，中心距 = 60 + 半高之和 ≈ 81。[有意差异] 未做字高补偿。

---

## 3. Fe-69 复测（逻辑 px，1280×800）

| 控件 | cx | cy | 相对 |
|---|---|---|---|
| halfLifeInformation | 640.0 | 222.3 | 底 y = 284.3 |
| stability | 640.0 | 295.8 | 顶 y = 286.3（数轴下 **+2**） |
| elementName | 640.0 | 376.8 | 在 stability 下 |
| nucleusCenter | 426.7 | 536.3 | 画布 y=390.3，h=265.3 |

同轴（未归一化）：

| | Δx | Δy |
|---|---|---|
| stability − nucleus | **+213.3** | −240.4 |
| elementName − nucleus | **+213.3** | −159.4 |
| elementName − stability（中心） | 0 | **+81.0** |
| stability 顶 − Half-Life 底 | — | **+2.0** |

归一化到 1024×618 后：

| | Flutter play | 原版设计 | 说明 |
|---|---|---|---|
| 标签 cx | 512 | ≈ 320（半衰期中心） | 中心格居中 vs 半衰期块中心 |
| 核 cx | 341.3 | 341.3 | P0 已对齐 |
| 标签 vs 核 Δx | **+170.7** | ≈ −21 | `[有意差异]` 水平居中映射；半衰期现拉满中心格 |

垂直：Half-Life → Unstable → 元素名 → 核，顺序已与原版一致。核 Y 因画布被标签占高而略下移（canvas h 371→265，原点仍是画布高 × 0.55）。

截图已更新：`flutter_decay_empty.png` / `flutter_decay_fe69.png` 及对应 `*_rects.json`。

---

## 4. 本阶段不修

- 标签 X 与核 X 不对齐（中心格居中 vs `width/3`）
- Half-Life 拉满中心格宽
- 中心距 81 vs 源码 60
- 字号 / 字重 / 颜色微调（P3 / P4）
- generator Y、Reset、Checkbox、右栏密度

---

## 5. 回归

- `flutter analyze`：No issues found
- `flutter test test/chemistry/build_a_nucleus`：**407/407**

P2-2 结束。
