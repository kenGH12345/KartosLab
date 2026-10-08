# GLOBAL_ZH_LAYOUT_RATIO_AUDIT

> PHASE 7B update

| Simulation | Component | Reference | Flutter | Delta | Cause | Severity | Action |
|---|---|---|---|---|---|---|---|
| Home cards | title / card | wrap OK | wrap | low | CJK length | P2 | record |
| pH Scale | tabs / bar | parent | parent | low | 我的溶液 | P2 | record |
| BCE | feedback panel | parent | parent | low | 显示原因 | P2 | record |
| QWI / QM | dense panels | parent | parent | low | long ZH | P2 | record |
| Gas Properties / Buoyancy | control panels | LayoutSpec | LayoutSpec | low | intrinsic | P2 | record |
| Concentration | solute combo | panel | panel | low | ZH names | P2 | record |

No page-magic `Positioned` introduced for ZH. No P0/P1 layout blockers identified in captured goldens.
