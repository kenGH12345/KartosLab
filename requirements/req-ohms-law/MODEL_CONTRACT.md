# MODEL CONTRACT — Ohm's Law (Flutter ↔ PhET 1.5.0-dev.6)

> Phase 1 · 2026-09-27  
> Source: `phet sourses/ohms-law-main/ohms-law-main/js/ohms-law/model/OhmsLawModel.js`  
> Flutter: `lib/ohms_law/model/`  
> Status: **FROZEN** after Phase 1 PASS

---

## Authority

```text
OhmsLawModel.js + OhmsLawConstants.js + CurrentUnit.js
        ↓
This MODEL_CONTRACT
        ↓
lib/ohms_law/model/*
        ↓
test/ohms_law/model/* (oracle)
```

---

## Files

| Flutter | Source |
|---|---|
| `ohms_law_model.dart` | `OhmsLawModel.js` |
| `ohms_law_constants.dart` | `OhmsLawConstants.js` (ranges + sig figs + A→mA factor only) |
| `current_units.dart` | `CurrentUnit.js` |
| `ohms_law_property.dart` | axon `NumberProperty` / `DerivedProperty` / `EnumerationDeprecatedProperty` subset + `dot/Utils.toFixed*` |

---

## Properties

| Property | Type | Default | Range | Unit | reset()? |
|---|---|---|---|---|---|
| `voltageProperty` | NumberProperty | **4.5** | **0.1 … 9** | V | ✅ |
| `resistanceProperty` | NumberProperty | **500** | **10 … 1000** | Ω | ✅ |
| `currentProperty` | DerivedProperty | `1000*V/R` | [0.1, 900] mA | **mA** | derived |
| `currentUnitsProperty` | EnumProperty | **milliamps** | milliamps \| amps | display | ❌ |

### Formula

```dart
I_mA = 1000 * voltage / resistance
```

`currentProperty` **always** stores milliamps. Changing units does **not** rewrite it.

### `getFixedCurrent()` (display / a11y helper on Model)

| Units | Transform | decimals | Example (default 9.0 mA) |
|---|---|---|---|
| milliamps | raw mA | 1 | `"9.0"` |
| amps | `mA / 100` (**VD-03**) | 3 | `"0.090"` |

Physical amperes would be `/1000` → `"0.009"`. Source uses `/100`. Flutter mirrors source.

### `reset()`

```dart
voltageProperty.reset();
resistanceProperty.reset();
// currentUnitsProperty intentionally NOT reset
```

---

## Boundary policy

Flutter `NumberProperty.value=` applies `OhmsLawRange.constrain` (PhET `Range.constrainValue` / slider path).  
Out-of-range programmatic sets clamp to `[min, max]`. Within source UI range, current is always finite and > 0.

---

## Explicitly NOT in Model

- Slider step / keyboardStep / shiftKeyboardStep  
- Timer / Ticker / `step(dt)`  
- Colors, fonts, layout, painters  
- Units Radio UI  
- Sound playback  

---

## Oracle coverage

See `test/ohms_law/model/ohms_law_model_test.dart` — defaults, formula matrix, reactivity, units, VD-03, reset preserves units, boundaries, lifecycle.

---

## Freeze rule

After Phase 1 PASS, do not change formula / ranges / defaults / units semantics / reset / VD-03 without a documented source mismatch.
