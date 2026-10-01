# FINAL_REPORT · States of Matter

> req-id: `req-states-of-matter`  
> Date: 2026-09-16  
> Local source: **1.3.0-dev.3**  
> **Final Status: DONE**  
> **Home: WIRED**

---

## Gate Checklist

| Gate | Status | Evidence |
|---|---|---|
| Compilation | PASS | Module builds · hot restart OK |
| Simulation Tests | **PASS** | **38 PASS** (`tool/_run_som_tests.bat` · 2026-09-16 close) |
| Analyze | **PASS** | Painters analyze clean (graph chrome pass) |
| Physics | PASS | Unchanged in visual polish |
| Major Geometry P1 | **PASS** | `MAJOR_GEOMETRY_CHECKLIST.md` |
| Visual QA | **PASS** | ORIGINAL/FLUTTER/DIFF 15/15 (geometry gate) + post-READY polish below |
| Browser QA | **PASS** | `BROWSER_QA.md` |
| Lifecycle / Reset | PASS | `SomResetButton` → L0 `KratosResetAllButton` |
| Home Integration | PASS | Wired |

P0 = 0 · P1 geometry = 0 · Post-READY P2 chrome **closed** by user (2026-09-16)

---

## Screens

| Screen | Scope | Status |
|---|---|---|
| States | Container / phase / heater / reset | PASS |
| Phase Changes | Pump + hose + gauge + hand lid + RightPanelLayout + LJ + Phase Diagram | PASS |
| Interaction | Dual atom MVT · Forces accordion · LJ wide graph · Return Atom · pin/hand | PASS |

---

## Post-READY Visual Polish (2026-09-16)

User-driven alignment after geometry READY; closed by user request to report.

| Item | Outcome | Tags |
|---|---|---|
| Pointing hand lid | Drag direction = view ΔY (down→down); original `pointingHand` asset | `[原版资源一致]` `[交互已对齐]` |
| Bicycle pump | Interactive inject; red barrel + segmented ticks; size ~100×130 | `[动态绘制已对齐]` |
| Right panels | FittedBox scaleDown; Phase Diagram not clipped | `[布局已对齐]` |
| Reset All | L0 `KratosResetAllButton` (`#F79722` · ResetShape · elasticOut); rule `86-phet-reset-all-button.mdc` | `[原版资源一致]` |
| Interaction tab | Two atoms · Return Atom · Forces colors · Atoms panel | `[布局已对齐]` `[交互已对齐]` |
| Heat / Cool | Gases Intro layout (flame/ice + RotatedBox slider); track red/blue swapped to match UX | `[布局已对齐]` |
| Graph axes | Shared `SomGraphAxes`: L-arrow axes, grid, σ/ε, cyan well; LJ + Phase Diagram | `[动态绘制已对齐]` |

### Key files (polish)

- `lib/common/widgets/kratos_reset_all_button.dart` — L0 Reset All
- `lib/chemistry/states_of_matter/painters/som_graph_axes.dart` — shared axis chrome
- `lib/chemistry/states_of_matter/painters/lj_potential_graph_painter.dart`
- `lib/chemistry/states_of_matter/painters/phase_diagram_painter.dart`
- `lib/chemistry/states_of_matter/widgets/heater_cooler_control.dart`
- `lib/chemistry/states_of_matter/widgets/bicycle_pump_button.dart`
- `.cursor/rules/86-phet-reset-all-button.mdc`

---

## Major Geometry Closure (summary)

| Screen | B content relations | Status |
|---|---|---|
| States | container / thermo / right Column / phase spacing 10 | PASS |
| Phase Changes | pump/hose/gauge/hand150/RightPanelLayout | PASS |
| Interaction | MVT (145,360)×0.25 · graph 350×262.5 · hand80 · pin20 | PASS |

---

## Deferred / Known gaps (non-blocking)

- Full PhET bicycle-pump hose animation fidelity (inject works; chrome simplified)
- Pixel re-DIFF of 15/15 after polish not re-run (user accepted visually)
- Audio / a11y omitted (same as other ports)

---

## Final Status

```text
Final Status: DONE
```

**Run:** Home → Chemistry → States of Matter  
**Docs:** `requirements/req-states-of-matter/`  
**Code:** `lib/chemistry/states_of_matter/` + L0 `lib/common/widgets/kratos_reset_all_button.dart`
