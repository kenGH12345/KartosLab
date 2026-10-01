# Build an Atom — Post-Release UX Closeout

Date: 2026-09-28  
Base: Phase 9 `FINAL_RELEASE_MATRIX.md` → **READY**  
Scope: Atom Screen interaction + right-column layout polish (post-release)

## Verdict

```text
Post-Release UX: DONE
Prior Release Gate: READY (unchanged)
```

## Problems addressed

| # | Issue | Resolution |
| --- | --- | --- |
| 1 | Page too small / large letterbox margins | `BaaPageShell` maximize contain + white letterbox |
| 2 | Drag not following pointer / wrong particle | `Listener` + `zLayer` hit-test (topmost under cursor) |
| 3 | Accordion reserved empty space when collapsed (wrong shrink) then later wrong flex squash | Absolute **expanded-height seats**; collapse hides body, headers keep Y; blank gap left |
| 4 | Incomplete periodic table | Full shred `POPULATED_CELLS` main table (H…Og path) |
| 5 | Checkboxes overlapped Mass Number / wrong place | Checkboxes bottom-anchored under panel column, **left of Reset** (PhET `BAAScreenView`) |
| 6 | Bucket reflow forced firstOpen path | `nearestOpenPosition` + animate destinations; top particle can land in nearby gap |
| 7 | Right panels scaled/distorted in flex slots | Natural PhET sizes (`PT@0.55`, charge/mass `@0.85`); no `FittedBox` seat squash |
| 8 | Expand/collapse chrome | Red (−) / green (+) per PhET ExpandCollapseButton |

## Visual judgment

- `[原版资源一致]` — scale.png / particle assets; `KratosResetAllButton` L0 Reset All
- `[布局已对齐]` — right column absolute seats + checkbox/Reset band match PhET reference screenshots
- `[动态绘制已对齐]` — ChargeMeter + ChargeComparisonDisplay; SphereBucket nearest-gap roll

## Key files

| Area | Path |
| --- | --- |
| Atom layout | `lib/chemistry/build_an_atom/screens/atom_screen.dart` |
| Symbol layout | `lib/chemistry/build_an_atom/screens/symbol_screen.dart` |
| Accordion | `lib/chemistry/build_an_atom/widgets/baa_accordion_box.dart` |
| View flags | `lib/chemistry/build_an_atom/view/atom_view_state.dart` |
| Bucket layout | `lib/chemistry/build_an_atom/model/baa_model.dart` + IAAM `sphere_bucket_layout.dart` |
| Charge compare | `lib/chemistry/build_an_atom/widgets/charge_comparison_display.dart` |
| Shell / scale | `lib/chemistry/build_an_atom/view/baa_page_shell.dart`, `widgets/baa_scaled_box.dart` |

## Tests (closeout run)

```text
flutter test \
  test/chemistry/build_an_atom/atom_screen_test.dart \
  test/chemistry/build_an_atom/baa_accordion_and_pt_test.dart \
  test/chemistry/build_an_atom/bucket_hit_and_reflow_test.dart \
  test/chemistry/build_an_atom/symbol_screen_test.dart
→ All tests passed

dart analyze (touched screens/model/widgets/view) → No issues found
```

Covered: empty/edge/drag/lifecycle/reset; accordion seat Y stable on collapse; PT full symbols; bucket mid-stack gap fill + nearest drop + zLayer hit.

## Defaults note

Atom Screen opens with Periodic Table / Net Charge / Mass Number **all expanded** (teaching / reference screenshot). Collapse keeps absolute seats (headers do not shift up).

## Status

```text
Phase 9 Release: READY
Post-Release UX: CLOSED
```
