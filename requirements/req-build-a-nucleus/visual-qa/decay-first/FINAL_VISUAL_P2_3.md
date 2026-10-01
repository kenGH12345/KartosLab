# FINAL-VISUAL-P2-3

> Element / Stability X anchor · 2026-08-31

---

## 1. 原版 X anchor 来源 [已确认]

`DecayScreenView.ts`：

```
halfLifeInformationNode.left = minX + X_MARGIN + 30   // 15+30
halfLifeInformationNodeCenterX = halfLifeInformationNode.centerX  // 创建时冻结
stability.center = (halfLifeInformationNodeCenterX, availableDecays.top)
elementName.center = stability.center.plusXY(0, 60)
```

| 问题 | 结论 |
|---|---|
| 坐标来源 | 半衰期**整块** `centerX` = left + `numberLineWidth/2` = 45+275 = **320**（LAYOUT_BOUNDS 1024） |
| 是否冻结 | **是**。注释：箭头移动会改 bounds，故创建时拍成常量 |
| 是否等于读数条几何中心 | Decay 屏 `isHalfLifeLabelFixed: true`，读数居中在 **550 轴**上，与块中心重合。**不是** info 缩进后的文字盒 |
| info / inset | 按钮在块**内部**（left+124），不移动冻结中心 |
| Unstable 与 Element | **同一 X** |
| 不同窗口宽 | PhET `LAYOUT_BOUNDS` 固定 1024，窗口只做整体缩放。Flutter play 宽随视口，按 `layoutW/1024` 映射 |

**不等于** `atomCenterX`（width/3 ≈ 341）。未使用 `atomCenterXForLayout`。

## 2. Flutter 原 X 来源

`center` Column `CrossAxisAlignment.center` + 标签 `FittedBox` 居中 → 中心格中线（逻辑 **640**，归一化 **512**）。

半衰期视图拉满中心格，其**盒**中心也是 512。不能拿拉满后的盒中心当原版块中心。本阶段不改 Half-Life 宽度。

## 3. 最小修复

`BanConstants.halfLifeInformationCenterXForLayout(layoutW)`：

`(15 + 30 + 550/2) × (layoutW / 1024)`

中心格局部 X：`playCenter − (layoutW − columnW)/2`。

`_HalfLifeContentXAnchor`：`Transform.translate` + `FractionalTranslation(-0.5, 0)`，父级拉满列宽、`Align.topLeft`。无 `Positioned(left: 固定像素)`。

## 4–6. 复测（Fe-69 · 1280×800 逻辑 / 归一化 1024×618）

| | 修前逻辑 cx | 修后逻辑 cx | 归一化 cx | 对原版 320 Δcx | 逻辑 cy |
|---|---:|---:|---:|---:|---:|
| Element | 640 | **400.0** | **320.0** | **0.0**（修前 +192） | 376.8 **未变** |
| Unstable | 640 | **400.0** | **320.0** | **0.0**（修前 +192） | 295.8 **未变** |
| nucleus | 426.7 | 426.7 | 341.3 | 0（resolved） | 536.3 **未变** |
| Half-Life 盒 | 640 | 640 | 512 | —（有意差异：拉满） | 222.3 **未变** |
| Half-Life 读数盒 | 526.2 | 526.2 | 420.9 | — 未当 anchor | 未变 |

用户表 Δx +203.5 / +204.6 是修前左缘。中心 Δcx 修前 +192 → 修后 **0**。

Half-Life 宽、nucleus、generator、右栏未改。

## 7. 视口 / 测试

- 640×360 / 1024×768 / 1280×800：无 overflow
- `flutter analyze`：No issues found
- BAN：**407/407**

## 8. 标记

- [已确认] 冻结块中心公式；两标签同 X；Y 未因本次改动变化
- [有意差异] Flutter 数轴仍拉满中心格；读数盒因 info inset 不在 400
- [视觉近似] 字号未动（P3）
- [待确认] 无

停在 P2-3。
