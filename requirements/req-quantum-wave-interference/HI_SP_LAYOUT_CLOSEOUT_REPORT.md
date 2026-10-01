# HI / SP Layout Closeout Report · Quantum Wave Interference

**日期**：2026-09-29  
**范围**：High Intensity + Single Particles 布局对齐原版 + Tab 切换渐变  
**状态**：**PASS**（布局收口）· Overall = ready_candidate（数值/视觉 golden 矩阵未本轮重跑）

---

## Summary

按用户提供的原版截图，完成 HI/SP 三栏布局收口：右栏顺序、波区尺寸与缝控位置、粒子选择器 2×2 左下锚点；并修复全局 `KratosTabSwitcher` 切页闪白，改为交叉渐出/渐入。

视觉判定：
- `[布局已对齐]` 右栏 Wave Display → Screen → Tools；Configuration | Slit Separation 横排贴波区下
- `[布局已对齐]` 粒子选择器固定 2×2，落在左栏下方空白
- `[动态绘制已对齐]` 未本轮改 WaveKernel / barrier chrome 几何

---

## Changes

### 1. Layout（HI / SP）

| Item | Before | After |
|------|--------|-------|
| 右栏顺序 | 曾按 Screen→Tools→WaveDisplay / 底锚 Wave | **Wave Display → Screen → Tools**（原版自上而下） |
| 波区显示 | 偏大导致右栏挤压 | **360 × 330**（留缝控行 + 右栏间隙） |
| 缝控 | 位置曾与 chrome 争抢 | **Configuration \| Slit Separation** 横排，`wave.bottom + 8` |
| 边距 / 右栏宽 | — | margin 15 · right 180 · left/right gap 12/14 |
| 粒子选择器 | `Wrap` + `FittedBox` → 缩成 **1×4** 横排 | 强制 **2×2**；锚在左栏 **底部空白** |
| SP emitter | 受 radios.bottom 顶推 | 波区中线，且 **高于** 底部 radios |

关键文件：
- `lib/.../view/layout/high_intensity_layout_spec.dart` / `_composer.dart`
- `lib/.../view/layout/single_particles_layout_spec.dart` / `_composer.dart`
- `lib/.../view/common/qwi_particle_selector.dart`
- `lib/.../view/high_intensity/high_intensity_controls.dart`（HiSlitControls 横排）

### 2. Tab 切换动画（全局）

| Item | Before | After |
|------|--------|-------|
| `KratosTabSwitcher` | 新页淡入、旧页保持不透明；易闪白 | **旧页渐出 + 新页渐入**（`AnimationController` 交叉淡化） |
| 底色 | 无 | `backdropColor` 垫底，半透明时不露 Scaffold 白底 |
| 默认时长 | 373 ms | **280 ms** · `Curves.easeInOut` |

文件：`lib/common/widgets/kratos_tab_bar.dart`（影响所有使用该 Switcher 的 Home）

---

## Verification

| Suite | Result |
|-------|--------|
| HI layout spec | **PASS** |
| SP layout spec | **PASS** |
| HI screen | **PASS** |
| SP screen | **PASS** |
| QWI home integration | **PASS** |
| Beers Law / Concentration lifecycle（Switcher 回归） | **PASS** |

合计本轮复核：**44 / 44**（上述五组 test 文件）。

---

## Honesty / Deferred

| Item | Status |
|------|--------|
| Official pixel-perfect 全态 golden 重录 | **NOT THIS ROUND** |
| Screen 面板 Camera / Gallery 图标（现 Snap/View 文案） | deferred |
| Clear 橡皮擦仅 Hits 模式显示 vs 原版常显 | deferred |
| Experiment 屏独立布局收口 | 不在本轮 |
| WaveKernel 色幂 / layered packet | 不挡布局封板 |

P0 = 0 · P1 = 0（布局）· P2 = 图标/文案细项

---

## Artifacts

| Path | Role |
|------|------|
| `requirements/.../HI_SP_LAYOUT_CLOSEOUT_REPORT.md` | 本报告 |
| `requirements/.../HI_SP_SEAL.md` | 封板清单（已同步） |
| `requirements/.../HIGH_INTENSITY_LAYOUT_SPEC.md` | HI Spec（波区数字以 Dart Spec 为准） |
| `requirements/.../SINGLE_PARTICLES_LAYOUT_SPEC.md` | SP Spec |

**HI/SP LAYOUT CLOSEOUT: PASS**
