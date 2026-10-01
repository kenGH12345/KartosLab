# PHASE 2 — VIEW REPORT · Resistance in a Wire

**日期**：2026-09-27  
**Source**：1.8.0-dev.0  
**状态**：Phase 2 = **PASS** · READY CANDIDATE  
**Model**：FROZEN · **Home**：NOT TOUCHED

---

## Summary

忠实重建 PhET `ResistanceInAWireScreenView`：动态公式 `R = ρ L / A`、3D 导线 + 杂质点 Canvas、静态箭头、三竖滑条 ControlPanel、`KratosResetAllButton(radius: 30)`，canvas **1024×618**，背景 **`#FFFFDF`**。

```text
ρ → impurity dots + R + formula
L → wire length  + R + formula
A → wire thickness + R + formula
Reset → defaults (0.50 / 10.00 / 7.50 → 0.667 ohms)
```

---

## Files

| Path | Role |
|------|------|
| `lib/resistance_in_a_wire/resistance_in_a_wire_view_constants.dart` | Layout / colors / wire maps |
| `lib/.../view/formula_equation.dart` | FormulaNode |
| `lib/.../view/wire_node.dart` | WireNode + DotsCanvasNode |
| `lib/.../view/static_arrow.dart` | ArrowNode |
| `lib/.../view/controls/slider_unit.dart` | PhET VSlider |
| `lib/.../view/controls/control_panel.dart` | Panel + readout |
| `lib/.../view/riaw_play_area.dart` | ScreenView layout |
| `lib/.../view/resistance_in_a_wire_screen.dart` | Screen shell |
| `lib/.../view/riaw_bindings.dart` | ChangeNotifier bridge |
| `lib/.../view/riaw_audio_hooks.dart` | Marimba event hooks (Phase 3) |

---

## Tests

```text
flutter test test/resistance_in_a_wire
→ All tests passed! (55)

Model regression: 24/24
View tests:       14
Visual contracts+golden: 17 (12 PNG goldens)
```

```text
dart analyze lib/resistance_in_a_wire test/resistance_in_a_wire
→ No issues found!
```

---

## Golden note

G01–G12 = **implementation regression goldens**（确定性 seed `0x52494157`）。  
非官方截图像素真值；官方 Gold Standard 仍为用户会话截图（Phase 4 对齐）。

---

## Gate

| Item | Status |
|------|--------|
| Canvas 1024×618 | PASS |
| Background #FFFFDF | PASS |
| Formula / scaling / VD-02 uncapped R | PASS |
| Wire geometry / L / A / gradient | PASS |
| Impurity dots / density / clip / seed | PASS |
| Static arrow (no flow animation) | PASS |
| Resistance readout + precision | PASS |
| ρ/L/A sliders + keyboard | PASS |
| Reset radius 30 | PASS |
| Reactive chains | PASS |
| Model FROZEN | PASS |
| Home | NOT TOUCHED |
| P0 / P1 | 0 / 0 |
| P2 | minor font/subpixel vs official screenshot |

**PHASE 2 STATUS: PASS** · View = **READY CANDIDATE**

```text
Next: PHASE 3 — RUNTIME (audio playback / lifecycle) when requested
Do NOT start Home until Phase 5.
```
