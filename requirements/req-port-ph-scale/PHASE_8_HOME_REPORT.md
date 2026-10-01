# PHASE 8 HOME FINAL VERIFICATION

**req-id:** `req-port-ph-scale`  
**date:** 2026-09-22  

---

## Entry

| Field | Value |
|---|---|
| Category | **化学** (`Chemistry`) |
| Subcategory | **溶液与浓度** |
| Title | **pH 标度** |
| Subtitle | 酸 · 碱 · 浓度 · Macro/Micro |
| Icon | `Icons.science_outlined` (Home catalog convention; same pattern as 摩尔浓度) |
| Color | `Color(0xFF0E7490)` |
| Ordering | After 摩尔浓度 in the same group |
| Builder | `_buildPhScale` → `const PhScaleScreen()` |

Source: `lib/screens/home_screen.dart` (import L8, entry L425–431, builder L593).

```text
Home → 化学 → 溶液与浓度 → pH 标度 → PhScaleScreen
```

---

## Navigation

```text
Home → pH Scale: PASS
```

- Card visible once  
- `Navigator.push(MaterialPageRoute(builder: _buildPhScale))`  
- Target = **`PhScaleScreen`** (not Demo / QA / Preview / Test)  

---

## Default Screen

```text
PASS
```

`PhScaleScreen(initialIndex: 0)` → **Macro** (PhET Macro-first ordering).

Verified: `MacroScreenView` present; Graph Concentration chrome absent on entry.

---

## Screen Navigation

| Screen | Status |
|---|---|
| Macro | **PASS** |
| Micro | **PASS** (Graph Concentration / Logarithmic) |
| My Solution | **PASS** (spinner `7.00`) |

KeepAlive (Phase 6) preserved across tab switches during Home-opened session.

---

## Back Navigation

```text
PASS
```

`pageBack` → `HomeScreen` restored; `PhScaleScreen` disposed (`findsNothing`).

---

## Re-entry

```text
PASS
```

Back → open again → defaults to **Macro** again (fresh `PhScaleScreen` push).

---

## Lifecycle

```text
PASS
```

Looped **3×**:

```text
Home → pH Scale → Macro → Micro → My Solution → Reset → Macro → Back → Home
```

No uncaught exceptions after idle pump; no duplicate Home cards.

---

## Reset

```text
PASS
```

`KratosResetAllButton` tappable on My Solution; spinner remains at source default `7.00`.

---

## Home Category Integrity

```text
PASS
```

- `pH 标度` appears **once**  
- Sibling `摩尔浓度` present  
- Group `溶液与浓度` under `化学`  
- No debug/QA duplicate entry  

---

## Assets

```text
Original: navbar icons via PhScaleAssets on PhScaleScreen tabs
Substituted: 0
Home card: Material catalog icon (project Home convention — not a PhET sim asset swap)
```

---

## Android APK

| Item | Status |
|---|---|
| Build | **PASS** (Phase 7: `app-debug.apk`) |
| Runtime | **NOT VERIFIED** (no device/emulator session this phase) |

---

## Tests

| Suite | Result |
|---|---|
| `flutter test test/chemistry/ph_scale/` | **88 PASS** (was 84; **+4** Home lifecycle) |
| New file | `test/chemistry/ph_scale/home/ph_scale_home_lifecycle_test.dart` |

Coverage:

- catalog category / title / uniqueness  
- open → `PhScaleScreen` / default Macro  
- Macro ↔ Micro ↔ My Solution + Reset + back + reopen ×3  
- no Demo/QA/Preview target  

---

## Analyze

```bash
dart analyze lib/chemistry/ph_scale lib/screens/home_screen.dart
```

```text
CLEAN
```

---

## P0

```text
0
```

## P1

```text
0
```

## P2

Unchanged Phase 5 visual leftovers (out of scope):

- faucet/dropper assembly  
- indicator bubble  
- joist bottom chrome  
- screenshot matrix / `toImage` harness  

Home card uses Material outlined science icon (catalog pattern) — not a sim Substituted asset.

---

## Known Issues

1. Phase 5 Visual = **PARTIAL**  
2. Android **runtime** Home→pH not manually verified on device  
3. Tap hit-test warning possible under FittedBox (non-fatal; tests PASS)  

---

## Phase 8 Status

```text
PHASE 8 STATUS: PASS
```

## Overall

```text
NOT READY
```

Reason: Phase 5 Visual still PARTIAL; PHASE 9 Final Status / visual reconciliation remains.

---

## Home code changes

```text
0 — no Home redesign; registration already correct
```

---

## Next Gate

```text
PHASE 9 — Final Status / Visual Reconciliation
```
