# PHASE1_LAYOUT_IMPACT

> Home + Shared Chrome Chinese migration

## Changes that affect layout

| Location | Change | Approach |
|---|---|---|
| Home sim cards | Titles/subtitles now Chinese; often longer/shorter than English | `minHeight: 88`, `maxLines: 2`, ellipsis — **no** page-level `Positioned` |
| Home discipline header | Removed English subtitle (`Physics` / `Chemistry`) | Intrinsic Row; badge uses `loc.home.simCountBadge` |
| `KratosResetAllButton` | Default tooltip + Semantics wrapper | Size unchanged (icon button) |
| `TimeControlBar` / `KratosPhetTimeControl` | Localized tooltips / semantics only | No geometry change |
| `SpectrumSlider` | Label「波长」vs Wavelength | Intrinsic Row; may be slightly shorter in Chinese |

## Reviewed risks

| Risk | Severity | Mitigation |
|---|---|---|
| Card title overflow | P1 | 2-line ellipsis + minHeight |
| Tab collision | N/A Home | No Home tabs |
| Shared chrome button width | P2 | Icon-only controls |
| Baseline CJK vs Arial | P2 | Theme fallback; monitor Golden later |

## Forbidden patterns (not used)

- Magic `Positioned(left: …)` to fix one Chinese string
- Shrinking fontSize globally without LayoutSpec

## Deferred

Full sim control-panel overflow review → PHASE 2+ batches after string migration.
