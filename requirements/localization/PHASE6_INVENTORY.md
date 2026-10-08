# PHASE6_INVENTORY — Chemistry

> Representative inventory. Bags rewritten to ZH; hard-coded UI patched to bags.

| Simulation | File | String | Type | Visible | A11y | Existing Key | Proposed Key | Chinese | Status |
|---|---|---|---|---|---|---|---|---|---|
| molarity | molarity_strings.dart | title | title | Y | | sim.molarity | chemistry.molarity | 摩尔浓度 | LOCALIZED |
| beers-law-lab | bll_strings.dart | concentration | tab | Y | | — | chemistry.concentration | 浓度 | LOCALIZED |
| ph-scale | phs_strings.dart | macro/micro/mySolution | tab | Y | | — | chemistry.macro… | 宏观/微观/我的溶液 | LOCALIZED |
| acid-base-solutions | abs_strings.dart | acid/base/solution | control | Y | | — | chemistry.acid… | 酸/碱/溶液 | LOCALIZED |
| build-a-nucleus | ban_strings.dart | proton/neutron | label | Y | | — | chemistry.proton… | 质子/中子 | LOCALIZED |
| rutherford-scattering | rs_strings.dart | atom/nucleus | label | Y | | — | chemistry.atom… | 原子/原子核 | LOCALIZED |
| build-an-atom | baa_strings.dart | atom/symbol/game | tab | Y | | — | chemistry.atom… | 原子/符号/游戏 | LOCALIZED |
| isotopes-and-atomic-mass | iaam_strings.dart | massNumber/symbol | label | Y | | — | chemistry.massNumber | 质量数/符号 | LOCALIZED |
| build-a-molecule | strings_zh.json | molecule names/UI | dynamic | Y | | — | chemistry.molecule | 水/甲烷… | LOCALIZED |
| molecule-polarity | mp_strings.dart | electronegativity… | control | Y | | — | chemistry.* | 电负性/偶极… | LOCALIZED |
| molecule-shapes | molecule_shapes_strings.dart | geometry | control | Y | | — | chemistry.molecularGeometry | 分子构型 | LOCALIZED |
| molecules-and-light | mal_strings.dart | title | title | Y | | quantum.photon | reuse | 分子与光 | LOCALIZED |
| reactants-products-and-leftovers | rpal_strings.dart | reactants/products | label | Y | | — | chemistry.reactants… | 反应物/生成物 | LOCALIZED |
| balancing-chemical-equations | bce_strings.dart | balanced/check | status | Y | | — | chemistry.balanced… | 已配平/检查 | LOCALIZED |
| states-of-matter | som_strings.dart | solid/liquid/gas | control | Y | | physics.pressure/temp | reuse | 固体/液体/气体 | LOCALIZED |

### Exceptions

Chemical formulas (H₂O, Na⁺, …), pH symbol, units (M, mol/L, atm, K), geometry enum ids (`linear`, `bent`), BAM catalog lookup keys (`'Water'` as structure name).
