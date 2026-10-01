# Build an Atom — shred Mapping

Locked shred SHA: `427a2abe9f84c6d94bffdb99d1bdb0fd6c843be8`

| PhET 类 / 数据 | 来源 | Flutter 对应 | 是否复用现有实现 |
|---|---|---|---|
| `NumberAtom` | `shred/js/model/NumberAtom.ts` | `lib/chemistry/build_an_atom/model/number_atom.dart` | 新建（轻量不可变）；派生公式对齐 shred |
| `ParticleAtom` | `shred/js/model/ParticleAtom.ts` | `lib/chemistry/build_an_atom/model/particle_atom.dart` | 新建；壳位/回填对齐 shred |
| `Particle` | `shred/js/model/Particle.ts` | `baa_particle.dart` | 新建 |
| `AtomIdentifier.isStable` / `stableElementTable` | `shred/js/AtomIdentifier.ts` | `atom_stability.dart` → `AtomInfoUtils.isStable` | **复用 IAAM** `atom_info_utils.dart` + `kStableNeutronsByZ` |
| `AtomIdentifier` name/symbol tables | same | `NumberAtom.symbol` / `elementNameEnglish` | **复用** `kSymbolTable` / `kEnglishNameTable` |
| `PeriodicTableNode` | `shred/js/view/PeriodicTableNode.ts` | （Phase 2+ View）数据用 `ElementData` | 数据复用 IAAM |
| `SymbolNode` | `shred/js/view/SymbolNode.ts` | Symbol **Model** = `NumberAtom` Z/A/charge | View 后期；Model 不重复造符号几何 |
| `reconfigureNucleus` | `ParticleAtom.ts` | `nucleus_packing.dart` | 算法对齐 IAAM `NucleusReconfigure` / BAN `NucleusLayout`，适配 `BaaParticle` |
| Electron shells | `ParticleAtom` slots | `ParticleAtom.electronShellSlots` | 新建 |
| Electron cloud | `ElectronCloudView.ts`（半径渐变，非随机点） | `ElectronModel` + `cloudRadius()` | 新建（数据/公式）；Painter 后期 |
| `ElectronShellDepiction` | `shells` \| `cloud` | `ElectronModelType` | 新建 |
| `ShredConstants` radii | `NUCLEON_RADIUS=10`, `ELECTRON_RADIUS=8` | `BAAConstants` | 新建常量入口 |
| `AtomViewProperties.electronModel` default | `'shells'` | `ElectronModel` default shells | 对齐 |

## Notes

- Locked shred uses **`AtomIdentifier`**, not the older `AtomInfoUtils` / `AtomNameUtils` names. Semantics match IAAM’s already-ported tables.
- Empty nucleus (`P+N==0`) → `nucleusStable = true` (shred DerivedProperty).
- Cloud depiction grows a radial gradient by electron count; Phase 1 does **not** store random cloud particle positions.
