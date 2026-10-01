# Membrane Transport · COMPONENT_MAP

> PHASE 5 更新 — Original → Flutter → Spec → Composer

---

## L0 / 工程已有（优先复用）

| Original | Existing Flutter | Notes |
|----------|------------------|-------|
| `ResetAllButton` | `KratosResetAllButton` | 规则 86 · **强制** · radius 20.5 |
| Tab chrome | `KratosTabbedScreen` / `KratosTab` | 原版 nav SVG 作 tabIcon |
| Checkbox / Radio 风格 | Material compact（P2 可换 PhET-style） | |

---

## Membrane-Transport 专用

| Module ID | Original | Flutter | Composer / Spec | Layout Rule |
|-----------|----------|---------|-----------------|-------------|
| ROOT | ScreenView | `MembraneTransportScreenBody` | `LayoutComposer` | Uniform scale design 768×504 |
| OBSERVATION | ObservationWindow | `ObservationWindowPainter` | slots.observation | centerX; y=8; 534×400 |
| MEMBRANE | Phospholipid canvas | same painter | fill obs | PHYSICS MVT |
| PARTICLES | Canvas images | `ParticleImageCache` + painter | — | PHYSICS |
| PROTEINS | TransportProteinNode SVG | `ProteinImageCache` + painter | slots | PHYSICS + state SVG |
| CHARGES | drawCharges | painter `_drawCharges` | — | when chargesVisible |
| SOLUTES_PANEL | SolutesPanel | `_SolutesPanel` | left + centerY | RELATIVE |
| SOLUTE_CTRL | SoluteControl | `_SideSoluteControl` | gapX; top/bottom | RELATIVE; ATP hides Outside |
| CELL | cell.svg | `SvgPicture` | cellLeft/Top | maxWidth 120 |
| THUMBNAIL | ThumbnailNode | `MembraneThumbnailNode` | thumbnailCenter | 15×(15·400/534) + rays |
| PROTEIN_PANEL | TransportProteinPanel | `TransportProteinPanel` | top/right | FEATURE-GATED |
| VOLTAGE | MembranePotentialPanel | panel footer | inside protein | −70/−50/+30 + Charges |
| LIGANDS | LigandToggleButton | `_LigandToggle` | inside protein | Add/Remove |
| GRAPH | SoluteConcentrationsAccordionBox | `_ConcentrationsPanel` | left+bottom | RELATIVE |
| TIME | TimeControlNode | `_TimeControls` | centerX + top | RELATIVE |
| ERASER | EraserButton | `_EraserButton` | left + centerY | RELATIVE |
| CHECKS | Crossing HL/SND | `_CrossingOptions` | right + centerY | RELATIVE |
| RESET | ResetAllButton | `KratosResetAllButton` | bottomRight | FIXED |
| NAV | Screen icons | Home tabs + nav SVG | — | Phase 8 Home card |

---

## Composer 架构

```
MembraneTransportLayoutPrimitives
MembraneTransportLayoutSpec.resolve(featureSet) → slots
MembraneTransportLayoutComposer(slots, children…)
```

Composer **只** placement / z-order / feature gate。Model / transport 在 ScreenBody。

---

## 禁止平行实现

- 不得新建第二套 Reset All / Layout Spec
- 不得为 MT 新建 Home / Navigator 体系（Phase 8）
- 不得复制 Phospholipid painter 到每个 screen
