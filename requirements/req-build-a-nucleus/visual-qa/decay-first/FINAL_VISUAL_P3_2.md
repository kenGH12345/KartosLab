# FINAL-VISUAL-P3-2

> Decay Screen 局部 Typography · 2026-08-31  
> 未改 Theme / 未打包字体 / 未改 Chart Intro / 未改 Symbol / 未改 Half-Life

Family 全程：**[视觉近似：font family]**（平台默认 + YaHei fallback，不是 Arial）。

截图：`flutter_decay_fe69.png`（1280×800 @ DPR 2）。

---

## 1. 修改清单

| 组件 | 修前 | 修后 | 原版 | Weight |
|---|---|---|---|---|
| Element name | 16 bold | **20 regular** | 20 regular | bold → normal |
| Stability | 13 regular | **20 regular** | 20 regular | 未加粗 |
| Decay title | 20 w600 | **24 regular** | 24 regular | w600 → normal |
| Counters | 12 + FittedBox | **18** + FittedBox | 18 | normal |
| Generator 标签 | 12 | **20** | 20 | normal |

未改：Symbol、Half-Life 读数/刻度/上标、Decay 按钮短符号、全局 Theme。

---

## 2. Fe-69 bbox（逻辑 px · 1280×800）

X 锚未动：Element / Stability **cx = 400**。

| | 修前 | 修后 | Δ |
|---|---|---|---|
| Element | 326.9,365.3 **146×23** cy=376.8 | 308.9,375.3 **182×29** cy=389.8 | w+36 h+6；顶下移 10（Stability 变高 + gap 60） |
| Stability | 347.0,286.3 **106×19** cy=295.8 | 319.0,286.3 **162×29** cy=300.8 | 顶 y **未变**；h+10；cy+5 |
| Decay title 带 | 84.5×**18** | 84.5×**24** | 带宽随字号；窄栏 FittedBox 仍可能压窄字形 |
| Counters（质子行） | ~33×7.6 | ~35×8.3 | 源码 18，边格 FittedBox 缩到 ~8px 高 |
| Generator 标签 | （无独立 key） | 40.5×29 | 字号 20；行盒 29（默认 height） |
| Generator 整组 | 418×55 y=730 bottom=785 | **同** | footer / Y 锚未破 |

Baseline：Stability 顶 y 不变 → 列起点不变。Element 顶 = Stability 底 + 60，随字高下移，不是 X/核锚漂移。

未测 Canvas 与 Arial 的 alphabetic 差（family 未换）。

---

## 3. Overflow / 640×360

- 1280 / 1024 / 640：viewport 测试无 overflow
- Element/Stability 仍在 center 内 `FittedBox.scaleDown`（矮视口 40% 帽）
- Counters 仍 `FittedBox`，右栏父布局未改
- Generator 整组高仍 55（箭头列决定），footer 96、底锚 15 未破
- 无组件因字变大而消失

---

## 4. 分类

- **[可精确修复]** Element / Stability 字号与 weight；Decay title 源码 24 regular
- **[视觉近似：NineGrid]** Counters 18 被边格缩到 ~8px 高；Decay 标题 24 在 ~85 宽栏内 FittedBox
- **[视觉近似：font family]** 全部未指定 Arial
- **[视觉近似：NineGrid]** Generator 标签源码 20 已写入；未为字高抬 footer

---

## 5. 回归

- `flutter analyze`：No issues found
- BAN：**407/407**

停在 P3-2。未进 Chart Intro Typography / Colors / icon。
