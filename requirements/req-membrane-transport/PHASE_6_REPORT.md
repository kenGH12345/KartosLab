# PHASE 6 REPORT — Behavioral Acceptance / Drag & Drop / Real User Path

> req-membrane-transport · 2026-09-29  
> Evidence: `DRAG_DROP_BEHAVIOR.md` + source + tests  
> **No Home · Android NOT VERIFIED · No Final READY**

---

## Verdict

| Gate | Result |
|------|--------|
| Source Drag Audit | **PASS** |
| Drag Source (toolbox + membrane) | **PASS** |
| Drag Lifecycle | **PASS** |
| Valid Drop | **PASS** |
| Invalid Drop | **PASS**（return toolbox; membrane pickup already cleared） |
| Snap | **PASS**（slot indicator intersect + closest center） |
| Protein Placement / Removal | **PASS** |
| Multiple Proteins | **PASS**（7 slots；同类可重复） |
| Facilitated Transport | **PASS** |
| Simple Diffusion | **PASS** |
| Active Transport | **PASS**（泵模型 + ATP featureSet） |
| Voltage / Charges / Ligands | **PASS** |
| FeatureSet | **PASS** |
| Particle Lifecycle | **PASS** |
| Concentration | **PASS**（gradient bias in model） |
| Equilibrium | **SOURCE-N/A**（无硬编码 equilibrium flag） |
| Pause / Play | **PASS**（无 Step 按钮 · SOURCE-N/A Step） |
| Speed | **PASS**（Normal 1.0 / Slow 0.5） |
| Reset | **PASS** |
| Reset During Drag | **PASS**（cancel → restore origin / clear ghost） |
| Reset During Transport | **PASS** |
| Rapid / Repeated Drag | **PASS**（×10 cycles） |
| Cross-Screen Isolation | **PASS**（per-screen model） |
| Lifecycle | **PASS** |
| Determinism | **PASS** |
| Statistics | **PASS**（counts ↔ solutes） |
| Hitbox / Responsive Drag | **PASS**（design-space GlobalKey + MVT） |
| Normal User Path | **PASS**（tap place + drag place + remove via drag-off） |
| Golden Regression | **PASS**（10/10 + ×3） |
| Tests | Previous **41** → Added **~21** → Final **62 PASS** |
| Analyze | **CLEAN** |
| P0 | **0** |
| P1 | **0** |
| P2 | **3** — SVG `<style/>`；Material Eraser/Play；非 PhetFont |
| Android | **NOT VERIFIED** |
| Home | **NOT STARTED** |
| **Status** | **READY CANDIDATE** |

---

## Drag & Drop (source-faithful)

| Behavior | Implementation |
|----------|----------------|
| Toolbox pan | `TransportProteinPanel.onDragStart` → `ProteinDragSession` ghost |
| Membrane pan | Clear slot immediately → drag with `originSlot` |
| Slot indicators | 65×105 · highlight closest while dragging |
| Valid drop | Bounds intersect + closest center → `dropProteinFromDrag` |
| Replace (toolbox→filled) | New type wins; old discarded to toolbox |
| Swap (slot→slot) | Exchange types |
| Invalid drop | Session end without drop → protein stays removed if from membrane |
| Tap toolbox | Leftmost empty else middle（键盘路径） |
| Reset mid-drag | Cancel session; restore origin slot if any |

---

## P2 remaining (visual / Final)

1. SVG `<style/>` flutter_svg warning  
2. Eraser / Play Material icons  
3. Non-PhetFont  

~~Toolbox 拖拽~~ → **FIXED**（本阶段）

---

## Next

**PHASE 7** — Technical / Android（含触屏拖放 smoke）  
**PHASE 8** — Home Integration  
**PHASE 9** — Final QA  
