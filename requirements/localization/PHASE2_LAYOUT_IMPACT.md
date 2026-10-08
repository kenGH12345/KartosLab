# PHASE2_LAYOUT_IMPACT

## Approach

String length changes only — **no** LayoutSpec / Composer / Physics edits.
No page-level magic `Positioned` introduced for Chinese.

## Observed risks

| Simulation | Risk | Severity | Mitigation |
|---|---|---|---|
| Forces tabs | 中文 tab 更短/更长 | P2 | Existing `KratosTabBar` intrinsic |
| Collision / Vector panels | 「动量矢量」longer than English | P2 | Existing panel wrap / ellipsis |
| GFL force values radios | 「科学计数法」width | P1? | Intrinsic radio row — verify in widget test |
| Hooke's labels | 「劲度系数」 | P2 | Existing number control title |
| Balancing Act banners | challenge banner template | P2 | Dynamic string |
| Kepler warnings | Longer Chinese sentences | P2 | Existing overlay |

## Typography

Continues PHASE 1 Theme CJK fallbacks. No global font change.

## Golden strategy

```
test/goldens/
  en_baseline/     # retain historical English captures (do not delete)
  zh/              # Chinese UI truth for PHASE 2+ (populate per sim)
```

Directory `test/goldens/zh/` created as placeholder. Full capture deferred where golden harness already exists per-sim — new Chinese baselines should be recorded under `zh/` without deleting `en_baseline/`.
