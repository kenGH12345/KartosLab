# PHASE 3 REPORT — Simple Diffusion Primary Screen

## PHASE 3 STATUS

**Scope:** 第一屏 Simple Diffusion：原版 SVG、LayoutComposer（design 768×504）、Observation Canvas（程序磷脂 + 粒子）、Solutes/Outside-Inside/Time/Eraser/Graph/`KratosResetAllButton`、真实 Model ticker。

---

| Gate | Result |
|------|--------|
| Source Audit | PASS |
| Model | PASS |
| Views (Simple Diffusion) | **PASS (MVP)** |
| Layout Spec | PASS |
| Composer | **PASS** (design-space Stack + uniform fit) |
| Assets (SD solutes/cell/icons) | **PASS** — original SVG copied |
| Function (SD path) | **PASS** |
| Behavior | **READY CANDIDATE** (SD user path) |
| Responsive | SPEC applied (uniform scale) |
| Hitbox | BASIC |
| Golden | 0 / N |
| Tests | **18 PASS** (17 model + 1 widget smoke) |
| Analyze | CLEAN (warnings only) |
| P0 | 0 |
| P1 | 0 |
| P2 | 见下 |
| Android | NOT VERIFIED |
| Home | **NOT STARTED** (Phase 8) |
| **Status** | **NOT READY** (overall) · SD screen **READY CANDIDATE** |

---

## Delivered

```
assets/simulations/membrane_transport/images/*.svg   # original PhET
lib/membrane_transport/layout/membrane_transport_layout.dart
lib/membrane_transport/view/observation_window_painter.dart
lib/membrane_transport/view/particle_image_cache.dart
lib/membrane_transport/screens/simple_diffusion_screen.dart
lib/membrane_transport/screens/membrane_transport_home.dart
test/membrane_transport/simple_diffusion_screen_test.dart
```

入口（尚未接 KartosLab Home）：

`MembraneTransportHome` → Simple Diffusion tab → `SimpleDiffusionScreenBody`

---

## Visual notes

- `[原版资源]` 溶质 / cell / screen icons 使用原 SVG  
- `[动态绘制]` 磷脂按 `Phospholipid.ts` 程序绘制  
- `[布局]` Observation 534×400 @ (117,8)；Reset bottom-right；Time 在 observation 下方  
- SVG `<style/>` loader warning：P2，不影响显示  

---

## P2

1. Thumbnail 放射线尚未画（cell 已显示）  
2. SoluteControl 间距为近似 gap（CONTENT_DRIVEN panel 宽未测 intrinsic）  
3. Eraser 使用 Material icon（原版 scenery-phet EraserButton；后续可换原 asset）  
4. Crossing Sounds 仅开关，未接线 MP3  
5. Facilitated / Active / Playground 未实现  

---

## Next

**PHASE 4** — Facilitated Diffusion（蛋白面板 + 电压 + 配体）  
或先做 SD Golden + 视觉对照 `visual-qa/screen1_simple_diffusion_ref.png`
