# Build an Atom — Full-sim Visual Baseline (Phase 5)

Regenerate:

```bash
flutter test --update-goldens test/chemistry/build_an_atom/atom_golden_test.dart
flutter test --update-goldens test/chemistry/build_an_atom/symbol_golden_test.dart
flutter test --update-goldens test/chemistry/build_an_atom/game_golden_test.dart
```

Determinism: DPR=1, design 768×464, Game `randomSeed` fixed, short pumps (no settle on accordion tickers).

## Atom (12)

| File | State |
|---|---|
| `atom_empty.png` | 0p / 0n / 0e |
| `atom_hydrogen.png` | 1p / 0n / 1e |
| `atom_helium.png` | 2p / 2n / 2e |
| `atom_isotope.png` | 1p / 1n / 1e |
| `atom_positive_ion.png` | 1p / 0n / 0e |
| `atom_negative_ion.png` | 1p / 0n / 2e |
| `atom_unstable.png` | unstable nucleus |
| `atom_shell.png` | Shell model |
| `atom_cloud.png` | Cloud model |
| `atom_periodic_table.png` | PT accordion |
| `atom_net_charge.png` | Net Charge expanded |
| `atom_mass_number.png` | Mass Number expanded |

## Symbol (10)

| File | State |
|---|---|
| `symbol_empty.png` | 0p / 0n / 0e |
| `symbol_hydrogen.png` | 1p / 0n / 1e |
| `symbol_isotope.png` | 1p / 1n / 1e |
| `symbol_positive_ion.png` | 1p / 0n / 0e |
| `symbol_negative_ion.png` | 1p / 0n / 2e |
| `symbol_carbon.png` | 6p / 6n / 6e |
| `symbol_accordion_open.png` | He + Symbol open |
| `symbol_accordion_closed.png` | He + Symbol closed |
| `symbol_charge_meter.png` | ChargeMeter charge=3 |
| `symbol_reset.png` | after reset |

## Game (12) — under `golden/game/`

| File | State |
|---|---|
| `game_level_selection.png` | level buttons |
| `game_timer_off.png` | timer disabled |
| `game_timer_on.png` | timer enabled |
| `game_level1.png` … `game_level4.png` | challenge play |
| `game_correct.png` | solved correctly |
| `game_try_again.png` | try again |
| `game_show_answer.png` | showing answer |
| `game_level_complete.png` | level completed |
| `game_reward.png` | reward rain |

**Target: 34 / 34**
