# PHASE 4 REPORT — Remaining Screens

> req-membrane-transport · 2026-09-29  
> Scope: Facilitated Diffusion + Active Transport + Playground

---

## Verdict

| Gate | Result |
|------|--------|
| Facilitated Diffusion UI | **PASS (MVP)** — protein toolbox + voltage + ligands |
| Active Transport UI | **PASS (MVP)** — Active Transporters panel + ATP selectable |
| Playground UI | **PASS (MVP)** — all protein sections + voltage + ligands + ATP |
| Shared ScreenBody | **PASS** — FeatureSet-gated single Composer |
| Protein SVG assets | **原版已拷贝**（18 channel/pump/ligand SVGs） |
| Observation proteins + charges | **PASS** — canvas drawImage + charge ± |
| Protein place / remove | **PASS** — tap toolbox → leftmost empty; tap protein → remove |
| Drag-from-toolbox | **DEFERRED** — tap-to-place functional equivalent; drag polish later |
| Tests | **23 PASS**（+5 Phase 4） |
| Home (KartosLab catalog) | **NOT STARTED** |
| Android | **NOT VERIFIED** |
| **Overall Status** | **NOT READY** |

---

## Delivered

### FeatureSet screens
- `MembraneTransportScreenBody(featureSet:)` shared shell
- `MembraneTransportHome` — 4 tabs with原版 nav icons
- Simple Diffusion thin alias retained for tests

### TransportProteinPanel
- Leakage / Voltage-Gated (+ MembranePotential −70/−50/+30 + Charges) / Ligand-Gated (+ Add/Remove Ligands)
- Active Transporters (Na⁺/K⁺ Pump, Na⁺/Glucose)
- Gated by FeatureSet per `MembraneTransportFeatureSet.ts`

### Assets copied
`sodiumLeakage`, `potassiumLeakage`, voltage/ligand open+closed ×4, `sodiumLigand`/`potassiumLigand`(+highlight), `naKPumpState1/2`, `sodiumGlucoseCotransporterState1/3`

### Model hooks
- `placeProtein` / `removeProtein` / `setChargesVisible`
- Full membrane rejects overwrite
- ATP Outside control hidden when ATP selected (source: inside-only)

---

## Known gaps (non-blocking for Phase 4 MVP)

1. Toolbox → membrane **drag** (currently tap-to-place)
2. Sounds still off
3. Eraser still Material icon (P2)
4. Cotransporter exclamation mark when Na gradient adverse
5. KartosLab Home card not wired
6. Golden / visual-qa vs ref screenshots not run

---

## Test summary

```
flutter test test/membrane_transport/  →  23 PASS
```

---

## Next

**PHASE 5+** — Visual Golden vs `visual-qa/screen*_ref.png`；polish drag；  
**PHASE 8** — KartosLab Home 挂载；Android VERIFIED；Final READY gates。
