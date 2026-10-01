# GEOMETRY_CALIBRATION · Normal Modes Visual QA

> 日期：2026-09-03  
> 范围：PAGE LAYOUT / VIEWPORT / PANEL ANCHOR / RESPONSIVE GEOMETRY  
> **不改**：Model / Solver / State ownership / 频率 / Verlet / 动画语义  

比较方法：不直接比截图绝对像素（四张图 viewport 不同）。使用归一化坐标：

```
x_norm = x / viewportWidth
y_norm = y / viewportHeight
```

Flutter 再生成截图（widget test · `1280×800` · DPR=1）：

- `screenshots/flutter-one-dimension.png`
- `screenshots/flutter-two-dimensions.png`

原版图 1/2 由用户提供对照；磁盘上未另存 PhET PNG 时，原版 rect 取用户标注 + ScreenView 逻辑锚点。

---

## 0. 修复摘要（本轮）

| ID | 问题 | 修复方式 |
|---|---|---|
| P0 | Stack + 多个 `Positioned` 抢同一空间 → panel 覆盖 sim | `NmPageMetrics` + `SimulationViewport` + `ControlColumn` 兄弟列 |
| P0-2D | Amplitudes 从右向左侵入 grid | 2D：`Row(Expanded(sim), ControlColumn(control+amplitudes+reset))` |
| P1-1D | Spectrum 过宽侵入右列 | 1D：`Row( Column(sim, spectrum), ControlColumn )` — Spectrum 仅左列底部 |
| P1 | 禁止 `left: 270` / `top: 96` 截图像素硬编码 | `availableWidth/Height`、`rightPanelWidth`、`bottomPanelHeight` 推导 |
| P2 | App chrome | 保留 KARTOSLAB AppBar/Tabs；sim 只用 NineGrid center 剩余空间 |
| P3 | mass / spring / grid 微调 | **本轮不做**（viewport 先过） |

断言：`test/normal_modes/layout_viewport_test.dart`（无 overlap；Spectrum.right ≤ Control.left）。

---

## 1. Flutter 页面几何公式

实现：`lib/normal_modes/widgets/nm_page_shell.dart`

### 1.1 One Dimension

```
rightPanelWidth  = clamp(W * 0.26, 220, 280)
bottomPanelHeight = clamp(H * 0.36, 160, 280)
simViewportWidth  = W - rightPanelWidth
simViewportHeight = H - bottomPanelHeight
```

逻辑 play 裁剪：宽 `1024−250`，高 `618−280`（左上裁切进 `SimulationViewport`）。

### 1.2 Two Dimensions

```
rightPanelWidth   = clamp(W * 0.32, 300, 380)
bottomPanelHeight = 0
simViewportWidth  = W - rightPanelWidth
simViewportHeight = H
```

逻辑 play 裁剪：宽 `1024−420`（`twoDRightReserve`），高 `618`。

---

## 2. One Dimension · 归一化对照

参考 viewport（Flutter capture）：**1280 × 800**

| 区域 | 原版（用户图1 + 逻辑锚点） | Flutter rect (px) | Flutter norm | 原版 norm（估） | Δ norm | 状态 |
|---|---|---|---|---|---|---|
| SimulationViewport | 左主区；墙右缘≈759/1024 | `[0,0]–[1000,520]`* | x0–0.781 · y0–0.650 | ~x0–0.74 · y0–0.55 | ≤0.08 | **[视觉近似]** |
| left wall | 逻辑 x≈14 | 落在 sim 内 local | — | — | — | local MVT 未改 |
| right wall | 逻辑 x≈759 | 落在 sim 内 local | — | — | — | local MVT 未改 |
| masses | 墙间 20×20 | local | — | — | — | P3 再校 |
| ControlColumn | 右独立列 | `[1000,0]–[1280,800]`* | x0.781–1 · y0–1 | ~x0.75–0.99 | ≤0.05 | **[视觉已对齐]** 列分离 |
| BottomSpectrum | 底中央；不盖右列 | `[0,520]–[1000,800]`* | x0–0.781 · y0.650–1 | 底中、宽≈play | ≈0 | **[视觉已对齐]** 不侵入右列 |

\* 由 `NmPageMetrics.oneDimension(1280×800)`：`right=280`，`bottom=280`。含 NineGrid/padding 时实测略内缩；以 layout test `getRect` 无 overlap 为准。

### 修复记录

1. **Spectrum 侵入右列** → 改为左列 `Column(sim, spectrum)` + 右列全高 `ControlColumn`。  
2. **不再 Stack 叠 panel**。

---

## 3. Two Dimensions · 归一化对照

参考 viewport（Flutter capture）：**1280 × 800**  
用户原版标注（其截图像素）：grid 右缘 **x≈986**，Amplitudes 左缘 **x≈999** → 明确列间隙。

| 区域 | 原版 | Flutter rect (px)* | Flutter norm | 原版 norm（若 VW≈1280） | Δ | 状态 |
|---|---|---|---|---|---|---|
| SimulationViewport / grid bounds | 左近方；右缘≈986 | `[0,0]–[900,800]` | x0–0.703 · y0–1 | x_right≈0.770 | ~0.07 | **[视觉近似]** 列内再校 scale 属 P3 |
| ControlColumn | 右独立 | `[900,0]–[1280,800]` | x0.703–1 | x_left≈0.780 | ~0.08 | **[视觉已对齐]** 不重叠 |
| Amplitudes panel | 右列内；左≈999 | 完全落在 ControlColumn | ≥ play.right | ≥0.780 | — | **[视觉已对齐]** P0 已修 |
| Reset | 右列底部 | ControlColumn 内 | — | — | — | **[视觉近似]** |
| Control anchors | 右上 panel | ControlColumn 顶部 | — | — | — | **[视觉近似]** |

\* `NmPageMetrics.twoDimensions(1280×800)`：`right=380`，`simW=900`。

### 修复记录

1. **Amplitudes 覆盖 grid（图4）** → 取消 Positioned 叠层；Amplitudes 仅作 `ControlColumn` 子项。  
2. 逻辑右保留仍用 PhET `twoDRightReserve=420` 裁切 play canvas。

---

## 4. Overlap / Clipping 检查清单

| 检查项 | 1D | 2D |
|---|---|---|
| panel overlap simulation | 否 | 否 |
| spectrum / amplitudes overlap control sibling incorrectly | 否 | 否 |
| unintended full-bleed compression of grid under panel | 否 | 否 |
| clipping of play（ClipRect 仅裁逻辑右/底预留） | 预期 | 预期 |

测试：

```
flutter test test/normal_modes/layout_viewport_test.dart
```

---

## 5. 下一步（本轮之后）

进入 **typography / micro geometry（P3）** 前确认：

- [ ] 用户在真实设备/模拟器上目视确认无 panel 覆盖  
- [ ] mass size / spring thickness / wall / grid / panel padding / spectrum cells  
- [ ] 将用户图1–4 落盘到 `visual-qa/screenshots/phet-*.png` 以便精确 Δ 表  

**禁止**在未确认 viewport 前改 Model/Solver。
