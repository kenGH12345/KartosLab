# PHASE 5 — Visual QA（Projectile Motion）

日期：2026-09-15
状态：PASS（含已记录版本差异；第二轮 capture 已替换过时截图）

## 方法

- ORIGINAL：Playwright 发布版 `projectile-motion_all.html?screens=N`（1280×800，DPR 1），
  20 状态，`tool/capture_projectile_original.js`。
- FLUTTER：widget test `RepaintBoundary.toImage`，同 20 状态，
  `test/projectile_motion/projectile_visual_qa_capture_test.dart`（加载 Arial/Trebuchet）。
- 对齐：发布版 joist scale ≈ 1.1918，FLUTTER 同 scale 居中顶对齐到 1280×800 黑底。
- manifest：`tool/build_visual_manifest_projectile.py`。

Smoke：`ORIGINAL/smoke_test.png`、`FLUTTER/smoke_test.png`（= 01_Intro_initial）。

## 版本差异（发布版 1.0.34 vs 本地 1.1.0-dev.41）

Flutter **跟随本地源码**。整帧 diff% 含这些预期差，不能当收敛目标：

| # | 发布版 1.0.34 | 本地 1.1.0-dev.41 / Flutter |
|---|---|---|
| V1 | 底栏水平居中；无独立 Angle 面板 | 左锚定 + Initial Speed **与** Angle 面板（ScreenView:235-250） |
| V2 | 炮管视觉更大 | `s = modelToViewDeltaX(4)/275 = 0.4364` |
| V3 | 圆柱更靠原点 | `CYLINDER_DISTANCE_FROM_ORIGIN = 1.3` |
| V4 | david 略埋入路面 | `davidPosition=(7,0)` bottom=ground |
| V5 | 炮口绿色 "0" 圆徽 | 源码无此节点 |
| V6 | 淡色预览抛物线 | 源码无预览轨迹 |
| V7 | 无 Stats 屏 | 源码 `stats/` 未挂入 `projectile-motion-main.ts` → 4 屏 |

## 第二轮相对第一轮

| 指标（01_Intro_initial） | 第一轮 | 第二轮 |
|---|---|---|
| mean_abs_diff | 39.99 | **27.65** |
| pct_pixels_changed | 81.8 | **71.32** |
| pct_pixels_delta_gt32 | 30.13 | **18.16** |

根因修复：圆柱弧方向、Ahem 字体黑块、面板米色、Fire PNG、向量色、Zoom 横向。

## 区域判读

- 场景几何（天/草/路/虚线/圆柱/炮/david/靶）：[布局已对齐]（除 V2/V3/V4）
- 轨迹 02/08/12/16：折线+点阵+抛体=最新点 [动态绘制已对齐]
- 工具 05/19：卷尺与探针结构 [原版资源一致]
- 资源：全部原版 PNG，Substituted = 0 [原版资源一致]

## P2 余项

- 字体度量（Arial vs PhET PhetFont/Trebuchet）
- 发布版 navbar / 缩放外壳 vs KartosLab FittedBox
- Lab Keypad 未做
- 探针读数未做成独立右对齐盒
- capture 用例在 PNG 落盘后 TimeoutException（FakeAsync，**不进入 unit-test gate**）
