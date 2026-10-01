# Resistance in a Wire — Final Acceptance Report

**Sim:** Resistance in a Wire（导线电阻）  
**Source:** PhET HTML5 `1.8.0-dev.0`  
**Date:** 2026-09-27  
**Overall:** READY CANDIDATE

---

## Phase gates

| Phase | Scope | Status |
|-------|--------|--------|
| 0 | Source audit / baseline | PASS |
| 1 | Model (oracle) | PASS · FROZEN |
| 2 | View / Product UX | PASS |
| 3 | Runtime | PASS |
| 4 | Visual QA / Raster Golden | PASS |
| 5 | Home Integration | READY CANDIDATE |

---

## Frozen contracts

```text
R = ρ · L / A
Default: ρ=0.50 Ω·cm, L=10.00 cm, A=7.50 cm² → R=0.667 Ω
Canvas: 1024 × 618
Background: #FFFFDF
Reset: KratosResetAllButton(radius: 30)
production dotRandom: UNSEEDED
R scale cap: none (VD-02)
1 ≤ R < 10 → 2 decimal places (e.g. 1.33)
```

---

## Home

```text
Category: 电学与电路
Title:    导线电阻
Target:   ResistanceInAWireScreen (unique)
Entry:    Home → 电学与电路 → 导线电阻
```

---

## Test totals (re-verified 2026-09-27)

| Suite | Result |
|-------|--------|
| Phase 1 Model | 24 / 24 |
| Phase 2 View | 14 / 14 |
| Phase 2 Visual State | 16 / 16 |
| Phase 2 Golden | 12 / 12 |
| Phase 3 Runtime | 26 / 26 |
| Phase 4 Golden Matrix | 30 / 30 |
| Phase 4 Visual Regression | 38 / 38 |
| Phase 5 Home | 21 / 21 |
| **Final Combined** | **123 / 123** |
| Analyze | CLEAN |
| P0 / P1 | 0 / 0 |

---

## Product visual / UX

- Formula `R = ρ·L/A` with source-defined glyph scaling  
- Wire length / thickness / impurity dots mapped from ρ / L / A  
- Static arrow (not animated)  
- Three sliders + resistance readout + Reset All  
- Slider readout: no wrap (`10.00` single line; PhET maxWidth / FittedBox)  
- [原版资源一致] programmatic graphics · Substituted Assets = 0  

---

## Honesty flags (not upgraded without device verification)

| Item | Status |
|------|--------|
| Audio (tambo brightMarimbaShort) | PARTIAL |
| Audio Lifecycle | PARTIAL |
| Accessibility / Screen Reader | PARTIAL |
| Keyboard Reset Enter | PARTIAL |
| Performance 60fps | NOT VERIFIED |
| Android Emulator / Device | NOT VERIFIED |

---

## Deliverables

```text
lib/resistance_in_a_wire/
test/resistance_in_a_wire/
requirements/req-resistance-in-a-wire/
  PHASE_0_SOURCE_AUDIT.md
  PHASE_0_SCREENSHOT_AUDIT.md
  ASSET_MAP.md
  MODEL_CONTRACT.md
  PHASE_1_MODEL_REPORT.md
  PHASE_2_VIEW_REPORT.md
  PHASE_3_RUNTIME_REPORT.md
  PHASE_4_VISUAL_QA_REPORT.md
  PHASE_4_GOLDEN_MATRIX.md
  PHASE_5_HOME_INTEGRATION_REPORT.md
  FINAL_ACCEPTANCE_REPORT.md  ← this file
  meta.yaml / process.txt
```

---

## Verdict

```text
PHASE 0–4: PASS
PHASE 5:   READY CANDIDATE
OVERALL:   READY CANDIDATE

Model: FROZEN
View:  READY_CANDIDATE
Home:  INTEGRATED
```

可上架 KartosLab Home 作为成品 simulation；Audio / A11y / Keyboard Reset / 60fps / Android 待真机补验后可升为 FULL PASS。
