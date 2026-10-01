# PHASE_5_KICKOFF — Voltmeter measurement + charge/E-field viz

> Auto-started after Phase 4 PASS · 2026-09-12

## Goals (from ARCHITECTURE_PLAN + deferred items)

1. **Voltmeter `computeValue` / probe targets** from PhET `Voltmeter.js` — no invented physics  
2. Probe tip hit-testing vs battery / plates / wires / switch (Shape creators)  
3. Plate charge visualization (`PlateChargeNode`) when `plateChargesVisible`  
4. E-field lines (`EFieldNode`) when `electricFieldVisible`  
5. Current indicators (optional Capacitance) when connected  

## Still out of scope

- Home registration  
- Light Bulb full polish (Phase 6)  

## Evidence

- `Voltmeter.js` computeValue / ProbeTarget  
- `PlateChargeNode.js` / `EFieldNode.js`  
- `INTERACTION_REPORT.md` deferred measurement  
