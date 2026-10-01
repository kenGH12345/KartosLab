# PHASE 4 — Final Gap Matrix

对照 local source 与 Phase 0–3 报告。优先级：P0 阻塞 / P1 行为错误 / P2 外观微调 / VERSION_DELTA 已知可接受差异。

| Feature | Source | Model Screen | Real Molecules | Current Flutter | Gap | Priority | Status |
|---|---|---|---|---|---|---|---|
| Screens | Model + Real | ✅ | ✅ | Both widgets | — | — | PASS |
| Domain = 1 per bond order | `wouldAllowBondOrder` | ✅ | N/A (no edit) | Phase 1 | — | — | PASS |
| Max 6 domains | `maxConnections=6` | ✅ | N/A | Phase 1 | — | — | PASS |
| Geometry name from (x,e) | `MoleculeGeometry` | ✅ | ✅ labels | Phase 1 | — | — | PASS |
| Drag ≠ rename | ScreenView + AXE | ✅ | N/A primary | Phase 2 | — | — | PASS |
| Ideal tetrahedral 109.5° | ElectronGeometry | ✅ | Model half | Phase 1 | — | — | PASS |
| H2O 104.5 / 109.5 | RealMoleculeShape | N/A | ✅ | Phase 3 | — | — | PASS |
| Kabsch + Coulomb step | AttractorModel | ✅ | step on molecule | Phase 2 | — | — | PASS |
| Perspective + depth | three.js | ✅ shared | ✅ shared | Phase 2/3 | — | — | PASS |
| Bonding / Lone Pair / Remove All | Model only | ✅ | absent (correct) | Phase 2 | — | — | PASS |
| Molecule ComboBox + subscripts | Real only | absent | ✅ H₂O… | Phase 3 | — | — | PASS |
| Real / Model radios | Real only | absent | ✅ | Phase 3 | — | — | PASS |
| Show Lone Pairs / Bond Angles | OptionsNode | ✅ | ✅ | Phase 2/3 | — | — | PASS |
| Show Outer Lone Pairs | Preferences | N/A UI | ✅ preference | Phase 3 | Model screen has no prefs UI (source same) | — | PASS |
| Name panel text only | GeometryNamePanel | ✅ | ✅ | Phase 2 | — | — | PASS |
| Reset All | scenery-phet | ✅ Kratos | ✅ Kratos | Phase 2/3 | — | — | PASS |
| Screen state isolation | separate Screen models | ✅ | ✅ | separate instances | — | — | PASS |
| Rotation = quaternion only | moleculeQuaternion | ✅ | ✅ | Phase 2/3 | — | — | PASS |
| Real↔Model orientation match | Attractor remap | N/A | rebuild without match | angles/data correct; view may jump | VERSION_DELTA | P2 | OPEN |
| Lone-pair shell mesh | LonePairGeometryData | approximate stroke | same painter | balloon OBJ not embedded | VERSION_DELTA | P2 | OPEN |
| Bonding thumbnails | WebGL dataURL | 2D CustomPaint | N/A | not three.js capture | VERSION_DELTA | P2 | OPEN |
| Bond A/B half colors | BondView split | single-color strokes | same | visual only | VERSION_DELTA | P2 | OPEN |
| Home entry / lifecycle re-entry | joist Sim | not wired | not wired | intentional | Home phase | — | DEFERRED |
| Substituted assets | 0 | 0 | 0 | CustomPainter + L0 Reset | — | — | PASS |

## Summary

| Bucket | Count |
|---|---|
| P0 open | 0 |
| P1 open | 0 |
| P2 / VERSION_DELTA open | 4 (visual fidelity only) |
| Deferred | Home Integration |

Phase 4 goal: confirm PASS on all behavioral rows; leave P2 VERSION_DELTA documented; do not redesign Model or change VSEPR/real data.
