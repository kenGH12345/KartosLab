# PHASE 3 — CONTROLS REPORT · Faraday's Law

**日期**：2026-09-22  
**状态**：Phase 3 = COMPLETE · Overall = NOT READY

## Implemented controls

1. **Voltmeter** — PhET-style checkbox → `setVoltmeterVisible`
2. **Field Lines** — PhET-style checkbox → `setFieldLinesVisible`
3. **Circuit Mode** — 1 coil / 2 coil radios → `setTopCoilVisible`
4. **Flip Magnet** — green rectangular button → `flipPolarity`
5. **Reset All** — `KratosResetAllButton` → `model.reset()`

## Files

| Path | Role |
|------|------|
| `view/controls/control_panel.dart` | Layout strip |
| `view/controls/fl_phet_checkbox.dart` | PhET checkbox (non-Material) |
| `view/controls/coil_radio_group.dart` | Coil mode radios |
| `view/controls/flip_magnet_button.dart` | Flip button |
| `view/faradays_law_play_area.dart` | + `FaradaysLawControlPanel` |

Play Area painters / Model physics：**未改**。

## Sync

```text
Control → Model API → notifyListeners → Play Area rebuild
```

无独立 View control state。

## Keyboard / A11y / Sound

| Item | Status |
|------|--------|
| WASD / 1/2/3 magnet keys | **VD-A11Y** — not ported |
| Full Parallel DOM | **VD-A11Y** |
| Control click sounds | **VD-SOUND** |

## Reset

Calls `model.reset()` (includes VD-02 voltage clear). Verified via widget test.
