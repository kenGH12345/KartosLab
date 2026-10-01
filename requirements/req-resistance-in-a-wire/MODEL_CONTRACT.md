# MODEL CONTRACT — Resistance in a Wire (Flutter ↔ PhET 1.8.0-dev.0)

> Phase 1 · 2026-09-27  
> Source: `phet sourses/resistance-in-a-wire-main/.../ResistanceInAWireModel.ts`  
> + `ResistanceInAWireConstants.ts`  
> Flutter: `lib/resistance_in_a_wire/model/`  
> Status: **FROZEN** after Phase 1 PASS

---

## Authority

```text
ResistanceInAWireModel.ts + ResistanceInAWireConstants.ts
        ↓
This MODEL_CONTRACT
        ↓
lib/resistance_in_a_wire/model/*
        ↓
test/resistance_in_a_wire/model/* (oracle)
```

---

## Files

| Flutter | Source |
|---|---|
| `resistance_in_a_wire_model.dart` | `ResistanceInAWireModel.ts` |
| `resistance_in_a_wire_constants.dart` | `ResistanceInAWireConstants.ts`（ranges + 显示小数位） |
| `resistance_in_a_wire_property.dart` | axon `NumberProperty` / `DerivedProperty` + `toFixed*` |

---

## Properties

| Property | Type | Default | Range | Unit | reset()? |
|---|---|---|---|---|---|
| `resistivityProperty` | NumberProperty | **0.5** | **0.01 … 1.00** | Ω·cm | ✅ |
| `lengthProperty` | NumberProperty | **10** | **0.1 … 20** | cm | ✅ |
| `areaProperty` | NumberProperty | **7.5** | **0.01 … 15** | cm² | ✅ |
| `resistanceProperty` | DerivedProperty | `ρ*L/A` | ≈[6.67e-5, 2000] | **Ω** | derived |

### Formula

```dart
R = resistivity * length / area;
```

### Display helpers

```dart
int getResistanceDecimals(double r) {
  if (r >= 100) return 0;
  if (r >= 10) return 1;
  if (r < 0.001) return 4;
  if (r < 1) return 3;
  return 2; // 1 ≤ R < 10
}

String getFormattedResistanceValue(r) => toFixed(r, getResistanceDecimals(r));
```

Slider 读数：**始终 2 位**（`toFixed(_, 2)`）。

### Formula letter scale（供 View；无 R cap）

```dart
scaleMagnitude = (7 / defaultValue) * value + 1;
// VD-02: source ignores FormulaNode.cappedSize — do NOT add a max
```

默认态四字母 scaleMagnitude = **8**。

### `reset()`

```dart
resistivityProperty.reset();
lengthProperty.reset();
areaProperty.reset();
```

---

## Oracle must-pass

| ρ | L | A | R raw | formatted |
|---|---|---|---|---|
| 0.5 | 10 | 7.5 | 0.666… | `0.667` |
| 0.01 | 0.1 | 15 | ≈6.666e-5 | `0.0001` |
| 1.0 | 20 | 0.01 | 2000 | `2000` |
| 1.0 | 20 | 15 | 1.333… | `1.33`（1≤R<10 → 2 位） |

---

## Boundary policy

Flutter `NumberProperty.value=` applies `ResistanceInAWireRange.constrain`.  
Out-of-range programmatic sets clamp to `[min, max]`. Within UI range, R is always finite and > 0.

---

## Explicitly NOT in Model

- Slider step / keyboardStep / shiftKeyboardStep  
- Formula letter pixels、Wire 几何、dots 坐标  
- Sound / a11y 字符串  
- layoutBounds / Reset radius  
- **R 缩放上限**（VD-02）
