# PHASE 6 — HOME INTEGRATION REPORT

## Integration

| Item | Value |
| ---- | ----- |
| Home Category | 物理 → **光学与波动** |
| Home card title | `Wave on a String` |
| Home card subtitle | `绳波 · 反射 · 阻尼 · 张力` |
| Icon | `Icons.timeline_rounded` (Material — Home strategy) |
| Accent | `#0E7490` |
| Entry | `const WoasScreen()` |
| Screens | **1** (WOASScreen only) |

## Files changed

```text
lib/wave_on_a_string/view/woas_screen.dart   (Faraday-style Stateful owner + AppBar)
lib/screens/home_screen.dart                 (card + builder under 光学与波动)
test/wave_on_a_string/home/*                 (lifecycle suite)
requirements/req-wave-on-a-string/PHASE_6_*
```

**No** changes to WoasModel / evolve / solver / Phase 5 visuals / other sims.

## Gates

| Gate | Result |
| ---- | ------ |
| Home category / card / entry | PASS |
| Navigation / Back | PASS |
| Model / Clock ownership | PASS |
| Dispose during Oscillate / Pulse / Manual / Timer | PASS |
| Re-entry fresh initial | PASS |
| Re-entry ×3 | PASS |
| Cross-instance A≠B≠C | PASS |
| Cross-sim Faraday round-trip | PASS |
| Single AppBar chrome | PASS |
| Substituted assets | 0 |
| Wave tests | **174 PASS** |
| Analyze | CLEAN |

## Status

```text
Phase 6 = COMPLETE
Overall = READY CANDIDATE
Home = PASS
Android = NOT VERIFIED
```
