# GLOSSARY_CONFLICTS

> PHASE 1 · Do not silently pick a translation when variants conflict.

| Term | Existing variants | Recommended canonical | Reason | Affected simulations |
|---|---|---|---|---|
| Gravity | 重力 / 引力 | **重力** for `g` controls; **引力** for Newtonian gravity force | Context split: acceleration due to gravity vs gravitational force between masses | forces, projectile, pendulum, gravity-force-lab*, gravity-and-orbits, my-solar-system |
| Weight | 重力 / 重量 | **重量** as noun label; force-context sentences may say「重力」 | Mainland textbooks: mass≠weight; weight often colloquial「重量」 | balancing-act, buoyancy, density |
| Pressure | 压强 / 压力 | **压强** | Fluid statics / Under Pressure educational standard | under-pressure, buoyancy, gas-properties |
| Velocity vs Speed | 速度 / 速率 | Glossary: velocity=**速度**, speed=**速率**; F&M tug UI uses「速度」for speed readout (PHASE 2 accepted) | Vector vs scalar | collision-lab, projectile, forces, waves |
| Displacement | 位移 / 排开体积 | kinematics=**位移**; buoyancy displaced fluid=**排开体积** (`physics.displacedVolume`) | Homonym in English PhET strings | buoyancy, projectile, vector-addition |
| Buoyancy / Buoyant Force | 浮力 | **浮力** for both title and force arrow | Chinese collapses the pair | buoyancy |
| Fluid vs Liquid | 流体 / 液体 | **流体**=Fluid; **液体**=Liquid | Must not conflate in density/buoyancy/gas UI | density, buoyancy, under-pressure, gases |
| Wood (material) | 木材 / 木头 / 木板 | **木材** | Cross-sim material glossary (PHASE 3) | density, buoyancy |
| Current | 电流 / 流 | **电流** | Not fluid “flow” | circuit, ohms-law, cck |
| Charge / Electricity | 电荷 / 电 | charge=**电荷**; electricity (discipline)=**电学** | Avoid「电」alone for charge | charges-and-fields, john-travoltage |
| Reset All | 全部重置 / 重置全部 | **全部重置** | Product + L0 `KratosResetAllButton` | all sims |
| Intro | 介绍 / 入门 | **介绍** | Tab consistency | multi-screen sims |
| Current (I) vs “current” (now) | 电流 / 当前 | Physics I=**电流**; never translate UI “current value” as 电流 without context | PHASE 4 | ohms-law, CCK, CLB |
| Charge vs charge (verb) | 电荷 / 充电 | Noun label=**电荷** | PHASE 4 | BASE, CAF, JT |
| Resistance vs Resistor | 电阻 / 电阻器 | Quantity=**电阻**; component=**电阻器** | PHASE 4 | CCK, ohms-law |
| Capacitance vs Capacitor | 电容 / 电容器 | Quantity=**电容**; component=**电容器** | PHASE 4 | CLB, CCK |
| Power | 功率 / 电源 | **功率** (unify with mechanics) | PHASE 4 cross-domain | circuits + mechanics |
| Light (EFAC) | 光 / 光能 | optics=**光**; energy form=**光能** | Domain split | energy-forms-and-changes, color-vision, bending-light |

## Resolution process

1. Prefer `LOCALIZATION_GLOSSARY.md` canonical row.
2. If conflict remains → add/update this table (do not invent in Widget).
3. Simulation batch owners must cite the chosen key in PR notes.
