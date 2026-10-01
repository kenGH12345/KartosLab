# Runtime Acceptance · Density

> 实机/运行时逐项验收清单。每项：**操作 → 期望（PhET 源码）→ 通过/备注**。

## 0. 前置

- [ ] `flutter run -d windows`（或目标设备）进入 Home → **密度与浮力** → **密度**
- [ ] Intro 六材料块正面显示 **JPEG 贴图**（非纯色）；Custom 仍为渐变/纯色
- [ ] `flutter analyze lib/density` 0 issues；`flutter test test/density` 全绿

---

## 1. Intro

| # | 操作 | 期望 | ✓ |
|---|---|---|---|
| 1.1 | 默认 One Block | 仅块 A；Wood 2.00 kg；V=0.005 m³；位置约 (-0.2, 0.2) | |
| 1.2 | Two Blocks | 出现块 B；Aluminum 13.50 kg；同体积 0.005 m³ | |
| 1.3 | 材料 Wood→Ice | 质量/密度联动；体积不变；贴图切换 | |
| 1.4 | 质量滑块 A | 范围随材料；ρ=m/V 读数一致 | |
| 1.5 | 体积滑块 | 1–10 L；立方体尺寸变化 | |
| 1.6 | Custom + 密度 | 自定义密度；Intro max custom mass 10 kg | |
| 1.7 | 拖 A 入池 | 跟手（非瞬移）；Wood 浮、Al 沉 | |
| 1.8 | 拖 B 与 A 碰撞 | 块分离、不穿透；restitution≈0 | |
| 1.9 | 池壁/屏障 | 不能穿出 ±0.875；池内不能穿侧壁 | |
| 1.10 | Reset All | 回到 One Block 默认 | |

---

## 2. Compare

| # | 操作 | 期望 | ✓ |
|---|---|---|---|
| 2.1 | Same Mass 默认 | 5 kg 三套块；仅 sameMass 可见 | |
| 2.2 | Same Volume | 0.005 m³ 锁定；切换可见集 | |
| 2.3 | Same Density | 密度 500（100–2000）；块颜色/尺寸符合约束 | |
| 2.4 | 质量/体积/密度控件 | 仅当前模式对应滑块生效 | |
| 2.5 | 拖拽 | 三模式块可拖；浮力行为正确 | |
| 2.6 | Reset | 回到 Same Mass 5 kg | |

---

## 3. Mystery + Density Table

| # | 操作 | 期望 | ✓ |
|---|---|---|---|
| 3.1 | Set 1 | 5 块标签 1A–1E；默认无质量标签 | |
| 3.2 | Set 2 | 2A 密度 **11340**（非 Lead 11342） | |
| 3.3 | Set 3 / Random | 块集切换；Random 可刷新 | |
| 3.4 | 秤 | 块放秤上读数 = 块质量（抓取中不计） | |
| 3.5 | Mass labels 开关 | 显示/隐藏 kg 标签 | |
| 3.6 | Density Table | 展开 13 行；按密度 kg/L 升序 | |
| 3.7 | 屏间隔离 | 切 Intro/Compare 不污染 Mystery 状态 | |

---

## 4. 手感（拖拽 / 碰撞 / 边界）

| # | 检查点 | 期望 | ✓ |
|---|---|---|---|
| 4.1 | 抓取 offset | 块略抬 0.0001 m（防秤误读） | |
| 4.2 | 指针力 | 弹簧-阻尼跟手；maxForce≈2500 | |
| 4.3 | 块-块 | AABB 分离；允许 slip 0.01 | |
| 4.4 | 地面/池底 | 池内 poolMinY；池外 y=0 | |
| 4.5 | 天花板 | y≤4 | |

---

## 5. 非首要（本期不做）

- 键盘帮助对话框
- PhET-iO / Studio API
- 抓放音效（common 无 mp3）
- THREE PBR normal/metalness/roughness

---

*更新：2026-09-02 · Loop7 材质提取 + 物理手感 + 验收清单*
