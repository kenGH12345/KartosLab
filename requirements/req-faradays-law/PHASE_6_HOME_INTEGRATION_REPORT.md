# PHASE 6 — HOME INTEGRATION REPORT · Faraday's Law

## Status

```
Phase 6 = COMPLETE
Overall = READY CANDIDATE
Home = INTEGRATED
Android = NOT VERIFIED
```

## Integration summary

| Item | Value |
| --- | --- |
| Home Category | **物理 → 电磁学** |
| Card title | Faraday's Law |
| Card subtitle | 磁铁 · 线圈 · 感应电动势 |
| Card icon | `Icons.bolt_rounded` (Home Material pattern) |
| Entry | `FaradaysLawScreen` (direct; peer of 磁铁与罗盘) |
| Model owner | `FaradaysLawScreen` (creates when `model == null`) |
| Model dispose | Screen when owned; injected test models not disposed |
| Clock owner | `FaradaysLawPlayArea` → one `SimulationClock` |
| Dispose owner | PlayArea (clock + listener); Screen (owned model) |
| Navigation | Home `_SimCard` → `Navigator.push` → AppBar Back → pop |
| Re-entry | New Screen → new Model → source initial |

## Why this category / entry

- 「电磁学」已存在；感应线圈属该组，不属「电学与电路」。
- 单 screen → 与同组 Magnet 一样 **direct Screen**，不造 `FaradaysLawHome` 多屏壳。

## Files changed

| File | Change |
| --- | --- |
| `lib/screens/home_screen.dart` | Register card under 电磁学 |
| `lib/faradays_law/view/faradays_law_screen.dart` | AppBar + title/subtitle/accent + owned-model dispose; `SafeArea(top: false)` |
| `test/faradays_law/home/faradays_law_home_lifecycle_test.dart` | Home / Back / re-entry / cross-sim |
| `test/faradays_law/visual/faradays_law_visual_smoke_test.dart` | Expect AppBar (Phase 6 chrome) |
| `requirements/req-faradays-law/PHASE_6_*.md` | Reports |
| `requirements/req-faradays-law/meta.yaml` / `process.txt` | Status |

**Not changed:** model/, painters/, components/, physics, assets, other sims.

## Gates

| Gate | Result |
| --- | --- |
| Home entry | PASS |
| Navigation / Back | PASS |
| Lifecycle dispose | PASS |
| Re-entry fresh | PASS |
| Re-entry ×3 | PASS |
| Cross-sim isolation | PASS |
| Back while ticking | PASS |
| Faraday regression | **136 PASS** |
| Analyze | CLEAN |
| Full project | `+2805 ~1 -56` — Faraday failures = **0**; fails = SoM/pendulum/projectile capture timeouts + forces hang (pre-existing unrelated) |
| P0 / P1 | 0 / 0 |
| Substituted | 0 |

## P2

Phase 5 visual P2 (9) unchanged. No new Home P2 blockers.

Home card uses Material icon (KartosLab Home norm) — not a sim asset substitution.

## VERSION_DELTA

| ID | Note |
| --- | --- |
| VD-02 | reset clears voltage |
| VD-SOUND | sounds not wired |
| VD-A11Y | keyboard a11y not ported |
| VD-DRAG | AABB drag |
| VD-FONT | magnet/label font |
| VD-HOME-CHROME | KartosLab AppBar above play area (not in PhET HTML chrome); play logical 834×504 unchanged |

## Android

```
Android = NOT VERIFIED
```
