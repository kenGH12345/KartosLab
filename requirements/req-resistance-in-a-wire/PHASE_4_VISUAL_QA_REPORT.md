# PHASE 4 — VISUAL QA / RASTER GOLDEN REPORT · Resistance in a Wire

**日期**：2026-09-27  
**Source**：1.8.0-dev.0  
**状态**：Phase 4 = **PASS** · READY CANDIDATE  
**Model**：FROZEN · **View**：未改业务几何（本阶段仅扩测试）· **Home**：NOT TOUCHED

---

## Summary

扩展 Raster Golden 矩阵覆盖 G01–G30（含别名）+ V4 非像素视觉契约。确定性 seed `0x52494157`。全部声明为 **implementation regression goldens**，不以 Flutter 截图冒充官方 pixel truth。官方 Gold Standard 仍为用户默认态截图（构图对照）。

---

## Artifacts

| Path | Role |
|------|------|
| `test/.../visual/resistance_in_a_wire_visual_golden_test.dart` | V4 contracts + golden matrix |
| `test/.../visual/goldens/*.png` | **27** distinct PNGs |
| `requirements/.../PHASE_4_GOLDEN_MATRIX.md` | ID ↔ file + aliases |

---

## Counts

| Suite | Result |
|-------|--------|
| Phase 4 Visual tests | **38 / 38** |
| Golden matrix G01–G30 | **30 / 30** |
| Distinct PNGs | **27 / 27** |
| Phase 1 Model | **24 / 24** |
| Phase 2 View | **14 / 14** |
| Phase 2 Visual State | **16 / 16** |
| Phase 2 Golden continuity | **12 / 12** |
| Phase 3 Runtime | **26 / 26** |
| Full `test/resistance_in_a_wire` | **102 / 102** |
| Analyze | CLEAN |

---

## Honesty

| Item | Status |
|------|--------|
| Official pixel-perfect every state | **No** — regression goldens |
| Audio / A11y / Keyboard Reset | unchanged **PARTIAL** |
| Performance 60fps | **NOT VERIFIED** |
| Android | **NOT VERIFIED** |
| Production `dotRandom` fixed | **No** — seed test-only |

---

## P0 / P1 / P2

| Level | Count | Notes |
|-------|-------|-------|
| P0 | 0 | |
| P1 | 0 | |
| P2 | headless font / anti-aliasing / Phase 3 PARTIAL carry-forward | |

**PHASE 4 STATUS: PASS**

```text
Next: PHASE 5 — HOME when product owner requests
Do NOT modify Model / formula / precision / cappedSize.
```
