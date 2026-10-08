# PHASE3_GLOSSARY_UPDATE — Fluids / Density / Buoyancy / Gases

> Decisions frozen before mass string replacement. Cross-ref: `LOCALIZATION_GLOSSARY.md`, `GLOSSARY_CONFLICTS.md`.

| English | Canonical ZH | Conflict / note | Decision |
|---|---|---|---|
| Density | 密度 | — | Reuse `physics.density` |
| Fluid | 流体 | ≠ liquid | New `fluids.fluid` |
| Liquid | 液体 | ≠ fluid | New `fluids.liquid` |
| Gas | 气体 | — | New `fluids.gas` |
| Pressure | 压强 | ≠ 压力 / force | Reuse `physics.pressure` |
| Atmospheric Pressure / Atmosphere | 大气压 / 大气 | control label 「大气」 | `fluids.atmosphere` = 大气 |
| Volume | 体积 | — | Reuse `physics.volume` |
| Mass | 质量 | ≠ weight | Reuse `physics.mass` |
| Buoyancy / Buoyant Force | 浮力 | title & force collapse | Reuse `physics.buoyancy` / `buoyantForce` |
| Displaced Volume / Fluid Displaced | 排开体积 / 排开的流体 | | `physics.displacedVolume` / `fluids.fluidDisplaced` |
| Temperature | 温度 | — | New `fluids.temperature` |
| Particle(s) | 粒子 | — | Reuse `physics.particle(s)` |
| Molecule | 分子 | — | Reuse `physics.molecule` |
| Container | 容器 | — | New `fluids.container` |
| Piston | 活塞 | — | New `fluids.piston` |
| Pump | 泵 | — | New `fluids.pump` |
| Hold Constant | 保持恒定 | — | Existing glossary |
| Return Lid | 放回盖子 | — | Existing glossary |
| Object Density | 物体密度 | — | Existing glossary |
| % Submerged | 浸没百分比 | — | Existing glossary |
| Wood (material) | 木材 | avoid 木头/木板 | Unifyary: 木材 |
| Aluminum | 铝 | — | 铝 |
| Ice | 冰 | — | 冰 |
| Brick | 砖 | — | 砖 |
| Water | 水 | — | 水 |
| Seawater | 海水 | — | 海水 |
| Custom | 自定义 | — | 自定义 |
| Heavy / Light (particles) | 重粒子 / 轻粒子 | gas UI | 重 / 轻 (short panel) or 重粒子 / 轻粒子 |
| Ideal / Explore / Energy / Diffusion (tabs) | 理想气体 / 探索 / 能量 / 扩散 | gas-properties | Per sim titles |
| Metric / Atmospheres / English (units) | 公制 / 大气压 / 英制 | under-pressure | 公制 / 大气压 / 英制 |
| On / Off | 开 / 关 | atmosphere | 开 / 关 |
| Ruler / Grid | 直尺 / 网格 | tools | 直尺 / 网格 |
| Contact (force) | 接触力 | buoyancy forces panel | 接触力 |
| Force Values / Mass Values | 力数值 / 质量数值 | — | 力数值 / 质量数值 |
| Depth Lines | 深度线 | — | 深度线 |
| Vector Zoom | 矢量缩放 | — | 矢量缩放 |
| Outside / Inside (membrane) | 外侧 / 内侧 | — | 外侧 / 内侧 |
| Solutes | 溶质 | — | 溶质 |
| Normal / Slow (time) | 正常 / 慢速 | — | 正常 / 慢速 |

## Conflicts resolved this phase

1. **Pressure = 压强** (not 压力) — reaffirm GLOSSARY_CONFLICTS.
2. **Fluid ≠ Liquid** — both keys introduced; UI must not conflate.
3. **Mass ≠ Weight** — no「重量」for mass sliders in this batch.
4. **Wood = 木材** — single material term across density + buoyancy.
5. **Buoyancy title already ZH** (`浮力`); subtitle English → Chinese this phase.
