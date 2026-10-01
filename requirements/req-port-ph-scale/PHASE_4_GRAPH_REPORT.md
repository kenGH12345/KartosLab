# PHASE 4 — Graph Report

**req-id:** `req-port-ph-scale`  
**sim:** pH Scale (PhET HTML5 → Flutter)  
**date:** 2026-09-22  

---

## Phase 4 Status

```text
Phase 4 Status: PASS
Overall Status: NOT READY
```

Gates remaining: PHASE 5–9 (Full Visual / Behavioral / Regression / Home Final / Final Status).

---

## Source Graph

| Item | Source | Flutter |
|---|---|---|
| Entry | `js/common/view/graph/GraphNode.ts` | `lib/chemistry/ph_scale/view/graph/ph_scale_graph_node.dart` |
| Log scale | `LogarithmicGraphNode.ts` | `LogGraphMath` + `LogarithmicScalePainter` |
| Linear scale | `LinearGraphNode.ts` | `linearValueToY` + `LinearScalePainter` |
| Indicators | `GraphIndicatorNode.ts` + drag listener | `graph_indicator.dart` + `GraphIndicatorDrag` |
| Audit note | — | `view/graph/graph_source_audit.dart` |

### Graph semantics

**NOT continuous curves.** Vertical thermometer-like scale with three callout indicators pointing at H₂O / H₃O⁺ / OH⁻ values (concentration or quantity).

### X Axis

None (no horizontal domain axis).

### Y Axis

- **Logarithmic:** exponents −16 … 2 → value = 10^exponent  
- **Linear (Micro only):** mantissa 0…8 × 10^exponent; zoom exponent range −14…1 (default **1**)

### Curves

None. Three **indicators** only:

| Species | Side | Interactive |
|---|---|---|
| H₃O⁺ | left | My Solution only (drag → pH) |
| OH⁻ | right | My Solution only (drag → pH) |
| H₂O | right | never |

### Scale

- Units ABSwitch: Concentration (mol/L) ↔ Quantity (mol)  
- Expand/collapse (+) (−)  
- Micro only: Logarithmic ↔ Linear + zoom ±  

### Range

Constants from PhET `PHScaleConstants` (mirrored in `PhScaleConstants`):

- Log exponents: min −16, max 2  
- Linear exponent: min −14, max 1  
- Data from `SolutionDerivedProperties` (Model LOCKED — unchanged)

### Screen presence

| Screen | Graph | Heights | Interactive |
|---|---|---|---|
| Macro | **NO** | — | — |
| Micro | YES | log **485** / linear **440** | read-only |
| My Solution | YES | log **565** | H₃O⁺/OH⁻ draggable |

---

## Implementation

### Graph View

```text
PhScaleGraphNode
 ├── GraphControlPanel (units ABSwitch + expand)
 ├── vertical connector
 ├── LogarithmicScalePainter / LinearScalePainter
 ├── GraphIndicator ×3 (H3O / OH / H2O)
 ├── ScaleSwitch (Micro only)
 └── Zoom ± (linear only)
```

### Controls

- Units: Concentration / Quantity — wired to `GraphViewState.units`  
- Expand/collapse — `GraphViewState.expanded`  
- Log/Linear — Micro `hasLinearFeature: true`  
- Zoom — `linearExponent` clamp to source range  
- Reset All — `_graph.reset()` on Micro + My Solution  

### Animation

None added (source has no graph curve animation). Indicators follow derived values on rebuild.

### State linkage

```text
Chemistry Model (SolutionDerivedProperties)
        ↓
graphValueFor(units, species)
        ↓
LogGraphMath.valueToY / linearValueToY
        ↓
GraphIndicator positions + labels
```

My Solution drag:

```text
y → yToValue → round interval → concentrationH3OToPH / moles*ToPH → clamp PH_RANGE
```

Model formulas **not** changed (Phase 1 LOCKED).

Phase 3 Ratio / Particle Counts **not** modified.

---

## Tests

```text
flutter test test/chemistry/ph_scale/
→ 66 PASS
```

Includes:

- Graph math: valueToY / yToValue / round-trip / extremes finite  
- Chemistry linkage: neutral / acid / base / extreme  
- Drag → pH (My Solution)  
- GraphViewState reset  
- Screen: Macro **no** Graph; Micro log+linear chrome; My Solution log-only  

```text
dart analyze lib/chemistry/ph_scale
→ CLEAN (No issues found!)
```

### Regression

- `ph_scale` suite: **66 PASS** (Phase 3 was 50; +16 Graph)  
- Full-repo `flutter test` not treated as Phase 4 gate; any historical failures outside `test/chemistry/ph_scale/` are **PRE-EXISTING**, not NEW.

---

## Analyze

```text
CLEAN
```

---

## P0 / P1 / P2

| Severity | Count | Notes |
|---|---|---|
| P0 | **0** | — |
| P1 | **0** | — |
| P2 | several | Indicator callout chrome / ABSwitch bevel vs scenery-phet; typography polish; screenshot-level position vs beaker |

---

## Visual

```text
Visual: CANDIDATE
```

Functional Graph is source-true on semantics/math/controls/screen presence. Pixel-perfect chrome deferred to **PHASE 5**.

Screenshot QA (1024×618) deferred to Phase 5 Full Visual Reconstruction (no forged Visual PASS).

---

## Known Issues

1. Indicator bubble geometry is approximate vs scenery callout Node (functional OK).  
2. ABSwitch is a simplified PhET-style toggle (not full sun `ABSwitch` skin).  
3. Scientific notation on indicators uses project `ScientificNotation` (mantissa+superscript) — align further in Phase 5 if screenshot shows drift.  
4. Graph panel absolute `left/top` approximate source `graph.right = …` constraints; refine in Phase 5 layout pass.

---

## Next Gate

```text
PHASE 5 — Full Visual Reconstruction / Screenshot QA
```

Then: PHASE 6 Behavioral → PHASE 7 Full Regression → PHASE 8 Home Final → PHASE 9 Final Status.

**Do not claim overall READY after Phase 4.**
