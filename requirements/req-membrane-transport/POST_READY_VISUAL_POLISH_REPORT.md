# Membrane Transport — Post-READY Visual Polish Report

**FINAL STATUS: READY**（Phase 9 封板后视觉/布局热修完成）  
**Date:** 2026-09-29  
**Scope:** Phase 9 READY 之后的用户反馈修复（不改科学模型 / 不改 Home 路由体系）

---

## Summary

Phase 0–9 已交付 READY。本轮根据真机/对照截图修复 P0/P1 级视觉与布局问题，并关闭多项原 P2。  
正式路径不变：物理 → 热学与气体 → Membrane Transport。

| Gate | Result |
|------|--------|
| `flutter test test/membrane_transport` | **74 PASS** |
| Visual Golden MT5 | **10 / 10**（已刷新） |
| Home Golden MT8-H | **2 / 2**（已刷新） |
| Layout Spec | **1024×618** 公式对齐 joist DEFAULT |
| Substituted Assets（sim SVG） | **0** |
| Home / Android gates | **保持 INTEGRATED / VERIFIED** |

---

## Fixes（相对 Phase 9 READY）

### 1. SVG 黑剪影（原 P2 → Fixed）

| Item | Detail |
|------|--------|
| Root cause | PhET SVG 用 CSS `<style>`；`flutter_svg` 忽略 → 纯黑剪影 |
| Fix | `tooling/inline_mt_svg_styles.py` 内联 presentation attrs；35 张 sim SVG |
| Visual | `[原版资源一致]` 粒子 / 蛋白 / Home·Nav icon 彩色恢复 |

### 2. Tab 切屏 FeatureSet 错位（P0）

| Item | Detail |
|------|--------|
| Symptom | Facilitated 选中但无蛋白工具箱（仍跑 Simple 模型） |
| Root cause | `KratosTabSwitcher` 重排 Stack 子节点 → State 复用错 FeatureSet |
| Fix | 稳定 Stack 顺序 + `Offstage` + `ValueKey(featureSet)` |
| Test | `tab switch shows that screen FeatureSet UI` |

### 3. Design canvas 与组件比例（对图二原版）

| Item | Was (错) | Now（源码） |
|------|----------|-------------|
| ScreenView `layoutBounds` | 768×504 | **1024×618**（joist DEFAULT；本 sim 无 override） |
| Observation | x=117 | **x=245**（仍 534×400，水平居中） |
| `fitScale` | clamp max **1.0** → 平板大留白 | **可 >1**，等比铺满 |
| Solutes | 仅图标 | 图标 + O₂/CO₂/Na⁺/K⁺/Glucose 标签 |
| Cell | 盖住 Solutes | 膜中线垂直居中，落在 gap |
| Outside/Inside | 过宽叠压 | 收窄，落在 Solutes↔Observation gap |

证据：`ohms_law_view_constants.dart` / joist `ScreenView.DEFAULT_LAYOUT_BOUNDS`；`LAYOUT_SPEC.md` 已更正。

### 4. Solute Concentrations Accordion

| Item | Detail |
|------|--------|
| Expand | 标题固定顶部，内容**向下**展开；`useExpandedBoundsWhenCollapsed` 预留高度 |
| Content | 对齐 `SoluteBarChartNode`：Outside/Inside 半区、磷脂膜线、原点轴、水平浓度条、5×124 格 |
| Chrome | 绿色 ± Accordion 按钮 |
| Spacing | `graphTop = timeBottom + 12`，不贴 Play/Pause |

### 5. EraserButton（原 P2 Material → Fixed）

| Item | Detail |
|------|--------|
| Was | `Icons.auto_fix_off` / 空白黄钮 |
| Now | scenery-phet 橡皮几何（`CustomPaint`）+ `BUTTON_YELLOW`；禁用整钮略淡 |
| Asset | `assets/simulations/membrane_transport/images/eraser.svg`（源路径备份） |

### 6. 粒子溢出观察窗

| Item | Detail |
|------|--------|
| Root cause | 无 PhET `clipArea`；`Stack clipBehavior: none` |
| Fix | `ClipRRect` + painter `canvas.clipRRect`；边框在 clip 外绘制 |
| Visual | `[布局已对齐]` 粒子不穿出黑框 |

---

## P0 / P1 / P2

| Level | Count | Notes |
|-------|-------|-------|
| P0 | **0** | Tab FeatureSet / 黑剪影 / 比例错位 已修 |
| P1 | **0** | 浓度面板 / 橡皮 / clip / 与 pause 间距 已修 |
| P2 | **2** | ① Play/Pause 仍 Material 图标（非 PhET TimeControlNode art）② 非 PhetFont |

---

## Visual judgment（交付用语）

- `[原版资源一致]` — sim SVG 内联后彩色；Eraser 按 scenery-phet 路径重建  
- `[布局已对齐]` — design 1024×618；Observation / Solutes / gap / Concentrations / Reset；粒子 clip  
- `[动态绘制已对齐]` — 磷脂程序绘制 + 浓度条形图几何按源码  

**Substituted Assets（可交互 sim 资产）= 0**

---

## Tests / Artifacts

| Suite | Result |
|-------|--------|
| `test/membrane_transport/**` | **74 PASS** |
| `layout_spec_test` | design 1024×618；obs x=245；graphTop=476 |
| Goldens | `test/membrane_transport/goldens/` + home goldens 已刷新 |

Updated docs:

- `LAYOUT_SPEC.md` — 1024×618  
- `process.txt` — 本轮日志  
- `meta.yaml` — post_ready_polish  

---

## Explicit non-goals（本轮未改）

- 科学模型 / 蛋白状态机 / 梯度偏置 RNG  
- Home 分类与 Navigator 体系  
- Play/Pause 原版 TimeControlNode 美术（留 P2）  
- 音频 MP3 全量 parity  

---

## Verdict

**Membrane Transport 保持 FINAL STATUS: READY。**  
Post-READY 视觉与布局热修完成；正式用户路径（Home 进入 / 四屏 / 清除橡皮 / 浓度面板 / Reset / Back）可用。

**STOP** — 无进一步主动 MT 改动；后续仅用户新开单。
