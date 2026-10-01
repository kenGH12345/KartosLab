# PHASE 5 REPORT — Visual Golden + Layout Convergence

> req-membrane-transport · 2026-09-29  
> Scope: Visual / Layout / Assets / Typography / Geometry / Z-order / Golden  
> **No Home · No Android · No Model rewrite**

---

## Verdict Summary

| Gate | Result |
|------|--------|
| Source Visual Audit | **PASS** |
| Layout Archaeology | **PASS** |
| LAYOUT_SPEC | **PASS**（Phase 5 section + formulas） |
| Simple Diffusion Visual | **PASS** (Golden) |
| Facilitated Visual | **PASS** (Golden) |
| Active Visual | **PASS** (Golden) |
| Playground Visual | **PASS** (Golden) |
| Membrane (procedural lipids) | **PASS** |
| Protein (原版 SVG) | **PASS** |
| Particles (原版 SVG) | **PASS**（`<style/>` P2） |
| Toolbox | **PASS** |
| Voltage / Charges / Ligands | **PASS** |
| Observation | **PASS** |
| Tabs (nav icons) | **PASS**（sim 内；KartosLab Home 未接） |
| Controls | **PASS** |
| Typography | **PASS**（platform Arial/default · P2） |
| Original Assets | **PASS** · Substituted sim assets = 0 |
| Z-order | **PASS**（Composer §8） |
| Responsive | **PASS**（uniform fitScale · layout tests） |
| Hitbox | **PASS**（visual≈interactive · P2 eraser Material） |
| Performance | **PASS**（Canvas + image caches） |
| Memory | **PASS**（caches shared · model per screen） |
| Golden | **10 / 10** + determinism ×3 |
| Golden Determinism | **PASS** |
| Tests | Previous 23 → **+18** → **41 PASS** |
| Analyze | CLEAN（既有 info/warning 非本阶段引入） |
| P0 | **0** |
| P1 | **0** |
| P2 | **4**（见下） |
| Android | **NOT VERIFIED** |
| Home | **NOT STARTED** |
| **Status** | **READY CANDIDATE** |

---

## What changed (View / Layout only)

1. **`MembraneTransportLayoutSpec.resolve` + `MembraneTransportLayoutSlots`**  
   公式化 slots：obs / time / eraser / checks / gapX / cell / thumbnail / protein / reset
2. **`MembraneTransportLayoutComposer`**  
   按 LAYOUT_SPEC §8 z-order 放置；去掉 `centerY-140`、`centerX-90` 等 magic
3. **`MembraneThumbnailNode`**  
   原版 ThumbnailNode 几何：15×aspect + 射线到 observation 圆角
4. Ligand button color → `rgb(255,240,105)`（源码 ProfileColor）
5. Goldens under `test/membrane_transport/goldens/MT5-*.png`

---

## Design canvas re-confirmed

| Source | Value |
|--------|-------|
| ScreenView layoutBounds | **768×504**（无 override → joist default） |
| OBSERVATION_WINDOW | **534×400** |
| Margins | **8** |
| Shared across 4 FeatureSets | **Yes** — protein/ATP 仅 feature gate |

---

## Golden matrix

| ID | Screen | State |
|----|--------|-------|
| MT5-SD-01 | Simple | initial |
| MT5-SD-02 | Simple | solutes added |
| MT5-FD-01 | Facilitated | toolbox visible |
| MT5-FD-02 | Facilitated | proteins + Na |
| MT5-FD-03 | Facilitated | V=+30 + charges |
| MT5-FD-04 | Facilitated | ligands on |
| MT5-AT-01 | Active | initial |
| MT5-AT-02 | Active | pump + ATP inside |
| MT5-PG-01 | Playground | all panels |
| MT5-PG-02 | Playground | mixed proteins |
| determinism | SD-01 ×3 | same seed 42 |

---

## P2 backlog

1. SVG `<style/>` unhandled by flutter_svg — 部分着色可能偏淡  
2. Eraser / Play 仍用 Material icons（非原版 scenery 图标 asset）  
3. Typography 非 PhetFont — 平台默认  
4. Toolbox → membrane **drag** 未做（tap-place 保留）→ **Phase 6 Behavioral**

---

## Next

**PHASE 6 — Behavioral Acceptance**（拖放蛋白、用户路径、跨膜生命周期）  
然后 Technical/Android → Home → Final QA。
