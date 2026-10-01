# BLOCH_RESET_ERASE_SPEC_PHASE6

> Sources: `BlochSphereMeasurementArea.ts` EraserButton; `BlochSphereModel.ts` reset / resetCounts; ScreenView.reset

## Erase ≠ Reset

| Action | Source | Effect |
|---|---|---|
| **Erase** | `EraserButton` → `model.resetCounts()` | Clears `upMeasurementCount` / `downMeasurementCount` only. Does **not** change Bloch angles, measurement state, B-field, or axis. |
| **Reset All** | ScreenView.reset → `model.reset()` | Full model restore: counts, prep/measure spheres, B-field off, strength=1, axis=Z, single mode, delay default, spinState → +X via `setSpinState`. |

## Flutter

```
model.erase()      // → resetCounts()
model.reset()      // Reset All button
```

**Forbidden:** `onErase = onReset`.

## Tests

- After Observe, Erase → counts 0, collapsed state retained.
- After non-default, Reset All → +X prepared, counts 0, B off.
