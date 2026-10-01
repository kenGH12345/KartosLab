# Membrane Transport · LAYOUT_SPEC

> PHASE 1 — Layout Archaeology  
> 证据：`MembraneTransportConstants.ts`, `MembraneTransportScreenView.ts`, `ObservationWindow.ts`, `ThumbnailNode.ts`, `SoluteBarChartNode.ts`, `SoluteConcentrationsAccordionBox.ts`  
> Design canvas：**1024 × 618**（`MembraneTransportScreenView` 未覆盖 `layoutBounds`；joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` = `Bounds2(0,0,1024,618)`，与 ohms-law 等端口一致）`[已确认]`  
> 标记：`[已确认]` / `[CONTENT_DRIVEN]` / `[推测]`

---

## PHASE: 5 — Visual Golden + Layout Convergence
## STATUS: PASS (公式层 + Composer + Golden baselines)

**Composer 已按本文件公式放置；禁止散乱 Padding/Positioned magic number。**

### Phase 5 Convergence Checklist

| Check | Result |
|-------|--------|
| Design canvas 1024×618 再确认 | **PASS** — ScreenView 无 override → joist 1024×618；OW 534×400 constants |
| Shared Spec 四屏同几何 | **PASS** — FeatureSet 仅门控 PROTEIN / ATP Outside |
| MembraneTransportLayoutComposer | **PASS** — z-order §8 |
| ThumbnailNode + rays | **PASS** |
| Solutes centerY / gapX / cell left+3 | **PASS** — 无再用 `centerY-140` |
| Time centerX / Eraser·Checks centerY | **PASS** |
| Golden 10 states + determinism ×3 | **PASS** — `test/membrane_transport/goldens/` |
| Original protein/solute/nav SVG | **PASS** — Substituted=0 for sim assets |
| Drag-from-toolbox | **DEFERRED** → Phase 6 Behavioral |
| KartosLab Home / Android | **NOT THIS PHASE** |

---

## PHASE: 1 — Layout Archaeology
## STATUS: PASS (公式层) · 像素级 Golden 对照 → Phase 5 ✓

**在 Composer 实现前必须遵守本文件的公式；禁止凭截图加减像素。**

---

## 1. Design Canvas

| 项 | 值 | 标记 |
|----|-----|------|
| `layoutBounds.width` | **1024** | `[已确认]` 无 override → joist `DEFAULT_LAYOUT_BOUNDS` |
| `layoutBounds.height` | **618** | 同上 |
| `SCREEN_VIEW_X_MARGIN` | **8** | `[已确认]` |
| `SCREEN_VIEW_Y_MARGIN` | **8** | `[已确认]` |
| Responsive | Uniform scale：design → viewport；无面板 reflow | `[已确认]` |

```
Design Space (1024×618)
        │ Uniform Scale s = min(vw/1024, vh/618)  （可 >1）
        ▼
Viewport
```

---

## 2. Coordinate Systems (分离)

| Space | Origin | Units | Used for |
|-------|--------|-------|----------|
| **LAYOUT** | layoutBounds top-left (0,0) | view px in design space | panels, buttons, observation frame |
| **PHYSICS** | membrane center (0,0)；+y = outside | model units | particles, slots, membrane |
| **OBSERVATION LOCAL** | observation top-left | view px | canvas draw inside frame |

### Physics ↔ Observation MVT `[已确认]`

```
OBSERVATION_WINDOW_MODEL_VIEW_TRANSFORM =
  SinglePointScaleInvertedY(
    modelPoint = (0,0),
    viewPoint  = observationBounds.center = (267, 200),
    scale      = 534 / 200 = 2.67
  )
```

### Physics ↔ ScreenView MVT（拖蛋白用）`[已确认]`

```
screenViewModelViewTransform =
  SinglePointScaleInvertedY(
    modelPoint = (0,0),
    viewPoint  = observationCenterInScreen
               = (layoutBounds.width/2, SCREEN_VIEW_Y_MARGIN + OBSERVATION_WINDOW_HEIGHT/2)
               = (512, 208),
    scale      = 534 / 200 = 2.67
  )
```

---

## 3. Root Regions

| Module ID | Type | Description |
|-----------|------|-------------|
| `ROOT` | STRUCTURAL | ScreenView / page |
| `OBSERVATION` | FUNCTIONAL | 主仿真窗 534×400 |
| `SOLUTES_COLUMN` | FUNCTIONAL | SolutesPanel + Outside/Inside controls + cell |
| `PROTEIN_COLUMN` | FUNCTIONAL | TransportProteinPanel（非 simpleDiffusion） |
| `TIME_STRIP` | FUNCTIONAL | Eraser + Play/Pause + Speed + Checkboxes |
| `GRAPH_AREA` | DISPLAY | Solute Concentrations accordion |
| `RESET` | STRUCTURAL | Reset All |
| `NAV_FOOTER` | STRUCTURAL | Joist tabs（Flutter：sim 内 Tab 或 Home 导航，另议） |
| `DRAG_OVERLAY` | OVERLAY | TransportProteinDragNode / grab cue |

---

## 4. Module Measurements (Design Space 1024×618)

### 4.1 OBSERVATION `[已确认]` FIXED

| Field | Value | Ratio (of canvas) |
|-------|-------|-------------------|
| x | `1024/2 - 534/2` = **245** | 0.2393 |
| y | **8** | 0.0129 |
| width | **534** | 0.5215 |
| height | **400** | 0.6472 |
| centerX | **512** | 0.5000 |
| centerY | **208** | 0.3366 |
| right | **779** | |
| bottom | **408** | |
| Anchor | topCenter of canvas（水平居中，顶边 margin） | |
| Classification | **FIXED** size；**RELATIVE** position to canvas centerX / top |

```
observation.x = layoutBounds.centerX - OBSERVATION_WINDOW_WIDTH / 2
observation.y = SCREEN_VIEW_Y_MARGIN
```

Frame：`Rectangle` stroke black lineWidth **2**, cornerRadius **3**.  
Clip = 534×400.

### 4.2 PHYSICS inside Observation

| Field | Model | View (in observation local) |
|-------|-------|------------------------------|
| Membrane band | y ∈ [-10, 10] | ± y ≈ 200 ± 10×2.67 ≈ **173.3 … 226.7** |
| Outside region | y > 10 → +MODEL_H/2 | above membrane → top |
| Inside region | y < -10 → −MODEL_H/2 | below membrane → bottom |
| Slot X | [-84,-56,-28,0,28,56,84] | viewX = 267 + x×2.67 |
| Classification | **PHYSICS_DRIVEN** | |

`MODEL_HEIGHT` = 200 × 400/534 ≈ **149.8127**.

### 4.3 RESET `[已确认]` FIXED anchor

| Field | Formula | Numeric |
|-------|---------|---------|
| right | `layoutBounds.maxX - 8` | 760 |
| bottom | `layoutBounds.maxY - 8` | 496 |
| Anchor | **bottomRight** | |
| Classification | **FIXED** | |
| Flutter | `KratosResetAllButton` radius default **20.5**（若原版未写 radius） | |

### 4.4 TIME_STRIP — TimeControlNode `[已确认]` RELATIVE

| Field | Formula | Numeric |
|-------|---------|---------|
| centerX | `observation.centerX` | 384 |
| top | `observation.bottom + 8` | **416** |
| Anchor | topCenter relative to observation bottom | |
| Classification | **RELATIVE** to OBSERVATION | |
| Contents | Play/Pause（无 Step）；Normal/Slow radio | |

### 4.5 ERASER `[已确认]` RELATIVE

| Field | Formula |
|-------|---------|
| left | `observation.left` (=117) |
| centerY | `timeControl.centerY` |
| Classification | **RELATIVE** |
| scale | 1.2 |

### 4.6 CHECKBOXES (Crossing Highlights / Sounds) `[已确认]` RELATIVE

| Field | Formula |
|-------|---------|
| right | `observation.right` (=651) |
| centerY | `timeControl.centerY` |
| spacing | 8 (VBox) |
| align | left |
| Classification | **RELATIVE** |
| boxWidth | 14；text maxWidth 120 |

### 4.7 GRAPH_AREA — SoluteConcentrationsAccordionBox `[已确认]` RELATIVE

| Field | Formula | Numeric |
|-------|---------|---------|
| left | `layoutBounds.left + 8` | 8 |
| bottom | `layoutBounds.bottom - 8` | 496 |
| Anchor | **bottomLeft** | |
| maxWidth (title) | 400 | |
| expandedDefault | **true** | |
| Classification | **RELATIVE** + **CONTENT_DRIVEN** height | |

#### Bar chart cell (per solute) `[已确认]`

| Field | Value |
|-------|-------|
| BOX_WIDTH | **124** |
| BOX_HEIGHT | **92** |
| BAR_WIDTH | 15 |
| BAR_MULTIPLIER | 2（计数→条长） |
| Membrane line | horizontal at BOX_HEIGHT/2 |
| Plottable types | O₂, CO₂, Na⁺, K⁺, Glucose（无 ATP） |

### 4.8 SOLUTES_PANEL `[已确认]` RELATIVE + CONTENT_DRIVEN

| Field | Formula |
|-------|---------|
| left | `graph.left` (=8) |
| centerY | `screenViewMVT.modelToViewY(MEMBRANE_BOUNDS.centerY)` = **208** |
| Anchor | centerLeft（竖直对齐膜中心） |
| Classification | **RELATIVE** |
| Internal | Radio group spacing 5；icon maxWidth 53；label maxWidth 60 |
| cornerRadius | 5 |

宽高由内容决定 → Composer 只定 **left + centerY**，不硬编码 height。

### 4.9 SOLUTE_CONTROL Outside / Inside `[已确认]` RELATIVE

```
gapCenterX = solutesPanel.right + (observation.left - solutesPanel.right) / 2

Outside:
  centerX = gapCenterX
  top     = observation.top (=8)
  fill    = observationOutsideColor (#dbefff)

Inside:
  centerX = gapCenterX
  bottom  = observation.bottom (=408)   // ManualConstraint
  fill    = observationInsideColor (#fff9f0)

ATP: 仅 Inside（无 Outside control）
```

| Classification | **RELATIVE**（相对 panel 与 observation） |
| Spinner | fine ±10 / coarse ±50 |
| AlignGroup | matchVertical true；matchHorizontal false |

### 4.10 CELL + THUMBNAIL `[已确认]` RELATIVE

```
cell:
  maxWidth = 120
  top  = observation.centerY (=208)
  left = soluteControlsParent.left + 3

thumbnail:
  size = 15 × (15 * 400/534) ≈ 15 × 11.24
  center = (cell.centerX - 3, cell.top + 1.5)
  lines → observation left corners (inset CORNER_RADIUS/2)
```

Classification: **RELATIVE** + **CONTENT_DRIVEN** (cell intrinsic).

Z: cell 在下；Thumbnail 之上；`soluteControlsParentNode.moveToFront()`。

### 4.11 PROTEIN_COLUMN `[已确认]` FEATURE-GATED + RELATIVE

仅当 `featureSet !== 'simpleDiffusion'`：

```
rightSideVBox:
  top    = observation.top (=8)
  right  = layoutBounds.right - 8 (=760)
  spacing = 8
```

| Screen | Panel contents |
|--------|----------------|
| Facilitated | Leakage + Voltage(+MembranePotential) + Ligand(+AddLigands) |
| Active | Active Transporters only |
| Playground | 全部 sections |

| Classification | **RELATIVE** + **CONTENT_DRIVEN** height |
| Title fontSize | 16；title maxWidth 175 |
| Grab cue | `grabCue.right = proteinPanel.left + 16` |

---

## 5. Parent-Relative Summary

| Child | Parent | relative rule |
|-------|--------|---------------|
| OBSERVATION | ROOT | centerX align；top=8 |
| TIME_STRIP | ROOT / OBS | centerX=obs.centerX；top=obs.bottom+8 |
| ERASER | ROOT / OBS+TIME | left=obs.left；centerY=time.centerY |
| CHECKBOXES | ROOT / OBS+TIME | right=obs.right；centerY=time.centerY |
| GRAPH | ROOT | left=8；bottom=maxY-8 |
| SOLUTES_PANEL | ROOT / GRAPH+PHYS | left=graph.left；centerY=membrane view Y |
| SOLUTE_CTRL | ROOT / PANEL+OBS | centerX mid-gap；top/bottom = obs |
| CELL | ROOT / CTRL | top=obs.centerY；left=ctrl.left+3 |
| PROTEIN | ROOT / OBS | top=obs.top；right=maxX-8 |
| RESET | ROOT | bottomRight − margins |

---

## 6. Layout Formulas (Composer 用)

```text
W=1024; H=618; mX=8; mY=8
OW=534; OH=400

obs.x = W/2 - OW/2
obs.y = mY
obs.w = OW; obs.h = OH

time.centerX = obs.centerX
time.top     = obs.bottom + mY

eraser.left    = obs.left
eraser.centerY = time.centerY

checks.right   = obs.right
checks.centerY = time.centerY

graph.left   = mX
graph.bottom = H - mY

solutes.left    = graph.left
solutes.centerY = obs.y + OH/2          // ≡ membrane centerY in screen

gapX = solutes.right + (obs.left - solutes.right) / 2
outsideCtrl.centerX = gapX; outsideCtrl.top = obs.top
insideCtrl.centerX  = gapX; insideCtrl.bottom = obs.bottom

cell.top = obs.centerY; cell.left = soluteControls.left + 3
protein.top = obs.top; protein.right = W - mX
reset.right = W - mX; reset.bottom = H - mY
```

---

## 7. Classification Matrix

| Module ID | FIXED | RELATIVE | CONTENT_DRIVEN | VIEWPORT_DRIVEN | PHYSICS_DRIVEN |
|-----------|-------|----------|----------------|-----------------|----------------|
| OBSERVATION | size ✓ | pos ✓ | | scale only | |
| MEMBRANE / PARTICLES / SLOTS | | | | | ✓ |
| TIME / ERASER / CHECKS | | ✓ | | | |
| GRAPH | | ✓ | height ✓ | | |
| SOLUTES_PANEL | | ✓ | size ✓ | | |
| SOLUTE_CTRL | | ✓ | size ✓ | | |
| CELL | | ✓ | size ✓ | | |
| PROTEIN_COLUMN | | ✓ | size ✓ | | |
| RESET | ✓ anchor | | | | |
| ROOT scale | | | | ✓ uniform | |

---

## 8. Z-Order (底 → 顶) `[已确认·addChild 顺序 + moveToFront]`

1. ObservationWindow（含 back canvas / proteins / front canvas）  
2. ResetAllButton  
3. TimeControlNode  
4. Checkbox VBox  
5. soluteControlsParentNode（Outside/Inside）  
6. EraserButton  
7. SoluteConcentrationsAccordionBox  
8. SolutesPanel  
9. cell Image  
10. ThumbnailNode  
11. soluteControlsParentNode.**moveToFront**  
12. rightSideVBox (protein panel)  
13. TransportProteinToolboxGrabCueNode（若有）  
14. TransportProteinDragNode（拖动时临时）

---

## 9. Screen Variants

| Screen | OBS | SOLUTES | TIME | GRAPH | RESET | PROTEIN | VOLTAGE | LIGANDS | ATP ctrl |
|--------|-----|---------|------|-------|-------|---------|---------|---------|----------|
| Simple | ✓ | 5 solutes | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Facilitated | ✓ | 5 | ✓ | ✓ | ✓ | Leak+V+L | ✓ | ✓ | ✗ |
| Active | ✓ | 6 (+ATP) | ✓ | ✓ | ✓ | Pumps | ✗ | ✗ | inside only |
| Playground | ✓ | 6 | ✓ | ✓ | ✓ | All | ✓ | ✓ | inside only |

共享同一 Composer；FeatureSet 开关子树可见性。

---

## 10. Hitbox Notes

| Control | Hit = Visual |
|---------|----------------|
| Observation frame | clip interior；蛋白/配体可点 |
| Solute radios / spinner arrows | panel bounds + touchArea dilation（spinner ArrowButton 有 dilation） |
| Protein toolbox icons | tool node bounds；拖出产生 DragNode |
| Membrane slots | SlotDragIndicator 命中 |
| Reset / Play / Eraser / Checkboxes | 标准按钮/checkbox bounds |

---

## 11. Flutter Architecture Mapping

```
MembraneTransportLayoutPrimitives  // W/H/margins/OW/OH/MVT helpers
MembraneTransportLayoutSpec        // 本文件常量 + 公式
MembraneTransportLayoutComposer    // 只做 geometry / z-order / feature gates
  └── children: Observation, Panels, TimeStrip, Graph, Reset
```

Composer **不**含 physics / RNG / transport。

---

## 12. Visual QA Anchors（对照 `visual-qa/screen*_ref.png`）

Phase 5 验收重点：

1. Observation 水平居中、顶边贴近  
2. 膜水平居中于 observation  
3. Solutes 列在左；蛋白列在右（非 SD）  
4. Graph 左下；Reset 右下  
5. Outside/Inside 控件夹在 panel 与 observation 之间  
6. Cell + 两条放射线对准 observation 左角  

---

## 13. Open Items (非阻塞 Composer)

| Item | Status |
|------|--------|
| SolutesPanel / ProteinPanel 精确像素宽 | CONTENT_DRIVEN — 实现时测 intrinsic，不写死 |
| TimeControlNode 内部高度 | scenery-phet 标准 — 用 centerY 对齐即可 |
| Joist navbar 高度 | Flutter 可用自有 Tab；design 504 为 **play area** |

**LAYOUT_SPEC: PASS**（公式与区域完备，可进入 Core Model / Composer 实现）。
