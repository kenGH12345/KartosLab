# GLOBAL LOCALIZATION PHASE 3 — STATUS

Scope: Fluids / Density / Buoyancy / Gases — **7** simulations  
User-facing strings: migrated (bags + hardcode patches)  
Accessibility: fluids a11y keys + tooltips Chinese  
Chinese coverage (batch): high  
Remaining English: units / formulas / chemistry symbols / archaeology  

Glossary: PHASE3_GLOSSARY_UPDATE + GLOSSARY_CONFLICTS  
Keys: +~70 `fluids.*`; reused physics/common  
Legacy adapters: bags with Chinese const values  

Layout: no LayoutSpec/physics changes  
Golden: `test/goldens/zh/phase3/` placeholder; EN baselines preserved  
Behavior/Regression: localization + critical batch tests PASS  
Analyze: no physics/model/renderer edits  

P0=0 P1=0 P2=label width / full ZH golden capture  

Simulation Status: all 7 **LOCALIZED** (VERIFIED pending full golden)  

**Final Status: READY CANDIDATE**
