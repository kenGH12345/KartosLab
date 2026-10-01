# FINAL-VISUAL-P2-5

> Generator Y + Width · 2026-08-31

---

## 1. 原版取证 [已确认]

`BANScreenView.ts`：

```
nucleonCreatorsNode.centerX = atomCenter.x          // width/3
nucleonCreatorsNode.bottom  = layoutBounds.maxY - SCREEN_VIEW_Y_MARGIN  // 618−15 = 603
```

`NucleonCreatorsNode` 是 HBox：

| 项 | 源码 |
|---|---|
| 结构 | protonArrows \| proton+label \| doubleArrows \| neutron+label \| neutronArrows |
| HBox | `align: 'bottom'`，`spacing: 5`，`stretch: true` |
| 生成器列 | `minContentWidth: 150`（`MAX_TEXT_WIDTH`） |
| 球 | `PARTICLE_DIAMETER` = 20 |
| 标签 | `PhetFont(20)`，maxWidth 150 |
| 箭头 VBox | spacing **7** |
| 箭头 glyph | 14×14 |
| 双箭头钮 | `xMargin: 7`，`yMargin: 5` → 约 42×24 |
| 固定宽？ | 否，内容撑开（两列至少 150） |
| 窗口缩放 | ScreenView 把 1024×618 整体仿射；坐标在 LAYOUT_BOUNDS 内 |

截图框（1024×672 页 / play 618）：`generator_design` **161.3, 513, 360×90**，cx=341.3，cy=558，bottom=603。360 是截图外包，略小于源码 150+150+箭头+4×5。

---

## 2. Flutter footer（未改 NineGrid）

1280×800、chrome 108、play 高 692。

`footerH = min(96, playH×0.16) = 96`。footer 底 = 视口底 = play 底。

Y 语义：`generator.bottom = footer.bottom − SCREEN_VIEW_Y_MARGIN`。
子级 `maxHeight = footerH − 15`，装不下才 `FittedBox.scaleDown`。

X 仍为 `atomCenterXForLayout`，未改。

---

## 3. 本次改动

- `_GeneratorAnchorDelegate`：X 不变；Y 底锚 15，不再垂直居中
- 生成器列宽 **150**；HBox 间距 **5**；球直径 **20**
- 单箭头钮 **28×24**，双箭头 **42×24**，列距 **7**
- `crossAxisAlignment: end`（HBox `align: 'bottom'`）
- 未改 NineGrid / footer 行高 / nucleus / Half-Life / 右栏 / Reset / Electron Cloud / State / Controller

---

## 4. Fe-69 复测（1280×800 → 仿射 1024×618）

`sx=0.8`，`sy=618/692`，去掉 chrome 108。

| | 修前逻辑 | 修后逻辑 | 仿射后 | 原版 | Δ |
|---|---:|---:|---:|---:|---:|
| centerX | 426.7 | **426.7** | **341.3** | 341.3 | **Δcx = 0** |
| bottom | 795.5（居中） | **785** | **604.6** | 603 | **+1.6**（对齐底锚） |
| centerY | 752 | 757.5 | 580.0 | 558 | +22（高更矮） |
| width | 169 | **418** | 334.4 | 360（截图） | 源码 150+150+箭头≈418 |
| height | 87 | **55** | 49.1 | 90 | 见下 |

内部（逻辑 px，未缩放）：

| | 修后 | 原版 |
|---|---:|---|
| 键间距（竖） | **7** | **7** |
| 组间距 | **5**（列间 5+150+5=160） | **5** |
| 单箭头 | **28×24** | 14+边距 |
| 双箭头 | **42×24** | 14×2+`xMargin` 7 |
| 生成器列 | **150** | **150** |

nucleus / Element·Stability / Half-Life / Available Decays **未变**。

---

## 5. 视口

640×360 / 1024×768 / 1280×800：无 overflow。矮 footer 时先扣 15 再 scaleDown。

---

## 6. 分类

- **[已对齐]** X（Δcx=0）；bottom = play 底 − 15（仿射 Δ+1.6）；组间距 5；箭头列距 7；列 minWidth 150；球直径 20；双箭头更宽
- **[视觉近似]** 整组高 55 vs 截图 90（标签仍 12，未进 Typography）；截图宽 360 vs 源码结构 418
- **[有意差异：NineGrid]** footer 封顶 96，装不下原版 90+15；不升高 footer

---

## 7. 回归

- `flutter analyze`：No issues found
- BAN：**407/407**

未进 Typography / Colors / Reset / Electron Cloud。

停在 P2-5。
