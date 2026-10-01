# PHASE 0 REPORT — Source Archaeology

**Req:** `req-quantum-measurement`  
**Date:** 2026-09-30  
**Final Status:** **NOT READY** (expected at PHASE 0)

---

## PHASE 0 STATUS

```
PHASE 0 STATUS

Scope:
  Full Source Archaeology for PhET Quantum Measurement 1.0.4
  (Coins / Photons / Spin / Bloch Sphere). No Flutter UI implementation.

Source Audit:
  PASS

Model:
  NOT STARTED (inventory only; formulas → PHASE 1 NUMERICAL_MODEL)

Screen:
  PASS (architecture mapped; implementation NOT STARTED)

Quantum Coin Integration:
  NOT STARTED (compatibility map DRAFT; embedding NOT STARTED)
  Note: existing lib/quantum_coin_toss identified as Coins-only candidate

Layout Archaeology:
  NOT STARTED

LAYOUT_SPEC:
  NOT STARTED

Composer:
  NOT STARTED

Original Assets:
  PASS (inventory); copy/wiring NOT STARTED
  Runtime images: classicalCoinHeads.svg, classicalCoinTails.svg,
                  greenPhoton.png, spinScreenIcon.png
  Programmatic visuals documented (not assets)

Function:
  NOT STARTED (FUNCTION_MAP skeleton deferred to PHASE 1 with model)

Behavior:
  NOT STARTED

Normal User Path:
  NOT STARTED

Responsive:
  NOT STARTED

Hitbox:
  NOT STARTED

Lifecycle:
  NOT STARTED

Performance:
  NOT STARTED (risk noted: 10000 coins → canvas)

Memory:
  NOT STARTED

Determinism:
  NOT STARTED (source seedProperty pattern identified; Flutter QCT gap noted)

Golden:
  0 / 0

Golden Determinism:
  NOT STARTED

Tests:
  Previous: N/A (new req)
  Added: 0
  Final: N/A

Analyze:
  N/A

P0:
  0 (no crash/runtime yet)

P1:
  0 open defects; process risks logged (R01, R06, …)

P2:
  1. Nested duplicate source folder (documentation risk only)
  2. tambo collect_mp3 not yet located in KartosLab tree
  3. QCT may already diverge visually from QM Coins chrome

Android:
  NOT VERIFIED

Home:
  NOT STARTED
  (Existing Quantum Coin Toss Home must remain; QM Home later)

Status:
  NOT READY
```

---

## Deliverables written

| Artifact | Path |
|---|---|
| meta.yaml | `requirements/req-quantum-measurement/meta.yaml` |
| process.txt | `requirements/req-quantum-measurement/process.txt` |
| SOURCE_MAP.md | `requirements/req-quantum-measurement/SOURCE_MAP.md` |
| VISUAL_ASSET_AUDIT.md | `requirements/req-quantum-measurement/VISUAL_ASSET_AUDIT.md` |
| QUANTUM_COIN_COMPONENT_MAP.md | `requirements/req-quantum-measurement/QUANTUM_COIN_COMPONENT_MAP.md` |
| RISK_REGISTER.md | `requirements/req-quantum-measurement/RISK_REGISTER.md` |
| This report | `requirements/req-quantum-measurement/PHASE_0_REPORT.md` |

**Still required later (not PHASE 0 complete docs):**  
`FUNCTION_MAP.md`, `NUMERICAL_MODEL.md`, `LAYOUT_SPEC.md`, `COMPONENT_MAP.md`, `RESET_SEMANTICS.md`

---

## Key facts locked

1. **Version 1.0.4**, deps SHA `69440e4f…`, four screens wired in `quantum-measurement-main.ts`.
2. **Coins** = two independent scene models (Classical / Quantum); multi quantities `[10, 100, 10000]`; 10k = pixel canvas.
3. **Buttons:** Classical Flip/Reveal vs Quantum Reprepare/Observe — different labels, shared `prepare`/`reveal` APIs.
4. **Spin experiments 1–6 + Custom** confirmed in source.
5. **Bloch** uses `ComplexBlochSphere`, magnetic precession, Observe/Erase, basis X/Y/Z.
6. **Existing `lib/quantum_coin_toss`** is a Coins-screen-oriented port already on Home — **candidate only**, must embed under QM Coins after audit.
7. Layout bounds: PhET `ScreenView.DEFAULT_LAYOUT_BOUNDS` (**1024×618**).

---

## Next: PHASE 1 — Numerical / Model Mapping

1. Trace `CoinSet` / `Coin` measurement math + seed RNG → `NUMERICAL_MODEL.md` (Coins section)  
2. Line-by-line diff vs `lib/quantum_coin_toss` models → update `QUANTUM_COIN_COMPONENT_MAP.md`  
3. Photons PBS probabilities + Classical/Quantum path semantics  
4. Spin projection / blocking / experiment wiring  
5. Bloch vector, basis change, precession (`MAX_PRECESSION_RATE`)  
6. Draft `FUNCTION_MAP.md` + `RESET_SEMANTICS.md` from source reset paths  

**No UI coding until PHASE 1 model map reaches PASS and PHASE 2 layout archaeology starts.**
