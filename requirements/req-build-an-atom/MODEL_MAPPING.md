# Build an Atom — Model Mapping (Phase 1)

## Directory

```text
lib/chemistry/build_an_atom/
├── constants/baa_constants.dart
└── model/
    ├── baa_model.dart
    ├── baa_particle.dart
    ├── particle_atom.dart
    ├── particle_bucket.dart
    ├── number_atom.dart
    ├── atom_stability.dart
    ├── electron_model.dart
    ├── nucleus_packing.dart
    └── game/
        ├── game_model.dart
        ├── game_level.dart
        ├── game_state.dart
        ├── game_timer.dart
        ├── challenge_type.dart
        ├── challenge.dart
        ├── challenge_descriptor.dart
        ├── challenge_descriptor_set_factory.dart
        ├── challenge_pool_data.dart   # GENERATED from PhET
        ├── atom_value_pool.dart
        ├── answer_atom.dart
        └── score_model.dart
```

## PhET → Flutter

| PhET | Flutter |
|---|---|
| `BAAModel` | `BAAModel` |
| `ParticleAtom` | `ParticleAtom` |
| `NumberAtom` | `NumberAtom` |
| `SphereBucket` | `ParticleBucket` |
| `BAAParticle` | `BaaParticle` |
| `GameModel` | `GameModel` |
| `GameLevel` | `GameLevel` |
| `GameState` | `GameState` |
| `ChallengeType` (15) | `ChallengeType` |
| `ChallengeDescriptor` | `ChallengeDescriptor` |
| `ChallengeDescriptorSetFactory` | `ChallengeDescriptorSetFactory` |
| `AtomValuePool` / `CHALLENGE_POOLS` | `AtomValuePool` / `kChallengePoolTriples` |
| `AnswerAtom` | `AnswerAtom` |
| `BAAGameChallenge` | `Challenge` |
| vegas `GameTimer` | `GameTimer` |
| vegas `ScoreDisplayStars` math | `StarProgress` |
| `BAAConstants` + capture radii | `BAAConstants` |

## Single sources of truth

| Concern | Source |
|---|---|
| Stability table | IAAM `AtomInfoUtils` / `kStableNeutronsByZ` |
| Element symbol / English name | IAAM `kSymbolTable` / `kEnglishNameTable` |
| Nucleus packing algorithm | `nucleus_packing.dart` (= shred / IAAM algorithm) |
| Challenge pools | Generated from PhET `AtomValuePool.ts` (184 rows) |
| Derived atom math | `NumberAtom` / `ParticleAtom` getters only |

## Out of scope (Phase 1)

No Screen UI, Painters, Home integration, Golden screenshots.
